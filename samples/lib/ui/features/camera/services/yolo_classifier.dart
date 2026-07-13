import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Detección individual producida por YOLOv8.
class YoloDetection {
  const YoloDetection({
    required this.classId,
    required this.label,
    required this.confidence,
    required this.rect,
  });

  final int classId;
  final String label;
  final double confidence;
  final Rect rect;
}

/// Servicio que carga el modelo YOLOv8s (.tflite) y realiza inferencia
/// sobre imágenes RGB redimensionadas a 640x640.
///
/// Formato de entrada esperado: [1, 640, 640, 3] float32 normalizado 0..1.
/// Formato de salida de YOLOv8 exportado a TFLite:
///   [1, 84, 8400] donde 84 = [cx, cy, w, h, 80 clases] y 8400 = nº de anchors.
class YoloClassifier {
  static const int _inputSize = 640;
  static const double _confThreshold = 0.45;
  static const double _iouThreshold = 0.5;

  Interpreter? _interpreter;
  List<String> _labels = const [];

  /// Nombres de las 80 clases COCO.
  static const List<String> cocoLabels = [
    'person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', 'train',
    'truck', 'boat', 'traffic light', 'fire hydrant', 'stop sign',
    'parking meter', 'bench', 'bird', 'cat', 'dog', 'horse', 'sheep', 'cow',
    'elephant', 'bear', 'zebra', 'giraffe', 'backpack', 'umbrella', 'handbag',
    'tie', 'suitcase', 'frisbee', 'skis', 'snowboard', 'sports ball', 'kite',
    'baseball bat', 'baseball glove', 'skateboard', 'surfboard',
    'tennis racket', 'bottle', 'wine glass', 'cup', 'fork', 'knife', 'spoon',
    'bowl', 'banana', 'apple', 'sandwich', 'orange', 'broccoli', 'carrot',
    'hot dog', 'pizza', 'donut', 'cake', 'chair', 'couch', 'potted plant',
    'bed', 'dining table', 'toilet', 'tv', 'laptop', 'mouse', 'remote',
    'keyboard', 'cell phone', 'microwave', 'oven', 'toaster', 'sink',
    'refrigerator', 'book', 'clock', 'vase', 'scissors', 'teddy bear',
    'hair drier', 'toothbrush',
  ];

  bool get isLoaded => _interpreter != null;
  List<String> get labels => _labels;

  /// Path del modelo cargado actualmente (o null si no hay ninguno).
  String? get loadedAssetPath => _loadedAssetPath;
  String? _loadedAssetPath;

