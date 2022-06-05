package com.github.rmtmckenzie.native_device_orientation;

import android.content.Context;

import java.util.LinkedList;
import java.util.List;

public class SensorOrientationReader implements IOrientationListener.OrientationCallback {

    private final Context context;
    private final List<IOrientationListener.OrientationCallback> callbackList = new LinkedList<>();

    public SensorOrientationReader(Context context) {
        this.context = context;
    }

    private IOrientationListener orientationListener;

    public void getOrientation(final IOrientationListener.OrientationCallback callback) {
        // We can't get the orientation of the device directly. We have to listen to the orientation and immediately return the orientation and cancel this listener.
        // if the OrientationListener isn't null, we are already requesting the getSensorOrientation. Firing it multiple times could cause problems.
        callbackList.add(callback);
        if (orientationListener != null) {
            return;
        }

        orientationListener = new SensorOrientationListener(context, this, SensorOrientationListener.Rate.fastest);
        orientationListener.startOrientationListener();
    }

    @Override
    public void receive(NativeOrientation orientation) {
        orientationListener.stopOrientationListener();
        orientationListener = null;
        for (IOrientationListener.OrientationCallback callback: callbackList) {
            callback.receive(orientation);
        }
        callbackList.clear();
    }
}
