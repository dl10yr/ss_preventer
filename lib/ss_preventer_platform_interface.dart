import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:ss_preventer/src/screenshot_event.dart';

import 'ss_preventer_method_channel.dart';

abstract class SsPreventerPlatform extends PlatformInterface {
  SsPreventerPlatform() : super(token: _token);

  static final Object _token = Object();

  static SsPreventerPlatform _instance = MethodChannelSsPreventer();

  static SsPreventerPlatform get instance => _instance;

  static set instance(SsPreventerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> preventOn() {
    throw UnimplementedError('preventOn() has not been implemented.');
  }

  Future<void> preventOff() {
    throw UnimplementedError('preventOff() has not been implemented.');
  }

  Future<void> setDetectionEnabled(bool enabled) {
    throw UnimplementedError('setDetectionEnabled() has not been implemented.');
  }

  Stream<ScreenshotEvent> get screenshotStream {
    throw UnimplementedError('screenshotStream has not been implemented.');
  }
}
