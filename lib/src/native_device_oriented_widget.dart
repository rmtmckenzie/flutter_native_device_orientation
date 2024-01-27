import 'package:flutter/widgets.dart';
import 'package:native_device_orientation/src/native_device_orientation.dart';
import 'package:native_device_orientation/src/native_device_orientation_reader.dart';

class NativeDeviceOrientedWidget extends StatelessWidget {
  const NativeDeviceOrientedWidget({
    super.key,
    this.useSensor = false,
    this.landscape,
    this.landscapeLeft,
    this.landscapeRight,
    this.portrait,
    this.portraitUp,
    this.portraitDown,
    required this.fallback,
  });

  final bool useSensor;
  final Widget Function(BuildContext)? landscape;
  final Widget Function(BuildContext)? landscapeLeft;
  final Widget Function(BuildContext)? landscapeRight;
  final Widget Function(BuildContext)? portrait;
  final Widget Function(BuildContext)? portraitUp;
  final Widget Function(BuildContext)? portraitDown;
  final Widget Function(BuildContext) fallback;

  @override
  Widget build(BuildContext context) {
    return NativeDeviceOrientationReader(
      useSensor: useSensor,
      builder: (context) {
        final orientation = NativeDeviceOrientationReader.orientation(context);

        switch (orientation) {
          case NativeDeviceOrientation.landscapeLeft:
            return Builder(builder: landscapeLeft ?? landscape ?? fallback);
          case NativeDeviceOrientation.landscapeRight:
            return Builder(builder: landscapeRight ?? landscape ?? fallback);
          case NativeDeviceOrientation.portraitUp:
            return Builder(builder: portraitUp ?? portrait ?? fallback);
          case NativeDeviceOrientation.portraitDown:
            return Builder(builder: portraitDown ?? portrait ?? fallback);
          case NativeDeviceOrientation.unknown:
          default:
            return OrientationBuilder(builder: (buildContext, orientation) {
              switch (orientation) {
                case Orientation.landscape:
                  return Builder(builder: landscape ?? fallback);
                case Orientation.portrait:
                  return Builder(builder: portrait ?? fallback);
                default:
                  return Builder(builder: fallback);
              }
            });
        }
      },
    );
  }
}
