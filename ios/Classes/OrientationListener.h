#import <Foundation/Foundation.h>
#import "Orientation.h"
#import "IOrientationListener.h"

#ifndef OrientationListener_h
#define OrientationListener_h
@interface OrientationListener : NSObject <IOrientationListener>

@property id observer;

@end

#endif /* OrientationListener_h */
