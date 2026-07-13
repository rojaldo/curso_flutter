#!/usr/bin/env bash
# Wrapper de `flutter build linux` / `flutter run -d linux` que asegura
# que la lib nativa de TensorFlow Lite esté en el bundle (tflite_flutter
# no la incluye para Linux y Flutter no corre los install() rules de CMake).
#
# Uso:
#   bash tooling/build_linux.sh         # build --debug
#   bash tooling/build_linux.sh run     # flutter run -d linux
#   bash tooling/build_linux.sh release # build --release
#
# Requisito: linux/blobs/libtensorflowlite_c-linux.so (descargada una vez,
# ver assets/models/README.md o tooling/yolo_sidecar/setup.sh).

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT="$(cd "$HERE/.." && pwd)"
LIB_SRC="$PROJECT/linux/blobs/libtensorflowlite_c-linux.so"

if [ ! -f "$LIB_SRC" ]; then
  echo "ERROR: Falta $LIB_SRC" >&2
  echo "  Descárgala de https://github.com/tphakala/tflite_c/releases" >&2
  echo "  y guárdala en linux/blobs/libtensorflowlite_c-linux.so" >&2
  exit 1
fi

MODE="${1:-debug}"
case "$MODE" in
  run)
    fvm flutter run -d linux
    ;;
  release)
    fvm flutter build linux --release
    BUNDLE="$PROJECT/build/linux/x64/release/bundle"
    ;;
  debug|"")
    fvm flutter build linux --debug
    BUNDLE="$PROJECT/build/linux/x64/debug/bundle"
    ;;
  *)
    echo "Uso: $0 [debug|release|run]" >&2
    exit 1
    ;;
esac

if [ "${MODE:-debug}" != "run" ]; then
  mkdir -p "$BUNDLE/blobs"
  cp -f "$LIB_SRC" "$BUNDLE/blobs/libtensorflowlite_c-linux.so"
  echo "✓ Copied libtensorflowlite_c-linux.so -> $BUNDLE/blobs/"
fi