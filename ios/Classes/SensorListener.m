#import "SensorListener.h"

@implementation SensorListener

CMMotionManager* motionManager;

void initMotionManager() {
    if (!motionManager) {
        motionManager = [[CMMotionManager alloc] init];
    }
}

- (void)startOrientationListener:(void (^)(NSString* orientation)) orientationRetrieved {
    initMotionManager();
    if([motionManager isDeviceMotionAvailable] == YES){
        motionManager.deviceMotionUpdateInterval = 0.1;
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *data, NSError *error) {
            
            NSString *orientation;
            if(fabs(data.gravity.x)>fabs(data.gravity.y)){
                // we are in landscape-mode
                if(data.gravity.x>=0){
                    NSLog(@"LandscapeRight");
                    orientation = LANDSCAPE_RIGHT;
                }
                else{
                    NSLog(@"LandscapeLeft");
                    orientation = LANDSCAPE_LEFT;
                }
            }
            else{
                // we are in portrait mode
                if(data.gravity.y>=0){
                    NSLog(@"PortraitDown");
                    orientation = PORTRAIT_DOWN;
                }
                else{
                    
                    NSLog(@"PortraitUp");
                    orientation = PORTRAIT_UP;
                }
                
            }
            orientationRetrieved(orientation);

        }];
    }
}

- (void) getOrientation:(void (^)(NSString* orientation)) orientationRetrieved{
    
    [self startOrientationListener:^(NSString *orientation) {
        orientationRetrieved(orientation);
        
        // we have received a orientation stop the listener. We only want to return one orientation
        [self stopOrientationListener];
    }];
}

- (void)stopOrientationListener {
    if (motionManager != NULL && [motionManager isDeviceMotionActive] == YES) {
        [motionManager stopDeviceMotionUpdates];
    }
}


@end


