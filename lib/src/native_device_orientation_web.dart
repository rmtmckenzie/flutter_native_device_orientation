import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

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

NativeDeviceOrientation _fromInt(int? orientation) {
  if (orientation == null) {
    return NativeDeviceOrientation.unknown;
  }

  switch (orientation) {
    case -90:
      return NativeDeviceOrientation.landscapeRight;
    case 0:
      return NativeDeviceOrientation.portraitUp;
    case 90:
      return NativeDeviceOrientation.landscapeLeft;
    case 180:
      return NativeDeviceOrientation.portraitDown;
    default:
      return NativeDeviceOrientation.unknown;
  }
}

/// Convert DeviceOrientationEvent to NativeDeviceOrientation
NativeDeviceOrientation _fromDeviceOrientation(
  // The alpha angle is 0° when top of the device is pointed directly toward the Earth's north pole, and increases as the device is rotated counterclockwise.
  // As such, 90° corresponds with pointing west, 180° with south, and 270° with east.
  num alpha,
  // The beta angle is 0° when the device's top and bottom are the same distance from the Earth's surface;
  // it increases toward 180° as the device is tipped forward toward the user, and it decreases toward -180° as the device is tipped backward away from the user.
  num beta,
  // The gamma angle is 0° when the device's left and right sides are the same distance from the surface of the Earth,
  // and increases toward 90° as the device is tipped toward the right, and toward -90° as the device is tipped toward the left.
  num gamma,
) {
  if (beta.abs() > gamma.abs()) {
    return beta > 0 ? NativeDeviceOrientation.portraitUp : NativeDeviceOrientation.portraitDown;
  } else {
    return gamma > 0 ? NativeDeviceOrientation.landscapeRight : NativeDeviceOrientation.landscapeLeft;
  }
}

class NativeDeviceOrientationWeb extends NativeDeviceOrientationPlatform {
  // A broadcast stream controller to listen to screen-based orientation changes
  final StreamController<NativeDeviceOrientation> _screenOrientationStreamController =
      StreamController<NativeDeviceOrientation>.broadcast();

  // A broadcast stream controller to listen to sensor-based orientation changes
  final StreamController<NativeDeviceOrientation> _sensorStreamController =
      StreamController<NativeDeviceOrientation>.broadcast();

  static void registerWith(Registrar registrar) {
    NativeDeviceOrientationPlatform.instance = NativeDeviceOrientationWeb();
  }

  // Check if the browser supports the DeviceOrientationEvent
  bool get _hasSensorSupport => globalContext.hasProperty('DeviceOrientationEvent'.toJS).toDart;

  NativeDeviceOrientationWeb() {
    // Set up the listeners for the stream controllers
    // we only listen to the orientation changes when there is a listener
    _screenOrientationStreamController.onListen = () {
      _startListenToScreenOrientationChanges();
    };
    _screenOrientationStreamController.onCancel = () {
      _stopListenToScreenOrientationChanges();
    };
    _sensorStreamController.onListen = () {
      _startListenToSensorChanges();
    };
    _sensorStreamController.onCancel = () {
      _stopListenToSensorChanges();
    };
  }

  // A callback to listen to screen-based orientation changes
  void _onScreenOrientationChange(web.Event event) {
    final orientation = _getCurrentOrientation();
    _screenOrientationStreamController.add(orientation);
  }

  // Starts listening to screen-based orientation changes
  void _startListenToScreenOrientationChanges() {
    web.window.screen.orientation.addEventListener('change', _onScreenOrientationChange.toJS);
  }

  // Stops listening to screen-based orientation changes
  void _stopListenToScreenOrientationChanges() {
    web.window.screen.orientation.removeEventListener('change', _onScreenOrientationChange.toJS);
  }

  // A callback to listen to sensor-based orientation changes
  void _onSensorChange(web.DeviceOrientationEvent event) {
    final orientation = _fromDeviceOrientation(
      event.alpha!,
      event.beta!,
      event.gamma!,
    );
    _sensorStreamController.add(orientation);
  }

  /// Starts listening to sensor-based orientation changes
  ///
  /// Uses the [DeviceOrientationEvent](https://developer.mozilla.org/en-US/docs/Web/API/DeviceOrientationEvent)
  /// This feature is available only in secure contexts (HTTPS)
  Future<void> _startListenToSensorChanges() async {
    final event = globalContext.getProperty<JSObject>('DeviceOrientationEvent'.toJS);
    // check if we need to ask for permission
    if (event.hasProperty('requestPermission'.toJS).toDart) {
      final permission = await event.callMethod<JSPromise>('requestPermission'.toJS).toDart;
      if ((permission as JSString).toDart != 'granted') {
        _sensorStreamController.addError(
          'Permission denied for DeviceOrientationEvent',
        );
      }
    }

    web.window.addEventListener('deviceorientation', _onSensorChange.toJS);
  }

  /// Stops listening to sensor-based orientation changes
  void _stopListenToSensorChanges() {
    web.window.removeEventListener('deviceorientation', _onSensorChange.toJS);
  }

  /// Get the current screen-based orientation
  NativeDeviceOrientation _getCurrentOrientation() {
    final screenOrientation = web.window.screen.getProperty("orientation".toJS);
    if (screenOrientation != null) {
      return _fromString(web.window.screen.orientation.type);
    } else {
      // probably on mobile safari, try to get orientation from window
      final windowOrientation = web.window.getProperty("orientation".toJS);
      return _fromInt((windowOrientation as JSNumber).toDartInt);
    }
  }

  @override
  Stream<NativeDeviceOrientation> onOrientationChanged({
    bool useSensor = false,
    NativeDeviceOrientation defaultOrientation = NativeDeviceOrientation.portraitUp,
  }) {
    if (!useSensor || !_hasSensorSupport) {
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

    return _sensorStreamController.stream.transform(
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
    NativeDeviceOrientation defaultOrientation = NativeDeviceOrientation.portraitUp,
  }) async {
    if (!useSensor || !_hasSensorSupport) {
      return _getCurrentOrientation();
    }

    return onOrientationChanged(
      useSensor: true,
      defaultOrientation: defaultOrientation,
    ).first;
  }

  @override
  Future<void> pause() async {
    if (_screenOrientationStreamController.hasListener) {
      _stopListenToScreenOrientationChanges();
    }
    if (_sensorStreamController.hasListener) {
      _stopListenToSensorChanges();
    }
  }

  @override
  Future<void> resume() async {
    if (_screenOrientationStreamController.hasListener) {
      _startListenToScreenOrientationChanges();
    }
    if (_sensorStreamController.hasListener) {
      _startListenToSensorChanges();
    }
  }
}
