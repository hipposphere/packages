//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <auto_updater_linux/auto_updater_linux_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) auto_updater_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "AutoUpdaterLinuxPlugin");
  auto_updater_linux_plugin_register_with_registrar(auto_updater_linux_registrar);
}
