#include "include/auto_updater_linux/auto_updater_linux_plugin.h"

#include <dlfcn.h>
#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#include <cstring>

#define AUTO_UPDATER_LINUX_PLUGIN(obj)                                  \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), auto_updater_linux_plugin_get_type(), \
                              AutoUpdaterLinuxPlugin))

namespace {

constexpr char kChannelName[] = "dev.hippolabs.auto_updater_linux/ui";
int kLibraryMarker = 0;

const gchar* StringArgument(FlValue* arguments, const gchar* key) {
  if (arguments == nullptr ||
      fl_value_get_type(arguments) != FL_VALUE_TYPE_MAP) {
    return nullptr;
  }
  FlValue* value = fl_value_lookup_string(arguments, key);
  if (value == nullptr || fl_value_get_type(value) != FL_VALUE_TYPE_STRING) {
    return nullptr;
  }
  return fl_value_get_string(value);
}

GtkWindow* ParentWindow(AutoUpdaterLinuxPlugin* self);

}  // namespace

struct _AutoUpdaterLinuxPlugin {
  GObject parent_instance;

  FlPluginRegistrar* registrar;
  FlMethodChannel* channel;
  GtkWidget* checking_dialog;
  GtkWidget* progress_dialog;
  GtkWidget* progress_bar;
};

G_DEFINE_TYPE(AutoUpdaterLinuxPlugin, auto_updater_linux_plugin,
              g_object_get_type())

