import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum NativeDeviceOrientation {
  portraitUp,
  portraitDown,
  landscapeLeft,
  landscapeRight,
  unknown
}

class DeviceOrientationCommunicator {
  static DeviceOrientationCommunicator _instance;

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  Stream<NativeDeviceOrientation> _onNativeOrientationChanged;

  factory DeviceOrientationCommunicator() {
    if (_instance == null) {
      final MethodChannel methodChannel = const MethodChannel(
          'com.github.rmtmckenzie/flutter_native_device_orientation/orientation');
      final EventChannel eventChannel = const EventChannel(
          'com.github.rmtmckenzie/flutter_native_device_orientation/orientationevent');
      _instance = new DeviceOrientationCommunicator.private(
          methodChannel, eventChannel);
    }

    return _instance;
  }

  @visibleForTesting
  DeviceOrientationCommunicator.private(
      this._methodChannel, this._eventChannel);

  Future<NativeDeviceOrientation> get orientation async {
    final String orientation =
        await _methodChannel.invokeMethod('getOrientation');
    return _fromString(orientation);
  }

  Stream<NativeDeviceOrientation> get onOrientationChanged {
    if (_onNativeOrientationChanged == null) {
      _onNativeOrientationChanged =
          _eventChannel.receiveBroadcastStream().map((dynamic event) => event);
    }
    return _onNativeOrientationChanged;
  }

  NativeDeviceOrientation _fromString(String orientationString) {
    switch (orientationString) {
      case "PortraitUp":
        return NativeDeviceOrientation.portraitUp;
      case "PortraitDown":
        return NativeDeviceOrientation.portraitDown;
      case "LandscapeRight":
        return NativeDeviceOrientation.landscapeRight;
      case "LandscapeLeft":
        return NativeDeviceOrientation.landscapeLeft;
      case "Unknown":
      default:
        return NativeDeviceOrientation.unknown;
    }
  }
}

class DeviceOrientationListener extends StatefulWidget {
  const DeviceOrientationListener({
    Key key,
    @required this.builder,
  }) : super(key: key);

  final WidgetBuilder builder;

  static NativeDeviceOrientation orientation(BuildContext context) {
    final _InheritedDeviceOrientation inheritedNativeOrientation =
        context.inheritFromWidgetOfExactType(_InheritedDeviceOrientation);

    assert(() {
      if (inheritedNativeOrientation != null) {
        throw new FlutterError(
            'DeviceOrientationListener.orientation was called but there'
            ' is no DeviceOrientationListener in the context.');
      }
      return true;
    }());

    return inheritedNativeOrientation.nativeOrientation;
  }

  @override
  State<StatefulWidget> createState() => new NativeOrientationBuilderState();
}

class NativeOrientationBuilderState extends State<DeviceOrientationListener> {
  DeviceOrientationCommunicator deviceOrientation =
      new DeviceOrientationCommunicator();

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(builder: (context, constraints) {
      return new StreamBuilder(
        stream: deviceOrientation.onOrientationChanged,
        builder: (context, AsyncSnapshot<NativeDeviceOrientation> asyncResult) {
          if (asyncResult.connectionState == ConnectionState.waiting) {
            return new OrientationBuilder(builder: (buildContext, orientation) {
              return new _InheritedDeviceOrientation(
                nativeOrientation: orientation == Orientation.landscape
                    ? NativeDeviceOrientation.landscapeRight
                    : NativeDeviceOrientation.portraitUp,
                child: new Builder(builder: widget.builder),
              );
            });
          } else {
            return new _InheritedDeviceOrientation(
              nativeOrientation: asyncResult.data,
              child: new Builder(builder: widget.builder),
            );
          }
        },
      );
    });
  }
}

class _InheritedDeviceOrientation extends InheritedWidget {
  final NativeDeviceOrientation nativeOrientation;

  const _InheritedDeviceOrientation({
    Key key,
    @required this.nativeOrientation,
    @required Widget child,
  })  : assert(nativeOrientation != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedDeviceOrientation oldWidget) =>
      this.nativeOrientation != oldWidget.nativeOrientation;
}
