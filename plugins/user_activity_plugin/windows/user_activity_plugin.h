#ifndef USER_ACTIVITY_PLUGIN_H_
#define USER_ACTIVITY_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <memory>

namespace user_activity_plugin {

class UserActivityPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  UserActivityPlugin();

  virtual ~UserActivityPlugin();

 private:
  static int64_t idleThresholdMillis;  // variável estática para guardar o threshold

  bool IsUserIdle(int64_t thresholdMillis);

  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace user_activity_plugin

#endif  // USER_ACTIVITY_PLUGIN_H_
