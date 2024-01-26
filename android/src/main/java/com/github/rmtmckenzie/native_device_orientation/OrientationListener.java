package com.github.rmtmckenzie.native_device_orientation;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

public class OrientationListener implements IOrientationListener {

  private static final IntentFilter orientationIntentFilter = new IntentFilter(Intent.ACTION_CONFIGURATION_CHANGED);

  private final OrientationReader reader;
  private final Activity activity;
  private final OrientationCallback callback;
  private BroadcastReceiver broadcastReceiver;
  private NativeOrientation lastOrientation = null;

  public OrientationListener(OrientationReader reader, Activity activity, OrientationCallback callback) {
    this.reader = reader;
    this.activity = activity;
    this.callback = callback;
  }

  public void startOrientationListener() {
    if (broadcastReceiver != null) return;

    broadcastReceiver = new BroadcastReceiver() {
      @Override
      public void onReceive(Context context, Intent intent) {
        NativeOrientation orientation = reader.getOrientation(activity);
        if (!orientation.equals(lastOrientation)) {
          lastOrientation = orientation;
          callback.receive(orientation);
        }
      }
    };

    activity.registerReceiver(broadcastReceiver, orientationIntentFilter);

    lastOrientation = reader.getOrientation(activity);
    // send initial orientation.
    callback.receive(lastOrientation);
  }

  public void stopOrientationListener() {
    if (broadcastReceiver == null) return;
    activity.unregisterReceiver(broadcastReceiver);
    broadcastReceiver = null;
  }

}
