// Abstracción de backends de inferencia YOLOv8 para el ejercicio de
// detección sobre imagen estática.
//
// Hay dos implementaciones:
//   - TfliteBackend: carga .tflite in-process con tflite_flutter. Rápido,
//     sin dependencias externas, pero solo soporta .tflite.
//   - PytorchSidecarBackend: lanza un proceso Python (tooling/yolo_sidecar/)
//     que carga .pt con ultralytics y sirve inferencia por stdin/stdout.
//     Soporta .pt a costa de requerir Python+ultralytics instalados.
//
// Contrato unificado: detect() devuelve rect en píxeles de la imagen ORIGINAL.
// El TfliteBackend hace el mapeo 640x640 -> original internamente; el sidecar
// ya devuelve coords originales. La UI no necesita saber qué backend hay
// debajo.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show Rect;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'yolo_classifier.dart' show YoloDetection;

/// Interfaz común para los backends de inferencia.
abstract class YoloBackend {
  /// Carga el modelo desde un asset path (p. ej. 'assets/models/yolov8s.tflite').
  /// Lanza [StateError] si el formato no es soportado o el archivo es inválido.
  Future<void> load(String assetPath);

  /// Ejecuta inferencia sobre [image].
  /// [origWidth]/[origHeight] son las dimensiones de la imagen original (antes
  /// de cualquier resize interno del backend) — se usan para mapear las
  /// detecciones al espacio original.
  Future<List<YoloDetection>> detect(
      img.Image image, int origWidth, int origHeight);

  /// Path del asset cargado actualmente, o null si no hay ninguno.
  String? get loadedAssetPath;

  /// Libera recursos (cierra intérprete/proceso).
  void dispose();
}

// ── Backend TFLite (in-process) ──────────────────────────────────────────────

class TfliteBackend implements YoloBackend {
  static const int _inputSize = 640;
  static const double _confThreshold = 0.45;
  static const double _iouThreshold = 0.5;

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

  Interpreter? _interpreter;
  String? _loadedAssetPath;

  @override
  String? get loadedAssetPath => _loadedAssetPath;

