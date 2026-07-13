// Ejemplo 2 — Captura de foto.
//
// Flujo:
// 1. Inicializa la cámara trasera (la frontal si no hay trasera).
// 2. Botón "Capturar" → controller.takePicture() → XFile temporal.
// 3. Botón "Guardar en galería" → Gal.putImage(bytes).
// 4. Muestra thumbnail de la última foto capturada.

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:sample_app/ui/features/camera/services/camera_utils.dart';

class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({super.key});

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  String? _error;
  String? _lastPhotoPath;
  bool _saving = false;
  String? _savedHint;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setup();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setup();
    }
  }

  Future<void> _setup() async {
    try {
      final cameras = await requestCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller =
          CameraController(back, ResolutionPreset.high, enableAudio: false);
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

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      final file = await controller.takePicture();
      setState(() {
        _lastPhotoPath = file.path;
        _savedHint = null;
      });
    } catch (e) {
      _showSnack('Error al capturar: $e');
    }
  }

  Future<void> _saveToGallery() async {
    final path = _lastPhotoPath;
    if (path == null) return;
    setState(() => _saving = true);
    try {
      final bytes = await File(path).readAsBytes();
      await Gal.putImageBytes(bytes, name: 'sample_app_${DateTime.now().millisecondsSinceEpoch}');
      setState(() => _savedHint = 'Guardado en la galería');
      _showSnack('Foto guardada en la galería');
    } catch (e) {
      _showSnack('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cámara — Captura de foto')),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton.icon(
                onPressed: _saving ? null : _saveToGallery,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_alt),
                label: const Text('Guardar en galería'),
              ),
              FloatingActionButton.large(
                onPressed: _capture,
                child: const Icon(Icons.camera),
              ),
              if (_savedHint != null)
                const Icon(Icons.check_circle, color: Colors.green)
              else
                const SizedBox(width: 56),
            ],
          ),
        ),
      ],
    );
  }

  void _showFullPhoto(BuildContext context, String path) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullPhotoPage(path: path),
      ),
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
      appBar: AppBar(title: const Text('Foto capturada')),
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