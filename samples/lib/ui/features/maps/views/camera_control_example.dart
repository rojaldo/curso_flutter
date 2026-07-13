import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de control programático de la cámara.
///
/// Obtiene el [GoogleMapController] desde el callback [onMapCreated] y
/// muestra dos botones: uno salta instantáneamente (moveCamera) y otro
/// anima suavemente (animateCamera) a una nueva posición.
class CameraControlExample extends StatefulWidget {
  const CameraControlExample({super.key});

  @override
  State<CameraControlExample> createState() => _CameraControlExampleState();
}

class _CameraControlExampleState extends State<CameraControlExample> {
  GoogleMapController? _controller;

  static const LatLng _madrid = LatLng(40.4168, -3.7038);
  static const LatLng _barcelona = LatLng(41.3851, 2.1734);

  void _jump() {
    _controller?.moveCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(target: _barcelona, zoom: 12),
      ),
    );
  }

  void _animate() {
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: _barcelona,
          zoom: 12,
          bearing: 270, // heading en grados
          tilt: 30, // perspectiva 3D
        ),
      ),
    );
  }

  void _reset() {
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(target: _madrid, zoom: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Cámara — moveCamera vs animateCamera',
      description:
          'El controlador se obtiene en onMapCreated. moveCamera salta '
          'instantáneamente; animateCamera hace una transición suave '
          '(puede incluir bearing y tilt para una vista 3D).',
      code: '''GoogleMapController? _controller;

GoogleMap(
  initialCameraPosition: CameraPosition(target: LatLng(40.4168, -3.7038)),
  onMapCreated: (controller) => _controller = controller,
);

// Salto instantáneo:
_controller.moveCamera(
  CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(41.3851, 2.1734), zoom: 12)),
);

// Animación suave con bearing y tilt:
_controller.animateCamera(
  CameraUpdate.newCameraPosition(CameraPosition(
    target: LatLng(41.3851, 2.1734),
    zoom: 12,
    bearing: 270,
    tilt: 30,
  )),
);''',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton.icon(
                onPressed: _jump,
                icon: const Icon(Icons.flash_on),
                label: const Text('Saltar'),
              ),
              FilledButton.icon(
                onPressed: _animate,
                icon: const Icon(Icons.animation),
                label: const Text('Animar'),
              ),
              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.replay),
                label: const Text('Reset'),
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
                  zoom: 10,
                ),
                onMapCreated: (controller) => _controller = controller,
              ),
            ),
          ),
        ],
      ),
    );
  }
}