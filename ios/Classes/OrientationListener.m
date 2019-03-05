//
//  OrientationListener.m
//  native_device_orientation
//
//  Created by Sebastiaan de Smet on 21/01/2019.
//


#import "OrientationListener.h"

@implementation OrientationListener {
    UIDeviceOrientation lastDeviceOrientation;
    NSString* lastOrientation;
}

- (void)startOrientationListener:(void (^)(NSString* orientation)) orientationRetrieved {
    UIDevice *device = [UIDevice currentDevice];
    [device beginGeneratingDeviceOrientationNotifications];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    self.observer = [nc addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {

        NSString* orientation = [self getDeviceOrientation];

        if (![orientation isEqualToString:(self->lastOrientation)]) {
            self->lastOrientation = orientation;
            orientationRetrieved(orientation);
        }
    }];

    self-> lastOrientation = [self getDeviceOrientation];
    orientationRetrieved(lastOrientation);
}

- (void) getOrientation:(void (^)(NSString* orientation)) orientationRetrieved{
    NSString* orientation = [self getDeviceOrientation];
    orientationRetrieved(orientation);
}

- (NSString*)getDeviceOrientation {
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    // extra check to make sure we don't return the FaceDown and FaceUp orientations but instead return the last known deviceOrientation.
    if(deviceOrientation != UIDeviceOrientationFaceDown && deviceOrientation != UIDeviceOrientationFaceUp) {
        lastDeviceOrientation = deviceOrientation;
    }
    
    switch (lastDeviceOrientation) {
        case UIDeviceOrientationPortrait:
            return PORTRAIT_UP;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            return PORTRAIT_DOWN;
            break;
        case UIDeviceOrientationLandscapeLeft:
            return LANDSCAPE_LEFT;
            break;
        case UIDeviceOrientationLandscapeRight:
            return LANDSCAPE_RIGHT;
            break;
        case UIDeviceOrientationUnknown:
        default:
            return UNKNOWN;
            break;
    }
}

- (void)stopOrientationListener {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UIDevice *device = [UIDevice currentDevice];
    [device endGeneratingDeviceOrientationNotifications];
    [nc removeObserver:self.observer];
    self.observer = NULL;
}

@end
