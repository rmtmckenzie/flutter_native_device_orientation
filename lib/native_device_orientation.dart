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

class NativeDeviceOrientationCommunicator {
  static NativeDeviceOrientationCommunicator _instance;

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  Stream<NativeDeviceOrientation> _onNativeOrientationChanged;

  factory NativeDeviceOrientationCommunicator() {
    if (_instance == null) {
      final MethodChannel methodChannel = const MethodChannel(
          'com.github.rmtmckenzie/flutter_native_device_orientation/orientation');
      final EventChannel eventChannel = const EventChannel(
          'com.github.rmtmckenzie/flutter_native_device_orientation/orientationevent');
      _instance = new NativeDeviceOrientationCommunicator.private(
          methodChannel, eventChannel);
    }

    return _instance;
  }

  @visibleForTesting
  NativeDeviceOrientationCommunicator.private(
      this._methodChannel, this._eventChannel);

  Future<NativeDeviceOrientation> get orientation async {
    final String orientation =
        await _methodChannel.invokeMethod('getOrientation');
    return _fromString(orientation);
  }

  Stream<NativeDeviceOrientation> get onOrientationChanged {
    if (_onNativeOrientationChanged == null) {
      _onNativeOrientationChanged =
          _eventChannel.receiveBroadcastStream().map((dynamic event) {
            return _fromString(event);
          });
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

class NativeDeviceOrientationReader extends StatefulWidget {
  const NativeDeviceOrientationReader({
    Key key,
    @required this.builder,
  }) : super(key: key);

  final WidgetBuilder builder;

  static NativeDeviceOrientation orientation(BuildContext context) {
    final _InheritedNativeDeviceOrientation inheritedNativeOrientation =
        context.inheritFromWidgetOfExactType(_InheritedNativeDeviceOrientation);

    assert(() {
      if (inheritedNativeOrientation == null) {
        throw new FlutterError(
            'DeviceOrientationListener.orientation was called but there'
            ' is no DeviceOrientationListener in the context.');
      }
      return true;
    }());

    return inheritedNativeOrientation.nativeOrientation;
  }

  @override
  State<StatefulWidget> createState() => new NativeDeviceOrientationReaderState();
}

class NativeDeviceOrientationReaderState extends State<NativeDeviceOrientationReader> {
  NativeDeviceOrientationCommunicator deviceOrientation =
      new NativeDeviceOrientationCommunicator();

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(builder: (context, constraints) {
      return new StreamBuilder(
        stream: deviceOrientation.onOrientationChanged,
        builder: (context, AsyncSnapshot<NativeDeviceOrientation> asyncResult) {
          if (asyncResult.connectionState == ConnectionState.waiting) {
            return new OrientationBuilder(builder: (buildContext, orientation) {
              return new _InheritedNativeDeviceOrientation(
                nativeOrientation: orientation == Orientation.landscape
                    ? NativeDeviceOrientation.landscapeRight
                    : NativeDeviceOrientation.portraitUp,
                child: new Builder(builder: widget.builder),
              );
            });
          } else {
            return new _InheritedNativeDeviceOrientation(
              nativeOrientation: asyncResult.data,
              child: new Builder(builder: widget.builder),
            );
          }
        },
      );
    });
  }
}

class _InheritedNativeDeviceOrientation extends InheritedWidget {
  final NativeDeviceOrientation nativeOrientation;

  const _InheritedNativeDeviceOrientation({
    Key key,
    @required this.nativeOrientation,
    @required Widget child,
  })  : assert(nativeOrientation != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedNativeDeviceOrientation oldWidget) =>
      this.nativeOrientation != oldWidget.nativeOrientation;
}
