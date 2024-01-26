package com.github.rmtmckenzie.native_device_orientation;

public interface IOrientationListener {

  interface OrientationCallback {
    void receive(NativeOrientation orientation);
  }

  void startOrientationListener();

  void stopOrientationListener();
}
