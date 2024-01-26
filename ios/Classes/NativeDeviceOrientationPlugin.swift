import Flutter
import UIKit

let METHOD_CHANEL:String = "native_device_orientation"
let EVENT_CHANNEL:String = "native_device_orientation_events"

let PORTRAIT_UP:String! = "PortraitUp"
let PORTRAIT_DOWN:String! = "PortraitDown"
let LANDSCAPE_LEFT:String! = "LandscapeLeft"
let LANDSCAPE_RIGHT:String! = "LandscapeRight"
let UNKNOWN:String! = "Unknown"

public class NativeDeviceOrientationPlugin: NSObject, FlutterPlugin {
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = NativeDeviceOrientationPlugin()
    
    let channel = FlutterMethodChannel(name: "native_device_orientation", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    let eventChannel = FlutterEventChannel(name: "native_device_orientation_events", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)
  }
  
  
  private var listener:OrientationListener?
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let argReader = MapArgumentReader(call.arguments as? [String: Any])
    
    switch call.method {
    case "getOrientation":
      getOrientation(useSensor: argReader.bool(key: "useSensor") ?? false, result: result)
    case "pause":
      result(pause())
    case "resume":
      result(resume())
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func getOrientation(useSensor: Bool, result: @escaping FlutterResult) {
    let listener: OrientationListener
    if useSensor {
      listener = SensorListener(callback: result)
    } else {
      listener = DisplayOrientationListener(callback: result)
    }
    
    if let error = listener.once() {
      result(error)
    }
  }
  
}

extension NativeDeviceOrientationPlugin: FlutterStreamHandler {
  func pause() {
    guard let listener = listener else {
      return
    }
    
    listener.stop()
  }
  
  func resume() -> FlutterError? {
    if let listener = listener {
      return listener.start()
    }
    return nil
  }
  
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    let argReader = MapArgumentReader(arguments as? [String: Any])
    
    let listener: OrientationListener
    if argReader.bool(key: "useSensor") ?? false {
      listener = SensorListener{ events($0) }
    } else {
      listener = DisplayOrientationListener{ events($0) }
    }
    
    if let error = listener.start() {
      return error
    }
    
    self.listener = listener
    return nil
  }
  
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    if let listener = listener {
      listener.stop()
    }
    listener = nil
    return nil
  }
}