  /// Carga un modelo TFLite desde un asset path.
  ///
  /// [assetPath] debe apuntar a un `.tflite` dentro de `assets/models/`.
  /// Si se omite, usa el default `assets/models/yolov8s.tflite`.
  /// Si ya había un modelo cargado, lo cierra antes de cargar el nuevo.
  /// Lanza [StateError] si el archivo no existe o no es un TFLite válido.
  Future<void> load({String assetPath = 'assets/models/yolov8s.tflite'}) async {
    if (_loadedAssetPath == assetPath && _interpreter != null) return;
    final old = _interpreter;
    _interpreter = null;
    _loadedAssetPath = null;
    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List(
          byteData.offsetInBytes, byteData.lengthInBytes);
      _interpreter = Interpreter.fromBuffer(bytes);
      _loadedAssetPath = assetPath;
      _labels = cocoLabels;
      old?.close();
    } on PlatformException catch (e) {
      old?.close();
      throw StateError(
        'No se pudo cargar $assetPath. '
        'Verifica que sea un archivo .tflite válido (ver assets/models/README.md). '
        'Detalle: ${e.message}',
      );
    } catch (e) {
      old?.close();
      throw StateError('No se pudo cargar $assetPath. Detalle: $e');
    }
  }

  /// Recarga el mismo modelo (útil tras hot-reload si se reemplazó el asset).
  Future<void> reload() async {
    final path = _loadedAssetPath;
    if (path == null) return;
    _loadedAssetPath = null;
    _interpreter?.close();
    _interpreter = null;
    await load(assetPath: path);
  }

  /// Ejecuta la inferencia sobre un frame RGB ya decodificado.
  /// Devuelve la lista de detecciones filtradas por confianza y NMS.
  List<YoloDetection> detect(img.Image image) {
    final interpreter = _interpreter;
    if (interpreter == null) {
      throw StateError('YoloClassifier no inicializado: llama a load() antes.');
    }

    final resized = img.copyResize(image,
        width: _inputSize, height: _inputSize);
    final input = _imageToFloatBuffer(resized);

    // Salida YOLOv8s TFLite: [1, 84, 8400] float32.
    final output = List.filled(1 * 84 * 8400, 0.0)
        .reshape<double>([1, 84, 8400]);
    interpreter.run(input, output);

    final detections = _parseDetections(output[0]);
    final kept = _nonMaxSuppression(detections, _iouThreshold);
    return kept;
  }

  /// Convierte un img.Image 640x640 a un buffer [1,640,640,3] float32 normalizado.
  List<List<List<List<double>>>> _imageToFloatBuffer(img.Image image) {
    final result = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (_) => List.generate(
          _inputSize,
          (_) => List<double>.filled(3, 0),
        ),
      ),
    );
    for (var y = 0; y < _inputSize; y++) {
      for (var x = 0; x < _inputSize; x++) {
        final pixel = image.getPixel(x, y);
        result[0][y][x][0] = pixel.r / 255.0;
        result[0][y][x][1] = pixel.g / 255.0;
        result[0][y][x][2] = pixel.b / 255.0;
      }
    }
    return result;
  }

  /// Convierte la salida [84, 8400] en detecciones con coordenadas absolutas.
  List<_RawDetection> _parseDetections(List<List<double>> raw) {
    final List<_RawDetection> result = [];
    final numAnchors = raw[0].length;
    for (var i = 0; i < numAnchors; i++) {
      final cx = raw[0][i];
      final cy = raw[1][i];
      final w = raw[2][i];
      final h = raw[3][i];

      var bestConf = 0.0;
      var bestClass = -1;
      for (var c = 0; c < 80; c++) {
        final conf = raw[4 + c][i];
        if (conf > bestConf) {
          bestConf = conf;
          bestClass = c;
        }
      }
      if (bestConf < _confThreshold || bestClass < 0) continue;

      result.add(_RawDetection(
        classId: bestClass,
        confidence: bestConf,
        cx: cx,
        cy: cy,
        w: w,
        h: h,
      ));
    }
    return result;
  }

  /// Non-Maximum Suppression básico para eliminar cajas solapadas.
  List<YoloDetection> _nonMaxSuppression(
      List<_RawDetection> dets, double iouThreshold) {
    dets.sort((a, b) => b.confidence.compareTo(a.confidence));
    final List<YoloDetection> kept = [];
    final suppressed = List<bool>.filled(dets.length, false);

    for (var i = 0; i < dets.length; i++) {
      if (suppressed[i]) continue;
      final a = dets[i];
      kept.add(YoloDetection(
        classId: a.classId,
        label: _labels.length > a.classId ? _labels[a.classId] : 'cls${a.classId}',
        confidence: a.confidence,
        rect: Rect.fromCenter(
          center: Offset(a.cx, a.cy),
          width: a.w,
          height: a.h,
        ),
      ));
      for (var j = i + 1; j < dets.length; j++) {
        if (suppressed[j]) continue;
        if (_iou(a, dets[j]) > iouThreshold) {
          suppressed[j] = true;
        }
      }
    }
    return kept;
  }

  double _iou(_RawDetection a, _RawDetection b) {
    final ax1 = a.cx - a.w / 2, ay1 = a.cy - a.h / 2;
    final ax2 = a.cx + a.w / 2, ay2 = a.cy + a.h / 2;
    final bx1 = b.cx - b.w / 2, by1 = b.cy - b.h / 2;
    final bx2 = b.cx + b.w / 2, by2 = b.cy + b.h / 2;

    final interLeft = ax1 > bx1 ? ax1 : bx1;
    final interTop = ay1 > by1 ? ay1 : by1;
    final interRight = ax2 < bx2 ? ax2 : bx2;
    final interBottom = ay2 < by2 ? ay2 : by2;
    final iw = (interRight - interLeft).clamp(0.0, double.infinity);
    final ih = (interBottom - interTop).clamp(0.0, double.infinity);
    final inter = iw * ih;
    final union = a.w * a.h + b.w * b.h - inter;
    return union <= 0 ? 0 : inter / union;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}

class _RawDetection {
  const _RawDetection({
    required this.classId,
    required this.confidence,
    required this.cx,
    required this.cy,
    required this.w,
    required this.h,
  });
  final int classId;
  final double confidence;
  final double cx, cy, w, h;
}

/// Extensión interna para reshape usando List.filled + .reshape de tflite_flutter.
// tflite_flutter exporta un extension method `reshape<T>` on List via ListShape.
// Se usa directamente: list.reshape<double>(shape).