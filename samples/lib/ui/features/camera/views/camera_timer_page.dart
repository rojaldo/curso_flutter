// Ejemplo 5 — Temporizador (selfie).
//
// Flujo:
// 1. Inicializa cámara (preferentemente frontal para selfies).
// 2. Selector de duración: 3 / 5 / 10 segundos.
// 3. Botón "Iniciar" → cuenta atrás visible en pantalla → captura automática.
// 4. Se puede cancelar durante la cuenta atrás.
// 5. Muestra thumbnail de la foto capturada y botón para guardar en galería.

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:sample_app/ui/features/camera/services/camera_utils.dart';

class CameraTimerPage extends StatefulWidget {
  const CameraTimerPage({super.key});

  @override
  State<CameraTimerPage> createState() => _CameraTimerPageState();
}

class _CameraTimerPageState extends State<CameraTimerPage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  String? _error;
  int _duration = 3;
  int _remaining = 0;
  Timer? _timer;
  bool _counting = false;
  String? _lastPhotoPath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setup();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive && !_counting) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed && !_counting) {
      _setup();
    }
  }

  Future<void> _setup() async {
    try {
      final cameras = await requestCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller =
          CameraController(front, ResolutionPreset.high, enableAudio: false);
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  void _startCountdown() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _counting) {
      return;
    }
    setState(() {
      _counting = true;
      _remaining = _duration;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _remaining -= 1);
      if (_remaining <= 0) {
        t.cancel();
        await _capture();
        setState(() => _counting = false);
      }
    });
  }

  void _cancelCountdown() {
    _timer?.cancel();
    setState(() {
      _counting = false;
      _remaining = 0;
    });
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      setState(() => _lastPhotoPath = file.path);
    } catch (e) {
      _showSnack('Error al capturar: $e');
    }
  }

  Future<void> _saveToGallery() async {
    final path = _lastPhotoPath;
    if (path == null) return;
    try {
      final bytes = await File(path).readAsBytes();
      await Gal.putImageBytes(bytes,
          name: 'sample_app_timer_${DateTime.now().millisecondsSinceEpoch}');
      _showSnack('Foto guardada en la galería');
    } catch (e) {
      _showSnack('Error al guardar: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cámara — Temporizador')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _CenterMessage(
        icon: Icons.error_outline,
        message: _error!,
        actionLabel: 'Reintentar',
        onAction: () {
          setState(() => _error = null);
          _setup();
        },
      );
    }
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: _aspectRatio(controller),
                  child: ClipRect(
                    child: OverflowBox(
                      maxWidth: double.infinity,
                      maxHeight: double.infinity,
                      child: CameraPreview(controller),
                    ),
                  ),
                ),
              ),
              if (_counting)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_remaining',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (_lastPhotoPath != null)
                Positioned(
                  right: 12,
                  top: 12,
                  child: GestureDetector(
                    onTap: () => _showFullPhoto(context, _lastPhotoPath!),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_lastPhotoPath!),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 3, label: Text('3s')),
                  ButtonSegment(value: 5, label: Text('5s')),
                  ButtonSegment(value: 10, label: Text('10s')),
                ],
                selected: {_duration},
                onSelectionChanged: (s) => setState(() => _duration = s.first),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _lastPhotoPath == null ? null : _saveToGallery,
                    icon: const Icon(Icons.save_alt),
                    label: const Text('Guardar'),
                  ),
                  if (_counting)
                    FilledButton.icon(
                      onPressed: _cancelCountdown,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancelar'),
                    )
                  else
                    FilledButton.icon(
                      onPressed: _startCountdown,
                      icon: const Icon(Icons.timer),
                      label: const Text('Iniciar'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFullPhoto(BuildContext context, String path) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _FullPhotoPage(path: path)),
    );
  }

  double _aspectRatio(CameraController c) {
    final size = c.value.previewSize;
    if (size == null) return 1;
    final isPortrait =
        c.value.deviceOrientation == DeviceOrientation.portraitUp ||
            c.value.deviceOrientation == DeviceOrientation.portraitDown;
    final ratio = size.width / size.height;
    return isPortrait ? 1 / ratio : ratio;
  }
}

class _FullPhotoPage extends StatelessWidget {
  const _FullPhotoPage({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foto')),
      body: Center(child: Image.file(File(path))),
    );
  }
}

class _CenterMessage extends StatelessWidget {
  const _CenterMessage({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}