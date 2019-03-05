package com.github.rmtmckenzie.nativedeviceorientation;

import android.content.Context;
import android.hardware.SensorManager;
import android.view.OrientationEventListener;

public class SensorOrientationListener implements IOrientationListener {

    private final OrientationReader reader;
    private final Context context;
    private final OrientationCallback callback;
    private OrientationEventListener orientationEventListener;
    private OrientationReader.Orientation lastOrientation = null;

    public SensorOrientationListener(OrientationReader orientationReader, Context context, OrientationCallback callback) {
        this.reader = orientationReader;
        this.context = context;
        this.callback = callback;
    }

    @Override
    public void startOrientationListener() {
        if (orientationEventListener != null) return;

        orientationEventListener = new OrientationEventListener(context, SensorManager.SENSOR_DELAY_NORMAL) {
            @Override
            public void onOrientationChanged(int angle) {
                OrientationReader.Orientation newOrientation = reader.calculateSensorOrientation(angle);

                if (!newOrientation.equals(lastOrientation)) {
                    lastOrientation = newOrientation;
                    callback.receive(newOrientation);
                }
            }
        };
        if (orientationEventListener.canDetectOrientation()) {
            orientationEventListener.enable();
        }
    }

    @Override
    public void stopOrientationListener() {
        if (orientationEventListener == null) return;
        orientationEventListener.disable();
        orientationEventListener = null;
    }
}
