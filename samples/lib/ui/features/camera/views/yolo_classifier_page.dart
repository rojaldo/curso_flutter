// Ejemplo 6 — Clasificación de objetos con YOLOv8s (TFLite).
//
// Flujo:
// 1. Carga el modelo assets/models/yolov8s.tflite al iniciar.
// 2. Inicializa la cámara trasera con startImageStream.
// 3. Por cada frame: decodifica → resize 640×640 → inferencia → detecciones.
// 4. Dibuja un overlay con CustomPainter sobre el preview mostrando
//    bounding boxes + etiqueta + confianza.
//
// Notas de rendimiento:
// - Se usa ResolutionPreset.low para reducir el coste de cada frame.
// - Se salta frames mientras una inferencia está en curso (busy flag).
// - Las detecciones se escalan del espacio 640×640 al espacio del preview.

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:sample_app/ui/features/camera/services/camera_utils.dart';
import 'package:sample_app/ui/features/camera/services/yolo_classifier.dart';

class YoloClassifierPage extends StatefulWidget {
  const YoloClassifierPage({super.key});

  @override
  State<YoloClassifierPage> createState() => _YoloClassifierPageState();
}

class _YoloClassifierPageState extends State<YoloClassifierPage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  String? _error;
  final YoloClassifier _yolo = YoloClassifier();
  bool _modelReady = false;
  bool _busy = false;
  List<YoloDetection> _detections = const [];
  double _fps = 0;
  DateTime? _lastFrameTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.stopImageStream();
    _controller?.dispose();
    _yolo.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.stopImageStream();
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setupCamera();
    }
  }

  Future<void> _bootstrap() async {
    try {
      await _yolo.load();
      if (!mounted) return;
      setState(() => _modelReady = true);
      await _setupCamera();
    } on StateError catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await requestCameras();
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller =
          CameraController(back, ResolutionPreset.low, enableAudio: false);
      await controller.initialize();
      await controller.startImageStream(_onFrame);
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

  Future<void> _onFrame(CameraImage image) async {
    if (_busy || !_modelReady) return;
    _busy = true;
    try {
      final inputImage = _convertToImage(image);
      if (inputImage == null) {
        _busy = false;
        return;
      }
      final detections = _yolo.detect(inputImage);
      final now = DateTime.now();
      if (_lastFrameTime != null) {
        final dt = now.difference(_lastFrameTime!).inMilliseconds;
        if (dt > 0) _fps = 1000.0 / dt;
      }
      _lastFrameTime = now;
      if (!mounted) return;
      setState(() => _detections = detections);
    } catch (_) {
      // Ignoramos frames fallidos: la cámara es ruidosa.
    } finally {
      _busy = false;
    }
  }

  /// Convierte un CameraImage (YUV420 en Android, BGRA8888 en iOS) a img.Image.
  img.Image? _convertToImage(CameraImage image) {
    try {
      if (image.format.group == ImageFormatGroup.yuv420) {
        return _yuv420ToRgb(image);
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        return _bgraToRgb(image);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  img.Image _yuv420ToRgb(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;
    final uvRowStride = image.planes[1].bytesPerRow;
    final uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

    final out = img.Image(width: width, height: height);
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final yIdx = y * width + x;
        final uvIdx = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;
        final yVal = yPlane[yIdx];
        final uVal = uPlane[uvIdx] - 128;
        final vVal = vPlane[uvIdx] - 128;
        final r = (yVal + 1.402 * vVal).clamp(0, 255).toInt();
        final g = (yVal - 0.344 * uVal - 0.714 * vVal).clamp(0, 255).toInt();
        final b = (yVal + 1.772 * uVal).clamp(0, 255).toInt();
        out.setPixelRgba(x, y, r, g, b, 255);
      }
    }
    return out;
  }

  img.Image _bgraToRgb(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final bytes = image.planes[0].bytes;
    final bytesPerRow = image.planes[0].bytesPerRow;
    final out = img.Image(width: width, height: height);
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final idx = y * bytesPerRow + x * 4;
        final b = bytes[idx];
        final g = bytes[idx + 1];
        final r = bytes[idx + 2];
        out.setPixelRgba(x, y, r, g, b, 255);
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cámara — YOLOv8s')),
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
          _bootstrap();
        },
      );
    }
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final previewSize = controller.value.previewSize;
    final screenSize = MediaQuery.of(context).size;
    final previewAspectRatio = previewSize != null
        ? previewSize.height / previewSize.width
        : 1 / screenSize.aspectRatio;

    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: previewAspectRatio,
            child: ClipRect(
              child: OverflowBox(
                maxWidth: double.infinity,
                maxHeight: double.infinity,
                child: CameraPreview(controller),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _DetectionOverlay(
                detections: _detections,
                modelInputSize: 640,
                previewSize: previewSize,
                screenSize: screenSize,
                isFrontCamera: false,
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: _HudCard(
            fps: _fps,
            count: _detections.length,
            modelReady: _modelReady,
          ),
        ),
      ],
    );
  }
}