namespace {

GtkWindow* ParentWindow(AutoUpdaterLinuxPlugin* self) {
  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  if (view == nullptr) {
    return nullptr;
  }
  GtkWidget* toplevel = gtk_widget_get_toplevel(GTK_WIDGET(view));
  return GTK_IS_WINDOW(toplevel) ? GTK_WINDOW(toplevel) : nullptr;
}

void RespondSuccess(FlMethodCall* call, FlValue* result = nullptr) {
  g_autoptr(FlMethodResponse) response =
      FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  fl_method_call_respond(call, response, nullptr);
}

void ShowMessage(AutoUpdaterLinuxPlugin* self, GtkMessageType type,
                 const gchar* title, const gchar* message,
                 const gchar* details) {
  GtkWidget* dialog = gtk_message_dialog_new(
      ParentWindow(self), GTK_DIALOG_MODAL, type, GTK_BUTTONS_OK, "%s",
      message == nullptr ? "" : message);
  gtk_window_set_title(GTK_WINDOW(dialog), title == nullptr ? "" : title);
  if (details != nullptr && strlen(details) > 0) {
    gtk_message_dialog_format_secondary_text(GTK_MESSAGE_DIALOG(dialog), "%s",
                                             details);
  }
  gtk_dialog_run(GTK_DIALOG(dialog));
  gtk_widget_destroy(dialog);
}

bool ShowUpdateDialog(AutoUpdaterLinuxPlugin* self, FlValue* arguments) {
  const gchar* app_name = StringArgument(arguments, "appName");
  const gchar* current_version = StringArgument(arguments, "currentVersion");
  const gchar* new_version = StringArgument(arguments, "newVersion");
  const gchar* release_notes_url =
      StringArgument(arguments, "releaseNotesURL");
  const gchar* description = StringArgument(arguments, "description");

  g_autofree gchar* primary =
      g_strdup_printf("A new version of %s is available.",
                      app_name == nullptr ? "the application" : app_name);
  g_autofree gchar* secondary = g_strdup_printf(
      "Version %s is available. You currently have version %s.",
      new_version == nullptr ? "" : new_version,
      current_version == nullptr ? "" : current_version);

  GtkWidget* dialog = gtk_message_dialog_new(
      ParentWindow(self), GTK_DIALOG_MODAL, GTK_MESSAGE_INFO, GTK_BUTTONS_NONE,
      "%s", primary);
  gtk_window_set_title(GTK_WINDOW(dialog), "Software Update");
  gtk_message_dialog_format_secondary_text(GTK_MESSAGE_DIALOG(dialog), "%s",
                                           secondary);
  gtk_dialog_add_button(GTK_DIALOG(dialog), "Later", GTK_RESPONSE_CANCEL);
  gtk_dialog_add_button(GTK_DIALOG(dialog), "Update and Restart",
                        GTK_RESPONSE_ACCEPT);
  gtk_dialog_set_default_response(GTK_DIALOG(dialog), GTK_RESPONSE_ACCEPT);

  GtkWidget* content = gtk_message_dialog_get_message_area(
      GTK_MESSAGE_DIALOG(dialog));
  if (description != nullptr && strlen(description) > 0) {
    GtkWidget* label = gtk_label_new(description);
    gtk_label_set_line_wrap(GTK_LABEL(label), TRUE);
    gtk_label_set_xalign(GTK_LABEL(label), 0.0);
    gtk_box_pack_start(GTK_BOX(content), label, FALSE, FALSE, 6);
  }
  if (release_notes_url != nullptr && strlen(release_notes_url) > 0) {
    g_autofree gchar* escaped_url = g_markup_escape_text(release_notes_url, -1);
    g_autofree gchar* markup =
        g_strdup_printf("<a href=\"%s\">View release notes</a>", escaped_url);
    GtkWidget* link = gtk_label_new(nullptr);
    gtk_label_set_markup(GTK_LABEL(link), markup);
    gtk_label_set_xalign(GTK_LABEL(link), 0.0);
    gtk_box_pack_start(GTK_BOX(content), link, FALSE, FALSE, 6);
  }

  gtk_widget_show_all(dialog);
  const gint response = gtk_dialog_run(GTK_DIALOG(dialog));
  gtk_widget_destroy(dialog);
  return response == GTK_RESPONSE_ACCEPT;
}

void OnProgressResponse(GtkDialog* dialog, gint response_id,
                        gpointer user_data) {
  AutoUpdaterLinuxPlugin* self = AUTO_UPDATER_LINUX_PLUGIN(user_data);
  if (response_id == GTK_RESPONSE_CANCEL ||
      response_id == GTK_RESPONSE_DELETE_EVENT) {
    fl_method_channel_invoke_method(self->channel, "cancelDownload", nullptr,
                                    nullptr, nullptr, nullptr);
    self->progress_dialog = nullptr;
    self->progress_bar = nullptr;
    gtk_widget_destroy(GTK_WIDGET(dialog));
  }
}

void ShowProgress(AutoUpdaterLinuxPlugin* self, FlValue* arguments) {
  if (self->progress_dialog != nullptr) {
    gtk_widget_destroy(self->progress_dialog);
  }
  const gchar* title = StringArgument(arguments, "title");
  const gchar* message = StringArgument(arguments, "message");
  GtkWidget* dialog = gtk_dialog_new_with_buttons(
      title == nullptr ? "Software Update" : title, ParentWindow(self),
      GTK_DIALOG_MODAL, "Cancel", GTK_RESPONSE_CANCEL, nullptr);
  GtkWidget* area = gtk_dialog_get_content_area(GTK_DIALOG(dialog));
  GtkWidget* label = gtk_label_new(message == nullptr ? "" : message);
  gtk_label_set_xalign(GTK_LABEL(label), 0.0);
  GtkWidget* progress = gtk_progress_bar_new();
  gtk_widget_set_size_request(progress, 420, -1);
  gtk_box_pack_start(GTK_BOX(area), label, FALSE, FALSE, 12);
  gtk_box_pack_start(GTK_BOX(area), progress, FALSE, FALSE, 12);
  g_signal_connect(dialog, "response", G_CALLBACK(OnProgressResponse), self);
  self->progress_dialog = dialog;
  self->progress_bar = progress;
  gtk_widget_show_all(dialog);
}

void ShowCheckingProgress(AutoUpdaterLinuxPlugin* self, FlValue* arguments) {
  if (self->checking_dialog != nullptr) {
    gtk_widget_destroy(self->checking_dialog);
  }
  const gchar* title = StringArgument(arguments, "title");
  const gchar* message = StringArgument(arguments, "message");
  GtkWidget* dialog = gtk_dialog_new_with_buttons(
      title == nullptr ? "Software Update" : title, ParentWindow(self),
      GTK_DIALOG_MODAL, nullptr);
  gtk_window_set_deletable(GTK_WINDOW(dialog), FALSE);
  GtkWidget* area = gtk_dialog_get_content_area(GTK_DIALOG(dialog));
  GtkWidget* row = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 12);
  GtkWidget* spinner = gtk_spinner_new();
  GtkWidget* label = gtk_label_new(
      message == nullptr ? "Checking for updates…" : message);
  gtk_spinner_start(GTK_SPINNER(spinner));
  gtk_box_pack_start(GTK_BOX(row), spinner, FALSE, FALSE, 0);
  gtk_box_pack_start(GTK_BOX(row), label, FALSE, FALSE, 0);
  gtk_box_pack_start(GTK_BOX(area), row, FALSE, FALSE, 16);
  self->checking_dialog = dialog;
  gtk_widget_show_all(dialog);
  gtk_window_present(GTK_WINDOW(dialog));
}

void CloseCheckingProgress(AutoUpdaterLinuxPlugin* self) {
  if (self->checking_dialog != nullptr) {
    gtk_widget_destroy(self->checking_dialog);
    self->checking_dialog = nullptr;
  }
}

