#include "include/user_activity_plugin/user_activity_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "user_activity_plugin.h"

void UserActivityPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  user_activity_plugin::UserActivityPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
