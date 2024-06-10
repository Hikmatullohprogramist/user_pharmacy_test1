import UIKit
import Flutter
import YandexMapsMobile
import AVKit
import Firebase
import FirebaseCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    YMKMapKit.setApiKey("c2270c63-ab7b-463b-b6d7-20821d098826")
    FirebaseApp.configure()
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let batteryChannel = FlutterMethodChannel(name: "payment_launch",
                                                  binaryMessenger: controller.binaryMessenger)
    batteryChannel.setMethodCallHandler({
          (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        
        guard call.method == "click" else {
          result(FlutterMethodNotImplemented)
          return
        }
        self.receiveBatteryLevel(result: result, url: call.arguments as! String)
        })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func receiveBatteryLevel(result: FlutterResult, url: String) {
        print(url)
        let instagramUrl = URL(string: url)!
        if UIApplication.shared.canOpenURL(instagramUrl)
        {
            result(1)
            UIApplication.shared.open(instagramUrl)
        } else {
            result(2)
            UIApplication.shared.open(URL(string: url)!)
        }
    }
}
