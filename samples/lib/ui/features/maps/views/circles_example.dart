import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de [Circle] — radios y zonas de cobertura.
///
/// Dibuja círculos concéntricos alrededor de puntos clave usando
/// strokeColor y fillColor semitransparente. Útil para mostrar áreas
/// de cobertura, radios de búsqueda o geofencing.
class CirclesExample extends StatelessWidget {
  const CirclesExample({super.key});

  static const LatLng _madrid = LatLng(40.4168, -3.7038);

  static final Set<Circle> _circles = {
    Circle(
      circleId: const CircleId('center'),
      center: _madrid,
      radius: 2000, // metros
      strokeColor: Colors.blue,
      strokeWidth: 2,
      fillColor: Colors.blue.withValues(alpha: 0.15),
    ),
    Circle(
      circleId: const CircleId('middle'),
      center: _madrid,
      radius: 5000,
      strokeColor: Colors.green,
      strokeWidth: 2,
      fillColor: Colors.green.withValues(alpha: 0.1),
    ),
    Circle(
      circleId: const CircleId('outer'),
      center: _madrid,
      radius: 10000,
      strokeColor: Colors.orange,
      strokeWidth: 2,
      fillColor: Colors.orange.withValues(alpha: 0.05),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Circles — radios y cobertura',
      description:
          'Un Circle dibuja un radio definido en metros alrededor de un '
          'centro LatLng. strokeColor es el borde y fillColor el relleno. '
          'Útil para mostrar zonas de cobertura o geofencing.',
      code: '''Circle(
  circleId: CircleId('cobertura'),
  center: LatLng(40.4168, -3.7038),
  radius: 5000, // metros
  strokeColor: Colors.blue,
  fillColor: Colors.blue.withValues(alpha: 0.15),
  strokeWidth: 2,
)''',
      child: SizedBox(
        height: 360,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _madrid,
              zoom: 11,
            ),
            circles: _circles,
          ),
        ),
      ),
    );
  }
}