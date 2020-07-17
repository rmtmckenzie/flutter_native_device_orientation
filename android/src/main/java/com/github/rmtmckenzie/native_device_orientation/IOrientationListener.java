package com.github.rmtmckenzie.native_device_orientation;

public interface IOrientationListener {

    interface OrientationCallback {
        void receive(OrientationReader.Orientation orientation);
    }

    void startOrientationListener();

    void stopOrientationListener();
}
