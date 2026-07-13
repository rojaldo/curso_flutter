#!/usr/bin/env python3
"""Sidecar Python para inferencia YOLOv8 sobre modelos .pt (PyTorch).

Flutter no puede cargar .pt directamente (tflite_flutter solo soporta .tflite).
Este proceso se lanza como hijo de la app Flutter y comunica por stdin/stdout
con JSON line-delimited.

Protocolo (una línea JSON por request, una línea JSON por response):

  Request  -> {"cmd": "load", "model_abs": "/abs/path/yolov8s.pt"}
  Response <- {"ok": true, "labels": ["person", "bicycle", ...]} |
              {"ok": false, "error": "..."}

  Request  -> {"cmd": "detect", "image_abs": "/abs/path/img.jpg"}
  Response <- {"ok": true,
               "width": 1920, "height": 1080,
               "detections": [
                 {"class_id": 0, "label": "person", "confidence": 0.87,
                  "x1": 10, "y1": 20, "x2": 100, "y2": 200},
                 ...
               ]} |
              {"ok": false, "error": "..."}

  Request  -> {"cmd": "shutdown"}
  Response <- (none, process exits 0)

Las coordenadas de las detecciones vienen en píxeles de la imagen ORIGINAL
(no del espacio 640x640 del modelo) — el postprocesamiento completo
(NMS incluido) lo hace Ultralytics internamente.
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path


def _log(msg: str) -> None:
    # Logs a stderr (no interfieren con el protocolo stdout).
    sys.stderr.write(f"[yolo_sidecar] {msg}\n")
    sys.stderr.flush()


def _send(obj: dict) -> None:
    sys.stdout.write(json.dumps(obj) + "\n")
    sys.stdout.flush()


def _send_ok(**fields) -> None:
    payload = {"ok": True}
    payload.update(fields)
    _send(payload)


def _send_err(msg: str) -> None:
    _send({"ok": False, "error": msg})


def _load_model(path: str):
    from ultralytics import YOLO
    if not Path(path).exists():
        raise FileNotFoundError(f"Modelo no encontrado: {path}")
    return YOLO(path)


def _detect(model, image_path: str) -> dict:
    if not Path(image_path).exists():
        raise FileNotFoundError(f"Imagen no encontrada: {image_path}")
    results = model(image_path, verbose=False)
    out = []
    width = height = 0
    for r in results:
        if width == 0 and r.boxes is not None and r.orig_shape is not None:
            height, width = int(r.orig_shape[0]), int(r.orig_shape[1])
        if r.boxes is None:
            continue
        # r.boxes.xyxy: tensor [N, 4] en píxeles originales
        # r.boxes.conf: tensor [N]
        # r.boxes.cls:  tensor [N]
        import torch
        xyxy = r.boxes.xyxy.tolist()
        conf = r.boxes.conf.tolist()
        cls = r.boxes.cls.tolist()
        names = r.names  # dict {0: 'person', 1: 'bicycle', ...}
        for box, c, k in zip(xyxy, conf, cls):
            cid = int(k)
            out.append({
                "class_id": cid,
                "label": names.get(cid, f"cls{cid}"),
                "confidence": float(c),
                "x1": int(box[0]), "y1": int(box[1]),
                "x2": int(box[2]), "y2": int(box[3]),
            })
    return {"width": width, "height": height, "detections": out}


def main() -> int:
    _log("sidecar starting, waiting for commands on stdin...")
    # Señal de "listo" — la app espera esta línea antes de mandar commands.
    _send({"ok": True, "ready": True})

    model = None
    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            req = json.loads(line)
        except json.JSONDecodeError as e:
            _send_err(f"JSON inválido: {e}")
            continue

        cmd = req.get("cmd")
        try:
            if cmd == "load":
                path = req.get("model_abs", "")
                _log(f"loading model: {path}")
                model = _load_model(path)
                names = getattr(model, "names", {})
                labels = [names[i] for i in sorted(names.keys())] if names else []
                _send_ok(labels=labels)
            elif cmd == "detect":
                if model is None:
                    _send_err("Modelo no cargado — envía 'load' primero.")
                    continue
                img = req.get("image_abs", "")
                _log(f"detect: {img}")
                result = _detect(model, img)
                _send_ok(**result)
            elif cmd == "shutdown":
                _log("shutdown received, exiting.")
                return 0
            else:
                _send_err(f"Comando desconocido: {cmd!r}")
        except Exception as e:
            _log(f"ERROR handling {cmd}: {e}")
            _send_err(str(e))

    _log("stdin closed, exiting.")
    return 0


if __name__ == "__main__":
    sys.exit(main())