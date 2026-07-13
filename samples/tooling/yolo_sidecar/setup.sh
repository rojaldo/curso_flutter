#!/usr/bin/env bash
# Crea un venv Python 3.12 con ultralytics para que el sidecar pueda
# cargar modelos .pt (PyTorch). Flutter no puede ejecutar .pt directamente.
#
# Uso:
#   bash tooling/yolo_sidecar/setup.sh
#
# Requisitos:
#   - Python 3.12 instalado (TF no tiene wheels para 3.14 todavía)
#   - uv (recomendado, más rápido) o pip
#
# Salida:
#   tooling/yolo_sidecar/.venv/bin/python  -> intérprete con ultralytics
#
# La app Flutter busca el binario en este orden:
#   1. $YOLO_SIDECAR_PYTHON (env var, sobreescribe todo)
#   2. tooling/yolo_sidecar/.venv/bin/python (este script lo crea)
#   3. python3 del PATH (último recurso — asume ultralytics global)

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV="$HERE/.venv"
REQ="$HERE/requirements.txt"

echo "=== Setup YOLO sidecar venv ==="
echo "  dir: $HERE"
echo "  venv: $VENV"

# 1. Crear venv con Python 3.12
if [ -d "$VENV" ]; then
  echo "  venv ya existe, reusando."
else
  if command -v uv >/dev/null 2>&1; then
    echo "  creando venv con uv (Python 3.12)..."
    uv venv --python 3.12 "$VENV"
  else
    PY312=""
    for cand in python3.12 python3.12.9 python3.12.10; do
      command -v "$cand" >/dev/null 2>&1 && PY312="$cand" && break
    done
    if [ -z "$PY312" ]; then
      echo "ERROR: Necesitas Python 3.12 instalado o 'uv'." >&2
      echo "  Instala uv:  curl -LsSf https://astral.sh/uv/install.sh | sh" >&2
      echo "  O Python 3.12:  https://www.python.org/downloads/" >&2
      exit 1
    fi
    echo "  creando venv con $PY312 -m venv..."
    "$PY312" -m venv "$VENV"
  fi
fi

# 2. Instalar dependencias
PY="$VENV/bin/python"
echo "=== Instalando dependencias en $VENV ==="
if command -v uv >/dev/null 2>&1; then
  uv pip install --python "$PY" -r "$REQ"
else
  "$PY" -m pip install --upgrade pip
  "$PY" -m pip install -r "$REQ"
fi

echo "=== Verificación ==="
"$PY" -c "import ultralytics; print('ultralytics:', ultralytics.__version__)"

echo "=== DONE ==="
echo "El sidecar usará: $PY"
echo "Asegúrate de que la app Flutter apunta a este binario"
echo "(lo hace automáticamente si el venv está en la ruta estándar)."