class _HudCard extends StatelessWidget {
  const _HudCard({
    required this.fps,
    required this.count,
    required this.modelReady,
  });

  final double fps;
  final int count;
  final bool modelReady;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black54,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              modelReady ? Icons.check_circle : Icons.hourglass_top,
              color: modelReady ? Colors.green : Colors.amber,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              modelReady ? 'YOLOv8s listo' : 'Cargando modelo…',
              style: const TextStyle(color: Colors.white),
            ),
            const Spacer(),
            Text(
              '${fps.toStringAsFixed(1)} FPS · $count objs',
              style: const TextStyle(
                  color: Colors.white, fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetectionOverlay extends CustomPainter {
  const _DetectionOverlay({
    required this.detections,
    required this.modelInputSize,
    required this.previewSize,
    required this.screenSize,
    required this.isFrontCamera,
  });

  final List<YoloDetection> detections;
  final int modelInputSize;
  final Size? previewSize;
  final Size screenSize;
  final bool isFrontCamera;

  @override
  void paint(Canvas canvas, Size size) {
    if (previewSize == null) return;

    final previewWidth = previewSize!.height;
    final previewHeight = previewSize!.width;
    final scaleX = size.width / previewWidth;
    final scaleY = size.height / previewHeight;
    final scale = math.min(scaleX, scaleY);

    final offsetX = (size.width - previewWidth * scale) / 2;
    final offsetY = (size.height - previewHeight * scale) / 2;

    final boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = Colors.redAccent;

    final labelBgPaint = Paint()..color = Colors.black54;
    final labelPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final det in detections) {
      final dx =
          det.rect.left / modelInputSize * previewWidth * scale + offsetX;
      final dy =
          det.rect.top / modelInputSize * previewHeight * scale + offsetY;
      final dw = det.rect.width / modelInputSize * previewWidth * scale;
      final dh = det.rect.height / modelInputSize * previewHeight * scale;

      final rect = Rect.fromLTWH(
        isFrontCamera ? size.width - dx - dw : dx,
        dy,
        dw,
        dh,
      );

      canvas.drawRect(rect, boxPaint);

      final text =
          '${det.label} ${(det.confidence * 100).toStringAsFixed(0)}%';
      labelPainter.text = TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      );
      labelPainter.layout();
      final lh = labelPainter.height;
      final labelY = rect.top - lh - 4 < 0 ? rect.bottom + 4 : rect.top - lh - 4;
      canvas.drawRect(
        Rect.fromLTWH(rect.left, labelY, labelPainter.width + 8, lh + 2),
        labelBgPaint,
      );
      labelPainter.paint(canvas, Offset(rect.left + 4, labelY));
    }
  }

  @override
  bool shouldRepaint(covariant _DetectionOverlay oldDelegate) =>
      oldDelegate.detections != detections;
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