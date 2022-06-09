import Firebase
import UIKit
import Flutter
import NetworkExtension

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var resultVar=false;
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let methodChannel = FlutterMethodChannel(name: "habilelabs.io/ESP_bell",
                                                 binaryMessenger: controller.binaryMessenger)
    methodChannel.setMethodCallHandler({
         (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      //  print(call.arguments);
        if (call.method == "WifiConnect") {
            self.connectToWifi(result: result)
        }
        else {
              result(FlutterMethodNotImplemented)
              return
        }
       })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
 
    
  private func connectToWifi(result: @escaping FlutterResult)  {
        
        if #available(iOS 11.0, *) {
            let configuration = NEHotspotConfiguration.init(ssid: "Smart Bell", passphrase: "password", isWEP: false)
            configuration.joinOnce = true
            
            NEHotspotConfigurationManager.shared.apply(configuration) { (error) in
                if error != nil {
                    if error?.localizedDescription == "already associated."
                    {
                        result(true)
                    }
                    else{
                        print("No Connected")
                        result(false)
                    }
                }
                else {
                    print("Connected")
                    result(true)
                }
            }
            
        } else {
            print("Version Error");
            result(false);
        }
    }
}
