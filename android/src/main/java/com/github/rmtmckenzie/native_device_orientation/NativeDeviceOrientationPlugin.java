package com.github.rmtmckenzie.native_device_orientation;

import android.content.Context;

import androidx.annotation.NonNull;

import java.util.Map;

import io.flutter.Log;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;

/** NativeDeviceOrientationPlugin */
public class NativeDeviceOrientationPlugin implements FlutterPlugin {

  private static final String METHOD_CHANEL = "com.github.rmtmckenzie/flutter_native_device_orientation/orientation";
  private static final String EVENT_CHANNEL = "com.github.rmtmckenzie/flutter_native_device_orientation/orientationevent";

  private MethodChannel channel;
  private EventChannel eventChannel;
  private OrientationReader reader;
  private SensorOrientationReader sensorReader;

  private final MethodCallHandler methodCallHandler = new MethodCallHandler();
  private final StreamHandler streamHandler = new StreamHandler();

  private IOrientationListener listener;
  private Context context;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel =  new MethodChannel(flutterPluginBinding.getBinaryMessenger(), METHOD_CHANEL);
    channel.setMethodCallHandler(methodCallHandler);

    eventChannel  = new EventChannel(flutterPluginBinding.getBinaryMessenger(), EVENT_CHANNEL);
    eventChannel.setStreamHandler(streamHandler);

    context = flutterPluginBinding.getApplicationContext();
    reader = new OrientationReader(context);
    sensorReader = new SensorOrientationReader(context);
  }


  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    eventChannel.setStreamHandler(null);
  }

  class MethodCallHandler implements MethodChannel.MethodCallHandler {
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
      switch (call.method) {
        case "getOrientation":
          Boolean useSensor = call.argument("useSensor");

          if(useSensor != null && useSensor){

            // we can't immediately retrieve a orientation from the sensor. We have to start listening
            // and return the first orientation retrieved.
            sensorReader.getOrientation(new IOrientationListener.OrientationCallback(){
              @Override
              public void receive(NativeOrientation orientation) {
                result.success(orientation.name());
              }
            });
          }else{
            result.success(reader.getOrientation().name());
          }
          break;

        case "pause":
          // if a listener is currently active, stop listening. The app is going to the background
          if(listener != null){
            listener.stopOrientationListener();
          }
          result.success(null);
          break;

        case "resume":
          // start listening for orientation changes again. The app is in the foreground.
          if(listener != null){
            listener.startOrientationListener();
          }
          result.success(null);
          break;
        default:
          result.notImplemented();
      }
    }
  }

  class StreamHandler implements EventChannel.StreamHandler {
    @Override
    public void onListen(Object parameters, final EventChannel.EventSink eventSink) {
      boolean useSensor = false;
      // used hashMap to send parameters to this method. This makes it easier in the future to add new parameters if needed.
      if(parameters instanceof Map){
        //noinspection unchecked
        Map<String, Object> params = (Map<String,Object>) parameters;

        if(params.containsKey("useSensor")){
          Boolean useSensorNullable = (Boolean) params.get("useSensor");
          useSensor = useSensorNullable != null && useSensorNullable;
        }
      }

      // initialize the callback. It is the same for both listeners.
      IOrientationListener.OrientationCallback callback = new IOrientationListener.OrientationCallback() {
        @Override
        public void receive(NativeOrientation orientation) {
          eventSink.success(orientation.name());
        }
      };

      if(useSensor){
        Log.i("NDOP", "listening using sensor listener");
        listener = new SensorOrientationListener(context, callback);
      }else{
        Log.i("NDOP", "listening using window listener");
        listener = new OrientationListener(reader, context, callback);
      }
      listener.startOrientationListener();
    }

    @Override
    public void onCancel(Object arguments) {
      listener.stopOrientationListener();
      listener = null;
    }
  }


}
