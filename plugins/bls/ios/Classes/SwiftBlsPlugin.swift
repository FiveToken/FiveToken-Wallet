import Flutter
import UIKit

public class SwiftBlsPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "bls", binaryMessenger: registrar.messenger())
    let instance = SwiftBlsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let method = call.method
    let args:Dictionary<String, AnyObject> = call.arguments as! Dictionary<String, AnyObject>;
    let arg = args["num"] as! String
    
    switch method {
    case "ckgen":
      let res = ckgen(arg)
      let sr = String(cString: res!)
      result(sr)
    case "cksign":
      let res = cksign(arg)
      let sr = String(cString: res!)
      result(sr)
    case "pkgen":
      let res = pkgen(arg)
      let sr = String(cString: res!)
      result(sr)
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
