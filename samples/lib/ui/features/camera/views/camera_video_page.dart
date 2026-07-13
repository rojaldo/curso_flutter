// Ejemplo 3 — Grabación de video.
//
// Flujo:
// 1. Inicializa la cámara con audio habilitado.
// 2. Botón "Empezar" → controller.startVideoRecording().
// 3. Botón "Parar" → controller.stopVideoRecording() → XFile.
// 4. Botón "Guardar" → Gal.putVideo(bytes).
// 5. Botón "Reproducir" → abre VideoPlayer del fichero grabado.

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:sample_app/ui/features/camera/services/camera_utils.dart';
import 'package:video_player/video_player.dart';

class CameraVideoPage extends StatefulWidget {
  const CameraVideoPage({super.key});

  @override
  State<CameraVideoPage> createState() => _CameraVideoPageState();
}

class _CameraVideoPageState extends State<CameraVideoPage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  String? _error;
  bool _recording = false;
  String? _videoPath;
  bool _saving = false;

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
    if (state == AppLifecycleState.inactive && !_recording) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed && !_recording) {
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
          CameraController(back, ResolutionPreset.high, enableAudio: true);
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

  Future<void> _toggleRecording() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      if (_recording) {
        final file = await controller.stopVideoRecording();
        setState(() {
          _recording = false;
          _videoPath = file.path;
        });
      } else {
        await controller.startVideoRecording();
        setState(() {
          _recording = true;
          _videoPath = null;
        });
      }
    } catch (e) {
      _showSnack('Error: $e');
    }
  }

  Future<void> _saveToGallery() async {
    final path = _videoPath;
    if (path == null) return;
    setState(() => _saving = true);
    try {
      await Gal.putVideo(path);
      _showSnack('Video guardado en la galería');
    } catch (e) {
      _showSnack('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _playVideo() {
    final path = _videoPath;
    if (path == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _VideoPlayerPage(path: path)),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cámara — Grabación de video')),
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
              if (_recording)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_manual_record, color: Colors.white),
                        SizedBox(width: 4),
                        Text('REC',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
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
              FilledButton.tonalIcon(
                onPressed: _videoPath == null || _saving ? null : _saveToGallery,
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save_alt),
                label: const Text('Guardar'),
              ),
              FloatingActionButton.large(
                onPressed: _toggleRecording,
                backgroundColor: _recording ? Colors.red : null,
                child: Icon(_recording ? Icons.stop : Icons.videocam),
              ),
              FilledButton.tonalIcon(
                onPressed: _videoPath == null ? null : _playVideo,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Reproducir'),
              ),
            ],
          ),
        ),
      ],
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

class _VideoPlayerPage extends StatefulWidget {
  const _VideoPlayerPage({required this.path});
  final String path;

  @override
  State<_VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<_VideoPlayerPage> {
  late final VideoPlayerController _player;

  @override
  void initState() {
    super.initState();
    _player = VideoPlayerController.file(File(widget.path));
    _player.initialize().then((_) {
      if (!mounted) return;
      _player.setLooping(true);
      _player.play();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_player.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Reproductor')),
      body: Center(
        child: AspectRatio(
          aspectRatio: _player.value.aspectRatio,
          child: VideoPlayer(_player),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _player.value.isPlaying ? _player.pause() : _player.play();
          });
        },
        child: Icon(_player.value.isPlaying ? Icons.pause : Icons.play_arrow),
      ),
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