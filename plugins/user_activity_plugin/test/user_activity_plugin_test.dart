import 'package:flutter_test/flutter_test.dart';
import 'package:user_activity_plugin/user_activity_plugin.dart';
import 'package:user_activity_plugin/user_activity_plugin_platform_interface.dart';
import 'package:user_activity_plugin/user_activity_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockUserActivityPluginPlatform
    with MockPlatformInterfaceMixin
    implements UserActivityPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final UserActivityPluginPlatform initialPlatform = UserActivityPluginPlatform.instance;

  test('$MethodChannelUserActivityPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelUserActivityPlugin>());
  });

  test('getPlatformVersion', () async {
    MockUserActivityPluginPlatform fakePlatform = MockUserActivityPluginPlatform();
    UserActivityPluginPlatform.instance = fakePlatform;

    expect(await UserActivityPlugin.isUserIdle(), true);
  });
}
