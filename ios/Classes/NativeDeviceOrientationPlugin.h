#import <Flutter/Flutter.h>

@interface NativeDeviceOrientationPlugin : NSObject<FlutterPlugin, FlutterStreamHandler>
- (void)pause;
- (void)resume;

@end
