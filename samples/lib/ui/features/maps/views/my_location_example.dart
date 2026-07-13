import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de [myLocationEnabled] y el botón "mi ubicación".
///
/// En un entorno real requerirías permisos con permission_handler.
/// Aquí, para mantener el ejemplo atomizado, simulamos el permiso con
/// un diálogo de aceptar/denegar y activamos la capa de ubicación.
class MyLocationExample extends StatefulWidget {
  const MyLocationExample({super.key});

  @override
  State<MyLocationExample> createState() => _MyLocationExampleState();
}

class _MyLocationExampleState extends State<MyLocationExample> {
  bool? _permissionGranted;

  static const LatLng _madrid = LatLng(40.4168, -3.7038);

  Future<void> _requestPermission() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso de ubicación'),
        content: const Text(
          'En una app real usarías permission_handler para pedir '
          'ACCESS_FINE_LOCATION. Aquí simulamos el flujo con un diálogo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Denegar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Conceder'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => _permissionGranted = result);
  }

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'My Location — punto azul y permisos',
      description:
          'myLocationEnabled muestra el punto azul de la ubicación del '
          'usuario. Requiere permisos de ubicación (en producción usa '
          'permission_handler). myLocationButtonEnabled muestra el botón '
          'que centra la cámara en el usuario.',
      code: '''// En producción:
// final status = await Permission.locationWhenInUse.request();
// if (status.isGranted) { /* activar capa */ }

GoogleMap(
  initialCameraPosition: CameraPosition(target: LatLng(40.4168, -3.7038)),
  myLocationEnabled: permissionGranted,
  myLocationButtonEnabled: true,
)''',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Permiso:'),
              Text(
                _permissionGranted == null
                    ? 'pendiente'
                    : (_permissionGranted! ? 'concedido' : 'denegado'),
                style: TextStyle(
                  color: _permissionGranted == true
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_permissionGranted != null)
                TextButton(
                  onPressed: _requestPermission,
                  child: const Text('Volver a pedir'),
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
                  zoom: 12,
                ),
                myLocationEnabled: _permissionGranted ?? false,
                myLocationButtonEnabled: _permissionGranted ?? false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}