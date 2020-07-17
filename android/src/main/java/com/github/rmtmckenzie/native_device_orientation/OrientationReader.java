package com.github.rmtmckenzie.native_device_orientation;

import android.content.Context;
import android.content.res.Configuration;
import android.view.Surface;
import android.view.WindowManager;

import androidx.arch.core.util.Function;

public class OrientationReader {

    public OrientationReader(Context context) {
        this.context = context;
    }

    private IOrientationListener orientationListener;

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
                    returnOrientation = Orientation.PortraitDown;
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

    public void getSensorOrientation(final IOrientationListener.OrientationCallback callback) {
        // We can't get the orientation of the device directly. We have to listen to the orientation and immediately return the orientation and cancel this listener.

        // if the OrientationListener isn't null, we are already requesting the getSensorOrientation. Firing it multiple times could cause problems.
        if (orientationListener != null) return;
        orientationListener = new SensorOrientationListener(new OrientationReader(context), context, new IOrientationListener.OrientationCallback() {
            @Override
            public void receive(Orientation orientation) {
                callback.receive(orientation);
                orientationListener.stopOrientationListener();
                orientationListener = null;
            }
        });
        orientationListener.startOrientationListener();

    }

    public Orientation calculateSensorOrientation(int angle) {
        Orientation returnOrientation;

        final int tolerance = 45;
        angle += tolerance;

        // orientation is 0 in the default orientation mode. This is portait-mode for phones
        // and landscape for tablets. We have to compensate this by calculating the default orientation,
        // and applying an offset.
        int defaultDeviceOrientation = getDeviceDefaultOrientation();
        if (defaultDeviceOrientation == Configuration.ORIENTATION_LANDSCAPE) {
            // add offset to landscape
            angle += 90;
        }

        angle = angle % 360;
        int screenOrientation = angle / 90;

        switch (screenOrientation) {
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

        return returnOrientation;
    }

    public int getDeviceDefaultOrientation() {

        WindowManager windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);

        Configuration config = context.getResources().getConfiguration();

        int rotation = windowManager.getDefaultDisplay().getRotation();

        if (((rotation == Surface.ROTATION_0 || rotation == Surface.ROTATION_180) &&
                config.orientation == Configuration.ORIENTATION_LANDSCAPE)
                || ((rotation == Surface.ROTATION_90 || rotation == Surface.ROTATION_270) &&
                config.orientation == Configuration.ORIENTATION_PORTRAIT)) {
            return Configuration.ORIENTATION_LANDSCAPE;
        } else {
            return Configuration.ORIENTATION_PORTRAIT;
        }
    }
}
