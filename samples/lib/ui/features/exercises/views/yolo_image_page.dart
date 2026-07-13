// Ejercicio — Detección de objetos con YOLOv8 sobre una imagen estática.
//
// Flujo:
// 1. Lista los modelos disponibles en assets/models/ (vía ModelRegistry).
// 2. Selector en la barra superior — el usuario elige modelo en caliente.
//    Soporta dos formatos:
//    - .tflite: inferencia in-process con tflite_flutter (TfliteBackend).
//    - .pt:     sidecar Python con ultralytics (PytorchSidecarBackend).
// 3. Botón "Elegir imagen" → FilePicker abre el selector nativo del sistema.
// 4. Decodifica el archivo (JPG/PNG/…) con el paquete `image`.
// 5. Ejecuta inferencia vía el backend seleccionado.
// 6. Pinta un overlay con CustomPainter mostrando bounding boxes + etiqueta +
//    confianza, y un listado resumen (count por clase).
//
// Contrato unificado: ambos backends devuelven rect en píxeles de la imagen
// original; el CustomPainter solo escala al tamaño renderizado del widget.

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:sample_app/ui/features/camera/services/model_registry.dart';
import 'package:sample_app/ui/features/camera/services/yolo_backend.dart';
import 'package:sample_app/ui/features/camera/services/yolo_classifier.dart'
    show YoloDetection;

class YoloImagePage extends StatefulWidget {
  const YoloImagePage({super.key});

  @override
  State<YoloImagePage> createState() => _YoloImagePageState();
}

class _YoloImagePageState extends State<YoloImagePage> {
  YoloBackend? _backend;

  List<ModelAsset> _models = const [];
  ModelAsset? _selectedModel;

  bool _modelReady = false;
  String? _modelError;

  String? _imagePath;
  Size _imageSize = Size.zero;
  List<YoloDetection> _detections = const [];

