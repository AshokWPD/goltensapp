import UIKit
import Flutter
import flutter_downloader
import FirebaseCore
import OneSignal

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Firebase
    FirebaseApp.configure()

    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

    // Setup Flutter Downloader with a closure instead of a method reference
    FlutterDownloaderPlugin.setPluginRegistrantCallback { registry in
      if !registry.hasPlugin("FlutterDownloaderPlugin") {
        FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
      }
    }

    // Initialize OneSignal with your app ID
    OneSignal.setAppId("YOUR_ONESIGNAL_APP_ID")

    // Handle notification received in foreground
    OneSignal.setNotificationWillShowInForegroundHandler { notification, completion in
      let currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
      UIApplication.shared.applicationIconBadgeNumber = currentBadgeCount + 1

      completion(notification)
    }

    // Handle notification opened
    OneSignal.setNotificationOpenedHandler { result in
      // Handle opened notification if needed
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
