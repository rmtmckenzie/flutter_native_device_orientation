package com.github.rmtmckenzie.nativedeviceorientation;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import com.github.rmtmckenzie.nativedeviceorientation.OrientationListener.OrientationCallback;

import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * NativeDeviceOrientationPlugin
 */
public class NativeDeviceOrientationPlugin implements MethodCallHandler, EventChannel.StreamHandler {


    private static final String METHOD_CHANEL = "com.github.rmtmckenzie/flutter_native_device_orientation/orientation";
    private static final String EVENT_CHANNEL = "com.github.rmtmckenzie/flutter_native_device_orientation/orientationevent";

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel methodChannel = new MethodChannel(registrar.messenger(), METHOD_CHANEL);
        final EventChannel eventChannel = new EventChannel(registrar.messenger(), EVENT_CHANNEL);
        final NativeDeviceOrientationPlugin instance = new NativeDeviceOrientationPlugin(registrar.activeContext());

        methodChannel.setMethodCallHandler(instance);
        eventChannel.setStreamHandler(instance);
    }

    private NativeDeviceOrientationPlugin(Context context) {
        this.context = context;
        this.reader = new OrientationReader(context);
    }

    private final Context context;
    private final OrientationReader reader;

    private OrientationListener listener;

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "getOrientation":
                result.success(reader.getOrientation().name());
                break;
            default:
                result.notImplemented();
        }
    }

    @Override
    public void onListen(Object o, final EventChannel.EventSink eventSink) {
        listener = new OrientationListener(reader, context, new OrientationCallback() {
            @Override
            public void receive(OrientationReader.Orientation orientation) {
                eventSink.success(orientation.name());
            }
        });
        listener.startOrientationListener();
    }

    @Override
    public void onCancel(Object o) {
        listener.stopOrientationListener();
        listener = null;
    }
}
