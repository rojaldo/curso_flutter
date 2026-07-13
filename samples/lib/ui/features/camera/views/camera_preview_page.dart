// Ejemplo 1 — Vista previa de la cámara.
//
// Demuestra el flujo básico del paquete `camera`:
// 1. Pedir la lista de cámaras disponibles con availableCameras().
// 2. Crear un CameraController con una de ellas.
// 3. Inicializar el controlador (abre el hardware de la cámara).
// 4. Mostrar el preview con CameraPreview.
// 5. Botón para alternar entre cámara frontal y trasera.

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample_app/ui/features/camera/services/camera_utils.dart';

class CameraPreviewPage extends StatefulWidget {
  const CameraPreviewPage({super.key});

  @override
  State<CameraPreviewPage> createState() => _CameraPreviewPageState();
}

class _CameraPreviewPageState extends State<CameraPreviewPage>
    with WidgetsBindingObserver {
  List<CameraDescription>? _cameras;
  CameraController? _controller;
  int _cameraIndex = 0;
  String? _error;
  bool _initializing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupCameras();
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
      _initController(_cameras![_cameraIndex]);
    }
  }

  Future<void> _setupCameras() async {
    try {
      final cameras = await requestCameras();
      final index = cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      final startIndex = index >= 0 ? index : 0;
      setState(() {
        _cameras = cameras;
        _cameraIndex = startIndex;
      });
      await _initController(cameras[startIndex]);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _initController(CameraDescription camera) async {
    if (_initializing) return;
    _initializing = true;
    final previous = _controller;
    _controller = null;
    await previous?.dispose();

    final controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    try {
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      _initializing = false;
    }
  }

  Future<void> _switchCamera() async {
    final cameras = _cameras;
    if (cameras == null || cameras.length < 2) return;
    final next = (_cameraIndex + 1) % cameras.length;
    setState(() => _cameraIndex = next);
    await _initController(cameras[next]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cámara — Vista previa')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _MessageOverlay(
        icon: Icons.error_outline,
        message: _error!,
        actionLabel: 'Reintentar',
        onAction: () {
          setState(() => _error = null);
          _setupCameras();
        },
      );
    }

    final cameras = _cameras;
    if (cameras == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: _aspectRatio(controller),
              child: ClipRect(
                child: OverflowBox(
                  maxWidth: double.infinity,
                  maxHeight: double.infinity,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width /
                        _aspectRatio(controller),
                    child: CameraPreview(controller),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _cameras![_cameraIndex].lensDirection ==
                        CameraLensDirection.front
                    ? Icons.face
                    : Icons.camera_rear,
              ),
              const SizedBox(width: 8),
              Text(_cameraLabel(_cameras![_cameraIndex])),
              const SizedBox(width: 16),
              FilledButton.tonalIcon(
                onPressed: cameras.length < 2 ? null : _switchCamera,
                icon: const Icon(Icons.cameraswitch),
                label: const Text('Cambiar cámara'),
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
    // previewSize viene en coords nativas; hay que invertir según orientación.
    final isPortrait =
        c.value.deviceOrientation == DeviceOrientation.portraitUp ||
            c.value.deviceOrientation == DeviceOrientation.portraitDown;
    final ratio = size.width / size.height;
    return isPortrait ? 1 / ratio : ratio;
  }

  String _cameraLabel(CameraDescription c) {
    switch (c.lensDirection) {
      case CameraLensDirection.front:
        return 'Frontal';
      case CameraLensDirection.back:
        return 'Trasera';
      case CameraLensDirection.external:
        return 'Externa';
    }
  }
}

class _MessageOverlay extends StatelessWidget {
  const _MessageOverlay({
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