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

    // Setup Flutter Downloader
    FlutterDownloaderPlugin.setPluginRegistrantCallback(registerPlugins)

    // Initialize OneSignal with your app ID
    OneSignal.setAppId("YOUR_ONESIGNAL_APP_ID")

    // Handle notification received in foreground
    OneSignal.setNotificationWillShowInForegroundHandler { notification, completion in
      // Increment badge count directly here
      let currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
      UIApplication.shared.applicationIconBadgeNumber = currentBadgeCount + 1

      // Show the notification
      completion(notification)
    }

    // Handle notification opened
    OneSignal.setNotificationOpenedHandler { result in
      // Optionally handle the opened notification
      // Access notification data via result.notification if needed
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func registerPlugins(registry: FlutterPluginRegistry) {
    if !registry.hasPlugin("FlutterDownloaderPlugin") {
      FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
    }
  }
}
