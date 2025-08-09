import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'user_activity_plugin_platform_interface.dart';

/// An implementation of [UserActivityPluginPlatform] that uses method channels.
class MethodChannelUserActivityPlugin extends UserActivityPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('user_activity_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
