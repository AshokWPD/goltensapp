import UIKit
import Flutter
import flutter_downloader
import FirebaseCore
import OneSignalFramework   // new SDK

// Foreground notification listener
class MyForegroundNotificationListener: NSObject, OSNotificationLifecycleListener {
    func onWillDisplay(event: OSNotificationWillDisplayEvent) {
        let currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
        UIApplication.shared.applicationIconBadgeNumber = currentBadgeCount + 1
        
        // Display notification
        event.notification.display()
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

    // 🔹 Initialize Firebase safely
    // FirebaseApp.configure()
    // if let app = FirebaseApp.app() {
    //     print("✅ Firebase initialized: \(app.name)")
    // } else {
    //     print("❌ Firebase failed to initialize")
    // }

    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

    // Setup Flutter Downloader
    FlutterDownloaderPlugin.setPluginRegistrantCallback { registry in
      if !registry.hasPlugin("FlutterDownloaderPlugin") {
        FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
      }
    }

    // 🔹 Initialize OneSignal safely
    // if "YOUR-ONESIGNAL-APP-ID" == "YOUR-ONESIGNAL-APP-ID" {
    //     print("⚠️ OneSignal App ID is placeholder — replace it with your real App ID")
    // }
    // OneSignal.initialize("YOUR-ONESIGNAL-APP-ID", withLaunchOptions: launchOptions)
    OneSignal.Notifications.addForegroundLifecycleListener(MyForegroundNotificationListener())
    OneSignal.Notifications.addClickListener(MyNotificationClickListener())
    
    print("✅ OneSignal initialized")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
