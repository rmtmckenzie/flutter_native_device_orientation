import 'package:flutter/services.dart';

enum NativeDeviceOrientation {
  portraitUp(DeviceOrientation.portraitUp),
  portraitDown(DeviceOrientation.portraitDown),
  landscapeLeft(DeviceOrientation.landscapeLeft),
  landscapeRight(DeviceOrientation.landscapeRight),
  unknown(null);

  const NativeDeviceOrientation(this.deviceOrientation);

  /// corresponding [DeviceOrientation] for this [NativeDeviceOrientation]
  final DeviceOrientation? deviceOrientation;
}
