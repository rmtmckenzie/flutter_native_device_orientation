package com.github.rmtmckenzie.nativedeviceorientation;

public interface IOrientationListener {

    interface OrientationCallback {
        void receive(OrientationReader.Orientation orientation);
    }

    public void startOrientationListener();

    public void stopOrientationListener();
}
