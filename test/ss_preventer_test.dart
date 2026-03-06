import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:ss_preventer/ss_preventer.dart';
import 'package:ss_preventer/ss_preventer_method_channel.dart';
import 'package:ss_preventer/ss_preventer_platform_interface.dart';

class MockSsPreventerPlatform
    with MockPlatformInterfaceMixin
    implements SsPreventerPlatform {
  bool preventOnCalled = false;
  bool preventOffCalled = false;
  bool? detectionEnabled;

  final _controller = Stream<ScreenshotEvent>.empty();

  @override
  Future<void> preventOn() async {
    preventOnCalled = true;
  }

  @override
  Future<void> preventOff() async {
    preventOffCalled = true;
  }

  @override
  Future<void> setDetectionEnabled(bool enabled) async {
    detectionEnabled = enabled;
  }

  @override
  Stream<ScreenshotEvent> get screenshotStream => _controller;
}

void main() {
  final initialPlatform = SsPreventerPlatform.instance;

  test('$MethodChannelSsPreventer is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSsPreventer>());
  });

  test('preventOn calls platform implementation', () async {
    final fakePlatform = MockSsPreventerPlatform();
    SsPreventerPlatform.instance = fakePlatform;

    await SsPreventer.preventOn();

    expect(fakePlatform.preventOnCalled, true);
  });

  test('preventOff calls platform implementation', () async {
    final fakePlatform = MockSsPreventerPlatform();
    SsPreventerPlatform.instance = fakePlatform;

    await SsPreventer.preventOff();

    expect(fakePlatform.preventOffCalled, true);
  });

  test('setDetectionEnabled calls platform implementation', () async {
    final fakePlatform = MockSsPreventerPlatform();
    SsPreventerPlatform.instance = fakePlatform;

    await SsPreventer.setDetectionEnabled(true);

    expect(fakePlatform.detectionEnabled, true);
  });
}
