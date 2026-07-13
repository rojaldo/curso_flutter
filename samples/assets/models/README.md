# Modelos YOLOv8 (TFLite + PyTorch)

Esta carpeta contiene los modelos usados por el ejercicio
`/exercise_yolo` (detección sobre imagen estática con selector de modelo).

## Formatos soportados

| Extensión | Backend | Cómo se ejecuta | Setup |
|---|---|---|---|
| `.tflite` | `TfliteBackend` | In-process con `tflite_flutter` (rápido) | `libtensorflowlite_c-linux.so` en `linux/blobs/` |
| `.pt` | `PytorchSidecarBackend` | Sidecar Python con `ultralytics` | `bash tooling/yolo_sidecar/setup.sh` (one-time) |

El selector lista **todos** los archivos de esta carpeta (vía `AssetManifest`),
ordenando primero los `.tflite` (icono verde ⚡) y luego los `.pt` (icono azul 🔥).
El usuario puede cambiar de modelo en caliente sin reiniciar la app.

## Setup Linux (one-time)

### 1. Lib nativa de TensorFlow Lite (para `.tflite`)

`tflite_flutter` no incluye la lib nativa para Linux. Descárgala una vez:

```bash
mkdir -p linux/blobs
curl -sSL -o /tmp/tflite_c.tar.gz \
  https://github.com/tphakala/tflite_c/releases/download/v2.17.1/tflite_c_v2.17.1_linux_amd64.tar.gz
tar -xzf /tmp/tflite_c.tar.gz -C /tmp/tflite_c_extract
cp /tmp/tflite_c_extract/libtensorflowlite_c.so.2.17.1 \
   linux/blobs/libtensorflowlite_c-linux.so
```

Flutter no copia `linux/blobs/` al bundle automáticamente — usa el wrapper:

```bash
bash tooling/build_linux.sh debug    # o `run` o `release`
```

### 2. Venv Python con ultralytics (para `.pt`)

```bash
bash tooling/yolo_sidecar/setup.sh
```

Esto crea `tooling/yolo_sidecar/.venv/` con `ultralytics` + `torch` (CPU).
Requiere Python 3.12 (TF/ultralytics aún no soportan 3.14) y `uv` o `pip`.

Sin este setup, seleccionar un `.pt` muestra el error:
> "No se pudo lanzar el sidecar Python en 'python3'. Ejecuta
> tooling/yolo_sidecar/setup.sh primero."

## Conversión PT → TFLite (opcional, si quieres ambas variantes)

```bash
uv venv --python 3.12 /tmp/yolo312
uv pip install --python /tmp/yolo312/bin/python \
  ultralytics "tensorflow-cpu<2.18" ai-edge-litert
cd assets/models
/tmp/yolo312/bin/python -c "
from ultralytics import YOLO
YOLO('yolov8s.pt').export(format='tflite', imgsz=640)
"
```

Forma de entrada: `1x640x640x3` float32 normalizado 0..1.
Forma de salida: `1x84x8400` (84 = `[cx, cy, w, h, 80 clases COCO]`).

## Modelos incluidos actualmente

| Archivo | Tamaño | Backend | Velocidad | mAP COCO |
|---|---|---|---|---|
| `yolov8n.tflite` | ~13 MB | TFLite | ⚡⚡⚡ | 37.3 |
| `yolov8s.tflite` | ~43 MB | TFLite | ⚡⚡ | 44.9 |
| `yolov8m.tflite` | ~100 MB | TFLite | ⚡ | 50.2 |
| `yolov8l.tflite` | ~167 MB | TFLite | 🐢 | 52.9 |
| `yolov8n.pt` | 6.3 MB | Sidecar PyTorch | ⚡⚡⚡ | 37.3 |
| `yolov8s.pt` | 22 MB | Sidecar PyTorch | ⚡⚡ | 44.9 |
| `yolov8m.pt` | 50 MB | Sidecar PyTorch | ⚡ | 50.2 |
| `yolov8l.pt` | 84 MB | Sidecar PyTorch | 🐢 | 52.9 |

## Cómo funciona el sidecar (detalle técnico)

Flutter no puede cargar `.pt` directamente — el plugin `tflite_flutter` solo
soporta `.tflite`. Para ejecutar PyTorch, la app lanza un proceso hijo
`python tooling/yolo_sidecar/yolo_sidecar.py` que carga el modelo con
`ultralytics` y sirve inferencia por stdin/stdout con JSON line-delimited:

```
App Flutter                    Sidecar Python
    │ ── spawn process ─────────> │
    │ <── {"ready": true} ─────── │
    │ ── {"cmd":"load",...} ───> │
    │ <── {"ok":true,"labels":…} │
    │ ── {"cmd":"detect",...} ─> │
    │ <── {"ok":true,"detections":[…]}
    │ ── {"cmd":"shutdown"} ───> │
    │                             │ exit 0
```

El asset `.pt` se extrae a un archivo temporal al iniciar el backend (el
sidecar necesita un path absoluto del filesystem, no un asset del bundle).
Las detecciones se devuelven en píxeles de la imagen original — el
`CustomPainter` de la UI solo escala al tamaño renderizado del widget.

## Verificación

```bash
# Test del sidecar Python (valida .pt end-to-end):
fvm flutter test integration_test/yolo_backends_test.dart -d linux

# Lanzar la app completa:
bash tooling/build_linux.sh run
```