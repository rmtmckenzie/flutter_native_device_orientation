import 'package:native_device_orientation/native_device_orientation.dart';
import 'package:native_device_orientation/src/native_device_orientation.dart';
import 'package:native_device_orientation/src/native_device_orientation_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class NativeDeviceOrientationPlatform extends PlatformInterface {
  /// Constructs a NativeDeviceOrientationPlatform.
  NativeDeviceOrientationPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeDeviceOrientationPlatform _instance = MethodChannelNativeDeviceOrientation();

  /// The default instance of [NativeDeviceOrientationPlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeDeviceOrientation].
  static NativeDeviceOrientationPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeDeviceOrientationPlatform] when
  /// they register themselves.
  static set instance(NativeDeviceOrientationPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<NativeDeviceOrientation> orientation({
    bool useSensor = false,
    NativeDeviceOrientation defaultOrientation = NativeDeviceOrientation.portraitUp,
  });

  Future<void> pause();

  Future<void> resume();

  Stream<NativeDeviceOrientation> onOrientationChanged({
    bool useSensor = false,
    NativeDeviceOrientation defaultOrientation = NativeDeviceOrientation.portraitUp,
  });
}
