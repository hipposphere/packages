#ifndef FLUTTER_PLUGIN_AUTO_UPDATER_LINUX_PLUGIN_H_
#define FLUTTER_PLUGIN_AUTO_UPDATER_LINUX_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define AUTO_UPDATER_LINUX_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define AUTO_UPDATER_LINUX_PLUGIN_EXPORT
#endif

typedef struct _AutoUpdaterLinuxPlugin AutoUpdaterLinuxPlugin;
typedef struct {
  GObjectClass parent_class;
} AutoUpdaterLinuxPluginClass;

AUTO_UPDATER_LINUX_PLUGIN_EXPORT GType
auto_updater_linux_plugin_get_type();

AUTO_UPDATER_LINUX_PLUGIN_EXPORT void
auto_updater_linux_plugin_register_with_registrar(
    FlPluginRegistrar* registrar);

G_END_DECLS

#endif  // FLUTTER_PLUGIN_AUTO_UPDATER_LINUX_PLUGIN_H_
