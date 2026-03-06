import 'package:flutter_test/flutter_test.dart';
import 'package:ss_preventer/ss_preventer.dart';
import 'package:ss_preventer/ss_preventer_platform_interface.dart';
import 'package:ss_preventer/ss_preventer_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSsPreventerPlatform
    with MockPlatformInterfaceMixin
    implements SsPreventerPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SsPreventerPlatform initialPlatform = SsPreventerPlatform.instance;

  test('$MethodChannelSsPreventer is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSsPreventer>());
  });

  test('getPlatformVersion', () async {
    SsPreventer ssPreventerPlugin = SsPreventer();
    MockSsPreventerPlatform fakePlatform = MockSsPreventerPlatform();
    SsPreventerPlatform.instance = fakePlatform;

    expect(await ssPreventerPlugin.getPlatformVersion(), '42');
  });
}
