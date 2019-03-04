#import <CoreMotion/CoreMotion.h>
#import <Foundation/Foundation.h>
#import "SensorListener.h"
#import "IOrientationListener.h"
#import "Orientation.h"

#ifndef SensorListener_h
#define SensorListener_h
@interface SensorListener : NSObject <IOrientationListener>

@end

#endif /* SensorListener_h */
