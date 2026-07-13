import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de [Polyline] para dibujar rutas.
///
/// Dibuja la ruta Southampton → Cobh → sitio del naufragio del Titanic
/// usando geodesic para seguir la curvatura terrestre, con caps redondos
/// y juntas redondas.
class PolylinesExample extends StatelessWidget {
  const PolylinesExample({super.key});

  static const LatLng _start = LatLng(50.90, -1.41); // Southampton

  static final Polyline _titanicRoute = const Polyline(
    polylineId: PolylineId('titanic_route'),
    points: [
      LatLng(50.90, -1.41), // Southampton
      LatLng(49.65, -1.60), // Cherbourg
      LatLng(49.77, -6.71), // Queenstown (Cobh)
      LatLng(51.83, -8.28),
      LatLng(50.96, -8.58),
      LatLng(41.75, -49.90), // Wreck site
    ],
    width: 5,
    color: Colors.red,
    geodesic: true, // Sigue la curvatura de la Tierra
    startCap: Cap.roundCap,
    endCap: Cap.roundCap,
    jointType: JointType.round,
    consumeTapEvents: true,
  );

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Polylines — rutas y caminos',
      description:
          'Una Polyline conecta una lista de LatLng. geodesic hace que '
          'la línea siga la curvatura terrestre (importante para rutas '
          'largas). width, color, startCap, endCap y jointType controlan '
          'el estilo.',
      code: '''Polyline(
  polylineId: PolylineId('ruta'),
  points: [LatLng(50.90, -1.41), LatLng(41.75, -49.90)],
  width: 5,
  color: Colors.red,
  geodesic: true, // curvatura terrestre
  startCap: Cap.roundCap,
  endCap: Cap.roundCap,
  jointType: JointType.round,
  consumeTapEvents: true,
  onTap: () => debugPrint('ruta tappeada'),
)''',
      child: SizedBox(
        height: 380,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _start,
              zoom: 4,
            ),
            polylines: {_titanicRoute},
          ),
        ),
      ),
    );
  }
}