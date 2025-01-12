import UIKit
import Flutter
import FirebaseCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Add error handling for Firebase initialization
        do {
            if FirebaseApp.app() == nil {
                FirebaseApp.configure()
            }
        } catch let error {
            print("Firebase configuration error: \(error.localizedDescription)")
        }
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}