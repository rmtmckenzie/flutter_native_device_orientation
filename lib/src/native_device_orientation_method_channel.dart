import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:native_device_orientation/src/native_device_orientation.dart';
import 'package:native_device_orientation/src/native_device_orientation_platform_interface.dart';

NativeDeviceOrientation _fromString(String orientationString) {
  switch (orientationString) {
    case 'PortraitUp':
      return NativeDeviceOrientation.portraitUp;
    case 'PortraitDown':
      return NativeDeviceOrientation.portraitDown;
    case 'LandscapeRight':
      return NativeDeviceOrientation.landscapeRight;
    case 'LandscapeLeft':
      return NativeDeviceOrientation.landscapeLeft;
    case 'Unknown':
    default:
      return NativeDeviceOrientation.unknown;
  }
}

class _OrientationStream {
  final Stream<NativeDeviceOrientation> stream;
  final bool useSensor;

  _OrientationStream({required this.stream, required this.useSensor});
}

/// An implementation of [NativeDeviceOrientationPlatform] that uses method channels.
class MethodChannelNativeDeviceOrientation extends NativeDeviceOrientationPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('native_device_orientation');
  @visibleForTesting
  final eventChannel = const EventChannel('native_device_orientation_events');

  _OrientationStream? _stream;

  @override
  Future<NativeDeviceOrientation> orientation({
    bool useSensor = false,
    NativeDeviceOrientation defaultOrientation = NativeDeviceOrientation.portraitUp,
  }) async {
    final params = <String, dynamic>{
      'useSensor': useSensor,
    };
    final orientationString = await methodChannel.invokeMethod('getOrientation', params);
    final orientation = _fromString(orientationString);
    return (orientation == NativeDeviceOrientation.unknown) ? defaultOrientation : orientation;
  }

  @override
  Future<void> pause() async {
    await methodChannel.invokeMethod('pause');
  }

  @override
  Future<void> resume() async {
    await methodChannel.invokeMethod('resume');
  }

  @override
  Stream<NativeDeviceOrientation> onOrientationChanged({
    bool useSensor = false,
    NativeDeviceOrientation defaultOrientation = NativeDeviceOrientation.portraitUp,
  }) {
    if (_stream == null || _stream!.useSensor != useSensor) {
      final params = <String, dynamic>{
        'useSensor': useSensor,
      };
      _stream = _OrientationStream(
        stream: eventChannel.receiveBroadcastStream(params).map((dynamic event) {
          return _fromString(event);
        }),
        useSensor: useSensor,
      );
    }
    return _stream!.stream
        .map((orientation) => (orientation == NativeDeviceOrientation.unknown) ? defaultOrientation : orientation);
  }
}
