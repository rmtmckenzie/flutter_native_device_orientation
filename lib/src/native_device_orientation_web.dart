import 'dart:async';
import 'dart:js_interop';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:native_device_orientation/src/native_device_orientation.dart';
import 'package:native_device_orientation/src/native_device_orientation_platform_interface.dart';
import 'package:web/web.dart' as web;

// Convert the screen orientation string to NativeDeviceOrientation
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
  // A broadcast stream controller to listen to screen-based orientation changes
  final StreamController<NativeDeviceOrientation>
      _screenOrientationStreamController =
      StreamController<NativeDeviceOrientation>.broadcast();

  static void registerWith(Registrar registrar) {
    NativeDeviceOrientationPlatform.instance = NativeDeviceOrientationWeb();
  }

  NativeDeviceOrientationWeb() {
    // Set up the listeners for the stream controllers
    // we only listen to the orientation changes when there is a listener
    _screenOrientationStreamController.onListen = () {
      _startListenToScreenOrientationChanges();
    };
    _screenOrientationStreamController.onCancel = () {
      _stopListenToScreenOrientationChanges();
    };
  }

  // A callback to listen to screen-based orientation changes
  void _onScreenOrientationChange(web.Event event) {
    final orientation = _getCurrentOrientation();
    _screenOrientationStreamController.add(orientation);
  }

  // Starts listening to screen-based orientation changes
  void _startListenToScreenOrientationChanges() {
    web.window.screen.orientation
        .addEventListener('change', _onScreenOrientationChange.toJS);
  }

  // Stops listening to screen-based orientation changes
  void _stopListenToScreenOrientationChanges() {
    web.window.screen.orientation
        .removeEventListener('change', _onScreenOrientationChange.toJS);
  }

  /// Get the current screen-based orientation
  NativeDeviceOrientation _getCurrentOrientation() {
    return _fromString(web.window.screen.orientation.type);
  }

  @override
  Stream<NativeDeviceOrientation> onOrientationChanged({
    bool useSensor = false,
    NativeDeviceOrientation defaultOrientation =
        NativeDeviceOrientation.portraitUp,
  }) {
    return _screenOrientationStreamController.stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(
            data == NativeDeviceOrientation.unknown ? defaultOrientation : data,
          );
        },
        handleError: (error, stackTrace, sink) {
          sink.add(defaultOrientation);
        },
      ),
    );
  }

  @override
  Future<NativeDeviceOrientation> orientation({
    bool useSensor = false,
    NativeDeviceOrientation defaultOrientation =
        NativeDeviceOrientation.portraitUp,
  }) async {
    return _getCurrentOrientation();
  }

  @override
  Future<void> pause() async {
    if (_screenOrientationStreamController.hasListener) {
      _stopListenToScreenOrientationChanges();
    }
  }

  @override
  Future<void> resume() async {
    if (_screenOrientationStreamController.hasListener) {
      _startListenToScreenOrientationChanges();
    }
  }
}
