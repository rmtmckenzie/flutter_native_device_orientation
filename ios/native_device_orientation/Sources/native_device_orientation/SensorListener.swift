import CoreMotion
import Flutter

class SensorListener : NSObject, OrientationListener {
  init(callback: @escaping (String) -> Void) {
    self.callback = callback
    motionManager = CMMotionManager()
  }
  
  private let callback: ((String) -> Void)
  private let motionManager:CMMotionManager
  private var lastOrientation: String?
  
  private func start(forCallback callback: (String) -> Void) -> FlutterError? {
    guard motionManager.isDeviceMotionAvailable else {
      return FlutterError(code: "orientation_not_available", message: "Sensor orientation not available on this device", details: nil)
    }
    
    motionManager.deviceMotionUpdateInterval = 0.1
    
    motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data:CMDeviceMotion?, error:Error?) in
      guard let data = data else {
        // if no data, return
        return
      }
      
      var orientation: String
      
      let agx = fabs(data.gravity.x), agy = fabs(data.gravity.y)
      
      if agx < 0.1 && agy < 0.1 {
        // ignore when both values are small as this means the device is flat
        return
      }
      
      if agx > agy {
        // landscape
        if data.gravity.x >= 0 {
          orientation = LANDSCAPE_RIGHT
        } else {
          orientation = LANDSCAPE_LEFT
        }
      } else {
        if data.gravity.y >= 0 {
          orientation = PORTRAIT_DOWN
        } else {
          orientation = PORTRAIT_UP
        }
      }
      
      if self.lastOrientation == nil || orientation != self.lastOrientation {
        self.lastOrientation = orientation
        self.callback(orientation)
      }
    }
    return nil
    
  }
  
  func start() -> FlutterError? {
    return self.start(forCallback: callback)
  }
  
  func once() -> FlutterError? {
    return self.start() { orientation in
      callback(orientation)
      // only want to return one orientation so stop
      self.stop()
    }
  }
  
  func stop() {
    if motionManager.isDeviceMotionActive {
      motionManager.stopDeviceMotionUpdates()
    }
  }
}

