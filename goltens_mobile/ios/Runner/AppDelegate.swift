import UIKit
import Flutter
import flutter_downloader
import FirebaseCore
import OneSignalFramework   // ✅ updated import

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

    // ✅ Initialize OneSignal
    OneSignal.initialize("YOUR_ONESIGNAL_APP_ID", withLaunchOptions: launchOptions)

    // ✅ Handle notification received in foreground
    OneSignal.Notifications.addForegroundLifecycleListener { notificationWillDisplayEvent in
      let currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
      UIApplication.shared.applicationIconBadgeNumber = currentBadgeCount + 1

      notificationWillDisplayEvent.complete(notificationWillDisplayEvent.notification)
    }

    // ✅ Handle notification opened
    OneSignal.Notifications.addClickListener { notificationClickEvent in
      // Handle opened notification if needed
      print("Notification clicked: \(notificationClickEvent.notification)")
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
