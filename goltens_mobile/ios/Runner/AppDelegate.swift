import UIKit
import Flutter
import flutter_downloader
import OneSignalFramework   // OneSignal SDK

// Foreground notification listener
class MyForegroundNotificationListener: NSObject, OSNotificationLifecycleListener {
    func onWillDisplay(event: OSNotificationWillDisplayEvent) {
        let currentBadgeCount = UIApplication.shared.applicationIconBadgeNumber
        UIApplication.shared.applicationIconBadgeNumber = currentBadgeCount + 1
        event.notification.display() // Always show notification
    }
}

// Click listener
class MyNotificationClickListener: NSObject, OSNotificationClickListener {
    func onClick(event: OSNotificationClickEvent) {
        print("📩 Notification clicked: \(event.notification)")
    }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

    // Setup Flutter Downloader
    FlutterDownloaderPlugin.setPluginRegistrantCallback { registry in
      if !registry.hasPlugin("FlutterDownloaderPlugin") {
        FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
      }
    }

    // 🔹 Initialize OneSignal
    OneSignal.initialize("7ea4ff4f-c154-4fd2-8cf6-d8ca1103f390", withLaunchOptions: launchOptions)

    // 🔹 Request push permission (system alert)
    OneSignal.Notifications.requestPermission({ accepted in
        print("🔔 Push permission accepted: \(accepted)")
    }, fallbackToSettings: true)

    // 🔹 Listeners
    OneSignal.Notifications.addForegroundLifecycleListener(MyForegroundNotificationListener())
    OneSignal.Notifications.addClickListener(MyNotificationClickListener())

    print("✅ OneSignal initialized")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
