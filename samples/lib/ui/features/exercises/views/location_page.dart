// Ejercicio de localización con geolocator.
//
// Flujo:
// 1. Comprueba si el servicio de localización del dispositivo está activo.
// 2. Comprueba el permiso de la app con Geolocator.checkPermission().
//    - Si está denegado (denied), pide permiso con requestPermission().
//    - Si está denegado para siempre (deniedForever), ofrece abrir
//      Ajustes del sistema para que el usuario lo habilite manualmente.
// 3. Cuando hay permiso, obtiene la posición con getCurrentPosition()
//    y muestra TODOS los campos del objeto Position en pantalla.

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  // Estado del flujo de permisos y localización.
  bool? _serviceEnabled;
  LocationPermission _permission = LocationPermission.unableToDetermine;
  Position? _position;
  String? _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  /// Paso 1+2: comprueba servicio y permiso sin pedirlos todavía.
  Future<void> _checkStatus() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final permission = await Geolocator.checkPermission();
    if (!mounted) return;
    setState(() {
      _serviceEnabled = serviceEnabled;
      _permission = permission;
    });
    // Si ya tenemos servicio activo y permiso concedido, va a por la posición.
    if (serviceEnabled &&
        (_permission == LocationPermission.whileInUse ||
            _permission == LocationPermission.always)) {
      _fetchPosition();
    }
  }

  /// Pide permiso al usuario (LocationPermission.denied → requestPermission).
  Future<void> _requestPermission() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      setState(() {
        _serviceEnabled = false;
        _isLoading = false;
      });
      return;
    }

    final permission = await Geolocator.requestPermission();
    if (!mounted) return;
    setState(() {
      _permission = permission;
      _isLoading = false;
    });

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      await _fetchPosition();
    }
  }

  /// Paso 3: obtiene la posición actual y la guarda en el estado.
  Future<void> _fetchPosition() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (!mounted) return;
      setState(() {
        _position = position;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al obtener la posición: $e';
        _isLoading = false;
      });
    }
  }

  /// Abre los ajustes de la app cuando el permiso está deniedForever.
  Future<void> _openAppSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron abrir los ajustes: $e')),
      );
    }
  }

  /// Abre los ajustes de localización del dispositivo cuando el servicio está off.
  Future<void> _openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron abrir los ajustes: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Localización')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 16),
            _buildActionArea(),
            const SizedBox(height: 16),
            if (_position != null) _buildPositionCard(_position!),
          ],
        ),
      ),
    );
  }

  /// Tarjeta con el estado del servicio y del permiso.
  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estado', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _StatusRow(
              label: 'Servicio de localización',
              value: _serviceEnabled == null
                  ? 'comprobando…'
                  : (_serviceEnabled! ? 'Activado' : 'Desactivado'),
              ok: _serviceEnabled == true,
            ),
            const SizedBox(height: 8),
            _StatusRow(
              label: 'Permiso de la app',
              value: _permissionLabel(_permission),
              ok: _permission == LocationPermission.whileInUse ||
                  _permission == LocationPermission.always,
            ),
          ],
        ),
      ),
    );
  }

  /// Zona de acción: depende del estado del servicio y del permiso.
  Widget _buildActionArea() {
    if (_serviceEnabled == false) {
      return _ActionCard(
        icon: Icons.location_off,
        title: 'Localización desactivada',
        message:
            'El servicio de localización del dispositivo está desactivado. '
            'Actívalo en Ajustes para poder usar este ejercicio.',
        actionLabel: 'Abrir ajustes de localización',
        onAction: _openLocationSettings,
      );
    }

    if (_permission == LocationPermission.deniedForever) {
      return _ActionCard(
        icon: Icons.privacy_tip,
        title: 'Permiso denegado permanentemente',
        message:
            'Has denegado el permiso de localización para siempre. '
            'Habilítalo manualmente en los Ajustes de la app.',
        actionLabel: 'Abrir ajustes de la app',
        onAction: _openAppSettings,
      );
    }

    if (_permission == LocationPermission.denied ||
        _permission == LocationPermission.unableToDetermine) {
      return _ActionCard(
        icon: Icons.location_searching,
        title: 'Permiso no concedido',
        message:
            'Esta app necesita permiso de localización para mostrar tu '
            'posición actual. Pulsa para concederlo.',
        actionLabel: 'Conceder permiso',
        onAction: _requestPermission,
      );
    }

    // Permiso concedido.
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Obteniendo posición…'),
              ],
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return _ActionCard(
        icon: Icons.error_outline,
        title: 'Error',
        message: _error!,
        actionLabel: 'Reintentar',
        onAction: _fetchPosition,
      );
    }

    return FilledButton.icon(
      onPressed: _fetchPosition,
      icon: const Icon(Icons.my_location),
      label: const Text('Actualizar posición'),
    );
  }

  /// Tarjeta con TODOS los campos del objeto Position.
  Widget _buildPositionCard(Position p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Objeto Position — todos los campos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _PositionField(label: 'latitude', value: '${p.latitude}'),
            _PositionField(label: 'longitude', value: '${p.longitude}'),
            _PositionField(
              label: 'timestamp',
              value: p.timestamp.toIso8601String(),
            ),
            _PositionField(label: 'accuracy', value: '${p.accuracy} m'),
            _PositionField(label: 'altitude', value: '${p.altitude} m'),
            _PositionField(
              label: 'altitudeAccuracy',
              value: '${p.altitudeAccuracy} m',
            ),
            _PositionField(label: 'heading', value: '${p.heading}°'),
            _PositionField(
              label: 'headingAccuracy',
              value: '${p.headingAccuracy}°',
            ),
            _PositionField(label: 'speed', value: '${p.speed} m/s'),
            _PositionField(
              label: 'speedAccuracy',
              value: '${p.speedAccuracy} m/s',
            ),
            _PositionField(
              label: 'floor',
              value: p.floor == null ? 'null' : '${p.floor}',
            ),
            _PositionField(label: 'isMocked', value: '${p.isMocked}'),
          ],
        ),
      ),
    );
  }

  /// Etiqueta legible para cada valor de LocationPermission.
  String _permissionLabel(LocationPermission p) {
    switch (p) {
      case LocationPermission.always:
        return 'Siempre (always)';
      case LocationPermission.whileInUse:
        return 'En uso (whileInUse)';
      case LocationPermission.denied:
        return 'Denegado (denied)';
      case LocationPermission.deniedForever:
        return 'Denegado para siempre (deniedForever)';
      case LocationPermission.unableToDetermine:
        return 'No determinado';
    }
  }
}

/// Fila de estado con semáforo visual (verde/rojo).
class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value, required this.ok});

  final String label;
  final String value;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final color = ok
        ? Colors.green
        : (value.contains('comprobando') ? Colors.grey : Colors.orange);
    return Row(
      children: [
        Icon(ok ? Icons.check_circle : Icons.error, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Text(value),
      ],
    );
  }
}

/// Tarjeta de acción reutilizable: icono + título + mensaje + botón.
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.settings),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila "campo: valor" monoespaciada para los datos del Position.
class _PositionField extends StatelessWidget {
  const _PositionField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: SelectableText.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: value),
            ],
          ),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
        ),
      ),
    );
  }
}