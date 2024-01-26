package com.github.rmtmckenzie.native_device_orientation;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;

import java.util.Map;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * NativeDeviceOrientationPlugin
 */
public class NativeDeviceOrientationPlugin implements FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler, ActivityAware {
  private final OrientationReader reader = new OrientationReader();
  private final SensorOrientationReader sensorReader = new SensorOrientationReader();
  private MethodChannel channel;
  private EventChannel eventChannel;
  private Activity activity;
  private IOrientationListener listener;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "native_device_orientation");
    channel.setMethodCallHandler(this);

    eventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(), "native_device_orientation_events");
    eventChannel.setStreamHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    eventChannel.setStreamHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    this.activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivity() {
    this.activity = null;
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    this.onAttachedToActivity(binding);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
    switch (call.method) {
      case "getOrientation":
        if (activity == null) {
          result.error("detached", "Cannot get orientation while not attached to window", null);
          return;
        }

        Boolean useSensor = call.argument("useSensor");

        if (useSensor != null && useSensor) {
          // we can't immediately retrieve a orientation from the sensor. We have to start listening
          // and return the first orientation retrieved.
          sensorReader.getOrientation(activity, orientation -> result.success(orientation.name()));
        } else {
          result.success(reader.getOrientation(activity).name());
        }
        break;

      case "pause":
        // if a listener is currently active, stop listening. The app is going to the background
        if (listener != null) {
          listener.stopOrientationListener();
        }
        result.success(null);
        break;

      case "resume":
        // start listening for orientation changes again. The app is in the foreground.
        if (listener != null) {
          listener.startOrientationListener();
        }
        result.success(null);
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onListen(Object parameters, final EventChannel.EventSink eventSink) {
    if (activity == null) {
      throw new IllegalStateException("Cannot start listening while activity is detached");
    }

    boolean useSensor = false;
    // used hashMap to send parameters to this method. This makes it easier in the future to add new parameters if needed.
    if (parameters instanceof Map) {
      @SuppressWarnings("unchecked")
      Map<String, Object> params = (Map<String, Object>) parameters;

      if (params.containsKey("useSensor")) {
        Boolean useSensorNullable = (Boolean) params.get("useSensor");
        useSensor = useSensorNullable != null && useSensorNullable;
      }
    }

    // initialize the callback. It is the same for both listeners.
    IOrientationListener.OrientationCallback callback = orientation -> eventSink.success(orientation.name());

    if (useSensor) {
      Log.i("NDOP", "listening using sensor listener");
      listener = new SensorOrientationListener(activity, callback);
    } else {
      Log.i("NDOP", "listening using window listener");
      listener = new OrientationListener(reader, activity, callback);
    }
    listener.startOrientationListener();
  }

  @Override
  public void onCancel(Object arguments) {
    listener.stopOrientationListener();
    listener = null;
  }
}
