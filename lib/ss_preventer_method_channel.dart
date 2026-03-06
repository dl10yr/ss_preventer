import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ss_preventer_platform_interface.dart';

/// An implementation of [SsPreventerPlatform] that uses method channels.
class MethodChannelSsPreventer extends SsPreventerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ss_preventer');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
