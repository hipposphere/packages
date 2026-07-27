#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#include <chrono>
#include <cstring>
#include <iostream>
#include <string>
#include <thread>
#include <vector>

namespace {

struct Options {
  std::string current;
  std::string staged;
  pid_t parent_pid = -1;
  std::vector<std::string> arguments;
};

bool ParseOptions(int argc, char** argv, Options* options) {
  int index = 1;
  while (index < argc) {
    const std::string argument = argv[index++];
    if (argument == "--") {
      while (index < argc) {
        options->arguments.emplace_back(argv[index++]);
      }
      break;
    }
    if (index >= argc) {
      return false;
    }
    const std::string value = argv[index++];
    if (argument == "--current") {
      options->current = value;
    } else if (argument == "--staged") {
      options->staged = value;
    } else if (argument == "--parent-pid") {
      try {
        options->parent_pid = static_cast<pid_t>(std::stol(value));
      } catch (...) {
        return false;
      }
    } else {
      return false;
    }
  }
  return !options->current.empty() && !options->staged.empty() &&
         options->parent_pid > 0;
}

void WaitForParent(pid_t parent_pid) {
  while (true) {
    if (kill(parent_pid, 0) == 0 || errno == EPERM) {
      std::this_thread::sleep_for(std::chrono::milliseconds(25));
      continue;
    }
    if (errno == EINTR) {
      continue;
    }
    return;
  }
}

bool Relaunch(const Options& options) {
  int error_pipe[2];
  if (pipe(error_pipe) != 0) {
    return false;
  }
  if (fcntl(error_pipe[1], F_SETFD, FD_CLOEXEC) != 0) {
    close(error_pipe[0]);
    close(error_pipe[1]);
    return false;
  }

  const pid_t child = fork();
  if (child < 0) {
    close(error_pipe[0]);
    close(error_pipe[1]);
    return false;
  }
  if (child == 0) {
    close(error_pipe[0]);
    std::vector<std::string> storage;
    storage.push_back(options.current);
    storage.insert(storage.end(), options.arguments.begin(),
                   options.arguments.end());
    std::vector<char*> arguments;
    for (std::string& value : storage) {
      arguments.push_back(&value[0]);
    }
    arguments.push_back(nullptr);
    execv(options.current.c_str(), arguments.data());
    const int launch_errno = errno;
    write(error_pipe[1], &launch_errno, sizeof(launch_errno));
    _exit(127);
  }

  close(error_pipe[1]);
  int launch_errno = 0;
  const ssize_t bytes_read =
      read(error_pipe[0], &launch_errno, sizeof(launch_errno));
  close(error_pipe[0]);
  if (bytes_read == 0) {
    return true;
  }
  waitpid(child, nullptr, 0);
  return false;
}

}  // namespace

int main(int argc, char** argv) {
  Options options;
  if (!ParseOptions(argc, argv, &options)) {
    std::cerr << "Invalid auto updater helper arguments.\n";
    return 64;
  }

  struct stat current_stat {};
  if (lstat(options.current.c_str(), &current_stat) != 0 ||
      !S_ISREG(current_stat.st_mode) ||
      lstat(options.staged.c_str(), &current_stat) != 0 ||
      !S_ISREG(current_stat.st_mode)) {
    std::cerr << "Update paths must be regular files.\n";
    return 65;
  }

  WaitForParent(options.parent_pid);

  struct stat installed_stat {};
  if (stat(options.current.c_str(), &installed_stat) != 0 ||
      chmod(options.staged.c_str(), installed_stat.st_mode & 07777) != 0) {
    std::cerr << "Unable to preserve AppImage permissions.\n";
    return 66;
  }

  const std::string backup = options.current + ".auto-updater-backup";
  unlink(backup.c_str());
  if (rename(options.current.c_str(), backup.c_str()) != 0) {
    std::cerr << "Unable to create the AppImage backup.\n";
    return 67;
  }
  if (rename(options.staged.c_str(), options.current.c_str()) != 0) {
    rename(backup.c_str(), options.current.c_str());
    std::cerr << "Unable to install the AppImage update.\n";
    return 68;
  }

  if (!Relaunch(options)) {
    unlink(options.current.c_str());
    rename(backup.c_str(), options.current.c_str());
    std::cerr << "Unable to relaunch the updated AppImage; rolled back.\n";
    return 69;
  }

  unlink(backup.c_str());
  return 0;
}
