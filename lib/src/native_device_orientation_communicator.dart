import 'package:native_device_orientation/src/native_device_orientation.dart';
import 'package:native_device_orientation/src/native_device_orientation_platform_interface.dart';

class NativeDeviceOrientationCommunicator {
  Future<NativeDeviceOrientation> orientation({
    bool useSensor = false,
    NativeDeviceOrientation defaultOrientation = NativeDeviceOrientation.portraitUp,
  }) =>
      NativeDeviceOrientationPlatform.instance.orientation(
        useSensor: useSensor,
        defaultOrientation: defaultOrientation,
      );

  Future<void> pause() => NativeDeviceOrientationPlatform.instance.pause();

  Future<void> resume() => NativeDeviceOrientationPlatform.instance.resume();

  Stream<NativeDeviceOrientation> onOrientationChanged({
    bool useSensor = false,
    NativeDeviceOrientation defaultOrientation = NativeDeviceOrientation.portraitUp,
  }) =>
      NativeDeviceOrientationPlatform.instance.onOrientationChanged(
        useSensor: useSensor,
        defaultOrientation: defaultOrientation,
      );
}
