package com.github.rmtmckenzie.nativedeviceorientation;

import android.content.Context;
import android.content.res.Configuration;
import android.hardware.SensorManager;
import android.view.OrientationEventListener;
import android.view.Surface;
import android.view.WindowManager;

public class OrientationReader {

    public OrientationReader(Context context) {
        this.context = context;
    }

    public enum Orientation {
        PortraitUp,
        PortraitDown,
        LandscapeLeft,
        LandscapeRight,
        Unknown
    }

    private final Context context;

    public Orientation getOrientation() {
        final int rotation = ((WindowManager) context.getSystemService(Context.WINDOW_SERVICE)).getDefaultDisplay().getRotation();
        final int orientation = context.getResources().getConfiguration().orientation;

        Orientation returnOrientation;

        switch (orientation) {
            case Configuration.ORIENTATION_PORTRAIT:
                if (rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_90) {
                    returnOrientation = Orientation.PortraitUp;
                } else {
                    returnOrientation =  Orientation.PortraitDown;
                }
                break;
            case Configuration.ORIENTATION_LANDSCAPE:
                if (rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_90) {
                    returnOrientation = Orientation.LandscapeLeft;
                } else {
                    returnOrientation = Orientation.LandscapeRight;
                }
                break;
            default:
                returnOrientation = Orientation.Unknown;
        }

        return returnOrientation;
    }

    public Orientation getSensorOrientation(){
        float[] rotationMatrix = new float[9];
        float[] values = new float[3];
        float[] test=  SensorManager.getOrientation(rotationMatrix, values);
        return Orientation.Unknown;
    }

    public Orientation calculateSensorOrientation(int angle){
        Orientation returnOrientation;

        final int tolerance = 45;

        angle += tolerance;
        angle = angle % 360;
        int screenOrientation = angle / 90;


        switch (screenOrientation){
            case 0:
                returnOrientation = Orientation.PortraitUp;
                break;
            case 1:
                returnOrientation = Orientation.LandscapeRight;
                break;
            case 2:
                returnOrientation = Orientation.PortraitDown;
                break;
            case 3:
                returnOrientation = Orientation.LandscapeLeft;
                break;

            default:
                returnOrientation = Orientation.Unknown;

        }

        return  returnOrientation;
    }
}