  @override
  Future<void> load(String assetPath) async {
    if (_loadedAssetPath == assetPath && _interpreter != null) return;
    final old = _interpreter;
    _interpreter = null;
    _loadedAssetPath = null;
    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
      _interpreter = Interpreter.fromBuffer(bytes);
      _loadedAssetPath = assetPath;
      old?.close();
    } catch (e) {
      old?.close();
      throw StateError('No se pudo cargar $assetPath. Detalle: $e');
    }
  }

  @override
  Future<List<YoloDetection>> detect(
      img.Image image, int origWidth, int origHeight) async {
    final interpreter = _interpreter;
    if (interpreter == null) {
      throw StateError('TfliteBackend no inicializado: llama a load() antes.');
    }
    final resized =
        img.copyResize(image, width: _inputSize, height: _inputSize);
    final input = _imageToFloatBuffer(resized);

    final output =
        List.filled(1 * 84 * 8400, 0.0).reshape<double>([1, 84, 8400]);
    interpreter.run(input, output);

    final raw = _parseDetections(output[0]);
    final kept = _nonMaxSuppression(raw, _iouThreshold);

    // Mapeo de coords 640x640 -> espacio original (cada eje independientemente
    // porque copyResize distorsiona el aspect ratio).
    final scaleX = origWidth / _inputSize;
    final scaleY = origHeight / _inputSize;
    return kept
        .map((d) => YoloDetection(
              classId: d.classId,
              label: cocoLabels.length > d.classId
                  ? cocoLabels[d.classId]
                  : 'cls${d.classId}',
              confidence: d.confidence,
              rect: Rect.fromLTWH(
                d.cx * scaleX - d.w * scaleX / 2,
                d.cy * scaleY - d.h * scaleY / 2,
                d.w * scaleX,
                d.h * scaleY,
              ),
            ))
        .toList();
  }

  @override
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _loadedAssetPath = null;
  }

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

  List<_RawDetection> _nonMaxSuppression(
      List<_RawDetection> dets, double iouThreshold) {
    dets.sort((a, b) => b.confidence.compareTo(a.confidence));
    final List<_RawDetection> kept = [];
    final suppressed = List<bool>.filled(dets.length, false);
    for (var i = 0; i < dets.length; i++) {
      if (suppressed[i]) continue;
      final a = dets[i];
      kept.add(a);
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
    final interLeft = math.max(ax1, bx1);
    final interTop = math.max(ay1, by1);
    final interRight = math.min(ax2, bx2);
    final interBottom = math.min(ay2, by2);
    final iw = (interRight - interLeft).clamp(0.0, double.infinity);
    final ih = (interBottom - interTop).clamp(0.0, double.infinity);
    final inter = iw * ih;
    final union = a.w * a.h + b.w * b.h - inter;
    return union <= 0 ? 0 : inter / union;
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

// ── Backend PyTorch sidecar (proceso Python) ─────────────────────────────────

/// Lanza un proceso Python (yolo_sidecar.py) que carga .pt con ultralytics
/// y sirve inferencia por stdin/stdout JSON line-delimited.
///
/// Requiere que el venv del sidecar esté creado (ver
/// tooling/yolo_sidecar/setup.sh). El binario Python se busca en este orden:
///   1. Variable de entorno YOLO_SIDECAR_PYTHON
///   2. tooling/yolo_sidecar/.venv/bin/python (relativo al proyecto)
///   3. python3 del PATH (asume ultralytics instalado global)
class PytorchSidecarBackend implements YoloBackend {
  PytorchSidecarBackend();

  Process? _process;
  String? _loadedAssetPath;
  String? _modelTempPath;
  Directory? _tempDir;

  /// Buffer de líneas de stdout (respuestas JSON del sidecar).
  final _stdoutQueue = <String>[];
  /// Completer pendiente — se completa cuando llega la siguiente línea a
  /// _stdoutQueue y hay alguien esperando en _readResponse().
  Completer<Map<String, dynamic>?>? _pendingRead;
  // Mantener viva la suscripción al stream de stdout — el listener encola
  // líneas en _stdoutQueue y completa _pendingRead cuando hay alguien esperando.
  // ignore: unused_field
  StreamSubscription<String>? _stdoutSub;
  Completer<void>? _readyCompleter;

  @override
  String? get loadedAssetPath => _loadedAssetPath;

  @override
  Future<void> load(String assetPath) async {
    if (_loadedAssetPath == assetPath && _process != null) return;
    await _disposeProcess();

    // 1. Extraer el asset .pt a un archivo temporal (el sidecar necesita
    //    un path absoluto del filesystem, no un asset del bundle Flutter).
    _modelTempPath = await _extractAssetToTemp(assetPath);

    // 2. Localizar el intérprete Python.
    final pyBin = await _resolvePythonBin();
    final scriptPath = await _resolveSidecarScript();

    // 3. Lanzar el proceso.
    try {
      _process = await Process.start(
        pyBin,
        [scriptPath],
        mode: ProcessStartMode.normal,
      );
    } catch (e) {
      throw StateError(
        'No se pudo lanzar el sidecar Python en "$pyBin". '
        'Ejecuta tooling/yolo_sidecar/setup.sh primero. Detalle: $e',
      );
    }

    // 4. Configurar listeners de stdout/stderr.
    _stdoutQueue.clear();
    _readyCompleter = Completer<void>();
    _stdoutSub = _process!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
      (line) {
        // 1. Si estamos esperando la señal "ready" y la línea es JSON con
        //    ready=true, la consumimos aquí (no la encolamos).
        if (_readyCompleter != null && !_readyCompleter!.isCompleted) {
          try {
            final decoded = json.decode(line) as Map<String, dynamic>;
            if (decoded['ready'] == true) {
              _readyCompleter!.complete();
              return;
            }
          } catch (_) {
            // No es JSON — cae al encolado abajo.
          }
        }
        // 2. Si hay alguien esperando en _readResponse, le entregamos la
        //    línea directamente.
        final pending = _pendingRead;
        if (pending != null && !pending.isCompleted) {
          pending.complete(_parseLine(line));
          return;
        }
        // 3. Si no, encolamos para el próximo _readResponse.
        _stdoutQueue.add(line);
      },
      onDone: () {
        _readyCompleter?.completeError('stdout cerrado');
        final p = _pendingRead;
        if (p != null && !p.isCompleted) p.complete(null);
      },
    );

    _process!.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      // Logs del sidecar a debugPrint (solo visible en debug).
      debugPrint('[sidecar] $line');
    });

    // 5. Esperar la señal "ready" del sidecar (timeout 30s para cold start).
    try {
      await _readyCompleter!.future.timeout(const Duration(seconds: 30));
    } catch (e) {
      throw StateError(
        'El sidecar no envió la señal "ready" en 30s. '
        'Revisa que el venv tenga ultralytics instalado. Detalle: $e',
      );
    }

    // 6. Mandar el comando "load".
    _sendJson({'cmd': 'load', 'model_abs': _modelTempPath});
    final loadResp = await _readResponse();
    if (loadResp == null || loadResp['ok'] != true) {
      final err = loadResp?['error'] ?? 'respuesta inválida';
      throw StateError('Error cargando modelo en el sidecar: $err');
    }

    _loadedAssetPath = assetPath;
  }

  @override
  Future<List<YoloDetection>> detect(
      img.Image image, int origWidth, int origHeight) async {
    if (_process == null) {
      throw StateError('PytorchSidecarBackend no inicializado.');
    }
    // 1. Volcar la imagen a un archivo temporal (el sidecar lee del disco).
    final imgFile = _writeImageToTemp(image);
    try {
      _sendJson({'cmd': 'detect', 'image_abs': imgFile.path});
      final resp = await _readResponse();
      if (resp == null || resp['ok'] != true) {
        final err = resp?['error'] ?? 'respuesta inválida';
        throw StateError('Error en detección del sidecar: $err');
      }
      final dets = (resp['detections'] as List)
          .map((d) => _parseDetection(d as Map<String, dynamic>))
          .toList();
      return dets;
    } finally {
      try {
        imgFile.deleteSync();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _disposeProcessSync();
    _cleanupTemp();
  }

  // ── Helpers ──

  Future<String> _resolvePythonBin() async {
    final env = Platform.environment['YOLO_SIDECAR_PYTHON'];
    if (env != null && env.isNotEmpty) return env;
    final candidates = <String>[
      '${Directory.current.path}/tooling/yolo_sidecar/.venv/bin/python',
      // En Linux desktop el cwd puede ser el dir del bundle.
      '${Platform.resolvedExecutable}/../../tooling/yolo_sidecar/.venv/bin/python',
    ];
    for (final c in candidates) {
      if (await File(c).exists()) return c;
    }
    return 'python3';
  }

  Future<String> _resolveSidecarScript() async {
    final candidates = <String>[
      '${Directory.current.path}/tooling/yolo_sidecar/yolo_sidecar.py',
      '${Platform.resolvedExecutable}/../../tooling/yolo_sidecar/yolo_sidecar.py',
    ];
    for (final c in candidates) {
      if (await File(c).exists()) return c;
    }
    throw StateError(
      'No se encontró tooling/yolo_sidecar/yolo_sidecar.py. '
      'Ejecuta desde la raíz del proyecto.',
    );
  }

  Future<String> _extractAssetToTemp(String assetPath) async {
    if (_tempDir == null) {
      _tempDir = await Directory.systemTemp.createTemp('yolo_sidecar_');
    }
    final fileName = assetPath.split('/').last;
    final outFile = File('${_tempDir!.path}/$fileName');
    if (!outFile.existsSync()) {
      final byteData = await rootBundle.load(assetPath);
      await outFile.writeAsBytes(
        byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
      );
    }
    return outFile.absolute.path;
  }

  File _writeImageToTemp(img.Image image) {
    if (_tempDir == null) {
      _tempDir = Directory.systemTemp.createTempSync('yolo_sidecar_');
    }
    final file = File(
        '${_tempDir!.path}/img_${DateTime.now().microsecondsSinceEpoch}.jpg');
    final encoded = img.encodeJpg(image);
    file.writeAsBytesSync(encoded);
    return file;
  }

  void _sendJson(Map<String, dynamic> obj) {
    final proc = _process;
    if (proc == null) return;
    proc.stdin.writeln(json.encode(obj));
  }

  /// Lee la siguiente respuesta JSON del sidecar.
  /// Si ya hay una línea encolada, la consume; si no, espera a que llegue.
  Future<Map<String, dynamic>?> _readResponse(
      {Duration timeout = const Duration(seconds: 60)}) async {
    // 1. Si hay líneas ya encoladas (p. ej. la señal ready llegó antes de
    //    que pidiéramos la respuesta de load), consumir la primera.
    if (_stdoutQueue.isNotEmpty) {
      return _parseLine(_stdoutQueue.removeAt(0));
    }
    // 2. Si no, registrarnos como pendientes — el listener principal nos
    //    entregará la próxima línea que llegue.
    if (_pendingRead != null && !_pendingRead!.isCompleted) {
      // Algo raro — ya había un pending; lo completamos con null para
      // destrabarlo y seguimos.
      _pendingRead!.complete(null);
    }
    _pendingRead = Completer<Map<String, dynamic>?>();
    return _pendingRead!.future.timeout(timeout, onTimeout: () {
      if (_pendingRead != null && !_pendingRead!.isCompleted) {
        _pendingRead!.complete(null);
      }
      return null;
    });
  }

  Map<String, dynamic>? _parseLine(String line) {
    try {
      return json.decode(line) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  YoloDetection _parseDetection(Map<String, dynamic> d) {
    return YoloDetection(
      classId: d['class_id'] as int,
      label: d['label'] as String,
      confidence: (d['confidence'] as num).toDouble(),
      rect: Rect.fromLTWH(
        (d['x1'] as num).toDouble(),
        (d['y1'] as num).toDouble(),
        ((d['x2'] as num) - (d['x1'] as num)).toDouble(),
        ((d['y2'] as num) - (d['y1'] as num)).toDouble(),
      ),
    );
  }

  Future<void> _disposeProcess() async {
    final p = _process;
    if (p == null) return;
    _sendJson({'cmd': 'shutdown'});
    try {
      await p.exitCode.timeout(const Duration(seconds: 3), onTimeout: () {
        p.kill(ProcessSignal.sigkill);
        return -1;
      });
    } catch (_) {
      p.kill(ProcessSignal.sigkill);
    }
    _process = null;
  }

  void _disposeProcessSync() {
    final p = _process;
    if (p == null) return;
    try {
      p.stdin.writeln(json.encode({'cmd': 'shutdown'}));
    } catch (_) {}
    p.kill();
    _process = null;
  }

  void _cleanupTemp() {
    _tempDir?.deleteSync(recursive: true);
    _tempDir = null;
    _modelTempPath = null;
  }
}