  bool _busy = false;
  bool _switchingModel = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _backend?.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      _models = await ModelRegistry.listModels();
    } catch (_) {
      // Si el manifest falla, seguimos con lista vacía; el usuario verá el CTA.
    }
    if (!mounted) return;
    // Default: primer .tflite (arranque in-process, sin sidecar). Si no hay
    // ninguno, default al primer modelo (PT — usará el sidecar).
    ModelAsset? defaultModel;
    for (final m in _models) {
      if (m.format == ModelFormat.tflite) {
        defaultModel = m;
        break;
      }
    }
    defaultModel ??= _models.isEmpty ? null : _models.first;
    if (defaultModel == null) {
      setState(() {});
      return;
    }
    setState(() => _selectedModel = defaultModel);
    await _loadModel(defaultModel);
  }

  /// Crea el backend adecuado según el formato del modelo y lo carga.
  /// Para .tflite usa TfliteBackend (in-process).
  /// Para .pt usa PytorchSidecarBackend (proceso Python con ultralytics).
  Future<void> _loadModel(ModelAsset model) async {
    setState(() {
      _switchingModel = true;
      _modelError = null;
      _modelReady = false;
      _detections = const [];
    });

    // Cerrar backend anterior si cambia de tipo (TFLite <-> Sidecar)
    // o si el sidecar ya tenía un modelo cargado (para liberar el proceso).
    final oldBackend = _backend;
    _backend = null;
    if (oldBackend != null) {
      try {
        oldBackend.dispose();
      } catch (_) {}
    }

    final newBackend =
        model.format == ModelFormat.tflite ? TfliteBackend() : PytorchSidecarBackend();

    try {
      await newBackend.load(model.assetPath);
      if (!mounted) {
        newBackend.dispose();
        return;
      }
      _backend = newBackend;
      setState(() {
        _modelReady = true;
        _selectedModel = model;
        _switchingModel = false;
      });
    } catch (e) {
      newBackend.dispose();
      if (!mounted) return;
      setState(() {
        _modelError = e is StateError ? e.message : e.toString();
        _switchingModel = false;
      });
    }
  }

  Future<void> _pickAndDetect() async {
    if (!_modelReady || _busy) return;
    final backend = _backend;
    if (backend == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) {
        if (!mounted) return;
        setState(() => _busy = false);
        return;
      }
      final path = result.files.single.path;
      if (path == null) {
        if (!mounted) return;
        setState(() => _busy = false);
        return;
      }

      final bytes = await File(path).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        if (!mounted) return;
        setState(() {
          _busy = false;
          _error = 'No se pudo decodificar la imagen (formato no soportado).';
        });
        return;
      }

      // detect() es async en ambos backends (TFLite envuelve trabajo síncrono
      // en Future; el sidecar espera respuesta del proceso Python).
      final detections = await backend.detect(
        decoded,
        decoded.width,
        decoded.height,
      );

      if (!mounted) return;
      setState(() {
        _imagePath = path;
        _imageSize = Size(decoded.width.toDouble(), decoded.height.toDouble());
        _detections = detections;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e is StateError ? e.message : e.toString();
      });
    }
  }

  void _clear() {
    setState(() {
      _imagePath = null;
      _imageSize = Size.zero;
      _detections = const [];
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YOLO — Detección en imagen')),
      body: _buildBody(),
      floatingActionButton: _modelReady && !_busy
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_imagePath != null) ...[
                  FloatingActionButton(
                    heroTag: 'clear',
                    onPressed: _clear,
                    child: const Icon(Icons.clear),
                  ),
                  const SizedBox(width: 12),
                ],
                FloatingActionButton.extended(
                  heroTag: 'pick',
                  onPressed: _pickAndDetect,
                  icon: const Icon(Icons.photo_library),
                  label: Text(_imagePath == null
                      ? 'Elegir imagen'
                      : 'Otra imagen'),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ModelSelectorBar(
          models: _models,
          selected: _selectedModel,
          switching: _switchingModel,
          modelReady: _modelReady,
          onChanged: (m) => _loadModel(m),
          onRetry: _bootstrap,
        ),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    if (_switchingModel) {
      return const _Centered(
        icon: Icons.swap_horiz,
        text: 'Cargando modelo…',
      );
    }
    if (_modelError != null) {
      return _CenterMessage(
        icon: Icons.error_outline,
        message: _modelError!,
        actionLabel: 'Reintentar',
        onAction: () {
          setState(() => _modelError = null);
          final m = _selectedModel;
          if (m != null) {
            _loadModel(m);
          } else {
            _bootstrap();
          }
        },
      );
    }
    if (!_modelReady) {
      return const _Centered(
        icon: Icons.hourglass_top,
        text: 'Cargando modelo…',
      );
    }
    if (_busy) {
      return const _Centered(
        icon: Icons.search,
        text: 'Detectando objetos…',
      );
    }
    if (_error != null) {
      return _CenterMessage(
        icon: Icons.broken_image_outlined,
        message: _error!,
        actionLabel: 'Descartar',
        onAction: _clear,
      );
    }
    final path = _imagePath;
    if (path == null || _imageSize == Size.zero) {
      return const _EmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _ImageWithDetections(
              imagePath: path,
              imageSize: _imageSize,
              detections: _detections,
            ),
          ),
        ),
        if (_detections.isNotEmpty)
          _DetectionSummary(detections: _detections),
      ],
    );
  }
}

/// Barra superior con el selector de modelo.
/// Muestra todos los archivos en assets/models/ — los .tflite son seleccionables,
/// los .pt aparecen en gris con tooltip "formato no soportado en Flutter".
class _ModelSelectorBar extends StatelessWidget {
  const _ModelSelectorBar({
    required this.models,
    required this.selected,
    required this.switching,
    required this.modelReady,
    required this.onChanged,
    required this.onRetry,
  });

  final List<ModelAsset> models;
  final ModelAsset? selected;
  final bool switching;
  final bool modelReady;
  final ValueChanged<ModelAsset> onChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (models.isEmpty) {
      return _NoModelsBar(onRetry: onRetry);
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(switching ? Icons.hourglass_top : Icons.memory,
              size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text('Modelo:', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(width: 12),
          Expanded(
            child: _ModelDropdown(
              models: models,
              selected: selected,
              switching: switching,
              onChanged: onChanged,
            ),
          ),
          if (selected != null && !switching) ...[
            const SizedBox(width: 8),
            _FormatChip(model: selected!),
          ],
        ],
      ),
    );
  }
}

class _ModelDropdown extends StatelessWidget {
  const _ModelDropdown({
    required this.models,
    required this.selected,
    required this.switching,
    required this.onChanged,
  });

