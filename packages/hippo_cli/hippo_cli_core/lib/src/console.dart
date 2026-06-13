import 'dart:io';

import 'exception.dart';
import 'spinner.dart';
import 'table.dart';
import 'theme.dart';

final class HippoConsole {
  HippoConsole({
    StringSink? stdoutSink,
    StringSink? stderrSink,
    bool? stdoutIsTerminal,
    bool? stderrIsTerminal,
    this.colorMode = HippoColorMode.auto,
    this.ci = false,
    this.quiet = false,
    this.verbose = false,
  }) : stdoutSink = stdoutSink ?? stdout,
       stderrSink = stderrSink ?? stderr,
       stdoutIsTerminal = stdoutIsTerminal ?? stdout.hasTerminal,
       stderrIsTerminal = stderrIsTerminal ?? stderr.hasTerminal;

  final StringSink stdoutSink;
  final StringSink stderrSink;
  final bool stdoutIsTerminal;
  final bool stderrIsTerminal;
  final HippoColorMode colorMode;
  final bool ci;
  final bool quiet;
  final bool verbose;

  HippoTheme get theme => HippoTheme(enabled: colorEnabled(stdoutIsTerminal));
  HippoTheme get errorTheme => HippoTheme(enabled: colorEnabled(stderrIsTerminal));
  bool get decorative => !ci && stdoutIsTerminal && !quiet;

  bool colorEnabled(bool isTerminal) {
    return switch (colorMode) {
      HippoColorMode.always => true,
      HippoColorMode.never => false,
      HippoColorMode.auto => isTerminal && !ci,
    };
  }

  void write(String text) {
    if (!quiet) {
      stdoutSink.write(text);
    }
  }

  void writeln([String text = '']) {
    if (!quiet) {
      stdoutSink.writeln(text);
    }
  }

  void trace(String text) {
    if (verbose && !quiet) {
      stdoutSink.writeln(theme.gray(text));
    }
  }

  void stderrLine(String text) {
    stderrSink.writeln(text);
  }

  void clearLine() {
    if (stdoutIsTerminal) {
      stdoutSink.write('\x1B[2K');
    }
  }

  void status(HippoStatus status, String subject, [String detail = '']) {
    if (quiet) {
      return;
    }
    final label = theme.statusLabel(status).padRight(status == HippoStatus.warn ? 4 : 5);
    stdoutSink.writeln(detail.isEmpty ? '$label $subject' : '$label $subject  $detail');
  }

  void ok(String subject, [String detail = '']) => status(HippoStatus.ok, subject, detail);
  void warn(String subject, [String detail = '']) => status(HippoStatus.warn, subject, detail);
  void fail(String subject, [String detail = '']) => status(HippoStatus.fail, subject, detail);
  void skip(String subject, [String detail = '']) => status(HippoStatus.skip, subject, detail);
  void run(String subject, [String detail = '']) => status(HippoStatus.run, subject, detail);
  void info(String subject, [String detail = '']) => status(HippoStatus.info, subject, detail);

  void table(HippoTable table) {
    final rendered = table.render();
    if (rendered.isNotEmpty) {
      writeln(rendered.trimRight());
    }
  }

  HippoSpinner spinner(String label) {
    return HippoSpinner(console: this, label: label, enabled: decorative);
  }

  void renderException(HippoException exception) {
    stderrSink.writeln(errorTheme.red(exception.message));
    if (exception.expected case final expected?) {
      stderrSink.writeln('');
      stderrSink.writeln(expected);
    }
    if (exception.nextSteps.isNotEmpty) {
      stderrSink.writeln('');
      stderrSink.writeln('Next steps:');
      for (final step in exception.nextSteps) {
        stderrSink.writeln('  $step');
      }
    }
  }
}
