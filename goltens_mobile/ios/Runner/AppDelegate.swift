import UIKit
import Flutter
import flutter_downloader
// Remove: import OneSignalFramework

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    GeneratedPluginRegistrant.register(with: self)

    FlutterDownloaderPlugin.setPluginRegistrantCallback { registry in
      if !registry.hasPlugin("FlutterDownloaderPlugin") {
        FlutterDownloaderPlugin.register(with: registry.registrar(forPlugin: "FlutterDownloaderPlugin")!)
      }
    }

    // OneSignal is now initialized in Flutter only
    print("✅ AppDelegate initialized")

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}