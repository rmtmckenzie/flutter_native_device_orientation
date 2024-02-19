import 'dart:async';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:native_device_orientation/src/native_device_orientation.dart';
import 'package:native_device_orientation/src/native_device_orientation_platform_interface.dart';
import 'dart:html' as html;

NativeDeviceOrientation _fromString(String? orientationString) {
  if (orientationString == null) {
    return NativeDeviceOrientation.unknown;
  }

  switch (orientationString) {
    case 'portrait-primary':
      return NativeDeviceOrientation.portraitUp;
    case 'portrait-secondary':
      return NativeDeviceOrientation.portraitDown;
    case 'landscape-primary':
      return NativeDeviceOrientation.landscapeLeft;
    case 'landscape-secondary':
      return NativeDeviceOrientation.landscapeRight;
    default:
      return NativeDeviceOrientation.unknown;
  }
}

class NativeDeviceOrientationWeb extends NativeDeviceOrientationPlatform {
  bool _isPaused = false;

  bool get _isSupported => html.window.screen?.orientation != null;

  static void registerWith(Registrar registrar) {
    NativeDeviceOrientationPlatform.instance = NativeDeviceOrientationWeb();
  }

  @override
  Stream<NativeDeviceOrientation> onOrientationChanged({
    bool useSensor = false,
    NativeDeviceOrientation defaultOrientation =
        NativeDeviceOrientation.portraitUp,
  }) {
    if (!_isSupported) {
      return Stream<NativeDeviceOrientation>.fromIterable([defaultOrientation]);
    }

    _isPaused = false;
    return html.window.screen!.orientation!.onChange
        .skipWhile((_) => _isPaused)
        .map((event) {
      final orientation = html.window.screen!.orientation!.type;
      return _fromString(orientation);
    });
  }

  @override
  Future<NativeDeviceOrientation> orientation({
    bool useSensor = false,
    NativeDeviceOrientation defaultOrientation =
        NativeDeviceOrientation.portraitUp,
  }) async {
    if (!_isSupported) {
      return defaultOrientation;
    }

    final orientation = html.window.screen!.orientation!.type;
    return _fromString(orientation);
  }

  @override
  Future<void> pause() async {
    _isPaused = true;
  }

  @override
  Future<void> resume() async {
    _isPaused = false;
  }
}
