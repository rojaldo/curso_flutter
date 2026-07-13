import 'package:flutter/services.dart' show AssetManifest, rootBundle;

/// Formato detectado de un modelo en assets/models/.
enum ModelFormat { tflite, pyTorch, unknown }

/// Modelo disponible en assets/models/, clasificado por formato.
class ModelAsset {
  const ModelAsset({
    required this.assetPath,
    required this.fileName,
    required this.format,
  });

  /// Path completo para rootBundle.load (p. ej. 'assets/models/yolov8s.tflite').
  final String assetPath;

  /// Nombre del archivo sin directorio (p. ej. 'yolov8s.tflite').
  final String fileName;

  /// Formato detectado a partir de la extensión.
  final ModelFormat format;

  /// TFLite es el único formato ejecutable on-device desde Flutter.
  bool get isRunnable => format == ModelFormat.tflite;

  /// Etiqueta legible: "TFLite" / "PyTorch (.pt)" / "Desconocido".
  String get formatLabel {
    switch (format) {
      case ModelFormat.tflite:
        return 'TFLite';
      case ModelFormat.pyTorch:
        return 'PyTorch (.pt)';
      case ModelFormat.unknown:
        return 'Desconocido';
    }
  }
}

/// Lista los modelos disponibles en assets/models/ leyendo el AssetManifest
/// generado por Flutter (funciona en release y debug, sin escanear disco).
class ModelRegistry {
  static const String _modelsDir = 'assets/models/';

  /// Devuelve todos los modelos en assets/models/, ordenados:
  /// primero TFLite (alfabético), luego PT (alfabético), luego otros.
  static Future<List<ModelAsset>> listModels() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final allAssets = manifest.listAssets();

    final models = <ModelAsset>[];
    for (final key in allAssets) {
      if (!key.startsWith(_modelsDir)) continue;
      final fileName = key.substring(_modelsDir.length);
      // El manifest puede incluir el propio directorio 'assets/models/' como
      // entrada (sin fileName útil). Lo saltamos.
      if (fileName.isEmpty || fileName.endsWith('/')) continue;
      models.add(ModelAsset(
        assetPath: key,
        fileName: fileName,
        format: _detectFormat(fileName),
      ));
    }

    models.sort((a, b) {
      final aRank = a.isRunnable ? 0 : (a.format == ModelFormat.pyTorch ? 1 : 2);
      final bRank = b.isRunnable ? 0 : (b.format == ModelFormat.pyTorch ? 1 : 2);
      final cmp = aRank.compareTo(bRank);
      return cmp != 0 ? cmp : a.fileName.compareTo(b.fileName);
    });
    return models;
  }

  static ModelFormat _detectFormat(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.tflite')) return ModelFormat.tflite;
    if (lower.endsWith('.pt')) return ModelFormat.pyTorch;
    return ModelFormat.unknown;
  }

  /// Devuelve el primer modelo TFLite disponible, o null si no hay ninguno.
  /// Útil para elegir un default al iniciar la página.
  static Future<ModelAsset?> defaultTflite() async {
    final models = await listModels();
    for (final m in models) {
      if (m.isRunnable) return m;
    }
    return null;
  }
}