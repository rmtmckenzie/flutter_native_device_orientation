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

class _OrientationStream {
  final Stream<NativeDeviceOrientation> stream;
  final bool useSensor;

  _OrientationStream({required this.stream, required this.useSensor});
}

class NativeDeviceOrientationCommunicator {
  static NativeDeviceOrientationCommunicator? _instance;

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  _OrientationStream? _stream;

  factory NativeDeviceOrientationCommunicator() {
    if (_instance == null) {
      final methodChannel = const MethodChannel(
          'com.github.rmtmckenzie/flutter_native_device_orientation/orientation');
      final eventChannel = const EventChannel(
          'com.github.rmtmckenzie/flutter_native_device_orientation/orientationevent');
      _instance = NativeDeviceOrientationCommunicator.private(
          methodChannel, eventChannel);
    }

    return _instance!;
  }

  @visibleForTesting
  NativeDeviceOrientationCommunicator.private(
      this._methodChannel, this._eventChannel);

  Future<NativeDeviceOrientation> orientation({bool useSensor = false}) async {
    final params = <String, dynamic>{
      'useSensor': useSensor,
    };
    final orientation =
        await _methodChannel.invokeMethod('getOrientation', params);
    return _fromString(orientation);
  }

  // these methods are needed to pause listening to sensorRequests when the app goes to background
  Future<void> pause() async {
    await _methodChannel.invokeMethod('pause');
  }

  // this method resumes listening to sensorEvents when the app goes to the foreground
  Future<void> resume() async {
    await _methodChannel.invokeMethod('resume');
  }

  Stream<NativeDeviceOrientation> onOrientationChanged(
      {bool useSensor = false}) {
    if (_stream == null || _stream!.useSensor != useSensor) {
      final params = <String, dynamic>{
        'useSensor': useSensor,
      };
      _stream = _OrientationStream(
          stream:
              _eventChannel.receiveBroadcastStream(params).map((dynamic event) {
            return _fromString(event);
          }),
          useSensor: useSensor);
    }
    return _stream!.stream;
  }

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
}

class NativeDeviceOrientationReader extends StatefulWidget {
  const NativeDeviceOrientationReader({
    Key? key,
    this.useSensor = false,
    required this.builder,
  }) : super(key: key);

  final WidgetBuilder builder;
  final bool useSensor;

  static NativeDeviceOrientation orientation(BuildContext context) {
    final inheritedNativeOrientation =
        context.dependOnInheritedWidgetOfExactType<
            _InheritedNativeDeviceOrientation>();

    assert(() {
      if (inheritedNativeOrientation == null) {
        throw FlutterError(
            'DeviceOrientationListener.orientation was called but there'
            ' is no DeviceOrientationListener in the context.');
      }
      return true;
    }());

    return inheritedNativeOrientation!.nativeOrientation!;
  }

  @override
  State<StatefulWidget> createState() => NativeDeviceOrientationReaderState();
}

class NativeDeviceOrientationReaderState
    extends State<NativeDeviceOrientationReader> with WidgetsBindingObserver {
  NativeDeviceOrientationCommunicator deviceOrientationCommunicator =
      NativeDeviceOrientationCommunicator();

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
    switch (state) {
      case AppLifecycleState.inactive:
        // Another app has focus, for example because the control center is opened,
        // or we have opened the app as a split-screen app. The app however might still be visible.
        // we would still like to retrieve orientationChanges
        break;
      case AppLifecycleState.paused:
        // pause the listener
        deviceOrientationCommunicator.pause();
        break;
      case AppLifecycleState.resumed:
        // resume the listener
        deviceOrientationCommunicator.resume();
        break;
      case AppLifecycleState.detached:
        // unused on iOS on Android the app will be suspended.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return StreamBuilder(
        stream: deviceOrientationCommunicator.onOrientationChanged(
            useSensor: widget.useSensor),
        builder: (context, AsyncSnapshot<NativeDeviceOrientation> asyncResult) {
          if (asyncResult.connectionState == ConnectionState.waiting) {
            return OrientationBuilder(builder: (buildContext, orientation) {
              return FutureBuilder<NativeDeviceOrientation>(
                  future: deviceOrientationCommunicator.orientation(),
                  builder: (context,
                      AsyncSnapshot<NativeDeviceOrientation> asyncResult) {
                    if (asyncResult.connectionState ==
                        ConnectionState.waiting) {
                      return _InheritedNativeDeviceOrientation(
                        nativeOrientation: orientation == Orientation.landscape
                            ? NativeDeviceOrientation.landscapeRight
                            : NativeDeviceOrientation.portraitUp,
                        child: Builder(builder: widget.builder),
                      );
                    } else {
                      return _InheritedNativeDeviceOrientation(
                        nativeOrientation: asyncResult.data,
                        child: Builder(builder: widget.builder),
                      );
                    }
                  });
            });
          } else {
            return _InheritedNativeDeviceOrientation(
              nativeOrientation: asyncResult.data,
              child: Builder(builder: widget.builder),
            );
          }
        },
      );
    });
  }
}

class _InheritedNativeDeviceOrientation extends InheritedWidget {
  final NativeDeviceOrientation? nativeOrientation;

  const _InheritedNativeDeviceOrientation({
    Key? key,
    required this.nativeOrientation,
    required Widget child,
  })  : assert(nativeOrientation != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedNativeDeviceOrientation oldWidget) =>
      nativeOrientation != oldWidget.nativeOrientation;
}
