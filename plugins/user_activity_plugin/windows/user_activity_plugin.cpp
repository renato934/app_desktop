#include "user_activity_plugin.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <windows.h>

namespace user_activity_plugin {

// Define o valor padrão estático (10 segundos)
int64_t UserActivityPlugin::idleThresholdMillis = 10000;

void UserActivityPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      registrar->messenger(), "user_activity_plugin",
      &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<UserActivityPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

UserActivityPlugin::UserActivityPlugin() {}

UserActivityPlugin::~UserActivityPlugin() {}

bool UserActivityPlugin::IsUserIdle(int64_t thresholdMillis) {
  LASTINPUTINFO lastInputInfo;
  lastInputInfo.cbSize = sizeof(LASTINPUTINFO);
  if (!GetLastInputInfo(&lastInputInfo)) {
    return false; // erro ao obter info
  }

  DWORD currentTickCount = GetTickCount();

  DWORD elapsedMillis = currentTickCount - lastInputInfo.dwTime;

  return elapsedMillis >= static_cast<DWORD>(thresholdMillis);
}

void UserActivityPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("isUserIdle") == 0) {
    // Se receber thresholdMillis por argumento, atualiza o valor estático
    const auto* args_map = std::get_if<flutter::EncodableMap>(method_call.arguments());
    if (args_map) {
      auto it = args_map->find(flutter::EncodableValue("thresholdMillis"));
      if (it != args_map->end()) {
        if (std::holds_alternative<int64_t>(it->second)) {
          idleThresholdMillis = std::get<int64_t>(it->second);
        }
      }
    }

    bool is_idle = IsUserIdle(idleThresholdMillis);

    result->Success(flutter::EncodableValue(is_idle));
  } else {
    result->NotImplemented();
  }
}

}  // namespace user_activity_plugin
