import UIKit
import Flutter
import GoogleMaps
import FirebaseMessaging
import Firebase
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyAIZAHqq0Gpw0yNcq6LgsQd9EAGpee5sMg")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       // NOTE: For logging
       // let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
       // print("==== didRegisterForRemoteNotificationsWithDeviceToken ====")
       // print(deviceTokenString)
       Messaging.messaging().apnsToken = deviceToken
     }
      override func application(
         _ application: UIApplication,
         open url: URL,
         options: [UIApplication.OpenURLOptionsKey : Any] = [:]
       ) -> Bool {
         if Auth.auth().canHandle(url) {
           return true
         }
         return super.application(application, open: url, options: options)
       }
}
