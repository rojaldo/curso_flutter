import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Tipos de flash disponibles en el paquete camera.
enum FlashOption { auto, on, off }

/// Pide permisos de cámara de forma nativa y retorna la lista de cámaras.
/// Lanza una excepción si el usuario deniega el permiso o no hay cámaras.
Future<List<CameraDescription>> requestCameras() async {
  final cameras = await availableCameras();
  if (cameras.isEmpty) {
    throw StateError('No se encontraron cámaras en el dispositivo.');
  }
  return cameras;
}

/// Resolución de flash a string legible para la UI.
String flashLabel(FlashOption f) {
  switch (f) {
    case FlashOption.auto:
      return 'Auto';
    case FlashOption.on:
      return 'On';
    case FlashOption.off:
      return 'Off';
  }
}

/// Icono Material asociado a cada modo de flash.
IconData flashIcon(FlashOption f) {
  switch (f) {
    case FlashOption.auto:
      return Icons.flash_auto;
    case FlashOption.on:
      return Icons.flash_on;
    case FlashOption.off:
      return Icons.flash_off;
  }
}

/// Mapea nuestro enum al FlashMode del paquete camera.
FlashMode toCameraFlashMode(FlashOption f) {
  switch (f) {
    case FlashOption.auto:
      return FlashMode.auto;
    case FlashOption.on:
      return FlashMode.always;
    case FlashOption.off:
      return FlashMode.off;
  }
}