package com.github.rmtmckenzie.native_device_orientation;

import android.content.Context;

public class SensorOrientationReader {

    private final Context context;

    public SensorOrientationReader(Context context) {
        this.context = context;
    }

    private IOrientationListener orientationListener;

    public void getOrientation(final IOrientationListener.OrientationCallback callback) {
        // We can't get the orientation of the device directly. We have to listen to the orientation and immediately return the orientation and cancel this listener.
        // if the OrientationListener isn't null, we are already requesting the getSensorOrientation. Firing it multiple times could cause problems.
        if (orientationListener != null) return;
        orientationListener = new SensorOrientationListener(context, new IOrientationListener.OrientationCallback() {
            @Override
            public void receive(NativeOrientation orientation) {
                callback.receive(orientation);
                orientationListener.stopOrientationListener();
                orientationListener = null;
            }
        }, SensorOrientationListener.Rate.fastest);
        orientationListener.startOrientationListener();
    }


}