void CloseProgress(AutoUpdaterLinuxPlugin* self) {
  if (self->progress_dialog != nullptr) {
    gtk_widget_destroy(self->progress_dialog);
    self->progress_dialog = nullptr;
    self->progress_bar = nullptr;
  }
}

gchar* HelperPath() {
  Dl_info info;
  if (dladdr(&kLibraryMarker, &info) == 0 ||
      info.dli_fname == nullptr) {
    return nullptr;
  }
  g_autofree gchar* directory = g_path_get_dirname(info.dli_fname);
  return g_build_filename(directory, "auto_updater_linux_helper", nullptr);
}

void HandleMethodCall(AutoUpdaterLinuxPlugin* self, FlMethodCall* call) {
  const gchar* method = fl_method_call_get_name(call);
  FlValue* arguments = fl_method_call_get_args(call);

  if (strcmp(method, "showUpdateDialog") == 0) {
    g_autoptr(FlValue) result =
        fl_value_new_bool(ShowUpdateDialog(self, arguments));
    RespondSuccess(call, result);
  } else if (strcmp(method, "showInformation") == 0) {
    ShowMessage(self, GTK_MESSAGE_INFO, StringArgument(arguments, "title"),
                StringArgument(arguments, "message"),
                StringArgument(arguments, "details"));
    RespondSuccess(call);
  } else if (strcmp(method, "showError") == 0) {
    ShowMessage(self, GTK_MESSAGE_ERROR, StringArgument(arguments, "title"),
                StringArgument(arguments, "message"), nullptr);
    RespondSuccess(call);
  } else if (strcmp(method, "showCheckingProgress") == 0) {
    ShowCheckingProgress(self, arguments);
    RespondSuccess(call);
  } else if (strcmp(method, "closeCheckingProgress") == 0) {
    CloseCheckingProgress(self);
    RespondSuccess(call);
  } else if (strcmp(method, "showDownloadProgress") == 0) {
    ShowProgress(self, arguments);
    RespondSuccess(call);
  } else if (strcmp(method, "updateDownloadProgress") == 0) {
    FlValue* value = arguments == nullptr
                         ? nullptr
                         : fl_value_lookup_string(arguments, "progress");
    if (self->progress_bar != nullptr && value != nullptr &&
        fl_value_get_type(value) == FL_VALUE_TYPE_FLOAT) {
      gtk_progress_bar_set_fraction(GTK_PROGRESS_BAR(self->progress_bar),
                                    fl_value_get_float(value));
    }
    RespondSuccess(call);
  } else if (strcmp(method, "closeDownloadProgress") == 0) {
    CloseProgress(self);
    RespondSuccess(call);
  } else if (strcmp(method, "getHelperPath") == 0) {
    g_autofree gchar* helper_path = HelperPath();
    g_autoptr(FlValue) result =
        helper_path == nullptr ? nullptr : fl_value_new_string(helper_path);
    RespondSuccess(call, result);
  } else if (strcmp(method, "quitApplication") == 0) {
    RespondSuccess(call);
    GApplication* application = g_application_get_default();
    if (application != nullptr) {
      g_application_quit(application);
    }
  } else {
    g_autoptr(FlMethodResponse) response =
        FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
    fl_method_call_respond(call, response, nullptr);
  }
}

void MethodCallCallback(FlMethodChannel* channel, FlMethodCall* call,
                        gpointer user_data) {
  HandleMethodCall(AUTO_UPDATER_LINUX_PLUGIN(user_data), call);
}

}  // namespace

static void auto_updater_linux_plugin_dispose(GObject* object) {
  AutoUpdaterLinuxPlugin* self = AUTO_UPDATER_LINUX_PLUGIN(object);
  CloseCheckingProgress(self);
  CloseProgress(self);
  g_clear_object(&self->channel);
  g_clear_object(&self->registrar);
  G_OBJECT_CLASS(auto_updater_linux_plugin_parent_class)->dispose(object);
}

static void auto_updater_linux_plugin_class_init(
    AutoUpdaterLinuxPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = auto_updater_linux_plugin_dispose;
}

static void auto_updater_linux_plugin_init(AutoUpdaterLinuxPlugin* self) {}

void auto_updater_linux_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  AutoUpdaterLinuxPlugin* plugin = AUTO_UPDATER_LINUX_PLUGIN(
      g_object_new(auto_updater_linux_plugin_get_type(), nullptr));
  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  plugin->channel = fl_method_channel_new(
      fl_plugin_registrar_get_messenger(registrar), kChannelName,
      FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      plugin->channel, MethodCallCallback, g_object_ref(plugin),
      g_object_unref);

  g_object_unref(plugin);
}
