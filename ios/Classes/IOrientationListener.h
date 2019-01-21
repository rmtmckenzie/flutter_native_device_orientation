#ifndef IOrientationListener_h
#define IOrientationListener_h

@protocol IOrientationListener <NSObject>

- (void) startOrientationListener:(void (^)(NSString* orientation)) orientationRetrieved;
- (void) stopOrientationListener;
- (void) getOrientation:(void (^)(NSString* orientation)) orientationRetrieved;

@end

#endif
