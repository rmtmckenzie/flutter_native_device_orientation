import 'package:flutter/widgets.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

class NativeDeviceOrientationReader extends StatefulWidget {
  const NativeDeviceOrientationReader({
    super.key,
    this.useSensor = false,
    required this.builder,
  });

  final WidgetBuilder builder;
  final bool useSensor;

  static NativeDeviceOrientation orientation(BuildContext context) {
    final inheritedNativeOrientation = context.dependOnInheritedWidgetOfExactType<_InheritedNativeDeviceOrientation>();

    assert(() {
      if (inheritedNativeOrientation == null) {
        throw FlutterError('DeviceOrientationListener.orientation was called but there'
            ' is no DeviceOrientationListener in the context.');
      }
      return true;
    }());

    return inheritedNativeOrientation!.nativeOrientation;
  }

  @override
  State<StatefulWidget> createState() => NativeDeviceOrientationReaderState();
}

class NativeDeviceOrientationReaderState extends State<NativeDeviceOrientationReader> with WidgetsBindingObserver {
  NativeDeviceOrientationCommunicator deviceOrientationCommunicator = NativeDeviceOrientationCommunicator();

  // allow value of type T or T? to be treated as
  // a value of type T?
  T? _ambiguate<T>(T? value) => value;

  @override
  void initState() {
    super.initState();
    _ambiguate(WidgetsBinding.instance)?.addObserver(this);
  }

  @override
  void dispose() {
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
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
      default:
        // ignoring AppLifecycleState.hidden as it is synthetic event on iOS/Androidq
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return StreamBuilder(
        stream: deviceOrientationCommunicator.onOrientationChanged(useSensor: widget.useSensor),
        builder: (context, AsyncSnapshot<NativeDeviceOrientation> asyncResult) {
          if (asyncResult.connectionState == ConnectionState.waiting) {
            return OrientationBuilder(builder: (buildContext, orientation) {
              return FutureBuilder<NativeDeviceOrientation>(
                  future: deviceOrientationCommunicator.orientation(),
                  builder: (context, AsyncSnapshot<NativeDeviceOrientation> asyncResult) {
                    if (asyncResult.connectionState == ConnectionState.waiting) {
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
  final NativeDeviceOrientation nativeOrientation;

  const _InheritedNativeDeviceOrientation._({
    required this.nativeOrientation,
    required super.child,
  });

  factory _InheritedNativeDeviceOrientation({
    required NativeDeviceOrientation? nativeOrientation,
    required Widget child,
  }) {
    return _InheritedNativeDeviceOrientation._(
      nativeOrientation: nativeOrientation ?? NativeDeviceOrientation.unknown,
      child: child,
    );
  }

  @override
  bool updateShouldNotify(_InheritedNativeDeviceOrientation oldWidget) =>
      nativeOrientation != oldWidget.nativeOrientation;
}
