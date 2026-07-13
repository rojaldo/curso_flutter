import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de marcadores dinámicos.
///
/// Mantiene un [Set<Marker>] en el estado. Al pulsar el mapa (onLongPress)
/// se añade un marcador en esa posición. Al pulsar el FAB se añade un
/// marcador fijo. Demuestra que GoogleMap reacciona a cambios en markers.
class MarkersExample extends StatefulWidget {
  const MarkersExample({super.key});

  @override
  State<MarkersExample> createState() => _MarkersExampleState();
}

class _MarkersExampleState extends State<MarkersExample> {
  final Set<Marker> _markers = {};
  int _counter = 0;

  static const LatLng _madrid = LatLng(40.4168, -3.7038);

  void _addMarker(LatLng position) {
    _counter++;
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('marker_$_counter'),
          position: position,
          infoWindow: InfoWindow(
            title: 'Marcador #$_counter',
            snippet: '${position.latitude.toStringAsFixed(4)}, '
                '${position.longitude.toStringAsFixed(4)}',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Markers — dinámicos con tap',
      description:
          'Los marcadores se gestionan como un Set<Marker>. Long-press '
          'sobre el mapa añade un marcador en esa posición; el botón fija '
          'uno en Madrid. Cada marcador puede tener un InfoWindow.',
      code: '''final Set<Marker> _markers = {};

GoogleMap(
  markers: _markers, // reconstruye cuando _markers cambia
  onLongPress: (LatLng position) {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId('m_\${DateTime.now().millisecondsSinceEpoch}'),
        position: position,
        infoWindow: InfoWindow(title: 'Nuevo marcador'),
      ));
    });
  },
);''',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Marcadores: ${_markers.length}'),
              FilledButton.icon(
                onPressed: () => _addMarker(_madrid),
                icon: const Icon(Icons.add_location_alt),
                label: const Text('Añadir en Madrid'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _madrid,
                  zoom: 11,
                ),
                markers: _markers,
                onLongPress: _addMarker,
              ),
            ),
          ),
        ],
      ),
    );
  }
}