import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de [InfoWindow] en marcadores.
///
/// Muestra cómo configurar title, snippet y onTap del InfoWindow, y cómo
/// abrirlo programáticamente con showInfoWindow del controlador.
class InfoWindowExample extends StatefulWidget {
  const InfoWindowExample({super.key});

  @override
  State<InfoWindowExample> createState() => _InfoWindowExampleState();
}

class _InfoWindowExampleState extends State<InfoWindowExample> {
  GoogleMapController? _controller;
  static const LatLng _madrid = LatLng(40.4168, -3.7038);

  static final MarkerId _puertaDelSolId = MarkerId('puerta_del_sol');

  final Set<Marker> _markers = {
    Marker(
      markerId: _puertaDelSolId,
      position: const LatLng(40.4168, -3.7038),
      infoWindow: const InfoWindow(
        title: 'Puerta del Sol',
        snippet: 'Kilómetro cero de las carreteras radiales de España.',
      ),
      onTap: () => debugPrint('Marker tappeado'),
    ),
  };

  void _showInfo() {
    _controller?.showMarkerInfoWindow(_puertaDelSolId);
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'InfoWindow — título, snippet y onTap',
      description:
          'Cada Marker puede tener un InfoWindow con title y snippet. '
          'Se abre al tocar el marcador o programáticamente con '
          'showMarkerInfoWindow(markerId).',
      code: '''Marker(
  markerId: MarkerId('puerta_del_sol'),
  position: LatLng(40.4168, -3.7038),
  infoWindow: InfoWindow(
    title: 'Puerta del Sol',
    snippet: 'Kilómetro cero de las carreteras radiales.',
    onTap: () => debugPrint('InfoWindow tappeado'),
  ),
);

// Abrir programáticamente:
_controller.showMarkerInfoWindow(MarkerId('puerta_del_sol'));''',
      child: Column(
        children: [
          FilledButton.icon(
            onPressed: _showInfo,
            icon: const Icon(Icons.info_outline),
            label: const Text('Mostrar InfoWindow'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _madrid,
                  zoom: 14,
                ),
                markers: _markers,
                onMapCreated: (c) => _controller = c,
              ),
            ),
          ),
        ],
      ),
    );
  }
}