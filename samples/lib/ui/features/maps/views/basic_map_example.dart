import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico del widget [GoogleMap] más básico.
///
/// Muestra cómo instanciar un mapa centrado en una posición inicial
/// usando [CameraPosition] y [LatLng]. Es el punto de partida: sin
/// marcadores, sin overlays, solo el mapa.
class BasicMapExample extends StatelessWidget {
  const BasicMapExample({super.key});

  // Posición inicial: Madrid, España.
  static const LatLng _madrid = LatLng(40.4168, -3.7038);

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Mapa básico',
      description:
          'El widget GoogleMap requiere al menos una posición inicial de '
          'cámara (CameraPosition). Aquí centramos el mapa en Madrid con '
          'zoom 10. Todo lo demás (marcadores, polylines, etc.) se añade '
          'como propiedades opcionales.',
      code: '''import 'package:google_maps_flutter/google_maps_flutter.dart';

GoogleMap(
  initialCameraPosition: CameraPosition(
    target: LatLng(40.4168, -3.7038), // Madrid
    zoom: 10,
  ),
)''',
      child: SizedBox(
        height: 320,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: const GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _madrid,
              zoom: 10,
            ),
          ),
        ),
      ),
    );
  }
}