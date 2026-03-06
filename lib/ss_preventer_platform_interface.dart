import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ss_preventer_method_channel.dart';

abstract class SsPreventerPlatform extends PlatformInterface {
  /// Constructs a SsPreventerPlatform.
  SsPreventerPlatform() : super(token: _token);

  static final Object _token = Object();

  static SsPreventerPlatform _instance = MethodChannelSsPreventer();

  /// The default instance of [SsPreventerPlatform] to use.
  ///
  /// Defaults to [MethodChannelSsPreventer].
  static SsPreventerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SsPreventerPlatform] when
  /// they register themselves.
  static set instance(SsPreventerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
