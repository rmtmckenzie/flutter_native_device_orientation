import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_device_orientation/src/native_device_orientation_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelNativeDeviceOrientation platform = MethodChannelNativeDeviceOrientation();
  const MethodChannel channel = MethodChannel('native_device_orientation');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('todo', () async {
    await platform.pause();
  });
}
