// Ejemplo 4 — Control de flash y zoom.
//
// Flujo:
// 1. Inicializa la cámara trasera (el zoom óptico/digital solo funciona
//    bien en la trasera).
// 2. Selector de flash: Auto / On / Off (segmented button).
// 3. Zoom: gesture de pinza + slider de 1x a maxZoomLevel.
// 4. El zoom se aplica con controller.setZoomLevel(clamped).

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample_app/ui/features/camera/services/camera_utils.dart';

class CameraFlashZoomPage extends StatefulWidget {
  const CameraFlashZoomPage({super.key});

  @override
  State<CameraFlashZoomPage> createState() => _CameraFlashZoomPageState();
}

class _CameraFlashZoomPageState extends State<CameraFlashZoomPage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  String? _error;
  FlashOption _flash = FlashOption.off;
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _zoom = 1.0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;

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
      final minZoom = await controller.getMinZoomLevel();
      final maxZoom = await controller.getMaxZoomLevel();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _minZoom = minZoom;
        _maxZoom = maxZoom;
        _zoom = 1.0;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _setFlash(FlashOption option) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      await controller.setFlashMode(toCameraFlashMode(option));
      setState(() => _flash = option);
    } catch (e) {
      _showSnack('Flash no soportado: $e');
    }
  }

  Future<void> _applyZoom(double value) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final clamped = value.clamp(_minZoom, _maxZoom);
    try {
      await controller.setZoomLevel(clamped);
      setState(() => _zoom = clamped);
    } catch (_) {
      // Algunos dispositivos rechazan valores intermedios: silencioso.
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cámara — Flash y Zoom')),
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
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: (details) {
              _currentScale = _zoom;
              _baseScale = _zoom;
            },
            onScaleUpdate: (details) {
              if (details.pointerCount < 2) return;
              final newScale = (_baseScale * details.scale)
                  .clamp(_minZoom, _maxZoom);
              if ((newScale - _currentScale).abs() > 0.05) {
                _currentScale = newScale;
                _applyZoom(newScale);
              }
            },
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
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_zoom.toStringAsFixed(1)}x  '
                      '(min ${_minZoom.toStringAsFixed(1)} / '
                      'max ${_maxZoom.toStringAsFixed(1)})',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              SegmentedButton<FlashOption>(
                segments: FlashOption.values
                    .map((e) => ButtonSegment(
                          value: e,
                          icon: Icon(flashIcon(e)),
                          label: Text(flashLabel(e)),
                        ))
                    .toList(),
                selected: {_flash},
                onSelectionChanged: (s) => _setFlash(s.first),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('${_minZoom.toStringAsFixed(1)}x'),
                  Expanded(
                    child: Slider(
                      min: _minZoom,
                      max: _maxZoom,
                      divisions: ((_maxZoom - _minZoom) * 10).round().clamp(1, 100),
                      value: _zoom.clamp(_minZoom, _maxZoom),
                      label: '${_zoom.toStringAsFixed(1)}x',
                      onChanged: _applyZoom,
                    ),
                  ),
                  Text('${_maxZoom.toStringAsFixed(1)}x'),
                ],
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