import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de estilo de mapa mediante JSON y callback de cámara.
///
/// Aplica un estilo oscuro (night mode) embebido como string JSON usando
/// el parámetro `style` del widget GoogleMap. Demuestra el callback
/// onCameraMove para trackear la cámara en tiempo real.
///
/// Genera tu propio estilo en https://mapstyle.withgoogle.com/
/// Alternativa en producción: `cloudMapId` para gestionar estilos desde
/// Google Cloud Console sin actualizar la app.
class MapStylingExample extends StatefulWidget {
  const MapStylingExample({super.key});

  @override
  State<MapStylingExample> createState() => _MapStylingExampleState();
}

class _MapStylingExampleState extends State<MapStylingExample> {
  CameraPosition? _currentPosition;

  static const LatLng _madrid = LatLng(40.4168, -3.7038);

  // Estilo "night mode" simplificado. En producción se usan JSON completos
  // generados con https://mapstyle.withgoogle.com/
  static const String _darkStyle = '''
[
  { "elementType": "geometry", "stylers": [ { "color": "#242f3e" } ] },
  { "elementType": "labels.text.stroke", "stylers": [ { "color": "#242f3e" } ] },
  { "elementType": "labels.text.fill", "stylers": [ { "color": "#746855" } ] },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [ { "color": "#38414e" } ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [ { "color": "#9ca5b3" } ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [ { "color": "#17263c" } ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [ { "color": "#515c6d" } ]
  }
]
''';

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Estilos de mapa (JSON) + cámara',
      description:
          'El parámetro style aplica un JSON de estilos embebido en el '
          'widget (generado en mapstyle.withgoogle.com). Aquí usamos un '
          'dark style minimal. Además trackeamos la cámara con '
          'onCameraMove. En producción puedes usar cloudMapId para '
          'gestionar estilos desde Google Cloud Console sin actualizar '
          'la app.',
      code: '''GoogleMap(
  initialCameraPosition: CameraPosition(target: LatLng(40.4168, -3.7038)),
  style: r\'\'\'
[ { "elementType": "geometry", "stylers": [ { "color": "#242f3e" } ] }, ... ]
\'\'\',
  onCameraMove: (position) {
    // Se llama en cada frame mientras mueves la cámara.
    print(position.target);
  },
)

// Alternativa: estilo gestionado en Cloud Console.
GoogleMap(cloudMapId: 'YOUR_MAP_ID');''',
      child: Column(
        children: [
          if (_currentPosition != null)
            Text(
              'Cámara: ${_currentPosition!.target.latitude.toStringAsFixed(4)}, '
              '${_currentPosition!.target.longitude.toStringAsFixed(4)} '
              '(zoom ${_currentPosition!.zoom.toStringAsFixed(1)})',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          const SizedBox(height: 12),
          SizedBox(
            height: 320,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _madrid,
                  zoom: 12,
                ),
                style: _darkStyle,
                onCameraMove: (position) =>
                    setState(() => _currentPosition = position),
              ),
            ),
          ),
        ],
      ),
    );
  }
}