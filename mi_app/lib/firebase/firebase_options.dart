import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/services.dart' show TargetPlatform;

/// Opciones de inicialización de Firebase.
///
/// - En **web** no existen `google-services.json` ni `GoogleService-Info.plist`,
///   hay que pasar [FirebaseOptions] explícitamente a `initializeApp`.
/// - En Android/iOS/macOS los configs nativos ya están colocados en el proyecto
///   y `initializeApp()` sin argumentos los lee automáticamente.
///
/// Estas claves públicas son las del proyecto `mi-app-flutter-demo` (app web
/// registrada en Firebase Console). No son secretas: cualquier cliente web las
/// termina viendo. La seguridad se controla con las reglas de Firebase.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        // Los configs nativos se cargan solos; aquí no se llega porque
        // main() solo llama a initializeApp() con estas opciones en web.
        throw UnsupportedError(
          'DefaultFirebaseOptions.currentPlatform solo se usa en web. '
          'En nativo usa Firebase.initializeApp() sin argumentos.',
        );
      default:
        throw UnsupportedError(
          'Firebase no está soportado en esta plataforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBitwlUlqN9x8wQa-v-l_aIXySFLdePzps',
    appId: '1:515751052950:web:0cd0b9654634ea9b9d64b7',
    messagingSenderId: '515751052950',
    projectId: 'mi-app-flutter-demo',
    authDomain: 'mi-app-flutter-demo.firebaseapp.com',
    storageBucket: 'mi-app-flutter-demo.firebasestorage.app',
  );
}