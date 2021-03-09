# Native Device Orientation

[![pub package][version_badge]](https://pub.dartlang.org/packages/native_device_orientation)

This is a plugin project that allows for getting the native device orientation.

## Why?

Flutter provides a couple of way to get the 'orientation', but they all amount
to basically checking whether the screen is taller or wider. This could fail for
a strangely shaped device, but that isn't the primary issue. 

The primary issue is that this method doesn't differentiate between landscape left and
landscape right (what you get from rotation an upright phone left or right).

This isn't an issue for most applications, but when I was writing a plugin which displays
a camera image, it became a problem as I need to know which way the screen is rotated.

## UseSensor

When using either the build-in widget or the plugin directly, there is an option you can pass in
which is called `useSensor`. When it is `true`, the device's sensors are used directly rather
than simply using the window/page orientation. By default it is `false`, which means the plugin
doesn't to much more than simply tell you whether the window is oriented landscapeLeft or landscapeRight.

This has been tested less thoroughly than other parts of the plugin so your mileage may vary and
if you run into any issues please open an issue!

## Using the plugin - built-in widget 

There are two ways of using the plugin. The most basic is what is shown in the example code;
 this entails encapsulating your code in a `NativeDeviceOrientationReader` widget, and then
 using `NativeDeviceOrientationReader.orientation(context);` in a widget encapsulated
 within the context.

This allows you to control when the device starts listening for orientation changes (which could
use a bit of energy) by deciding where the `NativeDeviceOrientationReader` is instantiated,
while being able to access the orientation in a simple way.


_Note that there could be a very slight time between when the `NativeDeviceOrientationReader` widget 
is instantiated and when the orientation is read where the widget could be built with an incorrect
orientation; it uses flutter's method of size until the first message it receives
back from the native code (which should be fairly immediate anyways). It
assumes that landscape is right and portrait is upright during this time._

See example and source code for more details.

## Using the plugin - directly

It is also possible to bypass the helper widget to access the native calls directly.
This is done by using the `NativeDeviceOrientationCommunicator` class. It is a singleton
but can be instantiated like a normal class, and handles the communication between the 
ios/android code and the flutter code.

This class has two interesting methods:

1. `Future<NativeDeviceOrientation> orientation(useSensor: false)`:
This can be called to get the orientation asynchronously.

1. `Stream<NativeDeviceOrientation> onOrientationChanged(useSensor: false)`:
This can be called to get a stream which receives new events whenever the 
orientation changes. It should also get an initial value pretty much
immediately.

[version_badge]: https://img.shields.io/pub/v/native_device_orientation.svg