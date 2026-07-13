import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de los [MapType] disponibles en Google Maps.
///
/// El usuario puede alternar entre normal, satellite, terrain y hybrid
/// usando botones de segmento. Demuestra que mapType es una propiedad
/// declarativa: al cambiar el estado, Flutter reconstruye el mapa.
class MapTypeExample extends StatefulWidget {
  const MapTypeExample({super.key});

  @override
  State<MapTypeExample> createState() => _MapTypeExampleState();
}

class _MapTypeExampleState extends State<MapTypeExample> {
  MapType _mapType = MapType.normal;

  static const LatLng _madrid = LatLng(40.4168, -3.7038);

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'MapType — normal, satellite, terrain, hybrid',
      description:
          'La propiedad mapType cambia el estilo del mapa. Al ser '
          'declarativa, basta con cambiar el estado y el mapa se '
          'reconstruye con el nuevo tipo.',
      code: '''GoogleMap(
  initialCameraPosition: CameraPosition(target: LatLng(40.4168, -3.7038)),
  mapType: MapType.satellite, // .normal | .terrain | .hybrid
)''',
      child: Column(
        children: [
          SegmentedButton<MapType>(
            segments: const [
              ButtonSegment(value: MapType.normal, label: Text('Normal')),
              ButtonSegment(value: MapType.satellite, label: Text('Satélite')),
              ButtonSegment(value: MapType.terrain, label: Text('Terrain')),
              ButtonSegment(value: MapType.hybrid, label: Text('Hybrid')),
            ],
            selected: {_mapType},
            onSelectionChanged: (selection) =>
                setState(() => _mapType = selection.first),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _madrid,
                  zoom: 10,
                ),
                mapType: _mapType,
              ),
            ),
          ),
        ],
      ),
    );
  }
}