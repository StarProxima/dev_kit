import Flutter
import UIKit

public class SwiftAppLoggerPlugin: NSObject, FlutterPlugin {
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "app_logger", binaryMessenger: registrar.messenger())
    let instance = SwiftCrLoggerPlugin()
    FlutterEventChannel(name: "com.crefter.app_logger/logger", binaryMessenger: registrar.messenger())
                  .setStreamHandler(CrLogger())
      

    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
