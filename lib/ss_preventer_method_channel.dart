import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:ss_preventer/src/screenshot_event.dart';

import 'ss_preventer_platform_interface.dart';

class MethodChannelSsPreventer extends SsPreventerPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('com.dl10yr.ss_preventer');

  @visibleForTesting
  final eventChannel = const EventChannel('com.dl10yr.ss_preventer/events');

  Stream<ScreenshotEvent>? _screenshotStream;

  @override
  Future<void> preventOn() {
    return methodChannel.invokeMethod<void>('preventOn');
  }

  @override
  Future<void> preventOff() {
    return methodChannel.invokeMethod<void>('preventOff');
  }

  @override
  Future<void> setDetectionEnabled(bool enabled) {
    return methodChannel.invokeMethod<void>('setDetectionEnabled', enabled);
  }

  @override
  Stream<ScreenshotEvent> get screenshotStream {
    return _screenshotStream ??= eventChannel
        .receiveBroadcastStream()
        .map(_toScreenshotEvent)
        .where((event) => event != null)
        .cast<ScreenshotEvent>();
  }

  ScreenshotEvent? _toScreenshotEvent(dynamic event) {
    if (event is String && event == 'screenshot') {
      return ScreenshotEvent(detectedAt: DateTime.now());
    }

    if (event is! Map) {
      return null;
    }

    final dynamic type = event['type'];
    if (type != 'screenshot') {
      return null;
    }

    final dynamic rawDetectedAt = event['detectedAt'];
    if (rawDetectedAt is int) {
      return ScreenshotEvent(
        detectedAt: DateTime.fromMillisecondsSinceEpoch(rawDetectedAt),
      );
    }

    if (rawDetectedAt is String) {
      final parsed = DateTime.tryParse(rawDetectedAt);
      if (parsed != null) {
        return ScreenshotEvent(detectedAt: parsed);
      }
    }

    return ScreenshotEvent(detectedAt: DateTime.now());
  }
}
