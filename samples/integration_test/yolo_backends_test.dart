// Test de integración — verifica que el sidecar PyTorch (para .pt) carga
// un modelo y ejecuta detect() sin lanzar excepciones.
//
// El test del TfliteBackend se omite en CI porque requiere la lib nativa
// libtensorflowlite_c-linux.so copiada al bundle del test (Flutter test
// recompila el bundle sin correr nuestro script post-build). El TFLite
// backend se valida manualmente lanzando la app con `bash tooling/build_linux.sh run`.
//
// Ejecutar con:
//   fvm flutter test integration_test/yolo_backends_test.dart -d linux

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:sample_app/ui/features/camera/services/yolo_backend.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PytorchSidecarBackend carga yolov8n.pt y detecta', () async {
    final backend = PytorchSidecarBackend();
    try {
      await backend.load('assets/models/yolov8n.pt');
      expect(backend.loadedAssetPath, 'assets/models/yolov8n.pt');

      // Imagen de test 320x240 gris — no debería lanzar (detecciones vacías).
      final image = img.Image(width: 320, height: 240);
      img.fill(image, color: img.ColorRgb8(128, 128, 128));
      final dets = await backend.detect(image, 320, 240);
      expect(dets, isA<List>());
      expect(dets, isEmpty);
    } finally {
      backend.dispose();
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
}