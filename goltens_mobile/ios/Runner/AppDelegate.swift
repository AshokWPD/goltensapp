import UIKit
import Flutter
import flutter_downloader
import FirebaseCore
import OneSignalFramework   // new SDK

// Foreground notification listener
class MyForegroundNotificationListener: NSObject, OSNotificationLifecycleListener {
    func onWillDisplay(event: OSNotificationWillDisplayEvent) {
        // Increment badge count
        let currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
        UIApplication.shared.applicationIconBadgeNumber = currentBadgeCount + 1

        // ✅ Show the notification (new API)
        event.notification.display()
        
        // 👉 If you want to suppress instead, use:
        // event.preventDefault()
    }
}

// Click listener
class MyNotificationClickListener: NSObject, OSNotificationClickListener {
    func onClick(event: OSNotificationClickEvent) {
        print("Notification clicked: \(event.notification)")
    }
}

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
    FlutterDownloaderPlugin.setPluginRegistrantCallback { registry in
      if !registry.hasPlugin("FlutterDownloaderPlugin") {
        FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
      }
    }

    // ✅ Initialize OneSignal with your App ID
    OneSignal.initialize("YOUR_ONESIGNAL_APP_ID", withLaunchOptions: launchOptions)

    // ✅ Add listeners
    OneSignal.Notifications.addForegroundLifecycleListener(MyForegroundNotificationListener())
    OneSignal.Notifications.addClickListener(MyNotificationClickListener())

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
