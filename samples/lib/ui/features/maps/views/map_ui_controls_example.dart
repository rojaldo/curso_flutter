import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de toggles de UI y gestures del mapa.
///
/// Permite activar/desactivar zoom, rotate, tilt, compass, mapToolbar,
/// myLocationButton y traffic. Demuestra que estas propiedades son
/// declarativas: cambias el estado y el mapa se reconstruye.
class MapUiControlsExample extends StatefulWidget {
  const MapUiControlsExample({super.key});

  @override
  State<MapUiControlsExample> createState() => _MapUiControlsExampleState();
}

class _MapUiControlsExampleState extends State<MapUiControlsExample> {
  bool _zoomEnabled = true;
  bool _rotateEnabled = true;
  bool _tiltEnabled = true;
  bool _scrollEnabled = true;
  bool _compassEnabled = true;
  bool _mapToolbarEnabled = true;
  bool _myLocationButtonEnabled = false;
  bool _trafficEnabled = false;

  static const LatLng _madrid = LatLng(40.4168, -3.7038);

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Controles de UI y gestures',
      description:
          'GoogleMap expone toggles para gestures (zoom, rotate, tilt, '
          'scroll) y botones (compass, mapToolbar, myLocationButton). '
          'trafficEnabled añade la capa de tráfico. Todos declarativos.',
      code: '''GoogleMap(
  initialCameraPosition: CameraPosition(target: LatLng(40.4168, -3.7038)),
  zoomGesturesEnabled: true,
  rotateGesturesEnabled: true,
  tiltGesturesEnabled: true,
  scrollGesturesEnabled: true,
  compassEnabled: true,
  mapToolbarEnabled: true,
  myLocationButtonEnabled: false,
  trafficEnabled: false,
)''',
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _toggle('Zoom gestures', _zoomEnabled, (v) => _zoomEnabled = v),
              _toggle(
                'Rotate gestures',
                _rotateEnabled,
                (v) => _rotateEnabled = v,
              ),
              _toggle('Tilt gestures', _tiltEnabled, (v) => _tiltEnabled = v),
              _toggle(
                'Scroll gestures',
                _scrollEnabled,
                (v) => _scrollEnabled = v,
              ),
              _toggle('Compass', _compassEnabled, (v) => _compassEnabled = v),
              _toggle(
                'MapToolbar',
                _mapToolbarEnabled,
                (v) => _mapToolbarEnabled = v,
              ),
              _toggle(
                'MyLocation btn',
                _myLocationButtonEnabled,
                (v) => _myLocationButtonEnabled = v,
              ),
              _toggle('Traffic', _trafficEnabled, (v) => _trafficEnabled = v),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _madrid,
                  zoom: 11,
                ),
                zoomGesturesEnabled: _zoomEnabled,
                rotateGesturesEnabled: _rotateEnabled,
                tiltGesturesEnabled: _tiltEnabled,
                scrollGesturesEnabled: _scrollEnabled,
                compassEnabled: _compassEnabled,
                mapToolbarEnabled: _mapToolbarEnabled,
                myLocationButtonEnabled: _myLocationButtonEnabled,
                trafficEnabled: _trafficEnabled,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
      showCheckmark: true,
    );
  }
}