  final List<ModelAsset> models;
  final ModelAsset? selected;
  final bool switching;
  final ValueChanged<ModelAsset> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<ModelAsset>(
      value: selected,
      isExpanded: true,
      disabledHint: switching
          ? const Text('Cargando modelo…')
          : const Text('Selecciona un modelo'),
      items: models.map((m) {
        final isSelected = m.assetPath == selected?.assetPath;
        final isTflite = m.format == ModelFormat.tflite;
        return DropdownMenuItem<ModelAsset>(
          value: m,
          enabled: !switching,
          child: Row(
            children: [
              Icon(
                isTflite ? Icons.flash_on : Icons.local_fire_department,
                size: 16,
                color: isTflite
                    ? Colors.green
                    : Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  m.fileName,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                m.formatLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isTflite
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: switching
          ? null
          : (v) {
              if (v != null) onChanged(v);
            },
    );
  }
}

class _FormatChip extends StatelessWidget {
  const _FormatChip({required this.model});

  final ModelAsset model;

  @override
  Widget build(BuildContext context) {
    final isTflite = model.format == ModelFormat.tflite;
    final bg = isTflite
        ? Theme.of(context).colorScheme.primaryContainer
        : Theme.of(context).colorScheme.secondaryContainer;
    final fg = isTflite
        ? Theme.of(context).colorScheme.onPrimaryContainer
        : Theme.of(context).colorScheme.onSecondaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        model.formatLabel,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
      ),
    );
  }
}

class _NoModelsBar extends StatelessWidget {
  const _NoModelsBar({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.4),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, size: 18,
              color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'No hay modelos en assets/models/. '
              'Copia un .tflite (ver assets/models/README.md).',
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Releer')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_search,
                size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Selecciona una imagen para detectar objetos',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Pulsa "Elegir imagen" para abrir el selector del sistema. '
              'La detección se ejecuta on-device con YOLOv8s.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(text),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImageWithDetections extends StatelessWidget {
  const _ImageWithDetections({
    required this.imagePath,
    required this.imageSize,
    required this.detections,
  });

  final String imagePath;
  final Size imageSize;
  final List<YoloDetection> detections;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: imageSize.width / imageSize.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(File(imagePath), fit: BoxFit.fill),
            IgnorePointer(
              child: CustomPaint(
                painter: _DetectionOverlay(
                  detections: detections,
                  imageSize: imageSize,
                ),
              ),
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
    required this.imageSize,
  });

  final List<YoloDetection> detections;
  final Size imageSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (detections.isEmpty) return;

    // Los backends devuelven rect en píxeles de la imagen original.
    // El widget la muestra preservando aspect ratio, así que escalamos
    // linealmente al tamaño renderizado.
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    final boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = Colors.redAccent;

    final labelBgPaint = Paint()..color = Colors.black54;
    final labelPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final det in detections) {
      final screenRect = Rect.fromLTWH(
        det.rect.left * scaleX,
        det.rect.top * scaleY,
        det.rect.width * scaleX,
        det.rect.height * scaleY,
      );

      canvas.drawRect(screenRect, boxPaint);

      final text = '${det.label} ${(det.confidence * 100).toStringAsFixed(0)}%';
      labelPainter.text = TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      );
      labelPainter.layout();
      final lh = labelPainter.height;
      final labelY = screenRect.top - lh - 4 < 0
          ? screenRect.bottom + 4
          : screenRect.top - lh - 4;
      canvas.drawRect(
        Rect.fromLTWH(
            screenRect.left, labelY, labelPainter.width + 8, lh + 2),
        labelBgPaint,
      );
      labelPainter.paint(canvas, Offset(screenRect.left + 4, labelY));
    }
  }

  @override
  bool shouldRepaint(covariant _DetectionOverlay oldDelegate) =>
      oldDelegate.detections != detections || oldDelegate.imageSize != imageSize;
}

class _DetectionSummary extends StatelessWidget {
  const _DetectionSummary({required this.detections});

  final List<YoloDetection> detections;

  @override
  Widget build(BuildContext context) {
    final counts = <String, int>{};
    for (final d in detections) {
      counts[d.label] = (counts[d.label] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      constraints: const BoxConstraints(maxHeight: 120),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Detecciones: ${detections.length}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Flexible(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final e in sorted)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Chip(
                      label: Text('${e.value}× ${e.key}'),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
              ],
            ),
          ),
        ],
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
