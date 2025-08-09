import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'user_activity_plugin_method_channel.dart';

abstract class UserActivityPluginPlatform extends PlatformInterface {
  /// Constructs a UserActivityPluginPlatform.
  UserActivityPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static UserActivityPluginPlatform _instance = MethodChannelUserActivityPlugin();

  /// The default instance of [UserActivityPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelUserActivityPlugin].
  static UserActivityPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UserActivityPluginPlatform] when
  /// they register themselves.
  static set instance(UserActivityPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
