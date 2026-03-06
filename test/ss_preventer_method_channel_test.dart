import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ss_preventer/ss_preventer_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelSsPreventer();
  const channel = MethodChannel('com.dl10yr.ss_preventer');

  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          calls.add(methodCall);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('preventOn', () async {
    await platform.preventOn();
    expect(calls.single.method, 'preventOn');
  });

  test('preventOff', () async {
    await platform.preventOff();
    expect(calls.single.method, 'preventOff');
  });

  test('setDetectionEnabled', () async {
    await platform.setDetectionEnabled(true);
    expect(calls.single.method, 'setDetectionEnabled');
    expect(calls.single.arguments, true);
  });
}
