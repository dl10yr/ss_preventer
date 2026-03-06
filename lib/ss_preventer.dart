import 'package:ss_preventer/src/screenshot_event.dart';

import 'ss_preventer_platform_interface.dart';

export 'src/screenshot_event.dart';

class SsPreventer {
  const SsPreventer._();

  /// Enable screenshot prevention.
  static Future<void> preventOn() {
    return SsPreventerPlatform.instance.preventOn();
  }

  /// Disable screenshot prevention.
  static Future<void> preventOff() {
    return SsPreventerPlatform.instance.preventOff();
  }

  /// Enable or disable screenshot detection callback stream.
  static Future<void> setDetectionEnabled(bool enabled) {
    return SsPreventerPlatform.instance.setDetectionEnabled(enabled);
  }

  /// Emits an event when a screenshot is detected.
  static Stream<ScreenshotEvent> get screenshotStream {
    return SsPreventerPlatform.instance.screenshotStream;
  }
}
