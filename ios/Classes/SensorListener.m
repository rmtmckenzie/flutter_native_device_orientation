#import "SensorListener.h"

@implementation SensorListener {
    CMMotionManager* motionManager;
    NSString* lastOrientation;
}

- (void)initMotionManager {
    if (!motionManager) {
        motionManager = [[CMMotionManager alloc] init];
    }
}

- (void)startOrientationListener:(void (^)(NSString* orientation)) orientationRetrieved {
    [self initMotionManager];
    if([motionManager isDeviceMotionAvailable] == YES){
        motionManager.deviceMotionUpdateInterval = 0.1;
        
        [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *data, NSError *error) {
            NSString *orientation;

            float agx = fabs(data.gravity.x), agy = fabs(data.gravity.y);
          
            if (agx < 0.1 && agy < 0.1) {
                // ignore when both values are small as this means
                // the device is flat.
                return;
            }
          
            if(agx > agy){
                // we are in landscape-mode
                if(data.gravity.x >= 0){
                    orientation = LANDSCAPE_RIGHT;
                }
                else{
                    orientation = LANDSCAPE_LEFT;
                }
            }
            else{
                // we are in portrait mode
                if(data.gravity.y >= 0){
                    orientation = PORTRAIT_DOWN;
                }
                else{
                    orientation = PORTRAIT_UP;
                }
            }

            if (self->lastOrientation == nil || ![orientation isEqualToString:(self->lastOrientation)]) {
                self->lastOrientation = orientation;
                orientationRetrieved(orientation);
            }
        }];
    }
}

- (void) getOrientation:(void (^)(NSString* orientation)) orientationRetrieved {
    
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


