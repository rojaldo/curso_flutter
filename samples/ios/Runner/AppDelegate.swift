import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Google Maps iOS API key.
    // Reemplaza por tu clave real obtenida en:
    // https://console.cloud.google.com/google/maps-apis/credentials
    // Restringe la clave a tu Bundle ID (com.example.sampleApp).
    GMSServices.provideAPIKey("AIZA_SY_REEMPLAZA_P_TU_API_KEY_IOS")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}