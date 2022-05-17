package com.github.rmtmckenzie.native_device_orientation;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.Configuration;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import android.view.OrientationEventListener;
import android.view.Surface;
import android.view.WindowManager;

public class OrientationReader {

    public OrientationReader(Context context) {
        this.context = context;
    }


    private final Context context;

    @SuppressLint("SwitchIntDef")
    public NativeOrientation getOrientation() {
        final int rotation = ((WindowManager) context.getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay().getRotation();
        final int orientation = context.getResources().getConfiguration().orientation;

        NativeOrientation returnOrientation;

        switch (orientation) {
            case Configuration.ORIENTATION_PORTRAIT:
                if (rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_90) {
                    returnOrientation = NativeOrientation.PortraitUp;
                } else {
                    returnOrientation = NativeOrientation.PortraitDown;
                }
                break;
            case Configuration.ORIENTATION_LANDSCAPE:
                if (rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_90) {
                    returnOrientation = NativeOrientation.LandscapeLeft;
                } else {
                    returnOrientation = NativeOrientation.LandscapeRight;
                }
                break;
            default:
                returnOrientation = NativeOrientation.Unknown;
        }

        return returnOrientation;
    }
}
