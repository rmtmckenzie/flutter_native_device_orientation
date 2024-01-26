package com.github.rmtmckenzie.native_device_orientation;

import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.content.res.Configuration;
import android.os.Build;
import android.view.Surface;
import android.view.WindowManager;

import java.util.Objects;

public class OrientationReader {
  @TargetApi(Build.VERSION_CODES.N)
  @SuppressWarnings("deprecation")
  static int getRotationOld(Activity activity) {
    WindowManager windowManager = (WindowManager) activity.getSystemService(Context.WINDOW_SERVICE);
    return windowManager.getDefaultDisplay().getRotation();
  }

  @SuppressLint("SwitchIntDef")
  public NativeOrientation getOrientation(Activity activity) {
    int rotation;
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
      rotation = Objects.requireNonNull(activity.getDisplay()).getRotation();
    } else {
      rotation = getRotationOld(activity);
    }

    final int orientation = activity.getResources().getConfiguration().orientation;

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
