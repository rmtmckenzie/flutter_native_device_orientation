#import <Flutter/Flutter.h>
#import <CoreMotion/CoreMotion.h>

@interface NativeDeviceOrientationPlugin : NSObject<FlutterPlugin, FlutterStreamHandler>
- (void)pause;
- (void)resume;

@end
