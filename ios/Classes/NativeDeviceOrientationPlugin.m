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
        [listener startOrientationListener:^(NSString *orientation) {
            //todo sent back events to the listener
            
        }];
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
    [listener startOrientationListener:^(NSString *orientation) {
        events(orientation);
    }];
    
    return NULL;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    if(listener != NULL){
        [listener stopOrientationListener];
    }
    return NULL;
}

@end

//- (NSString*)getOrientation {
//    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
//
//    // exta check to make sure we don't return the FaceDown and FaceUp orientations but instead return the last known deviceOrientation.
//    if(deviceOrientation != UIDeviceOrientationFaceDown && deviceOrientation != UIDeviceOrientationFaceUp) {
//        lastDeviceOrientation = deviceOrientation;
//    }
//
//    switch (lastDeviceOrientation) {
//        case UIDeviceOrientationPortrait:
//            return PORTRAIT_UP;
//            break;
//        case UIDeviceOrientationPortraitUpsideDown:
//            return PORTRAIT_DOWN;
//            break;
//        case UIDeviceOrientationLandscapeLeft:
//            return LANDSCAPE_LEFT;
//            break;
//        case UIDeviceOrientationLandscapeRight:
//            return LANDSCAPE_RIGHT;
//            break;
//        case UIDeviceOrientationUnknown:
//        default:
//            return UNKNOWN;
//            break;
//    }
//}

//void initMotionManager() {
//    if (!motionManager) {
//        motionManager = [[CMMotionManager alloc] init];
//    }
//}

//- (void)startDeviceMotionUpdates:(FlutterEventSink _Nonnull)events {
//    initMotionManager();
//    if([motionManager isDeviceMotionAvailable] == YES){
//        motionManager.deviceMotionUpdateInterval = 0.1;
//        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *data, NSError *error) {
//
//            NSString *orientation;
//            if(fabs(data.gravity.x)>fabs(data.gravity.y)){
//                // we are in landscape-mode
//                if(data.gravity.x>=0){
//                    NSLog(@"LandscapeRight");
//                    orientation = LANDSCAPE_RIGHT;
//                }
//                else{
//                    NSLog(@"LandscapeLeft");
//                    orientation = LANDSCAPE_LEFT;
//                }
//            }
//            else{
//                // we are in portrait mode
//                if(data.gravity.y>=0){
//                    NSLog(@"PortraitDown");
//                    orientation = PORTRAIT_DOWN;
//                }
//                else{
//
//                    NSLog(@"PortraitUp");
//                    orientation = PORTRAIT_UP;
//                }
//
//            }
//            events(orientation);
//
//        }];
//    }
//}

//- (void)startOrientationUpdates:(FlutterEventSink _Nonnull)events {
//    UIDevice *device = [UIDevice currentDevice];
//    [device beginGeneratingDeviceOrientationNotifications];
//    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//    self.observer = [nc addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
//        events([self getOrientation]);
//    }];
//    events([self getOrientation]);
//}


//void stopDeviceMotionUpdates(){
//    if (motionManager != NULL && [motionManager isGyroActive] == YES) {
//        [motionManager stopDeviceMotionUpdates];
//    }
//}


//- (void)stopOrientationUpdates:(NSNotificationCenter *)nc {
//    UIDevice *device = [UIDevice currentDevice];
//    [device endGeneratingDeviceOrientationNotifications];
//    [nc removeObserver:self.observer];
//    self.observer = NULL;
//}






