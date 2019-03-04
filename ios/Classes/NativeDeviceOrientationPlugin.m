#import "NativeDeviceOrientationPlugin.h"
#import "SensorListener.h"
#import "OrientationListener.h"
#import "IOrientationListener.h"

NSString* const METHOD_CHANEL = @"com.github.rmtmckenzie/flutter_native_device_orientation/orientation";
NSString* const EVENT_CHANNEL = @"com.github.rmtmckenzie/flutter_native_device_orientation/orientationevent";


//CMMotionManager* motionManager;
id<IOrientationListener> listener;

@interface NativeDeviceOrientationPlugin ()
@property id observer;
@property (copy) void (^orientationRetrieved)(NSString *orientation);
@end

@implementation NativeDeviceOrientationPlugin



+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:METHOD_CHANEL
                                     binaryMessenger:[registrar messenger]];
    FlutterEventChannel* eventChannel = [FlutterEventChannel eventChannelWithName:EVENT_CHANNEL binaryMessenger:[registrar messenger]];
    
    NativeDeviceOrientationPlugin* instance = [[NativeDeviceOrientationPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
    [eventChannel setStreamHandler:instance];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    if ([@"getOrientation" isEqualToString:call.method]) {
        NSDictionary *args = call.arguments;
        _Bool useSensor = false;
        if(args != NULL){
            useSensor = args[@"useSensor"];
        }
        
        if(useSensor){
            SensorListener* sensorListener = [SensorListener alloc];
            [sensorListener getOrientation:^(NSString *orientation) {
                result(orientation);
            }];
        }else{
            OrientationListener* orientationListener = [OrientationListener alloc];
            [orientationListener getOrientation:^(NSString *orientation) {
                result(orientation);
            }];
        }
        
    } else if([@"pause" isEqualToString:call.method]){
        [self pause];
        result(NULL);
    }else if([@"resume" isEqualToString:call.method]){
        [self resume];
        result(NULL);
    }else {
        result(FlutterMethodNotImplemented);
    }
}

- (void) pause{
    // pause the listener
    if(listener != NULL){
        [listener stopOrientationListener];
    }
}

- (void) resume{
    // resume the listener
    if(listener != NULL){
        [listener startOrientationListener:_orientationRetrieved];
    }
}

- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
    NSDictionary *args = arguments;
    _Bool useSensor = false;
    if(args != NULL){
        useSensor = args[@"useSensor"];
    }
    
    if(useSensor){
        listener =[[SensorListener alloc] init];
    }else{
        listener = [[OrientationListener alloc] init];
    }
    _orientationRetrieved = ^(NSString *orientation){
        events(orientation);
    };
    [listener startOrientationListener:_orientationRetrieved];
    
    return NULL;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    if(listener != NULL){
        [listener stopOrientationListener];
    }
    return NULL;
}

@end
