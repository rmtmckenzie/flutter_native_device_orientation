import Foundation
import Flutter

class DisplayOrientationListener: OrientationListener {
  init(callback: @escaping (String) -> Void) {
    self.callback = callback
  }
  
  private let callback: ((String) -> Void)
  private var lastOrientation: String?
  
  func start() ->FlutterError? {
    UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    NotificationCenter.default.addObserver(self, selector: #selector(DisplayOrientationListener.receiveOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    return nil;
  }
  
  func stop() {
    UIDevice.current.endGeneratingDeviceOrientationNotifications()
    NotificationCenter.default.removeObserver(self)
  }
  
  func once() -> FlutterError? {
    callback(getDeviceOrientation())
    return nil
  }
  
  private func getDeviceOrientation() -> String {
    switch (UIApplication.shared.statusBarOrientation) {
    case .portrait:
      return PORTRAIT_UP
    case .portraitUpsideDown:
      return PORTRAIT_DOWN
    case .landscapeRight:
      // return left for right as UIInterfaceOrientation is 'the amount needed
      // to rotate to get back to normal', not the actual rotation
      return LANDSCAPE_LEFT
    case .landscapeLeft:
      // return right for left, see above
      return LANDSCAPE_RIGHT
    default:
      return UNKNOWN
    }
  }
  
  @objc private func receiveOrientationChange() {
    let orientation = getDeviceOrientation()
    
    if orientation != lastOrientation {
      lastOrientation = orientation
      callback(orientation)
    }
  }
}
