import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum NativeDeviceOrientation { portraitUp, portraitDown, landscapeLeft, landscapeRight, unknown }

class NativeDeviceOrientationCommunicator {
  static NativeDeviceOrientationCommunicator _instance;

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  final bool _useSensor;

  Stream<NativeDeviceOrientation> _onNativeOrientationChanged;

  factory NativeDeviceOrientationCommunicator({bool useSensor = false}) {
    if (_instance == null) {
      final MethodChannel methodChannel =
          const MethodChannel('com.github.rmtmckenzie/flutter_native_device_orientation/orientation');
      final EventChannel eventChannel =
          const EventChannel('com.github.rmtmckenzie/flutter_native_device_orientation/orientationevent');
      _instance = new NativeDeviceOrientationCommunicator.private(methodChannel, eventChannel, useSensor);
    }

    return _instance;
  }

  @visibleForTesting
  NativeDeviceOrientationCommunicator.private(this._methodChannel, this._eventChannel, this._useSensor);

  Future<NativeDeviceOrientation> get orientation async {
    final Map<String, dynamic> params = <String, dynamic>{
      'useSensor': _useSensor,
    };
    final String orientation = await _methodChannel.invokeMethod('getOrientation', params);
    return _fromString(orientation);
  }

  // these methods are needed to pause listening to sensorRequests when the app goes to background
  Future<void> pause() async{
    await _methodChannel.invokeMethod('pause');
}

// this method resumes listening to sensorEvents when the app goes to the foreground
Future<void> resume() async{
    await _methodChannel.invokeMethod('resume');
}

  Stream<NativeDeviceOrientation> get onOrientationChanged {
    if (_onNativeOrientationChanged == null) {
      final Map<String, dynamic> params = <String, dynamic>{
        'useSensor': _useSensor,
      };
      _onNativeOrientationChanged = _eventChannel.receiveBroadcastStream(params).map((dynamic event) {
        print("new orientation received");

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
    this.useSensor = false,
    @required this.builder,
  }) : super(key: key);

  final WidgetBuilder builder;
  final bool useSensor;

  static NativeDeviceOrientation orientation(BuildContext context) {
    final _InheritedNativeDeviceOrientation inheritedNativeOrientation =
        context.inheritFromWidgetOfExactType(_InheritedNativeDeviceOrientation);

    assert(() {
      if (inheritedNativeOrientation == null) {
        throw new FlutterError('DeviceOrientationListener.orientation was called but there'
            ' is no DeviceOrientationListener in the context.');
      }
      return true;
    }());

    return inheritedNativeOrientation.nativeOrientation;
  }

  @override
  State<StatefulWidget> createState() => new NativeDeviceOrientationReaderState();
}

class NativeDeviceOrientationReaderState extends State<NativeDeviceOrientationReader> with WidgetsBindingObserver {
  NativeDeviceOrientationCommunicator deviceOrientation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // we need to listen to the state of the application.
    // we shouldn't listen to orientation events when the app is in the background.
    switch(state){
      case AppLifecycleState.inactive:
        // Another app has focus, for example because the control center is opened,
      // or we have opened teh app as a split-screen app. The app however might still be visible.
      // we would still like to retrieve orientationChanges
        break;
      case AppLifecycleState.paused:
        // pause the listener
        deviceOrientation.pause();
        break;
      case AppLifecycleState.resumed:
        // resume the listener
      deviceOrientation.resume();
        break;
      case AppLifecycleState.suspending:
        // unused on iOS on Android the app will be suspbended.
        break;
    }


  }


  @override
  Widget build(BuildContext context) {
    deviceOrientation =
        new NativeDeviceOrientationCommunicator(useSensor: widget.useSensor);

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
