package com.github.rmtmckenzie.nativedeviceorientation;

import android.content.Context;
import android.content.res.Configuration;
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

        System.out.println("From orientation " + orientation + " and rotation " + rotation + " returning " + returnOrientation.name());
        return returnOrientation;
    }
}
