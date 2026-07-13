import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de [Polygon] — áreas rellenas y tappeables.
///
/// Dibuja el "Triángulo de las Bermudas" como un polígono cerrado con
/// strokeColor rojo y fillColor amarillo semitransparente.
class PolygonsExample extends StatelessWidget {
  const PolygonsExample({super.key});

  static const LatLng _center = LatLng(25, -72);

  static final Polygon _bermuda = Polygon(
    polygonId: PolygonId('bermuda_triangle'),
    points: const [
      LatLng(25.28, -80.33), // Miami
      LatLng(32.29, -64.79), // Bermuda
      LatLng(18.51, -65.36), // San Juan
      LatLng(25.28, -80.33), // cerrar el polígono
    ],
    strokeColor: Colors.red,
    fillColor: Colors.yellow.withValues(alpha: 0.35),
    strokeWidth: 3,
    consumeTapEvents: true,
    onTap: () => debugPrint('Triángulo tappeado'),
  );

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Polygons — áreas y regiones',
      description:
          'Un Polygon dibuja una forma cerrada rellena. La lista de '
          'points define el perímetro; strokeColor es el borde y '
          'fillColor el relleno (con opacidad). consumeTapEvents permite '
          'capturar taps sobre el área.',
      code: '''Polygon(
  polygonId: PolygonId('area'),
  points: [
    LatLng(25.28, -80.33),
    LatLng(32.29, -64.79),
    LatLng(18.51, -65.36),
    LatLng(25.28, -80.33), // cerrar
  ],
  strokeColor: Colors.red,
  fillColor: Colors.yellow.withValues(alpha: 0.35),
  consumeTapEvents: true,
  onTap: () => debugPrint('tapped'),
)''',
      child: SizedBox(
        height: 380,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _center,
              zoom: 4,
            ),
            polygons: {_bermuda},
          ),
        ),
      ),
    );
  }
}