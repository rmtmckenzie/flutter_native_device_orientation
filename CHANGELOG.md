## [1.1.4] - June 6, 2022

* Fix bug stopping android from compiling

## [1.1.3] - June 5, 2202

* Fix sensos getOrientation on android (for real this time)
* Make iOS keep last orientation if device is flat

## [1.1.2] - May 17, 2022

* Fix direct sensor getOrientation on android
* Listen to status bar change on iOS rather than device change (fix for older devices)

## [1.1.1] - May 17, 2022

* Rename unknownSubstitute to defaultOrientation.

## [1.1.0] - May 17, 2022

* Support Flutter 3.0 (should still support 2.x as well)
* Adds additional, more explicit way to use plugin
* Allows setting default if "unknown" is returned from native
  side, previously always defaulted to PortraitUp.

## [1.0.0] - March 9, 2021

* Support null-safety.

## [0.4.3] - July 20, 2020

* Re-add v1 embedding.

## [0.4.2] - July 19, 2020

* Fix package definition & remove iOS i386 block

## [0.4.1] - July 17, 2020

* Fix various pub-specific issues

## [0.4.0] - July 17, 2020

* Fix an issue where the most recent orientation is not always retrieved.
* Update to use new android embedding.
* Use pendantic style for dart code

## [0.3.0] - November 6th, 2019

* Breaking change to support the fact that AppLifecycleState.suspended has changed
  to AppLifecycleState.detached.

## [0.2.0] - April 24, 2019

* Slightly breaking change - on iOS, the sensor was used regardless of what was
  passed to useSensor due to a bug. This meant that even with UI rotation disabled,
  rotation events occured.
* Also switched back to using StatusBarOrientation. It isn't actually deprecated, just
  not advised for normal iOS usage. However, it does what I want and is consistent with
  Android - it returns the orientation of the actual window. If you really want to know
  the orientation of the device, use `useSensor`
* Add buttons to explicitly get rotation using sensor or not (UI)

## [0.1.2] - March 4, 2019

* Reduce amount of orientation changes by keeping track of last change.

## [0.1.1] - March 4, 2019

* Fix documentation and re-order changelog.

## [0.1.0] - March 4, 2019

* Integrate PRs updating to AndroidX and implementing useSensor
* Also made a few changes to do with UseSensor so be careful of that
if you're using the NativeDeviceOrientationCommunicator directly; users
who simply use the widget shouldn't notice anything.

## [0.0.4] - January 2, 2019

* Switch to using UIDeviceOrientation on iOS

## [0.0.2] - June 4, 2018

* Fix name of package

## [0.0.1] - June 4, 2018

* Implement Android & iOS native code.
* Implement Flutter code & widget.
* Write simple example.