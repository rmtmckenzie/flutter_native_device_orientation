import Foundation
import Flutter

protocol OrientationListener {
  func start() -> FlutterError?
  func stop()
  func once() -> FlutterError?
}

