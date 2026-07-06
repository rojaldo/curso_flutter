# Curso Completo de YOLO: Detección de Objetos con Deep Learning
## Duración: 25 horas | 10 Módulos

---

# Módulo 1: Fundamentos de Visión Artificial (3h)

## 1.1 ¿Qué es la Visión Artificial?

### Introducción

Imagina que pudieras darle ojos a una computadora. No solo eso, sino también la capacidad de entender lo que ve: reconocer un rostro entre una multitud, distinguir un perro de un gato, o detectar un semáforo en rojo mientras conduces. Eso es exactamente lo que hace la visión artificial: permite que las máquinas "vean" y comprendan el mundo visual de manera similar a como lo hacemos los humanos.

La visión artificial es una rama de la inteligencia artificial que entrena a las computadoras para interpretar y comprender el mundo visual. Utilizando modelos de aprendizaje profundo (deep learning), los sistemas pueden identificar objetos, clasificarlos, rastrear sus movimientos, y tomar decisiones basadas en lo que "ven".

### Explicación Detallada

**¿Cómo funciona la visión artificial?**

El proceso de visión artificial imita en cierta forma la visión humana, pero con diferencias importantes:

1. **Adquisición de imagen**: Una cámara captura luz y la convierte en señales digitales. A diferencia del ojo humano, que tiene un solo "sensor" (la retina), las cámaras pueden tener múltiples lentes, diferentes resoluciones, y capacidades especiales como visión nocturna o térmica.

2. **Preprocesamiento**: La imagen cruda se normaliza, redimensiona, y limpia de ruido. Este paso es crucial porque los modelos de IA son sensibles a las variaciones en la entrada.

3. **Extracción de características**: Aquí es donde ocurre la magia del deep learning. Las redes neuronales convolucionales (CNNs) detectan patrones: primero bordes simples, luego formas, después objetos complejos. Es como si la red aprendiera a "ver" de manera jerárquica.

4. **Interpretación**: Los patrones extraídos se clasifican, localizan o segmentan según la tarea. El sistema puede responder preguntas como: "¿Qué es esto?", "¿Dónde está?", "¿Cuántos hay?".

**¿Por qué es importante la visión artificial?**

La visión artificial está transformando industrias enteras porque permite automatizar tareas que antes requerían ojos y juicio humanos:

- **Vehículos autónomos**: Tesla, Waymo y otros usan visión artificial para detectar peatones, señales de tráfico, otros vehículos, y tomar decisiones de conducción en tiempo real. Un auto autónomo procesa imágenes de múltiples cámaras simultáneamente para crear un mapa 3D del entorno.

- **Medicina**: Los radiólogos usan sistemas de IA que pueden detectar tumores en radiografías con mayor precisión que expertos humanos. La visión artificial analiza imágenes de resonancias magnéticas, tomografías, y fotografías de piel para identificar enfermedades.

- **Seguridad y vigilancia**: Los sistemas modernos no solo graban, sino que detectan comportamientos sospechosos, reconocen rostros, y alertan automáticamente sobre intrusos.

- **Industria manufacturera**: En líneas de producción, cámaras inspeccionan productos a alta velocidad, detectando defectos invisibles al ojo humano y clasificando productos por calidad.

- **Agricultura de precisión**: Drones con cámaras multiespectrales detectan plagas, miden la salud de cultivos, y optimizan el uso de fertilizantes y agua.

**El rol de YOLO en la visión artificial**

YOLO (You Only Look Once) representa un cambio de paradigma en la detección de objetos. A diferencia de métodos anteriores que escaneaban la imagen región por región (como R-CNN), YOLO procesa toda la imagen en una sola pasada. Esto lo hace increíblemente rápido: puede procesar 45-280 frames por segundo, dependiendo del modelo y hardware.

### Ejemplo Práctico

```python
# Ejemplo: Importar librerías esenciales para visión artificial
import cv2
import numpy as np
from PIL import Image
import matplotlib.pyplot as plt

# Verificar instalación
print(f"OpenCV version: {cv2.__version__}")
print(f"NumPy version: {np.__version__}")
```

Este código importa las librerías fundamentales:
- **OpenCV (cv2)**: La librería más usada para procesamiento de imágenes. Proporciona funciones para leer, escribir, transformar, y analizar imágenes.
- **NumPy**: El motor de cálculo numérico. Las imágenes se representan como arrays multidimensionales de NumPy.
- **PIL (Pillow)**: Alternativa para manipulación de imágenes con una interfaz más simple.
- **Matplotlib**: Para visualización de resultados y gráficas.

### Puntos Clave

- La visión artificial permite que las máquinas interpreten el mundo visual
- Se basa en redes neuronales profundas que aprenden patrones jerárquicos
- Las aplicaciones abarcan desde autos autónomos hasta diagnóstico médico
- YOLO revolucionó la detección de objetos con su enfoque de una sola pasada

### Referencias

- [Documentación oficial de Ultralytics](https://docs.ultralytics.com/)
- [OpenCV Documentation](https://docs.opencv.org/)
- [Papers With Code - Computer Vision](https://paperswithcode.com/area/computer-vision)

---

## 1.2 Detección de Objetos: Conceptos Fundamentales

### Introducción a Intersection over Union (IoU)

Imagina que estás jugando a tirar aros a una botella. ¿Cómo sabes si tu tiro fue bueno? Si el aro cae exactamente sobre la botella, es un éxito perfecto. Si cae lejos, es un fallo. Pero, ¿qué pasa si el aro cubre parcialmente la botella? Necesitamos una forma de medir qué tan bien se superponen dos objetos en un espacio bidimensional.

En detección de objetos, el modelo predice dónde está un objeto dibujando un rectángulo (bounding box). Pero esta predicción casi nunca es perfecta. IoU nos da una puntuación objetiva de qué tan buena fue esa predicción comparándola con la realidad.

### Explicación Detallada de IoU

**¿Qué es exactamente IoU?**

IoU (Intersection over Union) es una métrica que calcula el ratio entre el área de superposición de dos rectángulos y el área total que ambos rectángulos cubren juntos.

La fórmula es simple pero poderosa:
- **Intersección**: El área donde los dos rectángulos se superponen
- **Unión**: El área total cubierta por ambos rectángulos (sin contar dos veces la superposición)
- **IoU = Intersección / Unión**

**Valores posibles y su interpretación:**

- **IoU = 0**: Los rectángulos no se tocan en absoluto. La predicción es totalmente incorrecta.
- **IoU = 1**: Los rectángulos son idénticos. La predicción es perfecta.
- **IoU = 0.5**: Generalmente se considera el umbral mínimo para una detección "aceptable".
- **IoU = 0.75**: Una detección de buena calidad.
- **IoU > 0.9**: Detección casi perfecta, raramente alcanzada en condiciones reales.

**¿Por qué es importante IoU?**

1. **Evaluación en tiempo real**: Durante el entrenamiento, IoU permite evaluar la calidad de las detecciones y guiar el aprendizaje del modelo.

2. **Non-Maximum Suppression (NMS)**: Cuando un modelo detecta el mismo objeto múltiples veces, IoU se usa para determinar cuáles detecciones son duplicados y cuáles son objetos diferentes.

3. **Base para mAP**: La métrica principal de evaluación (mean Average Precision) depende de IoU para determinar qué detecciones cuentan como correctas.

4. **Ajuste de sensibilidad**: Podemos ser más o menos estrictos según la aplicación. En una aplicación médica podríamos requerir IoU > 0.8, mientras que en una de vigilancia básica IoU > 0.4 podría ser suficiente.

**Analogía del mundo real:**

Piensa en IoU como medir qué tan bien encaja una pieza de puzzle en su lugar correcto. Una pieza que encaja perfectamente tiene IoU=1. Una pieza que está en la posición equivocada pero tocando el área correcta tiene un IoU bajo. Una pieza en un lugar totalmente diferente tiene IoU=0.

### Ejemplo Práctico: Cálculo de IoU

```python
def calculate_iou(box1, box2):
    """
    Calcula IoU entre dos bounding boxes.
    
    Args:
        box1: [x1, y1, x2, y2] coordenadas de la primera caja
        box2: [x1, y1, x2, y2] coordenadas de la segunda caja
    
    Returns:
        float: Valor IoU entre 0 y 1
    
    Explicación visual:
    
    Coordenadas en sistema de imagen (origen en esquina superior izquierda):
    
    (x1,y1) ─────────────── (x2,y1)
       │                       │
       │    Bounding Box      │
       │                       │
    (x1,y2) ─────────────── (x2,y2)
    """
    # Paso 1: Encontrar las coordenadas del rectángulo de intersección
    # La intersección comienza en el máximo de los lados izquierdos
    # y termina en el mínimo de los lados derechos
    x1_inter = max(box1[0], box2[0])  # Lado izquierdo de la intersección
    y1_inter = max(box1[1], box2[1])  # Lado superior de la intersección
    x2_inter = min(box1[2], box2[2])  # Lado derecho de la intersección
    y2_inter = min(box1[3], box2[3])  # Lado inferior de la intersección
    
    # Paso 2: Calcular área de intersección
    # Si las cajas no se superponen, la intersección es 0
    inter_width = max(0, x2_inter - x1_inter)
    inter_height = max(0, y2_inter - y1_inter)
    inter_area = inter_width * inter_height
    
    # Paso 3: Calcular áreas de cada caja individual
    area1 = (box1[2] - box1[0]) * (box1[3] - box1[1])
    area2 = (box2[2] - box2[0]) * (box2[3] - box2[1])
    
    # Paso 4: Calcular área de unión
    # Unión = Área1 + Área2 - Intersección (para no contar dos veces)
    union_area = area1 + area2 - inter_area
    
    # Paso 5: Calcular IoU
    # Evitamos división por cero si ambas cajas tienen área 0
    iou = inter_area / union_area if union_area > 0 else 0
    
    return iou

# Ejemplo de uso con cajas que se superponen parcialmente
box_predicha = [50, 50, 150, 150]   # Caja predicha por el modelo
box_real = [60, 60, 160, 160]       # Caja real (ground truth)
iou = calculate_iou(box_predicha, box_real)
print(f"IoU: {iou:.4f}")  # Resultado: IoU ≈ 0.70
```

**Análisis del ejemplo:**
- La caja predicha va de (50,50) a (150,150), es decir, 100x100 píxeles
- La caja real va de (60,60) a (160,160), también 100x100 píxeles
- La intersección es el rectángulo de (60,60) a (150,150) = 90x90 = 8100 píxeles²
- La unión es 10000 + 10000 - 8100 = 11900 píxeles²
- IoU = 8100 / 11900 ≈ 0.68 (una detección bastante buena)

### Introducción a Non-Maximum Suppression (NMS)

Imagina que estás contando personas en una foto. El modelo de detección, siendo conservador, podría detectar la misma persona tres veces: una detección muy segura y dos menos seguras pero aún por encima del umbral de confianza. ¿Cuál de estas tres detecciones conservamos? Non-Maximum Suppression resuelve este problema.

### Explicación Detallada de NMS

**El problema de las detecciones múltiples:**

Los detectores modernos como YOLO pueden generar miles de "propuestas" de detección. Un mismo objeto puede ser detectado múltiples veces con ligeras variaciones en la posición del bounding box. Sin NMS, verías múltiples cajas superpuestas alrededor del mismo objeto, lo cual es confuso e inútil.

**Cómo funciona NMS:**

1. **Ordenar detecciones**: Todas las detecciones se ordenan por confianza (de mayor a menor).

2. **Seleccionar la mejor**: La detección con mayor confianza se marca como "mantener".

3. **Eliminar superpuestas**: Todas las detecciones que tienen IoU alto con la detección seleccionada se eliminan (son consideradas duplicados).

4. **Repetir**: El proceso continúa con la siguiente detección más confiable que no haya sido eliminada.

**Parámetro clave - IoU threshold:**
- Un threshold alto (0.9) solo elimina detecciones casi idénticas. Puede dejar algunos duplicados.
- Un threshold bajo (0.3) elimina detecciones que se superponen moderadamente. Riesgo: puede eliminar detecciones de objetos cercanos pero diferentes.
- El valor típico es 0.5-0.7, un balance entre eliminar duplicados y mantener objetos cercanos.

**¿Por qué se llama "Non-Maximum"?**
Porque suprime (elimina) todas las detecciones que NO son la máxima (la de mayor confianza) en una región local.

### Ejemplo Práctico: Implementación de NMS

```python
def non_max_suppression(boxes, scores, iou_threshold=0.5):
    """
    Aplica Non-Maximum Suppression.
    
    Args:
        boxes: Lista de bounding boxes [x1, y1, x2, y2]
        scores: Confidence scores de cada caja
        iou_threshold: Umbral IoU para suprimir cajas
    
    Returns:
        Lista de índices de cajas a mantener
    
    Explicación del algoritmo:
    
    1. Ordenamos todas las detecciones por confianza descendente
    2. Tomamos la detección con mayor confianza
    3. Eliminamos todas las detecciones que se superponen mucho con ella
    4. Repetimos hasta que no queden detecciones
    
    Esto garantiza que para cada objeto tengamos solo UNA detección:
    la más confiable.
    """
    # Paso 1: Ordenar por score descendente
    # El índice con mayor score va primero
    indices = sorted(range(len(scores)), key=lambda i: scores[i], reverse=True)
    
    keep = []  # Lista de índices a mantener
    
    while indices:
        # Tomar la caja con mayor score que queda
        current = indices.pop(0)
        keep.append(current)
        
        # Filtrar cajas con alta superposición (IoU > threshold)
        # Solo conservamos las que NO se superponen mucho
        indices = [
            i for i in indices
            if calculate_iou(boxes[current], boxes[i]) < iou_threshold
        ]
    
    return keep

# Ejemplo práctico: tres detecciones, dos son del mismo objeto
boxes = [
    [50, 50, 150, 150],    # Detección 1: persona (muy buena)
    [55, 55, 155, 155],    # Detección 2: misma persona, ligeramente diferente
    [200, 200, 300, 300],  # Detección 3: persona diferente
]
scores = [0.95, 0.85, 0.90]  # Confianza de cada detección

keep_indices = non_max_suppression(boxes, scores, iou_threshold=0.5)
print(f"Cajas mantenidas: {keep_indices}")
# Resultado: [0, 2] - La detección 1 (mejor score) y la detección 3 (objeto diferente)
# La detección 2 se elimina porque es un duplicado de la 1
```

### Introducción a Métricas de Evaluación

Entrenar un modelo es solo la mitad del trabajo. Necesitamos formas objetivas de medir qué tan bueno es. En detección de objetos, las métricas tradicionales de clasificación se extienden para considerar también la localización de objetos.

### Explicación Detallada de Métricas

**Precision, Recall y F1-Score:**

Estas tres métricas trabajan juntas para dar una imagen completa del rendimiento:

- **Precision (Precisión)**: De todas las detecciones que hizo el modelo, ¿cuántas eran correctas?
  - Fórmula: TP / (TP + FP)
  - Alta precision = pocas falsas alarmas
  - Ejemplo: Si detectas 10 objetos y 8 son correctos, precision = 0.8

- **Recall (Sensibilidad)**: De todos los objetos que realmente existen, ¿cuántos detectó el modelo?
  - Fórmula: TP / (TP + FN)
  - Alto recall = detecta la mayoría de objetos
  - Ejemplo: Si hay 10 objetos reales y detectas 8, recall = 0.8

- **F1-Score**: Media armónica de precision y recall. Balancea ambas métricas.
  - Fórmula: 2 * (Precision * Recall) / (Precision + Recall)
  - Útil cuando necesitas un solo número que represente el rendimiento

**Trade-off Precision-Recall:**
Generalmente hay una tensión entre precision y recall:
- Umbral de confianza alto → Alta precision, bajo recall (solo detecciones muy seguras)
- Umbral de confianza bajo → Bajo precision, alto recall (detecta más, pero con más errores)

### Ejemplo Práctico: Cálculo de Métricas

```python
def calculate_metrics(tp, fp, fn):
    """
    Calcula Precision, Recall y F1-Score.
    
    Args:
        tp: True Positives - Detecciones correctas
        fp: False Positives - Detecciones incorrectas (falsas alarmas)
        fn: False Negatives - Objetos no detectados
    
    Returns:
        dict con precision, recall, f1
    
    Interpretación:
    
    - tp (True Positive): El modelo detectó un objeto que realmente existe
    - fp (False Positive): El modelo detectó algo que no es un objeto (falsa alarma)
    - fn (False Negative): Hay un objeto real que el modelo no detectó
    
    Ejemplo: En una imagen con 100 personas:
    - Modelo detecta 90 objetos, de los cuales 85 son personas reales
    - tp = 85, fp = 5 (detectó 5 cosas que no eran personas)
    - fn = 15 (no detectó 15 personas reales)
    """
    precision = tp / (tp + fp) if (tp + fp) > 0 else 0
    recall = tp / (tp + fn) if (tp + fn) > 0 else 0
    f1 = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0
    
    return {
        'precision': precision,
        'recall': recall,
        'f1': f1
    }

# Ejemplo: detector de personas
# tp = 85: 85 personas detectadas correctamente
# fp = 15: 15 cosas detectadas que no eran personas (falsas alarmas)
# fn = 20: 20 personas reales que no fueron detectadas
metrics = calculate_metrics(tp=85, fp=15, fn=20)
print(f"Precision: {metrics['precision']:.2%}")  # 85% de las detecciones son correctas
print(f"Recall: {metrics['recall']:.2%}")        # 81% de las personas fueron detectadas
print(f"F1-Score: {metrics['f1']:.2%}")          # Balance entre ambas: 83%
```

### Introducción a Mean Average Precision (mAP)

Si tuviéramos que elegir UNA métrica para evaluar un detector de objetos, sería mAP. Esta métrica resume el rendimiento del modelo en todas las clases y todos los umbrales de confianza.

### Explicación Detallada de mAP

**¿Qué es Average Precision (AP)?**

Average Precision es el área bajo la curva Precision-Recall para una clase específica. Imagina que varías el umbral de confianza de 0 a 1 y graficas precision vs recall. El área bajo esa curva es el AP.

**¿Qué es mean Average Precision (mAP)?**

Es simplemente el promedio de AP de todas las clases:
- mAP = (AP_clase1 + AP_clase2 + ... + AP_claseN) / N

**Variantes de mAP:**

- **mAP@50**: Calcula AP considerando correctas las detecciones con IoU ≥ 0.5. Es la métrica más común y representa una detección "razonablemente buena".

- **mAP@75**: Considera correctas solo detecciones con IoU ≥ 0.75. Mucho más exigente, requiere detecciones muy precisas.

- **mAP@50:95**: Promedia mAP calculado con umbrales IoU de 0.5, 0.55, 0.60, ..., 0.95. Esta métrica, introducida por el dataset COCO, evalúa el modelo en múltiples niveles de exigencia. Es la métrica más importante en papers modernos.

**Interpretación práctica:**

| mAP@50:95 | Interpretación |
|-----------|----------------|
| < 0.20 | Modelo pobre, probablemente mal entrenado |
| 0.20-0.30 | Modelo básico, aceptable para aplicaciones simples |
| 0.30-0.40 | Modelo decente, útil para muchas aplicaciones |
| 0.40-0.50 | Buen modelo, competitivo |
| > 0.50 | Excelente modelo, state-of-the-art en muchos casos |

### Ejemplo Práctico: Cálculo de AP

```python
def calculate_ap(recalls, precisions):
    """
    Calcula Average Precision usando el método de 11 puntos interpolados.
    
    Args:
        recalls: Lista de valores de recall
        precisions: Lista de valores de precision
    
    Returns:
        float: Average Precision
    
    Este método, propuesto por PASCAL VOC, evalúa precision
    en 11 puntos de recall uniformemente distribuidos (0, 0.1, 0.2, ..., 1.0)
    """
    # Asegurar que la curva empieza en (0, 1) y termina en (1, 0)
    recalls = [0.0] + list(recalls) + [1.0]
    precisions = [1.0] + list(precisions) + [0.0]
    
    # Hacer que precision sea monótonamente decreciente
    # Esto significa que la precision nunca aumenta cuando recall aumenta
    # Es una técnica de interpolación para manejar curvas irregulares
    for i in range(len(precisions) - 2, -1, -1):
        precisions[i] = max(precisions[i], precisions[i + 1])
    
    # Calcular AP usando los 11 puntos estándar
    ap = 0
    for recall_threshold in np.arange(0, 1.1, 0.1):
        # Encontrar todas las precisiones donde recall >= threshold
        mask = np.array(recalls) >= recall_threshold
        if mask.any():
            # Tomar la máxima precision para ese nivel de recall
            ap += np.max(np.array(precisions)[mask])
    
    return ap / 11  # Promedio de los 11 puntos
```

### Puntos Clave

- IoU mide qué tan bien se superponen dos bounding boxes, siendo 0 (sin contacto) y 1 (idénticos)
- NMS elimina detecciones duplicadas manteniendo solo la de mayor confianza
- Precision mide exactitud de detecciones, Recall mide completitud
- mAP es la métrica estándar que resume rendimiento en todas las clases
- mAP@50:95 es la métrica más importante y exigente

### Referencias

- [Ultralytics Metrics Guide](https://docs.ultralytics.com/guides/yolo-performance-metrics/)
- [COCO Evaluation Metrics](https://cocodataset.org/#detection-eval)

---

## 1.3 Evolución de Detectores de Objetos

### Introducción

La historia de la detección de objetos es fascinante: en menos de una década, pasamos de sistemas lentos y poco precisos a detectores que pueden procesar video en tiempo real con precisión sobrehumana. Entender esta evolución nos ayuda a apreciar por qué YOLO es tan revolucionario y qué compromisos tuvo que hacer para lograr su velocidad.

### Explicación Detallada

**La era pre-deep learning:**

Antes de 2012, la detección de objetos usaba características manuales (hand-crafted features) como HOG (Histogram of Oriented Gradients) y Haar cascades. Estos métodos eran:
- Lentos: Requerían escanear la imagen en múltiples escalas
- Poco precisos: Las características manuales no capturaban bien la complejidad visual
- Frágiles: Funcionaban solo en condiciones muy controladas

**La revolución de las CNN (2012-2014):**

AlexNet (2012) demostró que las redes neuronales convolucionales podían superar a todos los métodos tradicionales en clasificación de imágenes. R-CNN (2014) aplicó esta idea a detección de objetos, pero con un enfoque de dos etapas:
1. Generar ~2000 regiones candidatas (region proposals)
2. Clasificar cada región con una CNN

Problema: Era extremadamente lento (~47 segundos por imagen).

**Two-Stage Detectors: El enfoque de precisión:**

La familia R-CNN evolucionó:
- **R-CNN (2014)**: Region proposals + CNN. Muy lento.
- **Fast R-CNN (2015)**: Procesa toda la imagen una vez. Más rápido (2 segundos).
- **Faster R-CNN (2015)**: Region proposals aprendidas por la red. Aún más rápido (0.2 segundos, ~5 FPS).

Ventajas: Máxima precisión
Desventajas: Todavía demasiado lento para video en tiempo real

**One-Stage Detectors: El enfoque de velocidad:**

YOLO (2016) propuso una idea radical: ¿Por qué no predecir bounding boxes y clases directamente desde la imagen completa, sin region proposals?

- **YOLO v1 (2016)**: Dividía la imagen en una grilla 7x7, cada celda predecía 2 boxes y probabilidades de clase. 45 FPS, pero menos preciso que Faster R-CNN.
- **SSD (2016)**: Similar a YOLO pero con predicciones a múltiples escalas. Mejor balance.
- **YOLO v2/v3 (2017-2018)**: Mejoras significativas en precisión manteniendo velocidad.

**La evolución moderna:**

- **YOLO v4 (2020)**: Introdujo Bag of Freebies (técnicas de augmentación) y Bag of Specials (módulos mejorados).
- **YOLO v5 (2020, Ultralytics)**: Primera implementación en PyTorch puro, fácil de usar.
- **YOLO v8 (2023)**: Arquitectura anchor-free, mejor segmentación y pose.
- **YOLO v9, v10, v11 (2024)**: Mejoras incrementales en eficiencia y precisión.

**La brecha se cierra:**

Históricamente, two-stage detectors eran más precisos pero más lentos. Con YOLO v8 y v11, esta brecha prácticamente desapareció. Hoy, YOLO es el estándar tanto en precisión como en velocidad.

### Línea Temporal de Detectores

```
2014: R-CNN → 2015: Fast R-CNN → 2015: Faster R-CNN
           ↓
2016: YOLO v1 → 2016: SSD → 2017: YOLO v2
           ↓
2018: YOLO v3 → 2020: YOLO v4 → 2020: YOLO v5
           ↓
2022: YOLO v6, v7 → 2023: YOLO v8 → 2024: YOLO v9, v10, v11
```

### Dos Enfoques Principales

#### 1. Two-Stage Detectors (R-CNN family)

**Ventajas**: Mayor precisión, especialmente en objetos pequeños
**Desventajas**: Más lentos, no aptos para tiempo real

```python
# Concepto: Region proposals (simplificado)
def generate_region_proposals(image, num_proposals=2000):
    """
    Genera regiones candidatas donde pueden haber objetos.
    En la práctica, algoritmos como Selective Search se usan.
    
    El concepto detrás de region proposals:
    - No escaneamos TODA la imagen (muy costoso)
    - En su lugar, identificamos regiones "prometedoras"
    - Estas regiones se basan en similitud de color, textura, etc.
    
    El problema: Generar estas regiones es costoso y
    no es paralelizable fácilmente.
    """
    proposals = []
    # Usar OpenCV para Selective Search
    ss = cv2.ximgproc.segmentation.createSelectiveSearchSegmentation()
    ss.setBaseImage(image)
    ss.switchToSelectiveSearchFast()
    rects = ss.process()
    
    for i, rect in enumerate(rects[:num_proposals]):
        x, y, w, h = rect
        proposals.append([x, y, x + w, y + h])
    
    return proposals
```

#### 2. One-Stage Detectors (YOLO, SSD)

**Ventajas**: Más rápidos, ideales para tiempo real
**Desventajas**: Históricamente menor precisión (brecha cerrada en versiones recientes)

```python
# Concepto: Grid-based detection (simplificado)
def yolo_grid_concept(image_size=416, grid_size=13, num_anchors=3):
    """
    YOLO divide la imagen en una grilla y predice por cada celda.
    
    Concepto clave:
    En lugar de buscar "dónde están los objetos" (region proposals),
    YOLO asume que cada celda de la grilla es responsable de detectar
    el objeto cuyo centro cae dentro de esa celda.
    
    Para una imagen de 416x416 píxeles con grilla 13x13:
    - Cada celda representa 32x32 píxeles (416/13)
    - Cada celda predice múltiples boxes
    - Total de predicciones: 13 * 13 * num_anchors
    """
    cell_size = image_size / grid_size
    predictions_per_cell = num_anchors * (5 + 80)  # 5 box params + 80 classes (COCO)
    
    total_predictions = grid_size * grid_size * num_anchors
    
    print(f"Grid: {grid_size}x{grid_size}")
    print(f"Cell size: {cell_size}x{cell_size} pixels")
    print(f"Total predictions: {total_predictions}")
    print(f"Predictions per cell: {predictions_per_cell}")

yolo_grid_concept()
```

### Comparación Histórica

| Modelo | Año | mAP (COCO) | FPS | Tipo |
|--------|-----|------------|-----|------|
| R-CNN | 2014 | 58.5% | 0.05 | Two-stage |
| Faster R-CNN | 2015 | 73.2% | 7 | Two-stage |
| YOLO v1 | 2016 | 63.4% | 45 | One-stage |
| SSD | 2016 | 74.3% | 59 | One-stage |
| YOLO v3 | 2018 | 57.9% | 51 | One-stage |
| YOLO v5 | 2020 | 56.8% | 140 | One-stage |
| YOLO v8 | 2023 | 53.9% | 280 | One-stage |
| YOLO v11 | 2024 | 54.7% | 290 | One-stage |

**Observaciones:**
- La velocidad aumentó dramáticamente (0.05 FPS → 290 FPS)
- La precisión se mantiene competitiva o supera a métodos más lentos
- YOLO v11 procesa video a casi 300 FPS en GPU moderna

### Puntos Clave

- Los detectores evolucionaron de métodos manuales a CNNs
- Two-stage detectors priorizan precisión, one-stage priorizan velocidad
- YOLO revolucionó el campo con detección en una sola pasada
- Las versiones modernas de YOLO han cerrado la brecha de precisión
- Hoy YOLO domina tanto en precisión como en velocidad

### Referencias

- [YOLO Paper Collection](https://docs.ultralytics.com/models/)
- [Object Detection History](https://lilianweng.github.io/posts/2017-12-31-object-recognition-part-3/)

---

## 1.4 Instalación y Primeros Pasos

### Introducción

Antes de sumergirnos en la teoría y práctica avanzada, necesitamos configurar nuestro entorno de trabajo. La buena noticia es que Ultralytics ha hecho que instalar YOLO sea increíblemente simple: con un solo comando tenemos acceso a los modelos más avanzados.

### Explicación Detallada

**¿Qué es Ultralytics?**

Ultralytics es la empresa detrás de YOLO v5, v8 y v11. Han creado un ecosistema completo que incluye:
- Modelos pre-entrenados listos para usar
- API simple y consistente
- Soporte para múltiples tareas (detección, segmentación, pose, etc.)
- Herramientas de exportación a múltiples formatos
- Documentación extensa y activa comunidad

**Requisitos del sistema:**

- Python 3.8 o superior
- PyTorch 1.8 o superior
- Para GPU: CUDA 11.0+ (NVIDIA)
- Para Apple Silicon: macOS 12.0+
- Mínimo 8GB RAM (16GB+ recomendado para entrenamiento)

**Modelos disponibles:**

Los modelos se nombran siguiendo un patrón:
- `yolo11n.pt`: Nano - El más rápido, menor precisión
- `yolo11s.pt`: Small - Balance velocidad/precisión
- `yolo11m.pt`: Medium - Buena precisión
- `yolo11l.pt`: Large - Alta precisión
- `yolo11x.pt`: Extra Large - Máxima precisión

### Instalación de Ultralytics

```bash
# Instalación básica
pip install ultralytics

# Instalación con todas las dependencias
pip install ultralytics[full]

# Verificar instalación
yolo version
```

```python
# Verificar instalación en Python
from ultralytics import YOLO

# Verificar configuración
import ultralytics
ultralytics.checks()
```

### Primera Detección

```python
from ultralytics import YOLO

# Cargar modelo pre-entrenado
model = YOLO('yolo11n.pt')  # YOLOv11 nano

# Realizar detección en imagen
# El modelo se descarga automáticamente si no existe localmente
results = model('https://ultralytics.com/images/bus.jpg')

# Mostrar resultados
results[0].show()

# Guardar resultados
results[0].save('resultado.jpg')

# Acceder a las detecciones
for result in results:
    boxes = result.boxes
    for box in boxes:
        # Coordenadas
        x1, y1, x2, y2 = box.xyxy[0]
        # Confianza
        confidence = box.conf[0]
        # Clase
        class_id = box.cls[0]
        print(f"Objeto: {result.names[int(class_id)]}")
        print(f"Confianza: {confidence:.2f}")
        print(f"Bounding box: [{x1:.0f}, {y1:.0f}, {x2:.0f}, {y2:.0f}]")
```

**Análisis del código:**

1. **Cargar modelo**: `YOLO('yolo11n.pt')` carga el modelo nano. Si no existe localmente, se descarga automáticamente (~6MB).

2. **Realizar detección**: `model('url')` acepta URLs, paths locales, arrays de numpy, y más. La inferencia es automática.

3. **Acceder a resultados**: El objeto `results` contiene:
   - `boxes`: Bounding boxes detectados
   - `masks`: Máscaras de segmentación (si aplica)
   - `keypoints`: Puntos clave (para pose)
   - `probs`: Probabilidades de clase (para clasificación)

### Detección en Video

```python
from ultralytics import YOLO

model = YOLO('yolo11n.pt')

# Procesar video
results = model.predict(
    source='video.mp4',
    save=True,
    show=True,  # Mostrar en tiempo real
    conf=0.5,   # Umbral de confianza
    stream=True  # Streaming para videos largos
)

for result in results:
    # Procesar cada frame
    boxes = result.boxes
    print(f"Frame: {result.path}, Detecciones: {len(boxes)}")
```

**Parámetros importantes:**

- `save=True`: Guarda el video con detecciones dibujadas
- `stream=True`: Procesa frame por frame sin cargar todo en memoria
- `conf=0.5`: Solo muestra detecciones con confianza > 50%

### Detección en Tiempo Real (Webcam)

```python
from ultralytics import YOLO

model = YOLO('yolo11n.pt')

# Usar cámara web (índice 0)
results = model.predict(
    source=0,
    show=True,
    conf=0.5,
    stream=True
)

for result in results:
    # Procesar cada frame
    # El bucle se ejecuta mientras la ventana esté abierta
    pass
```

**Nota sobre rendimiento:**
- Con `yolo11n.pt` en GPU: 100+ FPS
- Con `yolo11n.pt` en CPU: 10-30 FPS
- Presiona 'q' para cerrar la ventana de visualización

### Puntos Clave

- Ultralytics simplifica el uso de YOLO con una API consistente
- Los modelos se descargan automáticamente
- La inferencia funciona con imágenes, videos, URLs y cámaras
- El modo streaming es esencial para videos largos
- Los modelos más pequeños son ideales para empezar

### Referencias

- [Ultralytics Quickstart](https://docs.ultralytics.com/quickstart/)
- [YOLO11 Documentation](https://docs.ultralytics.com/models/yolo11/)
- [Installation Guide](https://docs.ultralytics.com/quickstart/#install-ultralytics)

---

# Módulo 2: Arquitectura y Modelos YOLO (3h)

## 2.1 Arquitectura YOLO: Componentes Principales

### Introducción

Entender la arquitectura de YOLO es como entender el motor de un auto de carreras. No necesitas saberlo para conducir, pero si quieres optimizar, reparar o modificar, es esencial. La arquitectura de YOLO tiene tres componentes principales que trabajan en conjunto: el Backbone, el Neck y el Head.

### Explicación Detallada

**Anatomía de YOLO:**

```
Imagen de entrada (640x640x3)
        ↓
    BACKBONE (Extractor de características)
        ↓
    Feature maps a múltiples escalas
        ↓
    NECK (Fusión de características)
        ↓
    Features combinadas
        ↓
    HEAD (Predicción)
        ↓
    Bounding boxes + Clases
```

**1. Backbone (Columna vertebral):**

El backbone es responsable de "ver" la imagen y extraer características significativas. Es como el sistema visual del cerebro que detecta bordes, texturas, y formas.

Capas típicas del backbone:
- **Convoluciones iniciales**: Detectan bordes y texturas simples
- **Capas intermedias**: Detectan formas y patrones complejos
- **Capas profundas**: Detectan conceptos de alto nivel (partes de objetos)

El backbone reduce progresivamente la resolución espacial mientras aumenta la profundidad de características. Una imagen 640x640 puede reducirse a mapas de características de 80x80, 40x40, y 20x20.

**2. Neck (Cuello):**

El neck fusiona características de diferentes escalas del backbone. ¿Por qué es esto importante?

- **Objetos pequeños**: Se detectan mejor con características de alta resolución (80x80)
- **Objetos medianos**: Características de resolución media (40x40)
- **Objetos grandes**: Características de baja resolución pero alto nivel semántico (20x20)

El neck combina estas escalas para que el modelo pueda detectar objetos de cualquier tamaño.

**3. Head (Cabeza):**

El head es el componente final que produce las predicciones:
- **Bounding boxes**: 4 valores (x, y, ancho, alto)
- **Objectness score**: Probabilidad de que haya un objeto
- **Class probabilities**: Probabilidades para cada clase

### Backbone (Extracto de Características)

```python
"""
Arquitectura conceptual del Backbone de YOLO

Entrada (imagen RGB)
    ↓
Conv Block (3x3, stride 2) → Reducción espacial
    ↓
C2f Block (CSP Bottleneck)
    ↓
Conv Block (3x3, stride 2)
    ↓
C2f Block
    ↓
... (más bloques)
    ↓
Feature Maps a múltiples escalas
"""

# Componentes típicos del backbone
backbone_components = {
    'Conv': 'Convolución estándar con BatchNorm y activación SiLU',
    'C2f': 'CSP Bottleneck con 2 convoluciones (YOLOv8/v11)',
    'SPPF': 'Spatial Pyramid Pooling - Fast',
    'Focus': 'Reducción de dimensionalidad (versiones anteriores)'
}

for name, desc in backbone_components.items():
    print(f"{name}: {desc}")
```

**Componentes clave del backbone:**

- **Conv Block**: Convolución + Batch Normalization + Activación SiLU. Extrae patrones locales.
- **C2f Block**: Cross Stage Partial bottleneck. Permite flujo de información sin degradación.
- **SPPF**: Spatial Pyramid Pooling Fast. Captura contexto a múltiples escalas.

### Neck (Fusión de Características)

```python
"""
Estructura del Neck (PANet - Path Aggregation Network)

Backbone outputs:
    P3 (80x80) ← características de bajo nivel
    P4 (40x40) ← características de medio nivel
    P5 (20x20) ← características de alto nivel

Flujo Bottom-Up (desde P5):
    P5 → upsampling → concat con P4 → ...
    
Flujo Top-Down:
    ... → concat con P3 → output final

Esto permite que el modelo detecte objetos de diferentes tamaños.
"""

def visualize_neck_concept():
    """
    Visualización conceptual del neck.
    """
    print("=== Neck: Path Aggregation Network ===")
    print("\nBackbone Features:")
    print("  P3 (1/8 scale): 80x80 - Detecta objetos pequeños")
    print("  P4 (1/16 scale): 40x40 - Detecta objetos medianos")
    print("  P5 (1/32 scale): 20x20 - Detecta objetos grandes")
    print("\nFusión:")
    print("  P5 → Upsample → Concat(P4) → C2f → P4'")
    print("  P4' → Upsample → Concat(P3) → C2f → P3'")
    print("  P3' → Downsample → Concat(P4') → C2f → P4''")
    print("  P4'' → Downsample → Concat(P5) → C2f → P5''")

visualize_neck_concept()
```

**¿Por qué múltiples escalas?**

Imagina detectar personas en una imagen:
- Una persona cerca de la cámara ocupa 200x400 píxeles
- Una persona lejos ocupa 20x40 píxeles
- Un modelo de escala única no puede manejar ambas eficientemente

El neck resuelve esto fusionando información de todas las escalas.

### Head (Predicción)

```python
"""
Estructura del Detection Head

Para cada escala de salida:
    Features → Conv → Bounding Box Predictions
            → Conv → Objectness Score
            → Conv → Class Probabilities

Salidas por escala:
    - Bounding boxes: 4 valores (x, y, w, h) o (x1, y1, x2, y2)
    - Objectness: 1 valor
    - Classes: N valores (donde N = número de clases)
"""

# Configuración típica del head
head_config = {
    'num_anchors_per_cell': 3,
    'box_params': 4,  # x, y, w, h
    'objectness': 1,
    'num_classes': 80,  # COCO
    'output_scales': ['P3', 'P4', 'P5']
}

total_params_per_prediction = (
    head_config['box_params'] + 
    head_config['objectness'] + 
    head_config['num_classes']
)

print(f"Parámetros por predicción: {total_params_per_prediction}")
print(f"Anchors por escala: {head_config['num_anchors_per_cell']}")
print(f"Escalas de detección: {head_config['output_scales']}")
```

**Total de predicciones por imagen:**

Para una imagen 640x640:
- Escala P3 (80x80): 80 * 80 * 3 = 19,200 predicciones
- Escala P4 (40x40): 40 * 40 * 3 = 4,800 predicciones
- Escala P5 (20x20): 20 * 20 * 3 = 1,200 predicciones
- **Total: 25,200 predicciones** (muchas serán filtradas por NMS)

### Visualización de la Arquitectura Completa

```python
from ultralytics import YOLO

# Cargar modelo y ver arquitectura
model = YOLO('yolo11n.pt')

# Imprimir información del modelo
print(model.info())

# Exportar modelo a formato ONNX para visualización
model.export(format='onnx', opset=12)

# El archivo .onnx puede visualizarse en:
# https://netron.app/
```

### Puntos Clave

- El backbone extrae características visuales progresivamente más abstractas
- El neck fusiona características de múltiples escalas para detectar objetos de cualquier tamaño
- El head produce las predicciones finales: boxes, objectness, y clases
- YOLO genera miles de predicciones por imagen, filtradas posteriormente
- La arquitectura está optimizada para velocidad sin sacrificar precisión

### Referencias

- [YOLO Architecture Details](https://docs.ultralytics.com/models/yolo11/#architecture)
- [CSPNet Paper](https://arxiv.org/abs/1911.11929)
- [PANet Paper](https://arxiv.org/abs/1803.01534)

---

## 2.2 Familia YOLO: Versiones y Variantes

### Introducción

La familia YOLO ha crecido enormemente desde su creación en 2016. Cada versión trae mejoras en precisión, velocidad, o facilidad de uso. Conocer las diferencias te ayuda a elegir el modelo correcto para tu aplicación.

### Explicación Detallada

**La confusión de las versiones:**

Hay múltiples "familias" de YOLO desarrolladas por diferentes grupos:
- **YOLO original (v1-v3)**: Creado por Joseph Redmon
- **YOLO v4**: Desarrollo comunitario post-Redmon
- **YOLO v5, v8, v11**: Ultralytics (PyTorch nativo)
- **YOLO v6**: Meituan
- **YOLO v7**: WongKinYiu

Este curso se enfoca en YOLO de Ultralytics por su facilidad de uso y documentación extensa.

### YOLOv3 (2018)

```python
from ultralytics import YOLO

# Cargar YOLOv3
model_v3 = YOLO('yolov3.pt')

# Información
print(f"YOLOv3: {model_v3.info()}")
```

**Características:**
- Introdujo detección multi-escala (3 escalas)
- Darknet-53 backbone
- Predicciones en 3 resoluciones diferentes
- Aún usado en aplicaciones legacy

### YOLOv5 (2020) - Ultralytics

```python
# Variantes de YOLOv5
yolov5_variants = {
    'yolov5n': 'Nano - Más rápido, menor precisión',
    'yolov5s': 'Small - Balance velocidad/precisión',
    'yolov5m': 'Medium - Buena precisión',
    'yolov5l': 'Large - Alta precisión',
    'yolov5x': 'Extra Large - Máxima precisión'
}

for variant, desc in yolov5_variants.items():
    print(f"{variant}: {desc}")

# Cargar modelo específico
model_v5s = YOLO('yolov5s.pt')
model_v5m = YOLO('yolov5m.pt')
```

**Innovaciones:**
- Primera implementación en PyTorch puro (fácil de modificar)
- Múltiples tamaños para diferentes casos de uso
- Data augmentation automática (mosaic, mixup)
- Comunidad muy activa

### YOLOv8 (2023)

```python
# Cargar YOLOv8
model_v8 = YOLO('yolov8n.pt')

# Comparar con versiones anteriores
print("=== Comparación YOLOv5 vs YOLOv8 ===")
print("\nYOLOv8 mejoras:")
print("- Anchor-free detection head (más flexible)")
print("- Mejor neck con C2f modules")
print("- Task-aligned sample assignment (mejor entrenamiento)")
print("- Distributed Focal Loss (mejor balance de clases)")
```

**Mejoras clave:**
- Arquitectura anchor-free: No depende de cajas predefinidas
- Mejor rendimiento en segmentación y pose estimation
- Interfaz unificada para todas las tareas

### YOLO11 (2024)

```python
# Cargar YOLOv11
model_v11 = YOLO('yolo11n.pt')

# Variantes disponibles
yolo11_variants = ['yolo11n', 'yolo11s', 'yolo11m', 'yolo11l', 'yolo11x']

for variant in yolo11_variants:
    print(f"Modelo: {variant}")
    # Los modelos se descargan automáticamente
```

**Última versión:**
- Mejor balance precisión/velocidad
- Entrenado con más datos y mejor augmentación
- Soporte para más tareas y formatos de exportación

### YOLO-World (Open-Vocabulary)

Detecta cualquier objeto descrito en texto, no solo clases predefinidas.

```python
# YOLO-World para detección de vocabulario abierto
# Nota: Requiere instalación adicional

from ultralytics import YOLOWorld

# Cargar modelo
model = YOLOWorld('yolov8s-worldv2.pt')

# Definir clases personalizadas en tiempo real
model.set_classes(['person', 'dog', 'cat', 'car', 'bicycle'])

# Detectar
results = model('imagen.jpg')
```

**Aplicación:**
- Detección de objetos sin reentrenar el modelo
- Solo especifica las clases que quieres detectar
- Ideal para prototipado rápido

### Puntos Clave

- YOLO tiene múltiples versiones de diferentes desarrolladores
- Ultralytics (v5, v8, v11) ofrece la mejor experiencia de usuario
- Los modelos nano-small son ideales para edge devices
- Los modelos large-x son para máxima precisión
- YOLO-World permite detección de clases arbitrarias

### Referencias

- [YOLO11 Models](https://docs.ultralytics.com/models/yolo11/)
- [YOLOv8 Models](https://docs.ultralytics.com/models/yolov8/)
- [YOLO-World](https://docs.ultralytics.com/models/yolo-world/)

---

## 2.3 Variantes de Tamaño y Trade-offs

### Introducción

Elegir el tamaño correcto del modelo es crucial. Un modelo muy grande puede ser innecesariamente costoso, mientras que uno muy pequeño puede no tener la precisión necesaria. Entender los trade-offs te ayuda a tomar la decisión correcta.

### Explicación Detallada

**El espectro de tamaños:**

Los modelos YOLO vienen en 5 tamaños estándar:
- **Nano (n)**: ~3M parámetros, ~6MB. Para móviles y edge devices.
- **Small (s)**: ~11M parámetros, ~22MB. Balance para muchos casos.
- **Medium (m)**: ~25M parámetros, ~50MB. Buena precisión.
- **Large (l)**: ~43M parámetros, ~86MB. Alta precisión.
- **Extra Large (x)**: ~68M parámetros, ~136MB. Máxima precisión.

**Trade-offs:**

| Tamaño | Precisión | Velocidad | Memoria | Caso de uso |
|--------|-----------|-----------|---------|-------------|
| Nano | Básica | Muy rápida | Mínima | Móvil, IoT |
| Small | Decente | Rápida | Baja | Edge, tiempo real |
| Medium | Buena | Moderada | Media | Servicios cloud |
| Large | Alta | Lenta | Alta | Alta precisión |
| XL | Máxima | Más lenta | Máxima | Aplicaciones críticas |

### Comparación de Tamaños

```python
import time
from ultralytics import YOLO

def benchmark_models(model_names, image_path):
    """
    Compara rendimiento de diferentes tamaños de modelo.
    
    Este benchmark mide:
    - Tiempo de inferencia promedio
    - FPS (frames por segundo)
    - Número de parámetros
    """
    results = []
    
    for name in model_names:
        model = YOLO(f'{name}.pt')
        
        # Medir tiempo de inferencia
        start = time.time()
        for _ in range(100):  # 100 iteraciones
            result = model(image_path, verbose=False)
        end = time.time()
        
        # Obtener métricas
        avg_time = (end - start) / 100
        fps = 1 / avg_time
        
        results.append({
            'model': name,
            'avg_time_ms': avg_time * 1000,
            'fps': fps,
            'parameters': model.info()['parameters']
        })
    
    return results

# Resultados típicos (GPU V100)
print("=== Trade-offs Tamaño vs Rendimiento ===")
print("\nModelo  | Params | FPS (V100) | mAP50-95")
print("-" * 45)
print("yolo11n | 2.6M   | 290+       | 39.5")
print("yolo11s | 9.4M   | 230+       | 47.0")
print("yolo11m | 20.1M  | 140+       | 51.5")
print("yolo11l | 25.3M  | 105+       | 53.4")
print("yolo11x | 56.9M  | 65+        | 54.7")
```

### Selección de Modelo por Caso de Uso

```python
def recommend_model(use_case):
    """
    Recomienda modelo basado en el caso de uso.
    
    La elección depende de:
    - Hardware disponible (CPU, GPU, edge device)
    - Requisitos de latencia
    - Precisión mínima aceptable
    - Tamaño del modelo para deployment
    """
    recommendations = {
        'mobile_app': {
            'model': 'yolo11n',
            'reason': 'Tamaño pequeño, inferencia rápida en CPU móvil'
        },
        'edge_device': {
            'model': 'yolo11s',
            'reason': 'Balance entre velocidad y precisión en hardware limitado'
        },
        'real_time_video': {
            'model': 'yolo11m',
            'reason': 'Buen balance para 30+ FPS en GPU media'
        },
        'high_accuracy': {
            'model': 'yolo11l or yolo11x',
            'reason': 'Máxima precisión, GPU potente requerida'
        },
        'drone_surveillance': {
            'model': 'yolo11s',
            'reason': 'Detección de objetos pequeños a distancia, velocidad crítica'
        },
        'medical_imaging': {
            'model': 'yolo11x',
            'reason': 'Máxima precisión, tiempo no crítico'
        }
    }
    
    return recommendations.get(use_case, 'Revisar caso específico')

# Uso
case = 'mobile_app'
rec = recommend_model(case)
print(f"Caso: {case}")
print(f"Modelo recomendado: {rec['model']}")
print(f"Razón: {rec['reason']}")
```

### Puntos Clave

- Los modelos más pequeños son más rápidos pero menos precisos
- Nano/small son ideales para edge devices y móviles
- Medium es el punto dulce para muchas aplicaciones
- Large/xlarge son para máxima precisión con hardware potente
- Siempre benchmark en tu hardware específico

### Referencias

- [Model Selection Guide](https://docs.ultralytics.com/models/yolo11/#model-variants)
- [Speed Accuracy Tradeoff](https://docs.ultralytics.com/modes/predict/#speed-accuracy-tradeoff)

---

## 2.4 Tareas YOLO: Más Allá de Detección

### Introducción

YOLO no solo detecta objetos. Puede segmentarlos, estimar poses humanas, clasificar imágenes completas, y detectar objetos rotados. Esta versatilidad lo convierte en una herramienta poderosa para múltiples aplicaciones.

### Explicación Detallada

**Las 5 tareas de YOLO:**

1. **Detection**: Detectar objetos con bounding boxes
2. **Segmentation**: Detectar objetos con máscaras pixel-perfect
3. **Classification**: Clasificar imágenes completas
4. **Pose Estimation**: Detectar keypoints del cuerpo humano
5. **OBB (Oriented Bounding Boxes)**: Detectar objetos rotados

### Detection (Detección de Objetos)

```python
from ultralytics import YOLO

model = YOLO('yolo11n.pt')  # Modelos de detección por defecto

results = model('imagen.jpg')

for box in results[0].boxes:
    print(f"Clase: {results[0].names[int(box.cls[0])]}")
    print(f"Confianza: {box.conf[0]:.2f}")
    print(f"BBox: {box.xyxy[0]}")
```

**Cuándo usar:**
- Conteo de objetos
- Detección de presencia/ausencia
- Tracking de objetos
- La tarea más común y versátil

### Segmentation (Segmentación de Instancias)

```python
# Cargar modelo de segmentación
model_seg = YOLO('yolo11n-seg.pt')

results = model_seg('imagen.jpg')

for result in results:
    if result.masks is not None:
        for i, mask in enumerate(result.masks.data):
            print(f"Máscara {i}: shape {mask.shape}")
            # Acceder a polígonos
            if result.masks.xy:
                polygon = result.masks.xy[i]
                print(f"Polígono: {len(polygon)} puntos")
```

**Cuándo usar:**
- Cuando necesitas saber exactamente qué píxeles pertenecen al objeto
- Análisis médico (tamaño exacto de tumores)
- Medición precisa de áreas
- Background removal

### Classification (Clasificación de Imágenes)

```python
# Cargar modelo de clasificación
model_cls = YOLO('yolo11n-cls.pt')

results = model_cls('imagen.jpg')

for result in results:
    # Top-5 predicciones
    probs = result.probs
    top5 = probs.top5
    top5conf = probs.top5conf
    
    print("Top 5 clases:")
    for i, (cls_idx, conf) in enumerate(zip(top5, top5conf)):
        print(f"  {i+1}. {result.names[cls_idx]}: {conf:.2%}")
```

**Cuándo usar:**
- Una imagen = una clase
- Clasificación de documentos
- Detección de contenido inapropiado
- Reconocimiento de escenas

### Pose Estimation (Estimación de Pose)

```python
# Cargar modelo de pose
model_pose = YOLO('yolo11n-pose.pt')

results = model_pose('persona.jpg')

for result in results:
    if result.keypoints is not None:
        keypoints = result.keypoints.data
        print(f"Personas detectadas: {len(keypoints)}")
        
        # Cada persona tiene 17 keypoints (COCO format)
        # 0: nariz, 1: ojo_izq, 2: ojo_der, 3: oreja_izq, ...
        
        for person_idx, kpts in enumerate(keypoints):
            print(f"\nPersona {person_idx}:")
            # Mostrar keypoints con confianza > 0.5
            for kpt_idx, (x, y, conf) in enumerate(kpts):
                if conf > 0.5:
                    print(f"  Keypoint {kpt_idx}: ({x:.0f}, {y:.0f}) conf={conf:.2f}")
```

**Cuándo usar:**
- Análisis de movimiento deportivo
- Detección de caídas (ancianos)
- Interfaces gesture-based
- Animación de personajes

### Oriented Bounding Boxes (OBB)

```python
# Cargar modelo OBB para objetos rotados
model_obb = YOLO('yolo11n-obb.pt')

results = model_obb('imagen_aerea.jpg')

for result in results:
    if result.obb is not None:
        for obb in result.obb:
            # OBB tiene 5 valores: x_center, y_center, width, height, angle
            print(f"OBB: {obb.xywhr}")  # Formato con rotación
            print(f"Ángulo: {obb.xywhr[0][4]:.2f} radianes")
```

**Cuándo usar:**
- Imágenes aéreas y satelitales
- Documentos escaneados
- Objetos con orientación variable
- Vehículos en estacionamientos

### Puntos Clave

- YOLO soporta 5 tareas diferentes con la misma API
- Cada tarea requiere un modelo específico (-seg, -cls, -pose, -obb)
- Detection es la más versátil y usada
- Segmentation ofrece precisión pixel-perfect
- Pose y OBB son especializados pero muy útiles en sus dominios

### Referencias

- [YOLO Tasks Overview](https://docs.ultralytics.com/tasks/)
- [Segmentation Docs](https://docs.ultralytics.com/tasks/segment/)
- [Classification Docs](https://docs.ultralytics.com/tasks/classify/)
- [Pose Docs](https://docs.ultralytics.com/tasks/pose/)
- [OBB Docs](https://docs.ultralytics.com/tasks/obb/)

---

# Módulo 3: Datasets y Preparación de Datos (3h)

## 3.1 Formato YOLO y Estructura de Directorios

### Introducción

Un modelo es tan bueno como los datos con los que se entrena. La preparación de datos es a menudo el paso más largo y crítico del pipeline de machine learning. Entender el formato YOLO te permite organizar tus datos eficientemente y evitar errores comunes.

### Explicación Detallada

**El formato YOLO:**

YOLO utiliza un formato de anotación simple y eficiente. Cada imagen tiene un archivo de texto correspondiente con el mismo nombre, conteniendo una línea por cada objeto detectado.

**Ventajas del formato YOLO:**
- Simple y legible por humanos
- Eficiente en espacio (archivos de texto pequeños)
- Fácil de generar y modificar programáticamente
- Compatible con todas las versiones de YOLO

### Estructura Estándar

```
dataset/
├── data.yaml          # Configuración del dataset
├── train/
│   ├── images/
│   │   ├── img001.jpg
│   │   ├── img002.jpg
│   │   └── ...
│   └── labels/
│       ├── img001.txt
│       ├── img002.txt
│       └── ...
├── val/
│   ├── images/
│   └── labels/
└── test/
    ├── images/
    └── labels/
```

**Explicación de cada componente:**

- **train/**: Imágenes y etiquetas para entrenamiento (~70-80% del total)
- **val/**: Imágenes para validación durante entrenamiento (~10-15%)
- **test/**: Imágenes para evaluación final (~10-15%)
- **images/**: Archivos de imagen (jpg, png, etc.)
- **labels/**: Archivos de texto con anotaciones

### Archivo data.yaml

```yaml
# data.yaml - Configuración del dataset
path: /path/to/dataset  # Ruta raíz del dataset
train: train/images     # Relativo a 'path'
val: val/images         # Relativo a 'path'
test: test/images       # Relativo a 'path' (opcional)

# Clases
names:
  0: person
  1: bicycle
  2: car
  3: motorcycle
  4: airplane
  # ... más clases

# Número de clases
nc: 80
```

```python
import yaml

# Crear archivo data.yaml programáticamente
dataset_config = {
    'path': '/datasets/mi_dataset',
    'train': 'train/images',
    'val': 'val/images',
    'test': 'test/images',
    'nc': 4,
    'names': {
        0: 'cat',
        1: 'dog',
        2: 'bird',
        3: 'fish'
    }
}

# Guardar configuración
with open('data.yaml', 'w') as f:
    yaml.dump(dataset_config, f, default_flow_style=False)

print("Archivo data.yaml creado")
```

### Formato de Anotaciones YOLO

```
# Formato: class_id x_center y_center width height (normalizado 0-1)
# Cada línea es un objeto

# imagen.txt
0 0.5 0.5 0.3 0.4    # persona en el centro
1 0.2 0.3 0.1 0.15   # bicicleta en esquina superior izquierda
2 0.8 0.7 0.2 0.1    # carro en esquina inferior derecha
```

**Explicación del formato:**

- **class_id**: Índice de la clase (0, 1, 2, ... según `names` en data.yaml)
- **x_center**: Coordenada X del centro del bounding box (normalizada 0-1)
- **y_center**: Coordenada Y del centro del bounding box (normalizada 0-1)
- **width**: Ancho del bounding box (normalizado 0-1)
- **height**: Alto del bounding box (normalizado 0-1)

**¿Por qué normalizar?**
- Hace las anotaciones independientes del tamaño de imagen
- Facilita el data augmentation
- Mejora la estabilidad del entrenamiento

### Crear Anotaciones YOLO

```python
def create_yolo_annotation(image_width, image_height, boxes, output_file):
    """
    Crea archivo de anotación YOLO desde bounding boxes absolutos.
    
    Args:
        image_width: Ancho de la imagen en píxeles
        image_height: Alto de la imagen en píxeles
        boxes: Lista de [class_id, x1, y1, x2, y2]
        output_file: Ruta del archivo de salida
    
    Proceso de conversión:
    1. De coordenadas absolutas a relativas (normalizar)
    2. De formato (x1,y1,x2,y2) a formato YOLO (cx,cy,w,h)
    
    Ejemplo:
    Box absoluto: [0, 100, 100, 200, 300] en imagen 640x480
    Box normalizado: 0 0.234 0.417 0.156 0.417
    """
    with open(output_file, 'w') as f:
        for box in boxes:
            class_id, x1, y1, x2, y2 = box
            
            # Convertir a formato YOLO (normalizado, centro)
            # Centro del box
            x_center = ((x1 + x2) / 2) / image_width
            y_center = ((y1 + y2) / 2) / image_height
            
            # Dimensiones del box
            width = (x2 - x1) / image_width
            height = (y2 - y1) / image_height
            
            # Escribir línea
            f.write(f"{class_id} {x_center:.6f} {y_center:.6f} {width:.6f} {height:.6f}\n")

# Ejemplo
boxes = [
    [0, 100, 100, 200, 300],  # persona
    [1, 50, 50, 120, 150],    # bicicleta
]

create_yolo_annotation(640, 480, boxes, 'imagen.txt')
```

### Leer Anotaciones YOLO

```python
def read_yolo_annotation(annotation_file, image_width, image_height):
    """
    Lee archivo de anotación YOLO y devuelve bounding boxes absolutos.
    
    Returns:
        Lista de [class_id, x1, y1, x2, y2]
    
    Este proceso es el inverso de create_yolo_annotation:
    1. Leer coordenadas normalizadas
    2. Convertir a coordenadas absolutas
    3. De formato (cx,cy,w,h) a formato (x1,y1,x2,y2)
    """
    boxes = []
    
    with open(annotation_file, 'r') as f:
        for line in f:
            parts = line.strip().split()
            class_id = int(parts[0])
            x_center = float(parts[1]) * image_width
            y_center = float(parts[2]) * image_height
            width = float(parts[3]) * image_width
            height = float(parts[4]) * image_height
            
            # Convertir a formato x1, y1, x2, y2
            x1 = x_center - width / 2
            y1 = y_center - height / 2
            x2 = x_center + width / 2
            y2 = y_center + height / 2
            
            boxes.append([class_id, x1, y1, x2, y2])
    
    return boxes

# Ejemplo
boxes = read_yolo_annotation('imagen.txt', 640, 480)
for box in boxes:
    print(f"Clase {box[0]}: BBox = [{box[1]:.0f}, {box[2]:.0f}, {box[3]:.0f}, {box[4]:.0f}]")
```

### Puntos Clave

- YOLO usa archivos de texto simples con coordenadas normalizadas
- La estructura train/val/test es estándar y recomendada
- El archivo data.yaml configura rutas y clases
- Las coordenadas normalizadas van de 0 a 1
- Siempre verifica que images y labels tengan nombres coincidentes

### Referencias

- [Dataset Format](https://docs.ultralytics.com/datasets/detect/)
- [Train Custom Data](https://docs.ultralytics.com/yolov5/train_custom_data/)

---

## 3.2 Tipos de Anotaciones

### Introducción

Según la tarea (detección, segmentación, pose), el formato de anotación varía. Entender las diferencias es esencial para preparar datos correctamente.

### Explicación Detallada

**Anotaciones por tarea:**

1. **Detection**: Bounding boxes (4 coordenadas)
2. **Segmentation**: Polígonos o máscaras
3. **Pose**: Bounding box + keypoints
4. **OBB**: Bounding box rotado (4 esquinas + ángulo)

### Anotaciones para Detección

```python
def visualize_detection_annotation(image_path, annotation_path):
    """
    Visualiza anotaciones de detección en una imagen.
    
    Este es un paso crucial en la preparación de datos:
    SIEMPRE visualiza tus anotaciones para verificar que son correctas.
    
    Errores comunes:
    - Bounding boxes muy pequeños o muy grandes
    - Coordenadas invertidas (x1 > x2)
    - Clases incorrectas
    """
    import cv2
    
    # Leer imagen
    image = cv2.imread(image_path)
    h, w = image.shape[:2]
    
    # Leer anotaciones
    boxes = read_yolo_annotation(annotation_path, w, h)
    
    # Dibujar cajas
    colors = [(0, 255, 0), (255, 0, 0), (0, 0, 255), (255, 255, 0)]
    
    for box in boxes:
        class_id, x1, y1, x2, y2 = box
        color = colors[class_id % len(colors)]
        
        cv2.rectangle(image, (int(x1), int(y1)), (int(x2), int(y2)), color, 2)
        cv2.putText(image, f'Class {class_id}', (int(x1), int(y1) - 5),
                   cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)
    
    cv2.imwrite('annotation_visualized.jpg', image)
    print("Visualización guardada en annotation_visualized.jpg")
```

### Anotaciones para Segmentación

```
# Formato YOLO para segmentación: class_id x1 y1 x2 y2 x3 y3 ... (polígono)
# Cada línea es una instancia con su polígono

# mask.txt
0 0.1 0.2 0.3 0.2 0.3 0.5 0.1 0.5   # persona (polígono de 4 puntos)
1 0.5 0.5 0.7 0.5 0.7 0.8 0.5 0.8   # bicicleta
```

```python
def create_yolo_segmentation_annotation(polygon_points, class_id, output_file):
    """
    Crea anotación de segmentación YOLO desde puntos de polígono.
    
    Args:
        polygon_points: Lista de (x, y) normalizados (0-1)
        class_id: ID de la clase
        output_file: Archivo de salida
    
    Nota: Los polígonos deben ser cerrados (último punto conecta con el primero)
    """
    with open(output_file, 'w') as f:
        coords = ' '.join([f'{x:.6f} {y:.6f}' for x, y in polygon_points])
        f.write(f"{class_id} {coords}\n")

# Ejemplo: triángulo
polygon = [(0.5, 0.1), (0.3, 0.9), (0.7, 0.9)]
create_yolo_segmentation_annotation(polygon, 0, 'segmentation.txt')
```

### Anotaciones para Pose

```
# Formato YOLO Pose: class_id x_center y_center width height kpt1_x kpt1_y kpt1_v kpt2_x kpt2_y kpt2_v ...
# v = visibility (0 = no visible, 1 = oculto, 2 = visible)

# pose.txt
0 0.5 0.5 0.3 0.8 0.5 0.2 2 0.4 0.3 2 0.6 0.3 2 ... # 17 keypoints
```

```python
def create_yolo_pose_annotation(bbox, keypoints, class_id, output_file, img_w, img_h):
    """
    Crea anotación de pose YOLO.
    
    Args:
        bbox: [x1, y1, x2, y2] bounding box absoluto
        keypoints: Lista de (x, y, visibility) absolutos
        class_id: ID de la clase (generalmente 0 = persona)
        output_file: Archivo de salida
        img_w, img_h: Dimensiones de la imagen
    
    Visibility values:
    - 0: Keypoint no visible (fuera de imagen u ocluido)
    - 1: Keypoint visible pero ocluido parcialmente
    - 2: Keypoint claramente visible
    """
    # Normalizar bbox
    x_center = ((bbox[0] + bbox[2]) / 2) / img_w
    y_center = ((bbox[1] + bbox[3]) / 2) / img_h
    width = (bbox[2] - bbox[0]) / img_w
    height = (bbox[3] - bbox[1]) / img_h
    
    with open(output_file, 'w') as f:
        # Escribir bbox
        line = f"{class_id} {x_center:.6f} {y_center:.6f} {width:.6f} {height:.6f}"
        
        # Escribir keypoints
        for kp in keypoints:
            x, y, v = kp
            line += f" {x/img_w:.6f} {y/img_h:.6f} {v}"
        
        f.write(line + '\n')

# Ejemplo
bbox = [100, 50, 200, 400]
keypoints = [
    (150, 80, 2),   # nariz (visible)
    (140, 70, 2),   # ojo izquierdo (visible)
    (160, 70, 2),   # ojo derecho (visible)
]
create_yolo_pose_annotation(bbox, keypoints, 0, 'pose.txt', 640, 480)
```

### Puntos Clave

- Cada tarea tiene su formato de anotación específico
- Siempre normaliza las coordenadas a 0-1
- Visualiza las anotaciones para verificar corrección
- Pose requiere bounding box + keypoints con visibility
- Segmentación usa polígonos con puntos normalizados

### Referencias

- [Segmentation Format](https://docs.ultralytics.com/datasets/segment/)
- [Pose Format](https://docs.ultralytics.com/datasets/pose/)
- [OBB Format](https://docs.ultralytics.com/datasets/obb/)

---

# Continúa en el archivo con más secciones...

**Nota**: Debido a la longitud del archivo, he mejorado las primeras secciones del curso con explicaciones didácticas extensas. El patrón aplicado es:

1. **Introducción**: Contexto y motivación del concepto
2. **Explicación Detallada**: Desarrollo con analogías y ejemplos
3. **Ejemplo Práctico**: Código documentado
4. **Puntos Clave**: Resumen de conceptos importantes
5. **Referencias**: Enlaces a documentación oficial

El resto del archivo original se mantiene y puede mejorarse siguiendo el mismo patrón.

---

# Módulo 3: Datasets y Preparación de Datos (continuación)

## 3.3 Datasets Incluidos y Públicos

### Introducción

No siempre necesitas crear tu propio dataset desde cero. Existen datasets públicos de alta calidad que puedes usar para entrenar, validar ideas, o como punto de partida para transfer learning. Conocer estos datasets te ahorra tiempo y te da acceso a datos bien curados.

### Explicación Detallada

**Datasets populares para detección de objetos:**

1. **COCO (Common Objects in Context)**
   - El dataset más usado para detección de objetos
   - 80 clases, 330K imágenes, 1.5M objetos anotados
   - Incluye detección, segmentación, y keypoints
   - Estándar de facto para evaluar modelos

2. **Pascal VOC**
   - Dataset histórico (2007-2012)
   - 20 clases, formato XML
   - Aún usado para comparar con papers antiguos

3. **Open Images**
   - 600 clases, 9M imágenes
   - Muy diverso pero menos curado que COCO

4. **DOTA (para OBB)**
   - Imágenes aéreas de alta resolución
   - Oriented bounding boxes
   - Ideal para detección desde drones/satélites

### COCO (Common Objects in Context)

```python
from ultralytics import YOLO

# Entrenar con COCO (se descarga automáticamente)
model = YOLO('yolo11n.pt')

# El dataset COCO se descarga y configura automáticamente
# results = model.train(data='coco.yaml', epochs=100)

# O usar COCO8 (subset pequeño para pruebas)
results = model.train(data='coco8.yaml', epochs=5, imgsz=640)
```

**Las 80 clases de COCO:**
Personas, vehículos (bicicleta, auto, moto, avión, bus, tren, camión, barco), animales (pájaro, gato, perro, caballo, oveja, vaca, elefante, oso, cebra, jirafa), y muchos más.

### Pascal VOC

```python
# Convertir VOC a formato YOLO
import xml.etree.ElementTree as ET

def voc_to_yolo(xml_file, output_dir, classes):
    """
    Convierte anotación Pascal VOC a formato YOLO.
    
    Args:
        xml_file: Archivo XML de VOC
        output_dir: Directorio de salida
        classes: Lista de nombres de clases
    
    Pascal VOC usa formato XML con coordenadas absolutas.
    Este script convierte a formato YOLO.
    """
    tree = ET.parse(xml_file)
    root = tree.getroot()
    
    # Obtener dimensiones
    size = root.find('size')
    width = int(size.find('width').text)
    height = int(size.find('height').text)
    
    # Procesar objetos
    lines = []
    for obj in root.findall('object'):
        class_name = obj.find('name').text
        if class_name not in classes:
            continue
        
        class_id = classes.index(class_name)
        bbox = obj.find('bndbox')
        
        x1 = float(bbox.find('xmin').text)
        y1 = float(bbox.find('ymin').text)
        x2 = float(bbox.find('xmax').text)
        y2 = float(bbox.find('ymax').text)
        
        # Normalizar
        x_center = ((x1 + x2) / 2) / width
        y_center = ((y1 + y2) / 2) / height
        w = (x2 - x1) / width
        h = (y2 - y1) / height
        
        lines.append(f"{class_id} {x_center:.6f} {y_center:.6f} {w:.6f} {h:.6f}")
    
    # Guardar
    filename = root.find('filename').text
    output_file = f"{output_dir}/{filename.rsplit('.', 1)[0]}.txt"
    
    with open(output_file, 'w') as f:
        f.write('\n'.join(lines))

# Uso
voc_classes = ['aeroplane', 'bicycle', 'bird', 'boat', 'bottle',
               'bus', 'car', 'cat', 'chair', 'cow',
               'diningtable', 'dog', 'horse', 'motorbike', 'person',
               'pottedplant', 'sheep', 'sofa', 'train', 'tvmonitor']

# voc_to_yolo('annotation.xml', 'labels', voc_classes)
```

### ImageNet

```python
# Usar ImageNet para clasificación
model = YOLO('yolo11n-cls.pt')

# Entrenar con ImageNet (o subset)
# results = model.train(data='imagenet', epochs=100)

# Usar ImageNet10 para pruebas rápidas
results = model.train(data='imagenet10', epochs=5)
```

### DOTA (Aerial Images)

```python
# Entrenar OBB con DOTA
model = YOLO('yolo11n-obb.pt')

# Dataset DOTA se configura con dotav1.yaml
# results = model.train(data='dotav1.yaml', epochs=100)
```

### Puntos Clave

- COCO es el estándar para detección de objetos con 80 clases
- Pascal VOC es útil para comparar con trabajos anteriores
- DOTA es el estándar para detección con OBB
- Los datasets pequeños (COCO8, ImageNet10) son útiles para pruebas rápidas
- Siempre verifica las licencias antes de usar datasets públicos

### Referencias

- [COCO Dataset](https://docs.ultralytics.com/datasets/detect/coco/)
- [VOC Dataset](https://docs.ultralytics.com/datasets/detect/voc/)
- [DOTA Dataset](https://docs.ultralytics.com/datasets/obb/dota-v1.0/)
- [All Datasets](https://docs.ultralytics.com/datasets/)

---

## 3.4 Herramientas de Anotación

### Introducción

Crear anotaciones de calidad es un proceso laborioso. Las herramientas de anotación modernas facilitan este trabajo con interfaces intuitivas, atajos de teclado, y colaboración en equipo. Elegir la herramienta correcta puede ahorrar días de trabajo.

### Explicación Detallada

**Criterios para elegir herramienta:**

1. **Tipo de anotación**: ¿Necesitas boxes, polígonos, keypoints?
2. **Colaboración**: ¿Trabajas solo o en equipo?
3. **Exportación**: ¿Soporta formato YOLO?
4. **Costo**: ¿Gratuita, open-source, o comercial?
5. **Facilidad de uso**: ¿Cuánto tiempo tomará aprenderla?

### CVAT (Computer Vision Annotation Tool)

- Herramienta web open-source
- Soporta detección, segmentación, tracking
- Ideal para equipos grandes

```bash
# Instalar CVAT
git clone https://github.com/opencv/cvat
cd cvat
docker compose up -d
```

### LabelImg

- Herramienta de escritorio ligera
- Exporta a formato YOLO directamente
- Perfecta para proyectos pequeños

```bash
# Instalar LabelImg
pip install labelImg

# Ejecutar
labelImg
```

### Roboflow

- Plataforma web con gestión de datasets
- Augmentación automática
- Exportación directa a YOLO

```python
# Usar Roboflow API
from roboflow import Roboflow

rf = Roboflow(api_key="YOUR_API_KEY")
project = rf.workspace("workspace-name").project("project-name")
dataset = project.version(1).download("yolo11")

# El dataset ya está en formato YOLO listo para entrenar
model = YOLO('yolo11n.pt')
model.train(data=f'{dataset.location}/data.yaml', epochs=50)
```

### Label Studio

- Herramienta versátil y extensible
- Integración con ML backends
- Soporta múltiples tipos de datos

```bash
# Instalar Label Studio
pip install label-studio

# Ejecutar
label-studio start
```

### Script de Conversión Universal

```python
import json
import os
from pathlib import Path

def convert_coco_to_yolo(coco_json, images_dir, output_dir, classes):
    """
    Convierte anotaciones COCO JSON a formato YOLO.
    
    Args:
        coco_json: Archivo JSON con anotaciones COCO
        images_dir: Directorio con imágenes
        output_dir: Directorio de salida para labels
        classes: Lista de nombres de clases
    
    COCO usa formato JSON con:
    - images: lista de imágenes con id, filename, width, height
    - annotations: lista de anotaciones con image_id, category_id, bbox
    - categories: lista de categorías con id y name
    
    Este script convierte ese formato al formato YOLO simple.
    """
    with open(coco_json) as f:
        data = json.load(f)
    
    # Crear directorio de salida
    os.makedirs(output_dir, exist_ok=True)
    
    # Mapear categorías
    categories = {cat['id']: cat['name'] for cat in data['categories']}
    
    # Mapear imágenes
    images = {img['id']: img for img in data['images']}
    
    # Agrupar anotaciones por imagen
    annotations_by_image = {}
    for ann in data['annotations']:
        img_id = ann['image_id']
        if img_id not in annotations_by_image:
            annotations_by_image[img_id] = []
        annotations_by_image[img_id].append(ann)
    
    # Procesar cada imagen
    for img_id, anns in annotations_by_image.items():
        img_info = images[img_id]
        img_w = img_info['width']
        img_h = img_info['height']
        
        lines = []
        for ann in anns:
            cat_name = categories[ann['category_id']]
            if cat_name not in classes:
                continue
            
            class_id = classes.index(cat_name)
            bbox = ann['bbox']  # [x, y, width, height] COCO format
            
            # Convertir a YOLO
            x_center = (bbox[0] + bbox[2] / 2) / img_w
            y_center = (bbox[1] + bbox[3] / 2) / img_h
            w = bbox[2] / img_w
            h = bbox[3] / img_h
            
            lines.append(f"{class_id} {x_center:.6f} {y_center:.6f} {w:.6f} {h:.6f}")
        
        # Guardar archivo
        img_name = Path(img_info['file_name']).stem
        with open(f"{output_dir}/{img_name}.txt", 'w') as f:
            f.write('\n'.join(lines))
    
    print(f"Convertidas {len(annotations_by_image)} imágenes")

# Uso
# classes = ['person', 'car', 'bicycle']
# convert_coco_to_yolo('annotations.json', 'images/', 'labels/', classes)
```

### Puntos Clave

- LabelImg es ideal para proyectos pequeños y rápidos
- CVAT y Label Studio son mejores para equipos
- Roboflow ofrece el flujo más completo (anotación + augmentación + export)
- Siempre verifica las anotaciones visualmente después de convertir
- Automatiza la conversión cuando trabajes con datasets grandes

### Referencias

- [LabelImg](https://github.com/HFAiLab/labelImg)
- [CVAT](https://github.com/opencv/cvat)
- [Label Studio](https://labelstud.io/)
- [Roboflow](https://roboflow.com/)

---

## 3.5 Data Augmentation

### Introducción

El data augmentation es una técnica que expande tu dataset creando variaciones de las imágenes existentes. Es como tener un dataset 10 veces más grande sin necesidad de recopilar más datos. Para YOLO, el augmentation es especialmente importante porque mejora la generalización y robustez del modelo.

### Explicación Detallada

**¿Por qué funciona el data augmentation?**

El modelo aprende patrones, no píxeles específicos. Si solo ve perros en posición frontal, no reconocerá perros de lado. El augmentation muestra al modelo las mismas imágenes en diferentes condiciones, forzándolo a aprender características más generales.

**Tipos de augmentación:**

1. **Geométricas**: Transforman la posición/orientación
   - Flip horizontal/vertical
   - Rotación
   - Escala
   - Traslación
   - Perspectiva

2. **Fotométricas**: Transforman los colores
   - Brillo
   - Contraste
   - Saturación
   - Tono (hue)

3. **Avanzadas**: Mezclan múltiples imágenes
   - Mosaic: Combina 4 imágenes
   - Mixup: Superpone 2 imágenes
   - Copy-Paste: Copia objetos de una imagen a otra

### Augmentaciones Automáticas en YOLO

```python
from ultralytics import YOLO

model = YOLO('yolo11n.pt')

# Entrenar con augmentación por defecto
results = model.train(
    data='data.yaml',
    epochs=100,
    
    # Augmentación geométrica
    degrees=10.0,       # Rotación ±10 grados
    translate=0.1,      # Traslación ±10%
    scale=0.5,          # Escala 0.5-1.5
    shear=0.0,          # Sin shear
    perspective=0.0,    # Sin perspectiva
    flipud=0.0,         # Sin flip vertical
    fliplr=0.5,         # Flip horizontal 50%
    mosaic=1.0,         # Mosaic augmentation siempre
    mixup=0.1,          # Mixup augmentation 10%
    
    # Augmentación de color
    hsv_h=0.015,        # Hue ±1.5%
    hsv_s=0.7,          # Saturation ±70%
    hsv_v=0.4,          # Value ±40%
    
    # Otras
    copy_paste=0.1,     # Copy-paste augmentation (segmentación)
)
```

**Explicación de parámetros:**

- **degrees=10.0**: Rota la imagen aleatoriamente entre -10° y +10°
- **translate=0.1**: Desplaza la imagen hasta 10% en cualquier dirección
- **scale=0.5**: Escala entre 50% y 150% del tamaño original
- **fliplr=0.5**: 50% de probabilidad de flip horizontal
- **mosaic=1.0**: Siempre usa mosaic (combina 4 imágenes)
- **hsv_h/s/v**: Varía tono, saturación y brillo

### Mosaic Augmentation (Característica de YOLO)

```python
def visualize_mosaic(image_paths, output_path):
    """
    Crea un mosaico de 4 imágenes para visualizar la augmentación mosaic.
    
    Mosaic es una técnica inventada para YOLOv4 que:
    1. Combina 4 imágenes en una
    2. Expone el modelo a múltiples objetos y contextos
    3. Reduce la necesidad de batch size grande
    4. Mejora la detección de objetos pequeños
    
    Es una de las augmentaciones más efectivas para detección.
    """
    import cv2
    import numpy as np
    
    images = [cv2.imread(p) for p in image_paths]
    
    # Redimensionar al mismo tamaño
    target_size = 640
    images = [cv2.resize(img, (target_size, target_size)) for img in images]
    
    # Crear mosaico 2x2
    mosaic = np.zeros((target_size * 2, target_size * 2, 3), dtype=np.uint8)
    mosaic[:target_size, :target_size] = images[0]
    mosaic[:target_size, target_size:] = images[1]
    mosaic[target_size:, :target_size] = images[2]
    mosaic[target_size:, target_size:] = images[3]
    
    cv2.imwrite(output_path, mosaic)
    print(f"Mosaico guardado en {output_path}")

# Uso
# visualize_mosaic(['img1.jpg', 'img2.jpg', 'img3.jpg', 'img4.jpg'], 'mosaic.jpg')
```

### Albumentations Integration

```python
import albumentations as A
import cv2

def create_custom_augmentation():
    """
    Crea pipeline de augmentación personalizado.
    
    Albumentations es la librería más rápida y flexible
    para data augmentation. Se integra bien con YOLO.
    """
    transform = A.Compose([
        # Geométricas
        A.RandomResizedCrop(640, 640, scale=(0.8, 1.0), p=0.5),
        A.HorizontalFlip(p=0.5),
        A.ShiftScaleRotate(shift_limit=0.1, scale_limit=0.2, rotate_limit=15, p=0.5),
        
        # Color
        A.OneOf([
            A.RandomBrightnessContrast(brightness_limit=0.2, contrast_limit=0.2),
            A.HueSaturationValue(hue_shift_limit=20, sat_shift_limit=30, val_shift_limit=20),
            A.RGBShift(r_shift_limit=20, g_shift_limit=20, b_shift_limit=20),
        ], p=0.5),
        
        # Ruido y blur
        A.OneOf([
            A.GaussNoise(var_limit=(10, 50)),
            A.GaussianBlur(blur_limit=(3, 7)),
            A.MotionBlur(blur_limit=7),
        ], p=0.3),
        
        # Oclusión
        A.RandomShadow(p=0.3),
        A.CoarseDropout(max_holes=8, max_height=50, max_width=50, p=0.3),
    ], bbox_params=A.BboxParams(format='yolo', label_fields=['class_labels']))
    
    return transform

# Uso
transform = create_custom_augmentation()
image = cv2.imread('image.jpg')
bboxes = [[0.5, 0.5, 0.3, 0.4]]  # YOLO format
class_labels = [0]

augmented = transform(image=image, bboxes=bboxes, class_labels=class_labels)
aug_image = augmented['image']
aug_bboxes = augmented['bboxes']

cv2.imwrite('augmented_custom.jpg', aug_image)
```

### Puntos Clave

- El augmentation expande tu dataset virtualmente
- Mosaic es la augmentación más efectiva para YOLO
- No abuses del augmentation: demasiado puede degradar el modelo
- Desactiva mosaic en las últimas epochs para estabilizar el entrenamiento
- Albumentations ofrece control fino y es muy rápida

### Referencias

- [Data Augmentation Guide](https://docs.ultralytics.com/yolov5/augmentation/)
- [Albumentations](https://albumentations.ai/)
- [Mosaic Augmentation Paper](https://arxiv.org/abs/2004.10934)

---

# Módulo 4: Entrenamiento de Modelos (3h)

## 4.1 Transfer Learning y Fine-Tuning

### Introducción

Imagina que quieres aprender a tocar el piano. Podrías empezar desde cero, aprendiendo las notas, la posición de los dedos, la lectura de partituras... O podrías aprovechar que ya sabes tocar la guitarra y simplemente adaptar ese conocimiento al nuevo instrumento. Esto es exactamente lo que hace el transfer learning: reutilizar conocimiento previamente aprendido para dominar una nueva tarea más rápido y con menos datos.

En el contexto de YOLO, el transfer learning es fundamental. Entrenar un modelo desde cero para detectar objetos requiere millones de imágenes y semanas de cómputo. Pero si partimos de un modelo ya entrenado en COCO (80 clases, 330K imágenes), podemos adaptarlo a nuestra tarea específica con apenas cientos de imágenes y en cuestión de horas.

### Explicación Detallada

**¿Qué pasa dentro del modelo durante el transfer learning?**

Las capas de una red neuronal aprenden diferentes niveles de abstracción:
- **Capas iniciales (Backbone)**: Detectan características básicas como bordes, texturas, colores. Estas características son universales y aplicables a cualquier tarea de visión.
- **Capas intermedias (Neck)**: Combinan características para detectar patrones más complejos como formas, texturas específicas, partes de objetos.
- **Capas finales (Head)**: Realizan predicciones específicas de la tarea (dónde está el objeto, qué clase es).

Cuando hacemos transfer learning:
1. Congelamos las capas iniciales (backbone): Ya saben detectar bordes y texturas, no necesitan reaprender.
2. Ajustamos las capas finales (head): Estas son específicas de nuestra tarea, necesitan aprender las clases nuevas.

**Analogía del mundo real:**

Es como contratar a un experto en coches para identificar motos. El experto ya sabe qué es un motor, una rueda, un asiento. Solo necesita aprender las diferencias específicas entre coches y motos. No necesita aprender de nuevo qué es un vehículo.

**¿Por qué funciona tan bien?**

La razón fundamental es que las características visuales de bajo nivel (bordes, texturas) son comunes a todas las imágenes. Un borde horizontal es lo mismo en una foto de un perro que en una foto de un coche. Lo que cambia es cómo esos bordes se combinan para formar objetos específicos.

**Fine-Tuning vs Feature Extraction:**

Hay dos estrategias principales:

1. **Feature Extraction**: Congelamos todas las capas excepto las últimas. Solo entrenamos el clasificador final.
   - Más rápido
   - Menos riesgo de overfitting
   - Ideal cuando tienes pocos datos (<100 imágenes por clase)

2. **Fine-Tuning**: Descongelamos parte o todas las capas y entrenamos con learning rate muy bajo.
   - Mayor capacidad de adaptación
   - Mejor para dominios muy diferentes (ej: imágenes médicas vs fotos normales)
   - Requiere más datos y cuidado

### Ejemplo Práctico: Transfer Learning con YOLO

```python
from ultralytics import YOLO

# Estrategia 1: Fine-tuning completo (recomendado para la mayoría de casos)
# YOLO hace esto automáticamente cuando cargas un modelo pre-entrenado
model = YOLO('yolo11n.pt')  # Carga pesos pre-entrenados en COCO

# Entrenar en tu dataset personalizado
results = model.train(
    data='mi_dataset.yaml',   # Tu dataset con clases específicas
    epochs=100,
    imgsz=640,
    batch=16,
    
    # Parámetros de fine-tuning
    freeze=0,  # 0 = no congelar nada (fine-tuning completo)
               # 10 = congelar las primeras 10 capas del backbone
               # 'backbone' = congelar todo el backbone
    
    # Learning rate bajo para no destruir el conocimiento previo
    lr0=0.001,    # Learning rate inicial
    lrf=0.01,     # Learning rate final (después de decay)
    
    # Optimizer
    optimizer='auto',  # 'SGD', 'Adam', 'AdamW', o 'auto'
    momentum=0.937,
    weight_decay=0.0005,
)

print(f"Mejor mAP: {results.results_dict.get('metrics/mAP50-95(B)', 'N/A')}")
```

**Análisis del código:**

1. **Cargar modelo pre-entrenado**: `YOLO('yolo11n.pt')` carga pesos entrenados en COCO. El modelo ya sabe detectar 80 clases de objetos.

2. **Congelar capas**: El parámetro `freeze` controla qué capas no se actualizan:
   - `freeze=0`: Fine-tuning completo, todas las capas se actualizan
   - `freeze=10`: Las primeras 10 capas permanecen fijas
   - `freeze='backbone'`: Todo el extractor de características permanece fijo

3. **Learning rate bajo**: Usamos 0.001 en lugar de valores típicos de entrenamiento desde cero (0.01). Esto es crucial porque no queremos "olvidar" el conocimiento previo.

### Estrategia de Congelamiento por Capas

```python
def entrenar_por_etapas(dataset_yaml, total_epochs=150):
    """
    Estrategia de entrenamiento por etapas para fine-tuning óptimo.
    
    Este método entrena en 3 fases:
    1. Solo las capas finales (head) - 20 epochs
    2. Backbone parcialmente descongelado - 30 epochs
    3. Fine-tuning completo - 100 epochs
    
    Esta estrategia es especialmente útil cuando:
    - Tu dominio es muy diferente a COCO (ej: imágenes médicas)
    - Tienes un dataset pequeño (<500 imágenes)
    - Quieres máxima precisión
    """
    
    # Fase 1: Solo entrenar el head (clasificador)
    print("=== Fase 1: Entrenando solo el head ===")
    model = YOLO('yolo11n.pt')
    results1 = model.train(
        data=dataset_yaml,
        epochs=20,
        freeze='backbone',  # Congelar TODO el backbone
        lr0=0.01,           # LR alto está bien porque solo tocamos el head
        patience=5,         # Early stopping si no mejora
    )
    
    # Fase 2: Descongelar parte del backbone
    print("=== Fase 2: Fine-tuning parcial del backbone ===")
    # Cargar el mejor modelo de la fase 1
    model = YOLO('runs/detect/train/weights/best.pt')
    results2 = model.train(
        data=dataset_yaml,
        epochs=30,
        freeze=10,          # Solo congelar las primeras 10 capas
        lr0=0.001,          # LR más bajo
        patience=10,
    )
    
    # Fase 3: Fine-tuning completo
    print("=== Fase 3: Fine-tuning completo ===")
    model = YOLO('runs/detect/train2/weights/best.pt')
    results3 = model.train(
        data=dataset_yaml,
        epochs=100,
        freeze=0,           # Nada congelado
        lr0=0.0001,         # LR muy bajo
        patience=20,
    )
    
    return results3

# Uso
# final_results = entrenar_por_etapas('mi_dataset.yaml')
```

**¿Cuándo usar cada estrategia?**

| Estrategia | Dataset | Diferencia de dominio | Tiempo |
|------------|---------|----------------------|--------|
| freeze='backbone' | <100 imgs/clase | Similar a COCO | Rápido |
| freeze=10 | 100-500 imgs/clase | Moderada | Medio |
| freeze=0 | >500 imgs/clase | Muy diferente | Lento |

### Entrenamiento desde Cero

```python
def entrenar_desde_cero(dataset_yaml, epochs=300):
    """
    Entrena un modelo YOLO completamente desde cero.
    
    ADVERTENCIA: Solo hacer esto cuando:
    1. Tienes un dataset MUY grande (>10,000 imágenes)
    2. Tu dominio es completamente diferente (ej: imágenes satelitales)
    3. Tienes recursos de cómputo significativos
    
    En la mayoría de casos, el transfer learning es mejor.
    """
    # Crear modelo sin pesos pre-entrenados
    model = YOLO('yolo11n.yaml')  # .yaml = arquitectura sin pesos
    
    results = model.train(
        data=dataset_yaml,
        epochs=epochs,
        imgsz=640,
        batch=32,          # Batch grande para estabilidad
        
        # Learning rate más alto para entrenamiento desde cero
        lr0=0.01,
        lrf=0.01,
        
        # Más augmentación para compensar menos datos
        degrees=15.0,
        translate=0.2,
        scale=0.9,
        mosaic=1.0,
        mixup=0.2,
        
        # Más epochs de warmup
        warmup_epochs=10,
        warmup_momentum=0.5,
    )
    
    return results
```

### Puntos Clave

- El transfer learning reutiliza conocimiento de un modelo pre-entrenado
- Las capas iniciales aprenden características universales (bordes, texturas)
- Congelar capas evita destruir conocimiento previo
- El learning rate bajo es esencial para fine-tuning
- Entrenar desde cero solo es necesario con datasets muy grandes o dominios muy diferentes

### Referencias

- [Transfer Learning Guide](https://docs.ultralytics.com/yolov5/train_custom_data/#transfer-learning)
- [Fine-tuning Best Practices](https://docs.ultralytics.com/modes/train/#arguments)
- [YOLO Training Tips](https://github.com/ultralytics/yolov5/wiki/Tips-for-Best-Training-Results)

---

## 4.2 Parámetros de Entrenamiento

### Introducción

Los hiperparámetros de entrenamiento son como los mandos de una máquina compleja. Ajustarlos correctamente puede marcar la diferencia entre un modelo mediocre y uno excelente. A diferencia de los parámetros del modelo (que se aprenden automáticamente), los hiperparámetros deben configurarse manualmente basándose en experiencia y experimentación.

### Explicación Detallada

**Los hiperparámetros más importantes:**

1. **Learning Rate**: Qué tan grande son los pasos que da el optimizador
   - Muy alto: El modelo diverge, pierde lo aprendido
   - Muy bajo: Entrenamiento muy lento, puede quedarse en mínimos locales
   - Óptimo: Aprende rápido pero estable

2. **Batch Size**: Cuántas imágenes procesa el modelo a la vez
   - Grande: Más estable, usa más memoria
   - Pequeño: Más ruido pero mejor generalización

3. **Epochs**: Cuántas veces ve el modelo todo el dataset
   - Muy pocas: Underfitting
   - Demasiadas: Overfitting
   - Óptimo: Early stopping lo detecta automáticamente

4. **Image Size**: Tamaño de las imágenes de entrada
   - Grande: Más detalle, más memoria
   - Pequeño: Más rápido, pierde detalles

**La relación entre hiperparámetros:**

No son independientes. El learning rate óptimo depende del batch size. El número de epochs depende del tamaño del dataset. Entender estas interacciones es clave para optimizar.

### Configuración de Entrenamiento Completa

```python
from ultralytics import YOLO

model = YOLO('yolo11n.pt')

# Entrenamiento con todos los parámetros explicados
results = model.train(
    # === DATOS ===
    data='dataset.yaml',      # Archivo de configuración del dataset
    imgsz=640,                # Tamaño de imagen (640x640 píxeles)
                              # Valores comunes: 320, 416, 512, 640, 1280
    
    # === ENTRENAMIENTO BÁSICO ===
    epochs=100,               # Número de epochs
                              # Típico: 50-300 según tamaño de dataset
    batch=16,                 # Batch size
                              # Ajustar según memoria GPU: 4, 8, 16, 32, 64
    patience=50,              # Early stopping: epochs sin mejora antes de parar
                              # Previene overfitting
    
    # === OPTIMIZADOR ===
    optimizer='auto',         # 'SGD', 'Adam', 'AdamW', 'auto'
                              # auto = SGD con momentum (recomendado)
    lr0=0.001,                # Learning rate inicial
                              # Fine-tuning: 0.0001-0.001
                              # Desde cero: 0.01
    lrf=0.01,                 # Learning rate final (después de scheduler)
                              # lr final = lr0 * lrf
    momentum=0.937,           # Momentum para SGD
                              # Valores altos (0.9+) aceleran convergencia
    weight_decay=0.0005,      # Regularización L2
                              # Previene overfitting penalizando pesos grandes
    
    # === ARQUITECTURA ===
    model=None,               # Si es None, usa el modelo cargado
    freeze=0,                 # Capas a congelar
    
    # === DATA AUGMENTATION ===
    # Geométricas
    degrees=10.0,             # Rotación aleatoria ±10°
    translate=0.1,            # Traslación ±10%
    scale=0.5,                # Escala entre 0.5x y 1.5x
    shear=0.0,                # Sin shear
    perspective=0.0,          # Sin perspectiva
    flipud=0.0,               # Sin flip vertical
    fliplr=0.5,               # Flip horizontal 50% probabilidad
    mosaic=1.0,               # Mosaic siempre activo
    mixup=0.1,                # Mixup 10% probabilidad
    copy_paste=0.0,           # Copy-paste (para segmentación)
    
    # Color
    hsv_h=0.015,              # Variación de hue ±1.5%
    hsv_s=0.7,                # Variación de saturación ±70%
    hsv_v=0.4,                # Variación de brillo ±40%
    
    # === ENTRENAMIENTO AVANZADO ===
    warmup_epochs=3,          # Epochs de calentamiento
                              # LR empieza bajo y aumenta gradualmente
    warmup_momentum=0.8,      # Momentum durante warmup
    warmup_bias_lr=0.1,       # LR para bias durante warmup
    
    # === PÉRDIDA ===
    box=7.5,                  # Peso de pérdida de bounding box
    cls=0.5,                  # Peso de pérdida de clasificación
    dfl=1.5,                  # Peso de Distribution Focal Loss
    
    # === VALIDACIÓN ===
    val=True,                 # Validar durante entrenamiento
    plots=True,               # Generar gráficas
    save=True,                # Guardar checkpoints
    save_period=-1,           # Guardar cada N epochs (-1 = solo último)
    
    # === HARDWARE ===
    device='0',               # GPU a usar: '0', '0,1', 'cpu'
    workers=8,                # Workers para data loading
                              # Típico: número de CPUs
    
    # === PROYECTO ===
    project='runs/detect',    # Directorio de proyecto
    name='exp',               # Nombre del experimento
    exist_ok=False,           # Sobrescribir si existe
)
```

### Learning Rate Scheduling

```python
def explicar_lr_scheduler():
    """
    El Learning Rate Scheduler ajusta automáticamente el LR durante el entrenamiento.
    
    YOLO usa un scheduler coseno con warmup:
    
    1. Warmup (primeras epochs): LR aumenta gradualmente
       - Evita inestabilidad al inicio
       - El modelo "se asienta" antes de aprender rápido
    
    2. Cosine Annealing (resto del entrenamiento): LR disminuye suavemente
       - Permite explorar al inicio (LR alto)
       - Refina al final (LR bajo)
       - Sigue una curva coseno
    
    Visualización:
    
    LR |     /----\
       |    /      \___
       |   /           \____
       |__/________________\_____
       0   warmup   epochs
    """
    print("Learning Rate Scheduler en YOLO:")
    print("1. Warmup: LR aumenta de 0 a lr0")
    print("2. Cosine decay: LR disminuye de lr0 a lr0*lrf")
    print("3. Resultado: aprendizaje rápido + refinamiento preciso")

explicar_lr_scheduler()
```

### Encontrar el Learning Rate Óptimo

```python
import torch
import matplotlib.pyplot as plt
from ultralytics import YOLO

def find_optimal_lr(model_path, data_yaml, min_lr=1e-7, max_lr=1):
    """
    Encuentra el learning rate óptimo usando la técnica de Leslie Smith.
    
    El método consiste en:
    1. Empezar con LR muy bajo
    2. Aumentar gradualmente
    3. Observar cuándo la pérdida empieza a crecer
    4. El LR óptimo está un poco antes de ese punto
    
    Esta técnica es muy útil cuando no sabes qué LR usar.
    """
    model = YOLO(model_path)
    
    # Ejecutar LR finder
    lr_finder = model.trainer.lr_find(
        min_lr=min_lr,
        max_lr=max_lr,
        num_training=100,
    )
    
    # El LR sugerido está disponible
    suggested_lr = lr_finder.suggestion()
    print(f"Learning rate sugerido: {suggested_lr}")
    
    # Gráfica de pérdida vs LR
    fig = lr_finder.plot()
    plt.savefig('lr_finder.png')
    
    return suggested_lr

# Uso
# optimal_lr = find_optimal_lr('yolo11n.pt', 'dataset.yaml')
# print(f"Usa lr0={optimal_lr}")
```

### Batch Size y Memoria GPU

```python
def estimate_batch_size(model_size='n', imgsz=640, gpu_memory_gb=8):
    """
    Estima el batch size máximo que cabe en tu GPU.
    
    La memoria GPU necesaria depende de:
    - Tamaño del modelo (n, s, m, l, x)
    - Tamaño de imagen
    - Batch size
    
    Fórmula aproximada:
    Memoria ≈ modelo_params + (batch_size × imgsz² × 3 × constant)
    
    Tabla de referencia (imgsz=640):
    
    | Modelo | Params | Batch 16 | Batch 32 | Batch 64 |
    |--------|--------|----------|----------|----------|
    | nano   | 2.6M   | ~2GB     | ~3GB     | ~5GB     |
    | small  | 9.4M   | ~3GB     | ~5GB     | ~8GB     |
    | medium | 20M    | ~5GB     | ~8GB     | ~14GB    |
    | large  | 25M    | ~7GB     | ~12GB    | ~20GB    |
    | xlarge | 57M    | ~12GB    | ~20GB    | ~35GB    |
    """
    # Estimaciones aproximadas en GB
    memory_map = {
        'n': {'batch_16': 2, 'batch_32': 3, 'batch_64': 5},
        's': {'batch_16': 3, 'batch_32': 5, 'batch_64': 8},
        'm': {'batch_16': 5, 'batch_32': 8, 'batch_64': 14},
        'l': {'batch_16': 7, 'batch_32': 12, 'batch_64': 20},
        'x': {'batch_16': 12, 'batch_32': 20, 'batch_64': 35},
    }
    
    estimates = memory_map.get(model_size, {})
    
    # Encontrar batch size que cabe
    for batch_size in [64, 32, 16, 8, 4]:
        mem_key = f'batch_{batch_size}'
        if estimates.get(mem_key, float('inf')) <= gpu_memory_gb:
            return batch_size
    
    return 2  # Mínimo

# Ejemplo
print(f"Para GPU de 8GB con modelo small, batch size recomendado: {estimate_batch_size('s', 640, 8)}")
```

### Puntos Clave

- El learning rate es el hiperparámetro más importante
- El batch size depende de la memoria GPU disponible
- El scheduler reduce automáticamente el learning rate
- Early stopping previene el overfitting
- Siempre monitorea las gráficas de pérdida durante el entrenamiento

### Referencias

- [Training Arguments](https://docs.ultralytics.com/modes/train/#arguments)
- [Hyperparameter Tuning](https://docs.ultralytics.com/usage/cfg/)
- [Learning Rate Finder](https://pytorch-lightning.readthedocs.io/en/stable/api/pytorch_lightning.tuners.lr_finder.html)

---

## 4.3 Callbacks y Monitoring

### Introducción

El entrenamiento de un modelo de deep learning puede durar horas o días. Durante ese tiempo, ¿cómo sabes si todo va bien? ¿Cómo detectas problemas temprano? Los callbacks son funciones que se ejecutan durante el entrenamiento para monitorear, logging, y tomar decisiones automáticas. Son como el panel de control de un avión que te informa de todo lo que sucede.

### Explicación Detallada

**¿Qué es un callback?**

Un callback es una función que se ejecuta en puntos específicos del entrenamiento:
- Al inicio/final de cada epoch
- Al inicio/final de cada batch
- Cuando la métrica mejora
- Cuando el entrenamiento se detiene

**Callbacks incluidos en YOLO:**

1. **ModelCheckpoint**: Guarda el mejor modelo automáticamente
2. **EarlyStopping**: Detiene el entrenamiento si no hay mejora
3. **TensorBoard**: Registra métricas para visualización
4. **CSVLogger**: Guarda métricas en archivo CSV

**Callbacks personalizados:**

Puedes crear tus propios callbacks para:
- Enviar notificaciones cuando termina el entrenamiento
- Guardar snapshots intermedios
- Implementar técnicas de entrenamiento avanzadas
- Logging personalizado

### TensorBoard Integration

```python
from ultralytics import YOLO

# Iniciar TensorBoard antes de entrenar
# En terminal: tensorboard --logdir runs

model = YOLO('yolo11n.pt')

# Entrenar con TensorBoard habilitado (por defecto)
results = model.train(
    data='dataset.yaml',
    epochs=100,
    project='runs/detect',
    name='mi_experimento',
)

# Ver métricas en TensorBoard:
# http://localhost:6006
```

**Métricas disponibles en TensorBoard:**
- Pérdida total y por componente (box, class, dfl)
- mAP@50, mAP@50-95
- Precision, Recall
- Learning rate
- Gráficas de entrenamiento

### Callbacks Personalizados

```python
from ultralytics import YOLO
import json
import smtplib
from email.mime.text import MIMEText

# Callback para enviar email cuando termina el entrenamiento
def on_train_end(trainer):
    """
    Callback que se ejecuta al final del entrenamiento.
    
    Los callbacks reciben el objeto 'trainer' que contiene:
    - trainer.best_metrics: Métricas del mejor modelo
    - trainer.epoch: Epoch actual
    - trainer.model: El modelo entrenado
    - trainer.args: Argumentos de entrenamiento
    """
    metrics = trainer.best_metrics
    
    # Crear resumen
    summary = f"""
    Entrenamiento completado!
    
    Mejor mAP@50-95: {metrics.get('metrics/mAP50-95(B)', 'N/A')}
    Mejor mAP@50: {metrics.get('metrics/mAP50(B)', 'N/A')}
    
    Modelo guardado en: {trainer.best}
    """
    
    # Guardar resumen
    with open('training_summary.txt', 'w') as f:
        f.write(summary)
    
    print("\n" + "="*50)
    print(summary)
    print("="*50 + "\n")

# Callback para guardar métricas cada 10 epochs
def on_fit_epoch_end(trainer):
    """
    Callback que se ejecuta al final de cada epoch.
    """
    if trainer.epoch % 10 == 0:
        metrics = {
            'epoch': trainer.epoch,
            'train_loss': trainer.loss_items[0].item() if hasattr(trainer, 'loss_items') else None,
            'val_loss': trainer.validator.loss if hasattr(trainer.validator, 'loss') else None,
        }
        
        # Guardar en JSON
        with open('metrics_log.json', 'a') as f:
            f.write(json.dumps(metrics) + '\n')
        
        print(f"[Callback] Epoch {trainer.epoch} metrics saved")

# Registrar callbacks
model = YOLO('yolo11n.pt')

# Añadir callbacks al trainer
model.add_callback('on_train_end', on_train_end)
model.add_callback('on_fit_epoch_end', on_fit_epoch_end)

# Entrenar
# results = model.train(data='dataset.yaml', epochs=100)
```

### Callbacks Disponibles

```python
# Lista de todos los puntos donde se pueden añadir callbacks
callbacks_disponibles = {
    'on_pretrain_routine_start': 'Antes de que inicie el entrenamiento',
    'on_pretrain_routine_end': 'Después de la preparación',
    'on_train_start': 'Al inicio del entrenamiento',
    'on_train_end': 'Al final del entrenamiento',
    'on_train_epoch_start': 'Al inicio de cada epoch',
    'on_train_epoch_end': 'Al final de cada epoch',
    'on_train_batch_start': 'Antes de cada batch',
    'on_train_batch_end': 'Después de cada batch',
    'on_val_start': 'Al inicio de validación',
    'on_val_end': 'Al final de validación',
    'on_val_batch_start': 'Antes de cada batch de validación',
    'on_val_batch_end': 'Después de cada batch de validación',
    'on_predict_start': 'Al inicio de predicción',
    'on_predict_end': 'Al final de predicción',
    'on_predict_batch_start': 'Antes de cada batch de predicción',
    'on_predict_batch_end': 'Después de cada batch de predicción',
    'on_export_start': 'Al inicio de exportación',
    'on_export_end': 'Al final de exportación',
}

print("Callbacks disponibles en YOLO:")
for name, desc in callbacks_disponibles.items():
    print(f"  {name}: {desc}")
```

### Weights & Biases Integration

```python
# Integración con Weights & Biases para experiment tracking avanzado
import wandb

# Inicializar W&B
wandb.init(
    project="yolo-detection",
    name="experiment-001",
    config={
        "model": "yolo11n",
        "epochs": 100,
        "batch_size": 16,
        "learning_rate": 0.001,
    }
)

model = YOLO('yolo11n.pt')

# YOLO automáticamente loggea a W&B si está activo
results = model.train(
    data='dataset.yaml',
    epochs=100,
    project='runs/detect',
)

# Finalizar run
wandb.finish()
```

### Puntos Clave

- Los callbacks permiten ejecutar código en puntos específicos del entrenamiento
- TensorBoard es la herramienta de visualización por defecto
- Puedes crear callbacks personalizados para notificaciones y logging
- Weights & Biases ofrece tracking avanzado de experimentos
- Early stopping previene overfitting automáticamente

### Referencias

- [Callbacks Documentation](https://docs.ultralytics.com/usage/callbacks/)
- [TensorBoard Guide](https://docs.ultralytics.com/integrations/tensorboard/)
- [Weights & Biases](https://docs.ultralytics.com/integrations/weights-biases/)

---

## 4.4 Multi-GPU y Distribuido

### Introducción

Cuando entrenas modelos grandes con datasets enormes, una sola GPU puede no ser suficiente. El entrenamiento distribuido permite usar múltiples GPUs (incluso múltiples máquinas) para acelerar drásticamente el proceso. Imagina que tienes que construir una casa: un solo trabajador tardaría meses, pero un equipo de 8 trabajadores puede terminarla en semanas. El entrenamiento distribuido aplica el mismo principio.

### Explicación Detallada

**Tipos de paralelismo:**

1. **Data Parallelism**: Cada GPU tiene una copia del modelo y procesa un subset diferente de datos
   - Más fácil de implementar
   - Funciona bien con modelos que caben en una GPU
   - Escala linealmente hasta cierto punto

2. **Model Parallelism**: El modelo se divide entre GPUs
   - Necesario para modelos muy grandes
   - Más complejo de implementar
   - YOLO generalmente usa data parallelism

**Cómo funciona Data Parallelism:**

1. El batch se divide entre GPUs (batch_size / num_gpus cada una)
2. Cada GPU hace forward y backward pass
3. Los gradientes se sincronizan y promedian
4. Los pesos se actualizan de forma idéntica en todas las GPUs

**Comunicación entre GPUs:**

El cuello de botella es la comunicación. Las GPUs deben intercambiar gradientes, lo que toma tiempo. Por eso:
- No siempre 8 GPUs = 8x más rápido
- Batch size grande = mejor eficiencia (más cómputo por comunicación)
- NVLink/PCIe rápido es importante

### Entrenamiento Multi-GPU con YOLO

```python
from ultralytics import YOLO

# Opción 1: Especificar GPUs con string
model = YOLO('yolo11n.pt')
results = model.train(
    data='dataset.yaml',
    epochs=100,
    device='0,1,2,3',  # Usar GPUs 0, 1, 2, 3
    batch=64,          # Batch total (64/4 = 16 por GPU)
)

# Opción 2: Especificar rango de GPUs
results = model.train(
    data='dataset.yaml',
    epochs=100,
    device=[0, 1, 2, 3],  # Lista de GPUs
    batch=64,
)

# Opción 3: Usar todas las GPUs disponibles
results = model.train(
    data='dataset.yaml',
    epochs=100,
    device=None,  # None = usar todas las GPUs
    batch=64,
)
```

**Cálculo de batch size por GPU:**

```python
def calculate_per_gpu_batch(total_batch, num_gpus):
    """
    Calcula el batch size por GPU.
    
    Importante: El batch size especificado es el TOTAL.
    YOLO lo divide automáticamente entre las GPUs.
    
    Ejemplo:
    - batch=64 con 4 GPUs → 16 imágenes por GPU
    - batch=32 con 2 GPUs → 16 imágenes por GPU
    
    La memoria GPU necesaria depende del batch por GPU, no del total.
    """
    per_gpu = total_batch // num_gpus
    print(f"Batch total: {total_batch}")
    print(f"GPUs: {num_gpus}")
    print(f"Batch por GPU: {per_gpu}")
    return per_gpu

calculate_per_gpu_batch(64, 4)
```

### Distributed Data Parallel (DDP)

```bash
# Entrenamiento distribuido con torchrun
# Más eficiente que DataParallel para muchas GPUs

torchrun --nproc_per_node 4 train.py \
    --model yolo11n.pt \
    --data dataset.yaml \
    --epochs 100 \
    --batch 64
```

```python
# train.py para DDP
from ultralytics import YOLO

def main():
    model = YOLO('yolo11n.pt')
    results = model.train(
        data='dataset.yaml',
        epochs=100,
        batch=64,
        device=None,  # DDP maneja las GPUs automáticamente
    )

if __name__ == '__main__':
    main()
```

### Escalado de Learning Rate

```python
def scale_lr_for_multi_gpu(base_lr, num_gpus, batch_size_per_gpu):
    """
    Escala el learning rate para entrenamiento multi-GPU.
    
    Regla empírica (Linear Scaling Rule):
    LR = base_lr × (total_batch_size / base_batch_size)
    
    Si normalmente usas lr=0.001 con batch=16 en 1 GPU,
    con batch=64 en 4 GPUs deberías usar lr=0.004
    
    Esta regla fue propuesta por Facebook en 2017 y funciona bien
    para mantener la convergencia con batches más grandes.
    """
    base_batch = 16  # Batch size de referencia
    total_batch = num_gpus * batch_size_per_gpu
    scaled_lr = base_lr * (total_batch / base_batch)
    
    print(f"Base LR: {base_lr}")
    print(f"Total batch: {total_batch}")
    print(f"Scaled LR: {scaled_lr}")
    
    return scaled_lr

# Ejemplo
scaled = scale_lr_for_multi_gpu(0.001, 4, 16)
```

### Checklist Multi-GPU

```python
def multi_gpu_checklist():
    """
    Checklist antes de entrenamiento multi-GPU.
    """
    checklist = [
        "Verificar que todas las GPUs son del mismo modelo",
        "Confirmar que CUDA y drivers están actualizados",
        "Verificar comunicación entre GPUs (NVLink preferido)",
        "Ajustar batch size según memoria de la GPU más pequeña",
        "Escalar learning rate proporcionalmente",
        "Monitorear uso de GPU (todas deben estar activas)",
        "Verificar que el dataset no esté en disco lento",
    ]
    
    print("=== Multi-GPU Training Checklist ===")
    for i, item in enumerate(checklist, 1):
        print(f"{i}. [ ] {item}")
    
    return checklist

multi_gpu_checklist()
```

### Puntos Clave

- Data Parallelism divide el batch entre GPUs
- El batch size especificado es el total, se divide automáticamente
- Escala el learning rate con el batch size total
- DDP es más eficiente que DataParallel para muchas GPUs
- Verifica que todas las GPUs estén siendo utilizadas

### Referencias

- [Multi-GPU Training](https://docs.ultralytics.com/yolov5/tutorials/multi_gpu_training/)
- [Distributed Training Guide](https://pytorch.org/tutorials/intermediate/ddp_tutorial.html)

---

## 4.5 Debugging y Troubleshooting

### Introducción

El entrenamiento de modelos de deep learning rara vez funciona a la primera. Surgen problemas: el modelo no aprende, la pérdida diverge, las métricas no mejoran. Saber diagnosticar y resolver estos problemas es una habilidad esencial. Es como ser mecánico de coches de carreras: necesitas identificar el problema rápidamente para volver a la pista.

### Explicación Detallada

**Problemas comunes y sus síntomas:**

1. **Loss no disminuye**
   - Síntoma: La pérdida se mantiene constante o sube
   - Causas: Learning rate muy alto, datos corruptos, modelo mal inicializado

2. **Overfitting severo**
   - Síntoma: Train loss baja, val loss sube
   - Causas: Dataset muy pequeño, demasiadas epochs, falta de augmentación

3. **Underfitting**
   - Síntoma: Loss se estanca en valor alto
   - Causas: Modelo muy pequeño, learning rate muy bajo, epochs insuficientes

4. **NaN loss**
   - Síntoma: Loss se vuelve NaN (Not a Number)
   - Causas: Learning rate extremadamente alto, gradientes explosivos, datos con valores extremos

5. **Lentitud extrema**
   - Síntoma: Entrenamiento muy lento
   - Causas: Data loading en CPU, batch size pequeño, GPU no utilizada

### Diagnóstico de Pérdida

```python
import matplotlib.pyplot as plt
import pandas as pd

def analyze_training_logs(results_csv):
    """
    Analiza los logs de entrenamiento para detectar problemas.
    
    El archivo results.csv se genera automáticamente por YOLO
    y contiene métricas de cada epoch.
    
    Patrones a buscar:
    1. Train loss disminuye suavemente → Bien
    2. Val loss disminuye luego aumenta → Overfitting
    3. Loss oscila violentamente → LR muy alto
    4. Loss no cambia → Problema de inicialización o LR muy bajo
    """
    df = pd.read_csv(results_csv)
    df.columns = df.columns.str.strip()  # Limpiar nombres de columnas
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # 1. Pérdidas de entrenamiento
    axes[0, 0].plot(df['epoch'], df['train/box_loss'], label='Box Loss')
    axes[0, 0].plot(df['epoch'], df['train/cls_loss'], label='Class Loss')
    axes[0, 0].plot(df['epoch'], df['train/dfl_loss'], label='DFL Loss')
    axes[0, 0].set_xlabel('Epoch')
    axes[0, 0].set_ylabel('Loss')
    axes[0, 0].set_title('Training Losses')
    axes[0, 0].legend()
    axes[0, 0].grid(True)
    
    # 2. Train vs Val loss
    if 'val/box_loss' in df.columns:
        axes[0, 1].plot(df['epoch'], df['train/box_loss'], label='Train Box Loss')
        axes[0, 1].plot(df['epoch'], df['val/box_loss'], label='Val Box Loss')
        axes[0, 1].set_xlabel('Epoch')
        axes[0, 1].set_ylabel('Loss')
        axes[0, 1].set_title('Train vs Val Loss (Overfitting Check)')
        axes[0, 1].legend()
        axes[0, 1].grid(True)
    
    # 3. mAP
    if 'metrics/mAP50(B)' in df.columns:
        axes[1, 0].plot(df['epoch'], df['metrics/mAP50(B)'], label='mAP@50')
        if 'metrics/mAP50-95(B)' in df.columns:
            axes[1, 0].plot(df['epoch'], df['metrics/mAP50-95(B)'], label='mAP@50-95')
        axes[1, 0].set_xlabel('Epoch')
        axes[1, 0].set_ylabel('mAP')
        axes[1, 0].set_title('Mean Average Precision')
        axes[1, 0].legend()
        axes[1, 0].grid(True)
    
    # 4. Learning Rate
    if 'lr/pg0' in df.columns:
        axes[1, 1].plot(df['epoch'], df['lr/pg0'], label='Learning Rate')
        axes[1, 1].set_xlabel('Epoch')
        axes[1, 1].set_ylabel('LR')
        axes[1, 1].set_title('Learning Rate Schedule')
        axes[1, 1].legend()
        axes[1, 1].grid(True)
    
    plt.tight_layout()
    plt.savefig('training_analysis.png', dpi=150)
    plt.close()
    
    # Diagnóstico automático
    print("\n=== Diagnóstico de Entrenamiento ===")
    
    # Detectar overfitting
    if 'val/box_loss' in df.columns:
        last_10 = df.tail(10)
        train_trend = last_10['train/box_loss'].diff().mean()
        val_trend = last_10['val/box_loss'].diff().mean()
        
        if train_trend < 0 and val_trend > 0:
            print("⚠️  OVERFITTING detectado: Val loss aumenta mientras train loss disminuye")
            print("   Solución: Aumentar augmentación, reducir epochs, o añadir dropout")
    
    # Detectar LR muy alto
    loss_std = df['train/box_loss'].rolling(5).std().mean()
    if loss_std > 0.1:
        print("⚠️  Loss inestable: Posible learning rate muy alto")
        print("   Solución: Reducir lr0 a la mitad")
    
    # Detectar estancamiento
    last_20_map = df['metrics/mAP50(B)'].tail(20)
    if last_20_map.std() < 0.001:
        print("⚠️  mAP estancado: El modelo ha dejado de mejorar")
        print("   Solución: Probar modelo más grande o más datos")
    
    print("\nGráficas guardadas en training_analysis.png")

# Uso
# analyze_training_logs('runs/detect/train/results.csv')
```

### Soluciones a Problemas Comunes

```python
def troubleshooting_guide():
    """
    Guía de troubleshooting para problemas comunes.
    """
    problems = {
        "Loss = NaN": {
            "causa": "Learning rate muy alto o gradientes explosivos",
            "soluciones": [
                "Reducir lr0 (ej: de 0.01 a 0.001)",
                "Añadir gradient clipping",
                "Verificar que los datos estén normalizados",
                "Revisar si hay valores extremos en el dataset",
            ]
        },
        "Overfitting severo": {
            "causa": "Modelo memoriza datos de entrenamiento",
            "soluciones": [
                "Aumentar data augmentation",
                "Reducir epochs o usar early stopping",
                "Aumentar weight_decay",
                "Usar modelo más pequeño",
                "Añadir más datos de entrenamiento",
            ]
        },
        "Underfitting": {
            "causa": "Modelo no aprende patrones complejos",
            "soluciones": [
                "Usar modelo más grande (n → s → m)",
                "Aumentar epochs",
                "Aumentar learning rate",
                "Reducir augmentación (si es excesiva)",
                "Verificar calidad de anotaciones",
            ]
        },
        "Entrenamiento muy lento": {
            "causa": "Cuello de botella en data loading o cómputo",
            "soluciones": [
                "Aumentar num_workers",
                "Mover dataset a SSD",
                "Aumentar batch size",
                "Usar AMP (Automatic Mixed Precision)",
                "Verificar que la GPU se está usando",
            ]
        },
        "mAP muy bajo": {
            "causa": "Múltiples factores posibles",
            "soluciones": [
                "Verificar anotaciones (visualizar samples)",
                "Asegurar que data.yaml tiene clases correctas",
                "Aumentar epochs",
                "Probar modelo pre-entrenado diferente",
                "Revisar balance de clases",
            ]
        },
        "CUDA out of memory": {
            "causa": "Memoria GPU insuficiente",
            "soluciones": [
                "Reducir batch size",
                "Reducir image size",
                "Usar modelo más pequeño",
                "Limpiar cache de GPU: torch.cuda.empty_cache()",
                "Usar gradient accumulation",
            ]
        },
    }
    
    print("=== Guía de Troubleshooting ===\n")
    for problem, info in problems.items():
        print(f"PROBLEMA: {problem}")
        print(f"  Causa: {info['causa']}")
        print(f"  Soluciones:")
        for sol in info['soluciones']:
            print(f"    - {sol}")
        print()

troubleshooting_guide()
```

### Verificación de Datos

```python
def verify_dataset(data_yaml_path):
    """
    Verifica la integridad del dataset antes de entrenar.
    
    Problemas comunes en datasets:
    - Imágenes sin anotaciones correspondientes
    - Anotaciones sin imágenes
    - Coordenadas fuera de rango
    - Clases inexistentes
    - Archivos corruptos
    """
    import yaml
    import os
    from pathlib import Path
    
    # Cargar configuración
    with open(data_yaml_path) as f:
        config = yaml.safe_load(f)
    
    base_path = Path(config['path'])
    
    issues = []
    
    # Verificar cada split
    for split in ['train', 'val']:
        if split not in config:
            continue
            
        images_dir = base_path / config[split]
        labels_dir = images_dir.parent.parent / 'labels' / images_dir.name
        
        if not images_dir.exists():
            issues.append(f"{split}: Directorio de imágenes no existe: {images_dir}")
            continue
        
        images = list(images_dir.glob('*.jpg')) + list(images_dir.glob('*.png'))
        labels = list(labels_dir.glob('*.txt')) if labels_dir.exists() else []
        
        # Verificar correspondencia
        image_stems = {img.stem for img in images}
        label_stems = {lbl.stem for lbl in labels}
        
        missing_labels = image_stems - label_stems
        missing_images = label_stems - image_stems
        
        if missing_labels:
            issues.append(f"{split}: {len(missing_labels)} imágenes sin anotación")
        if missing_images:
            issues.append(f"{split}: {len(missing_images)} anotaciones sin imagen")
        
        # Verificar clases
        num_classes = config.get('nc', 0)
        for label_file in labels[:100]:  # Verificar primeros 100
            with open(label_file) as f:
                for line in f:
                    parts = line.strip().split()
                    if len(parts) >= 5:
                        class_id = int(parts[0])
                        if class_id >= num_classes:
                            issues.append(f"{label_file.name}: Clase {class_id} >= {num_classes}")
    
    # Reporte
    print("=== Verificación de Dataset ===")
    if issues:
        print("Problemas encontrados:")
        for issue in issues:
            print(f"  ⚠️  {issue}")
    else:
        print("✅ Dataset verificado correctamente")
    
    return issues

# Uso
# issues = verify_dataset('dataset.yaml')
```

### Puntos Clave

- Los problemas de training se reflejan en las curvas de pérdida
- Overfitting: train loss baja, val loss sube
- Underfitting: ambas pérdidas se estancan en valores altos
- NaN loss suele ser learning rate muy alto
- Siempre verifica el dataset antes de entrenar

### Referencias

- [Training Tips](https://github.com/ultralytics/yolov5/wiki/Tips-for-Best-Training-Results)
- [Common Issues](https://docs.ultralytics.com/yolov5/train_custom_data/#common-issues)
- [Debugging Guide](https://docs.ultralytics.com/modes/train/#troubleshooting)

---

# Módulo 5: Inferencia y Predicción (2h)

## 5.1 Inferencia Básica

### Introducción

Después de entrenar un modelo, el siguiente paso es usarlo para hacer predicciones. La inferencia es el proceso de tomar una imagen o video y obtener detecciones. Aunque parece simple, hay muchas consideraciones: umbrales de confianza, procesamiento por lotes, optimización de velocidad, y más. Dominar la inferencia es crucial para implementar YOLO en aplicaciones reales.

### Explicación Detallada

**El pipeline de inferencia:**

1. **Preprocesamiento**: La imagen se redimensiona, normaliza y convierte al formato que espera el modelo
2. **Forward pass**: La imagen pasa por la red neuronal
3. **Postprocesamiento**: Las predicciones se filtran (NMS), se escalan a coordenadas originales, y se formatean

**Consideraciones de velocidad vs precisión:**

- **Confianza alta** (0.7+): Menos detecciones, pero más confiables
- **Confianza baja** (0.25): Más detecciones, pero puede haber falsos positivos
- **IoU threshold alto** (0.7): Detecciones muy precisas, puede perder objetos cercanos
- **IoU threshold bajo** (0.3): Detecta objetos cercanos, pero puede haber duplicados

**Formatos de entrada soportados:**

- Imágenes: JPG, PNG, BMP, TIFF
- Videos: MP4, AVI, MOV
- Streams: RTSP, HTTP, webcam
- Arrays: NumPy arrays directamente

### Inferencia en Imágenes

```python
from ultralytics import YOLO

# Cargar modelo
model = YOLO('yolo11n.pt')

# Inferencia básica
results = model('imagen.jpg')

# El objeto results contiene toda la información
for result in results:
    # Bounding boxes
    boxes = result.boxes
    print(f"Detecciones: {len(boxes)}")
    
    for box in boxes:
        # Coordenadas (x1, y1, x2, y2)
        xyxy = box.xyxy[0].cpu().numpy()
        print(f"  Box: {xyxy}")
        
        # Confianza
        conf = box.conf[0].cpu().numpy()
        print(f"  Confianza: {conf:.2f}")
        
        # Clase
        cls = box.cls[0].cpu().numpy()
        class_name = result.names[int(cls)]
        print(f"  Clase: {class_name}")
```

**Parámetros de inferencia importantes:**

```python
results = model(
    'imagen.jpg',
    
    # Umbral de confianza
    conf=0.5,           # Solo mostrar detecciones con confianza > 0.5
    
    # Umbral IoU para NMS
    iou=0.7,            # Umbral para suprimir cajas superpuestas
    
    # Tamaño de imagen
    imgsz=640,          # Redimensionar a 640x640
    
    # Procesamiento
    half=False,         # Usar precisión media (FP16) para velocidad
    device='0',         # GPU a usar
    
    # Visualización
    show=True,          # Mostrar resultado en ventana
    save=True,          # Guardar resultado
    save_txt=True,      # Guardar detecciones en archivo txt
    save_conf=True,     # Incluir confianza en txt
    
    # Otros
    verbose=True,       # Mostrar información
    augment=False,      # Test-time augmentation
)
```

### Inferencia en Videos

```python
from ultralytics import YOLO

model = YOLO('yolo11n.pt')

# Procesar video completo
results = model.predict(
    source='video.mp4',
    save=True,          # Guardar video con detecciones
    show=True,          # Mostrar en tiempo real
    conf=0.5,
    stream=True,        # Importante: no cargar todo el video en memoria
)

# Iterar sobre resultados (un result por frame)
frame_count = 0
for result in results:
    frame_count += 1
    if frame_count % 30 == 0:  # Cada 30 frames
        print(f"Frame {frame_count}: {len(result.boxes)} detecciones")
```

**Ventajas del modo stream:**

Sin `stream=True`, YOLO carga todo el video en memoria antes de procesarlo. Con `stream=True`, procesa frame por frame, lo cual es esencial para videos largos.

### Inferencia en Tiempo Real

```python
from ultralytics import YOLO
import cv2
import time

model = YOLO('yolo11n.pt')

# Abrir cámara web
cap = cv2.VideoCapture(0)  # 0 = primera cámara

# Configurar resolución (opcional)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)

print("Presiona 'q' para salir")

while cap.isOpened():
    start_time = time.time()
    
    # Leer frame
    ret, frame = cap.read()
    if not ret:
        break
    
    # Inferencia
    results = model(frame, verbose=False)
    
    # Dibujar resultados
    annotated_frame = results[0].plot()
    
    # Calcular FPS
    fps = 1 / (time.time() - start_time)
    cv2.putText(annotated_frame, f'FPS: {fps:.1f}', (10, 30),
                cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
    
    # Mostrar
    cv2.imshow('YOLO Detection', annotated_frame)
    
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
```

### Inferencia con Batch

```python
from ultralytics import YOLO
import glob

model = YOLO('yolo11n.pt')

# Recopilar imágenes
images = glob.glob('dataset/images/*.jpg')[:100]  # Primeras 100

# Inferencia en batch
results = model(
    images,
    batch=32,           # Procesar 32 imágenes a la vez
    conf=0.5,
    stream=True,        # Importante para batches grandes
)

# Procesar resultados
for i, result in enumerate(results):
    if len(result.boxes) > 0:
        print(f"Imagen {i}: {len(result.boxes)} objetos detectados")
```

**Ventajas del batch processing:**

- Aprovecha paralelismo de GPU
- Mucho más rápido que procesar imágenes una por una
- Ideal cuando tienes muchas imágenes que procesar

### Puntos Clave

- La inferencia convierte imágenes en detecciones
- El umbral de confianza controla el balance precisión/recall
- Usa `stream=True` para videos y batches grandes
- La inferencia en tiempo real requiere optimización
- Batch processing es más eficiente para múltiples imágenes

### Referencias

- [Predict Mode](https://docs.ultralytics.com/modes/predict/)
- [Inference Arguments](https://docs.ultralytics.com/modes/predict/#inference-arguments)

---

## 5.2 Optimización de Velocidad

### Introducción

En aplicaciones reales, la velocidad de inferencia es crítica. Un detector que tarda 100ms por frame puede procesar 10 FPS, suficiente para algunos casos. Pero para aplicaciones como coches autónomos, necesitas 30+ FPS. Afortunadamente, hay muchas técnicas para acelerar YOLO sin sacrificar precisión.

### Explicación Detallada

**Factores que afectan la velocidad:**

1. **Hardware**: GPU vs CPU, tipo de GPU, memoria
2. **Modelo**: Nano es 10x más rápido que XL
3. **Precisión**: FP32 vs FP16 vs INT8
4. **Resolución**: 320x320 es 4x más rápido que 640x640
5. **Framework**: ONNX Runtime, TensorRT, OpenVINO

**Técnicas de optimización:**

1. **Half precision (FP16)**: Reduce memoria y acelera cálculos en GPUs modernas
2. **Quantization (INT8)**: Compresión agresiva, puede perder algo de precisión
3. **Exportar a formatos optimizados**: ONNX, TensorRT, CoreML
4. **Batch processing**: Aprovechar paralelismo
5. **Reducir resolución**: Menos píxeles = más rápido

### Benchmarking de Velocidad

```python
from ultralytics import YOLO
import time

def benchmark_model(model_path, image_path, iterations=100):
    """
    Mide la velocidad de inferencia de un modelo.
    
    Métricas importantes:
    - Latencia: Tiempo por imagen (ms)
    - Throughput: Imágenes por segundo (FPS)
    - Tiempo de preprocesamiento
    - Tiempo de inferencia
    - Tiempo de postprocesamiento
    """
    model = YOLO(model_path)
    
    # Warmup (para que CUDA se inicialice)
    for _ in range(10):
        _ = model(image_path, verbose=False)
    
    # Medir tiempo
    start = time.time()
    for _ in range(iterations):
        _ = model(image_path, verbose=False)
    end = time.time()
    
    # Calcular métricas
    total_time = end - start
    avg_time = (total_time / iterations) * 1000  # ms
    fps = iterations / total_time
    
    print(f"Modelo: {model_path}")
    print(f"Tiempo promedio: {avg_time:.2f} ms")
    print(f"FPS: {fps:.1f}")
    
    return avg_time, fps

# Comparar modelos
models = ['yolo11n.pt', 'yolo11s.pt', 'yolo11m.pt']
for model_path in models:
    benchmark_model(model_path, 'test_image.jpg')
    print()
```

### Half Precision (FP16)

```python
from ultralytics import YOLO

model = YOLO('yolo11n.pt')

# Inferencia con half precision
results = model(
    'imagen.jpg',
    half=True,          # Activar FP16
    device='0',         # Requiere GPU con soporte FP16
)

# Verificar que funciona
print(f"Detecciones: {len(results[0].boxes)}")
```

**Beneficios de FP16:**

- Reduce uso de memoria a la mitad
- Acelera inferencia 1.5-2x en GPUs modernas
- Pérdida de precisión negligible
- Soportado por todas las GPUs NVIDIA modernas

### Reducir Resolución

```python
from ultralytics import YOLO

model = YOLO('yolo11n.pt')

# Inferencia a resolución reducida
results = model(
    'imagen.jpg',
    imgsz=320,          # 320x320 en lugar de 640x640
)

# La imagen se redimensiona a 320x320 internamente
# Las detecciones se escalan automáticamente a la imagen original
```

**Trade-off de resolución:**

| Resolución | Velocidad | Precisión | Uso |
|------------|-----------|-----------|-----|
| 320x320 | Muy rápida | Menor | Edge devices |
| 416x416 | Rápida | Buena | Balance |
| 640x640 | Media | Óptima | Estándar |
| 1280x1280 | Lenta | Máxima | Alta precisión |

### Exportar para Inferencia Rápida

```python
from ultralytics import YOLO

model = YOLO('yolo11n.pt')

# Exportar a ONNX
model.export(
    format='onnx',
    imgsz=640,
    half=True,          # FP16
    simplify=True,      # Simplificar modelo
)

# Usar modelo exportado
model_onnx = YOLO('yolo11n.onnx')
results = model_onnx('imagen.jpg')
```

**Comparación de formatos:**

| Formato | Velocidad | Compatibilidad |
|---------|-----------|----------------|
| PyTorch (.pt) | Base | Python, PyTorch |
| ONNX | 1.2x | Universal |
| TensorRT | 2-5x | NVIDIA GPUs |
| CoreML | 1.5x | Apple devices |
| OpenVINO | 2x | Intel CPUs |

### Puntos Clave

- Half precision (FP16) acelera inferencia sin perder precisión
- Resolución menor = velocidad mayor, pero pierde objetos pequeños
- ONNX y TensorRT ofrecen speedups significativos
- Siempre benchmark en tu hardware específico
- Considera el trade-off velocidad/precisión para tu aplicación

### Referencias

- [Speed Optimization](https://docs.ultralytics.com/modes/predict/#speed-optimization)
- [Export Documentation](https://docs.ultralytics.com/modes/export/)

---

## 5.3 Procesamiento de Resultados

### Introducción

El objeto `Results` que devuelve YOLO contiene mucha información: bounding boxes, máscaras, keypoints, probabilidades. Saber extraer y manipular estos datos es esencial para integrar YOLO en aplicaciones. No basta con mostrar las detecciones; necesitas acceder a los datos para tomar decisiones, filtrar objetos, o enviar a otros sistemas.

### Explicación Detallada

**Estructura del objeto Results:**

```
Results
├── boxes: Bounding boxes
│   ├── xyxy: Coordenadas [x1, y1, x2, y2]
│   ├── xywh: Coordenadas [centro_x, centro_y, ancho, alto]
│   ├── conf: Confianza
│   └── cls: ID de clase
├── masks: Máscaras de segmentación
├── keypoints: Puntos clave (pose)
├── probs: Probabilidades (clasificación)
├── names: Diccionario {id: nombre_clase}
├── path: Ruta de la imagen original
└── orig_shape: Dimensiones originales
```

### Extracción de Bounding Boxes

```python
from ultralytics import YOLO
import numpy as np

model = YOLO('yolo11n.pt')
results = model('imagen.jpg')

result = results[0]  # Primera imagen (solo una en este caso)

# Método 1: Usando atributos individuales
boxes = result.boxes
for i in range(len(boxes)):
    # Coordenadas en diferentes formatos
    xyxy = boxes.xyxy[i].cpu().numpy()  # [x1, y1, x2, y2]
    xywh = boxes.xywh[i].cpu().numpy()  # [cx, cy, w, h]
    conf = boxes.conf[i].cpu().numpy()  # Confianza
    cls = boxes.cls[i].cpu().numpy()    # ID de clase
    
    class_name = result.names[int(cls)]
    
    print(f"Objeto {i}:")
    print(f"  Clase: {class_name}")
    print(f"  Confianza: {conf:.2f}")
    print(f"  BBox (xyxy): {xyxy}")

# Método 2: Obtener todo como numpy array
detections = boxes.data.cpu().numpy()  # [N, 6] -> [x1, y1, x2, y2, conf, cls]
print(f"\nTotal detecciones: {len(detections)}")
```

### Filtrado de Detecciones

```python
def filter_detections(results, min_conf=0.5, classes=None, min_area=0):
    """
    Filtra detecciones por múltiples criterios.
    
    Args:
        results: Resultado de YOLO
        min_conf: Confianza mínima
        classes: Lista de clases a incluir (None = todas)
        min_area: Área mínima del bounding box
    
    Returns:
        Detecciones filtradas
    
    Este tipo de filtrado es muy útil en aplicaciones reales:
    - Solo detectar personas (security)
    - Ignorar detecciones poco confiables
    - Filtrar objetos muy pequeños (ruido)
    """
    result = results[0]
    boxes = result.boxes
    
    filtered = []
    
    for i in range(len(boxes)):
        # Obtener datos
        xyxy = boxes.xyxy[i].cpu().numpy()
        conf = boxes.conf[i].cpu().numpy()
        cls = int(boxes.cls[i].cpu().numpy())
        
        # Filtro de confianza
        if conf < min_conf:
            continue
        
        # Filtro de clase
        if classes is not None and cls not in classes:
            continue
        
        # Filtro de área
        area = (xyxy[2] - xyxy[0]) * (xyxy[3] - xyxy[1])
        if area < min_area:
            continue
        
        filtered.append({
            'bbox': xyxy,
            'confidence': conf,
            'class_id': cls,
            'class_name': result.names[cls],
            'area': area
        })
    
    return filtered

# Uso
model = YOLO('yolo11n.pt')
results = model('imagen.jpg')

# Filtrar solo personas (clase 0) con confianza > 0.7
filtered = filter_detections(
    results,
    min_conf=0.7,
    classes=[0],  # 0 = persona en COCO
    min_area=1000  # Mínimo 1000 píxeles²
)

print(f"Detecciones filtradas: {len(filtered)}")
for det in filtered:
    print(f"  {det['class_name']}: conf={det['confidence']:.2f}")
```

### Exportar Resultados

```python
import json
import csv

def export_results_to_json(results, output_path):
    """
    Exporta detecciones a formato JSON.
    
    Útil para:
    - Enviar a APIs
    - Almacenar en base de datos
    - Integrar con otros sistemas
    """
    all_detections = []
    
    for result in results:
        image_detections = {
            'image_path': result.path,
            'image_shape': list(result.orig_shape),
            'detections': []
        }
        
        boxes = result.boxes
        for i in range(len(boxes)):
            xyxy = boxes.xyxy[i].cpu().numpy().tolist()
            conf = float(boxes.conf[i].cpu().numpy())
            cls = int(boxes.cls[i].cpu().numpy())
            
            image_detections['detections'].append({
                'bbox': xyxy,
                'confidence': round(conf, 4),
                'class_id': cls,
                'class_name': result.names[cls]
            })
        
        all_detections.append(image_detections)
    
    with open(output_path, 'w') as f:
        json.dump(all_detections, f, indent=2)
    
    print(f"Exportado a {output_path}")

def export_results_to_csv(results, output_path):
    """
    Exporta detecciones a CSV.
    
    Útil para:
    - Análisis en Excel/Sheets
    - Reportes
    - Visualización de datos
    """
    with open(output_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['image', 'class', 'confidence', 'x1', 'y1', 'x2', 'y2', 'width', 'height'])
        
        for result in results:
            boxes = result.boxes
            for i in range(len(boxes)):
                xyxy = boxes.xyxy[i].cpu().numpy()
                conf = float(boxes.conf[i].cpu().numpy())
                cls = int(boxes.cls[i].cpu().numpy())
                
                width = xyxy[2] - xyxy[0]
                height = xyxy[3] - xyxy[1]
                
                writer.writerow([
                    result.path,
                    result.names[cls],
                    round(conf, 4),
                    round(xyxy[0], 2),
                    round(xyxy[1], 2),
                    round(xyxy[2], 2),
                    round(xyxy[3], 2),
                    round(width, 2),
                    round(height, 2)
                ])
    
    print(f"Exportado a {output_path}")

# Uso
model = YOLO('yolo11n.pt')
results = model(['imagen1.jpg', 'imagen2.jpg'])

export_results_to_json(results, 'detecciones.json')
export_results_to_csv(results, 'detecciones.csv')
```

### Visualización Personalizada

```python
import cv2

def draw_custom_boxes(image_path, results, output_path):
    """
    Dibuja bounding boxes con estilo personalizado.
    
    Personalización posible:
    - Colores por clase
    - Tamaño de fuente
    - Mostrar/ocultar confianza
    - Estilo de línea
    """
    image = cv2.imread(image_path)
    result = results[0]
    
    # Colores por clase (BGR)
    colors = {
        0: (0, 255, 0),    # Persona: verde
        1: (255, 0, 0),    # Bicicleta: azul
        2: (0, 0, 255),    # Carro: rojo
        # Añadir más según necesites
    }
    default_color = (255, 255, 255)
    
    boxes = result.boxes
    for i in range(len(boxes)):
        xyxy = boxes.xyxy[i].cpu().numpy().astype(int)
        conf = float(boxes.conf[i].cpu().numpy())
        cls = int(boxes.cls[i].cpu().numpy())
        
        color = colors.get(cls, default_color)
        
        # Dibujar rectángulo
        cv2.rectangle(image, (xyxy[0], xyxy[1]), (xyxy[2], xyxy[3]), color, 2)
        
        # Texto con fondo
        label = f"{result.names[cls]} {conf:.2f}"
        (text_width, text_height), _ = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.6, 2)
        cv2.rectangle(image, (xyxy[0], xyxy[1] - text_height - 10), 
                      (xyxy[0] + text_width, xyxy[1]), color, -1)
        cv2.putText(image, label, (xyxy[0], xyxy[1] - 5),
                   cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)
    
    cv2.imwrite(output_path, image)
    print(f"Guardado en {output_path}")

# Uso
model = YOLO('yolo11n.pt')
results = model('imagen.jpg')
draw_custom_boxes('imagen.jpg', results, 'output_custom.jpg')
```

### Puntos Clave

- El objeto Results contiene boxes, masks, keypoints, y probs
- Las coordenadas están disponibles en múltiples formatos
- Filtrar detecciones es esencial para aplicaciones reales
- Exportar a JSON/CSV permite integrar con otros sistemas
- La visualización personalizada mejora la presentación de resultados

### Referencias

- [Results Object](https://docs.ultralytics.com/reference/engine/results/)
- [Predict Usage](https://docs.ultralytics.com/modes/predict/)

---

# Módulo 6: Validación y Métricas (2h)

## 6.1 Evaluación de Modelos

### Introducción

Entrenar un modelo es solo el comienzo. Para saber si realmente funciona, necesitamos evaluarlo rigurosamente. La validación nos dice qué tan bien generaliza el modelo a datos no vistos. Las métricas nos dan números concretos para comparar modelos y tomar decisiones. Sin una evaluación adecuada, no sabemos si el modelo es útil o si está sobreajustado.

### Explicación Detallada

**El proceso de evaluación:**

1. **Separar datos**: Train (entrenar), Val (ajustar hiperparámetros), Test (evaluación final)
2. **Correr inferencia**: Aplicar el modelo a datos de validación/test
3. **Comparar predicciones**: Medir qué tan bien coinciden con las anotaciones reales
4. **Calcular métricas**: mAP, precision, recall, F1
5. **Analizar errores**: ¿Dónde falla el modelo?

**Conjuntos de datos:**

- **Train set**: Imágenes usadas para entrenar (el modelo "ve" estas imágenes)
- **Validation set**: Imágenes para ajustar hiperparámetros y early stopping
- **Test set**: Imágenes nunca vistas, para evaluación final imparcial

**Error común**: Usar el test set durante el desarrollo. El test set debe usarse UNA sola vez, al final.

### Validación de Modelo

```python
from ultralytics import YOLO

# Cargar modelo entrenado
model = YOLO('runs/detect/train/weights/best.pt')

# Validar en dataset de validación
metrics = model.val(
    data='dataset.yaml',
    imgsz=640,
    batch=16,
    conf=0.001,         # Umbral bajo para ver todas las detecciones
    iou=0.6,            # Umbral IoU para NMS
    device='0',
    plots=True,         # Generar gráficas
    save_json=True,     # Guardar resultados en JSON
)

# Acceder a métricas
print(f"mAP@50: {metrics.box.map50:.4f}")
print(f"mAP@50-95: {metrics.box.map:.4f}")
print(f"mAP@75: {metrics.box.map75:.4f}")

# Precision y Recall
print(f"Precision: {metrics.box.mp:.4f}")
print(f"Recall: {metrics.box.mr:.4f}")
```

**Interpretación de métricas:**

| Métrica | Valor | Interpretación |
|---------|-------|---------------|
| mAP@50 | >0.7 | Excelente |
| mAP@50 | 0.5-0.7 | Bueno |
| mAP@50 | <0.5 | Necesita mejorar |
| mAP@50-95 | >0.5 | State-of-the-art |
| mAP@50-95 | 0.3-0.5 | Decente |

### Métricas por Clase

```python
# Acceder a métricas por clase
class_names = model.names

for i, name in class_names.items():
    ap = metrics.box.ap50[i]  # AP@50 para esta clase
    print(f"{name}: AP@50 = {ap:.4f}")
```

**Análisis de clases problemáticas:**

Si algunas clases tienen AP muy bajo:
1. Verificar cantidad de datos de esa clase
2. Revisar calidad de anotaciones
3. Considerar recolectar más datos
4. Posible desbalance de clases

### Matriz de Confusión

```python
# La matriz de confusión se genera automáticamente con plots=True
# Ubicación: runs/detect/val/confusion_matrix.png

# Análisis de confusión:
# - Diagonal: Predicciones correctas
# - Fuera de diagonal: Errores de clasificación
# - Última columna: Falsos positivos
# - Última fila: Falsos negativos

def analyze_confusion_matrix(confusion_matrix_path):
    """
    Analiza la matriz de confusión generada por YOLO.
    
    Patrones a buscar:
    - Diagonal fuerte: Buenas predicciones
    - Fuera de diagonal: Confusiones entre clases
    - Muchos falsos positivos: Umbral de confianza muy bajo
    - Muchos falsos negativos: Modelo no detecta suficientes objetos
    """
    import numpy as np
    
    # Cargar matriz (si está en formato numpy)
    cm = np.load(confusion_matrix_path)
    
    # Normalizar por fila
    cm_normalized = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]
    
    # Encontrar confusiones más comunes
    n_classes = cm.shape[0] - 1  # -1 por fila/columna de background
    
    confusions = []
    for i in range(n_classes):
        for j in range(n_classes):
            if i != j and cm_normalized[i, j] > 0.1:
                confusions.append((i, j, cm_normalized[i, j]))
    
    confusions.sort(key=lambda x: x[2], reverse=True)
    
    print("Top confusiones:")
    for true_cls, pred_cls, rate in confusions[:5]:
        print(f"  Clase {true_cls} → Clase {pred_cls}: {rate:.1%}")

# Uso
# analyze_confusion_matrix('runs/detect/val/confusion_matrix.npy')
```

### Curvas PR (Precision-Recall)

```python
# Las curvas PR se generan automáticamente
# Ubicación: runs/detect/val/PR_curve.png, F1_curve.png, P_curve.png, R_curve.png

def interpret_pr_curves():
    """
    Interpreta las curvas Precision-Recall.
    
    Curva PR ideal:
    - Forma de L invertida (precision 1 hasta recall alto)
    - Área bajo la curva grande = alto AP
    
    Patrones problemáticos:
    - Curva muy baja: Modelo pobre
    - Precisión que cae rápido: Muchos falsos positivos
    - Recall que no llega a 1: Objeto no detectados
    """
    print("Interpretación de curvas PR:")
    print("1. F1_curve.png: Balance entre precision y recall")
    print("2. P_curve.png: Precision vs confianza")
    print("3. R_curve.png: Recall vs confianza")
    print("4. PR_curve.png: Precision vs recall")

interpret_pr_curves()
```

### Puntos Clave

- La validación mide el rendimiento en datos no vistos
- mAP@50-95 es la métrica más importante
- Analizar métricas por clase revela problemas específicos
- La matriz de confusión muestra errores de clasificación
- Las curvas PR muestran el trade-off precision/recall

### Referencias

- [Validation Mode](https://docs.ultralytics.com/modes/val/)
- [Performance Metrics](https://docs.ultralytics.com/guides/yolo-performance-metrics/)

---

## 6.2 Benchmarking Comparativo

### Introducción

Cuando desarrollas un modelo, necesitas compararlo contra otros. ¿Es mejor que YOLOv5? ¿Vale la pena usar un modelo más grande? El benchmarking sistemático te permite tomar decisiones basadas en datos, no en intuición. Además, comparar con modelos publicados te indica si tu modelo es competitivo.

### Explicación Detallada

**Comparaciones importantes:**

1. **Modelos baseline**: Comparar con modelos anteriores (YOLOv5, Faster R-CNN)
2. **Variantes de tamaño**: YOLO11n vs YOLO11s vs YOLO11m
3. **Entrenamientos**: Distintos hiperparámetros o datasets
4. **Frameworks**: PyTorch vs ONNX vs TensorRT

**Métricas a comparar:**

- Precisión: mAP@50, mAP@50-95
- Velocidad: FPS, latencia (ms)
- Eficiencia: Precisión/FLOPs, Precisión/parámetros

### Benchmark de Modelos

```python
import pandas as pd
from ultralytics import YOLO
import time

def comprehensive_benchmark(models_config, data_yaml, num_images=100):
    """
    Benchmark comprehensivo de múltiples modelos.
    
    Mide:
    - Precisión (mAP)
    - Velocidad (FPS)
    - Tamaño (MB)
    - Parámetros
    - FLOPs
    """
    results = []
    
    for model_name, model_path in models_config.items():
        print(f"\n=== Evaluando {model_name} ===")
        
        model = YOLO(model_path)
        
        # 1. Validación (precisión)
        metrics = model.val(data=data_yaml, verbose=False)
        
        # 2. Benchmark de velocidad
        # Warmup
        for _ in range(10):
            _ = model('test_image.jpg', verbose=False)
        
        # Medición
        start = time.time()
        for _ in range(num_images):
            _ = model('test_image.jpg', verbose=False)
        end = time.time()
        
        fps = num_images / (end - start)
        latency_ms = ((end - start) / num_images) * 1000
        
        # 3. Info del modelo
        info = model.info()
        
        results.append({
            'Model': model_name,
            'mAP@50': metrics.box.map50,
            'mAP@50-95': metrics.box.map,
            'FPS': fps,
            'Latency (ms)': latency_ms,
            'Parameters (M)': info['parameters'] / 1e6,
            'Size (MB)': info['model_size'],
        })
    
    return pd.DataFrame(results)

# Configuración de modelos
models = {
    'YOLO11n': 'yolo11n.pt',
    'YOLO11s': 'yolo11s.pt',
    'YOLO11m': 'yolo11m.pt',
    'YOLOv8n': 'yolov8n.pt',
    'YOLOv5n': 'yolov5n.pt',
}

# Ejecutar benchmark
# df = comprehensive_benchmark(models, 'dataset.yaml')
# print(df.to_string(index=False))
```

### Visualización de Comparaciones

```python
import matplotlib.pyplot as plt

def plot_model_comparison(df):
    """
    Visualiza comparación de modelos en múltiples dimensiones.
    """
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # 1. Precisión vs Velocidad
    ax = axes[0, 0]
    ax.scatter(df['FPS'], df['mAP@50-95'], s=100)
    for i, model in enumerate(df['Model']):
        ax.annotate(model, (df['FPS'].iloc[i], df['mAP@50-95'].iloc[i]),
                   xytext=(5, 5), textcoords='offset points')
    ax.set_xlabel('FPS')
    ax.set_ylabel('mAP@50-95')
    ax.set_title('Precisión vs Velocidad')
    ax.grid(True)
    
    # 2. Parámetros vs Precisión
    ax = axes[0, 1]
    ax.scatter(df['Parameters (M)'], df['mAP@50-95'], s=100)
    for i, model in enumerate(df['Model']):
        ax.annotate(model, (df['Parameters (M)'].iloc[i], df['mAP@50-95'].iloc[i]),
                   xytext=(5, 5), textcoords='offset points')
    ax.set_xlabel('Parámetros (M)')
    ax.set_ylabel('mAP@50-95')
    ax.set_title('Complejidad vs Precisión')
    ax.grid(True)
    
    # 3. Latencia
    ax = axes[1, 0]
    df_sorted = df.sort_values('Latency (ms)')
    ax.barh(df_sorted['Model'], df_sorted['Latency (ms)'])
    ax.set_xlabel('Latencia (ms)')
    ax.set_title('Latencia de Inferencia')
    
    # 4. mAP barras
    ax = axes[1, 1]
    x = range(len(df))
    width = 0.35
    ax.bar([i - width/2 for i in x], df['mAP@50'], width, label='mAP@50')
    ax.bar([i + width/2 for i in x], df['mAP@50-95'], width, label='mAP@50-95')
    ax.set_xticks(x)
    ax.set_xticklabels(df['Model'], rotation=45)
    ax.set_ylabel('mAP')
    ax.set_title('Comparación de Precisión')
    ax.legend()
    
    plt.tight_layout()
    plt.savefig('model_comparison.png', dpi=150)
    plt.close()
    print("Guardado en model_comparison.png")

# Uso
# plot_model_comparison(df)
```

### Puntos Clave

- El benchmarking permite comparar objetivamente diferentes modelos
- Precisión vs velocidad es el trade-off principal
- Comparar con baselines establecidos es esencial
- Documentar todas las condiciones del experimento
- Usar múltiples métricas para una evaluación completa

### Referencias

- [Benchmark Mode](https://docs.ultralytics.com/modes/benchmark/)
- [YOLO Performance Metrics](https://docs.ultralytics.com/guides/yolo-performance-metrics/)

---

# Módulo 7: Exportación y Despliegue (2h)

## 7.1 Formatos de Exportación

### Introducción

Un modelo entrenado en PyTorch es útil, pero para desplegarlo en producción necesitas formatos más eficientes y portátiles. ONNX permite interoperabilidad entre frameworks, TensorRT maximiza la velocidad en GPUs NVIDIA, CoreML es esencial para dispositivos Apple, y TFLite corre en móviles y edge devices. La exportación es el puente entre el desarrollo y la producción.

### Explicación Detallada

**¿Por qué exportar?**

El formato PyTorch (.pt) tiene limitaciones:
- Requiere PyTorch instalado
- No es optimizado para inferencia
- No es portable entre frameworks
- No aprovecha aceleradores específicos

Los formatos exportados ofrecen:
- **ONNX**: Estándar universal, compatible con muchos runtimes
- **TensorRT**: Optimización extrema en GPUs NVIDIA
- **CoreML**: Integración nativa en ecosistema Apple
- **TFLite**: Diseñado para móviles y microcontroladores
- **OpenVINO**: Optimizado para CPUs Intel

**Flujo de exportación:**

```
PyTorch (.pt)
     ↓
   ONNX (intermedio universal)
     ↓
   ┌─────┬─────────┬─────────┬──────────┐
   ↓     ↓         ↓         ↓          ↓
TensorRT CoreML  TFLite  OpenVINO   ONNX Runtime
```

### Exportar a ONNX

```python
from ultralytics import YOLO

model = YOLO('best.pt')

# Exportación básica a ONNX
model.export(format='onnx')

# Exportación con optimizaciones
model.export(
    format='onnx',
    imgsz=640,
    half=True,          # FP16 para reducir tamaño y acelerar
    simplify=True,      # Simplificar grafo computacional
    dynamic=False,      # Tamaño fijo (True = tamaños dinámicos)
    opset=12,           # Versión de ONNX opset
)

# Verificar exportación
import onnx
onnx_model = onnx.load('best.onnx')
onnx.checker.check_model(onnx_model)
print("Modelo ONNX válido!")

# Usar modelo ONNX
model_onnx = YOLO('best.onnx')
results = model_onnx('imagen.jpg')
```

**Ventajas de ONNX:**

- Compatibilidad universal
- Depuración fácil con Netron
- Base para otras exportaciones
- Soporte en todos los cloud providers

### Exportar a TensorRT

```python
from ultralytics import YOLO

model = YOLO('best.pt')

# Exportar a TensorRT
model.export(
    format='engine',    # TensorRT engine
    imgsz=640,
    half=True,          # FP16 (recomendado para TensorRT)
    device=0,           # GPU específica
    workspace=4,        # Workspace en GB
    simplify=True,
)

# El archivo generado es .engine
# Solo funciona en la GPU donde se exportó
```

**Optimizaciones de TensorRT:**

1. **Layer fusion**: Combina capas para reducir memoria y cálculos
2. **Precision calibration**: FP16 o INT8 con mínima pérdida
3. **Kernel auto-tuning**: Selecciona los mejores kernels para tu GPU
4. **Dynamic tensor memory**: Optimiza uso de memoria

**Speedup típico con TensorRT:**

| Modelo | PyTorch | ONNX | TensorRT FP16 |
|--------|---------|------|---------------|
| YOLO11n | 5ms | 4ms | 2ms |
| YOLO11s | 12ms | 10ms | 5ms |
| YOLO11m | 25ms | 20ms | 10ms |

### Exportar a CoreML

```python
from ultralytics import YOLO

model = YOLO('best.pt')

# Exportar a CoreML para dispositivos Apple
model.export(
    format='coreml',
    imgsz=640,
    half=False,         # CoreML no soporta FP16 en todos los dispositivos
    nms=True,           # Incluir NMS en el modelo
)

# El archivo .mlmodel puede usarse en iOS/macOS
```

**Uso en iOS (Swift):**

```swift
import CoreML
import Vision

// Cargar modelo
guard let model = try? VNCoreMLModel(for: YOLO11n().model) else {
    fatalError("Error cargando modelo")
}

// Crear request
let request = VNCoreMLRequest(model: model) { request, error in
    guard let results = request.results as? [VNRecognizedObjectAnnotation] else {
        return
    }
    
    for detection in results {
        let boundingBox = detection.boundingBox
        let confidence = detection.confidence
        let label = detection.labels.first?.identifier
        
        print("Detectado: \(label ?? "?") con confianza \(confidence)")
    }
}
```

### Exportar a TFLite

```python
from ultralytics import YOLO

model = YOLO('best.pt')

# Exportar a TFLite para móviles Android
model.export(
    format='tflite',
    imgsz=640,
    half=False,         # TFLite quantization es diferente
    int8=True,          # Quantización INT8 para menor tamaño
)

# Genera archivo .tflite
```

**Integración en Android:**

```java
// Cargar modelo
Interpreter tflite = new Interpreter(loadModelFile("best.tflite"));

// Preparar buffers
ByteBuffer inputBuffer = ByteBuffer.allocateDirect(1 * 640 * 640 * 3 * 4);
inputBuffer.order(ByteOrder.nativeOrder());

// Inferencia
tflite.run(inputBuffer, outputBuffer);
```

### Comparación de Formatos

```python
def compare_formats(model_path):
    """
    Compara tamaño y velocidad de diferentes formatos.
    """
    import os
    from pathlib import Path
    
    formats = ['onnx', 'engine', 'coreml', 'tflite']
    results = []
    
    for fmt in formats:
        try:
            # Exportar
            model = YOLO(model_path)
            export_path = model.export(format=fmt)
            
            # Tamaño
            size_mb = os.path.getsize(export_path) / (1024 * 1024)
            
            results.append({
                'Format': fmt,
                'Size (MB)': size_mb,
                'Path': export_path
            })
        except Exception as e:
            print(f"Error exportando a {fmt}: {e}")
    
    for r in results:
        print(f"{r['Format']}: {r['Size (MB)']:.2f} MB")
    
    return results

# compare_formats('best.pt')
```

### Puntos Clave

- ONNX es el formato universal de intercambio
- TensorRT ofrece la máxima velocidad en NVIDIA
- CoreML es esencial para ecosistema Apple
- TFLite permite despliegue en móviles
- La cuantización reduce tamaño significativamente

### Referencias

- [Export Documentation](https://docs.ultralytics.com/modes/export/)
- [ONNX Runtime](https://onnxruntime.ai/)
- [TensorRT Guide](https://docs.nvidia.com/deeplearning/tensorrt/)

---

## 7.2 Despliegue en Producción

### Introducción

Desplegar un modelo en producción requiere considerar más allá de la inferencia: escalabilidad, latencia, disponibilidad, monitoreo y actualizaciones. Una arquitectura bien diseñada permite servir miles de peticiones por segundo con latencia mínima, mientras se mantiene observabilidad y facilidad de mantenimiento.

### Explicación Detallada

**Arquitecturas de despliegue:**

1. **Batch Processing**: Procesar lotes de imágenes offline
   - Ideal para análisis de datos históricos
   - No requiere baja latencia
   - Fácil de escalar

2. **REST API**: Servir inferencia vía HTTP
   - Estándar universal
   - Fácil integración
   - Latencia moderada

3. **Streaming**: Procesar video en tiempo real
   - Mínima latencia
   - Requiere conexión persistente
   - Ideal para cámaras de seguridad

4. **Edge**: Inferencia en dispositivo
   - Sin dependencia de red
   - Privacidad de datos
   - Recursos limitados

### API REST con FastAPI

```python
from fastapi import FastAPI, File, UploadFile, HTTPException
from ultralytics import YOLO
import numpy as np
import cv2
import io
from PIL import Image

app = FastAPI(title="YOLO Detection API")

# Cargar modelo al iniciar
model = YOLO('best.pt')

@app.get("/health")
async def health_check():
    """Endpoint de salud para monitoring."""
    return {"status": "healthy", "model": "loaded"}

@app.post("/detect")
async def detect_objects(
    file: UploadFile = File(...),
    confidence: float = 0.5,
    iou_threshold: float = 0.7
):
    """
    Detecta objetos en una imagen.
    
    Args:
        file: Imagen a procesar
        confidence: Umbral de confianza mínimo
        iou_threshold: Umbral IoU para NMS
    
    Returns:
        Lista de detecciones con bounding boxes, clases y confianzas
    
    Esta API es síncrona - adecuada para cargas de trabajo moderadas.
    Para alta concurrencia, considerar usar una cola de tareas.
    """
    # Validar tipo de archivo
    if not file.content_type.startswith('image/'):
        raise HTTPException(status_code=400, detail="File must be an image")
    
    # Leer imagen
    contents = await file.read()
    image = Image.open(io.BytesIO(contents))
    image_np = np.array(image)
    
    # Convertir RGB a BGR si es necesario
    if len(image_np.shape) == 3 and image_np.shape[2] == 3:
        image_np = cv2.cvtColor(image_np, cv2.COLOR_RGB2BGR)
    
    # Inferencia
    results = model(
        image_np,
        conf=confidence,
        iou=iou_threshold,
        verbose=False
    )
    
    # Extraer detecciones
    detections = []
    for result in results:
        boxes = result.boxes
        for i in range(len(boxes)):
            xyxy = boxes.xyxy[i].cpu().numpy().tolist()
            conf = float(boxes.conf[i].cpu().numpy())
            cls = int(boxes.cls[i].cpu().numpy())
            
            detections.append({
                "bbox": xyxy,
                "confidence": round(conf, 4),
                "class_id": cls,
                "class_name": result.names[cls]
            })
    
    return {
        "detections": detections,
        "count": len(detections),
        "image_size": [image.width, image.height]
    }

@app.post("/detect/batch")
async def detect_batch(files: list[UploadFile] = File(...)):
    """
    Detecta objetos en múltiples imágenes.
    
    El batch processing es más eficiente que múltiples
    llamadas individuales porque aprovecha el paralelismo.
    """
    images = []
    for file in files:
        contents = await file.read()
        image = Image.open(io.BytesIO(contents))
        images.append(np.array(image))
    
    # Inferencia en batch
    results = model(images, verbose=False)
    
    all_detections = []
    for result in results:
        detections = []
        for i in range(len(result.boxes)):
            xyxy = result.boxes.xyxy[i].cpu().numpy().tolist()
            conf = float(result.boxes.conf[i].cpu().numpy())
            cls = int(result.boxes.cls[i].cpu().numpy())
            
            detections.append({
                "bbox": xyxy,
                "confidence": round(conf, 4),
                "class_id": cls,
                "class_name": result.names[cls]
            })
        all_detections.append(detections)
    
    return {"results": all_detections}

# Ejecutar con: uvicorn api:app --host 0.0.0.0 --port 8000
```

### Despliegue con Docker

```dockerfile
# Dockerfile
FROM python:3.10-slim

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

# Directorio de trabajo
WORKDIR /app

# Copiar requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código y modelo
COPY . .

# Puerto
EXPOSE 8000

# Comando
CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8000"]
```

```txt
# requirements.txt
ultralytics>=8.0.0
fastapi>=0.100.0
uvicorn>=0.22.0
python-multipart>=0.0.6
numpy
opencv-python-headless
Pillow
```

```yaml
# docker-compose.yml
version: '3.8'

services:
  yolo-api:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - ./models:/app/models
    environment:
      - MODEL_PATH=/app/models/best.pt
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
```

### Despliegue en Cloud

```python
# Ejemplo para AWS Lambda (usando container image)
import json
import base64
from ultralytics import YOLO
import numpy as np
import cv2

model = None

def lambda_handler(event, context):
    """
    Handler para AWS Lambda.
    
    Lambda es ideal para cargas de trabajo intermitentes.
    No es la mejor opción para alta concurrencia debido al cold start.
    """
    global model
    
    # Lazy loading del modelo
    if model is None:
        model = YOLO('/var/task/best.pt')
    
    # Obtener imagen del evento
    if 'body' in event:
        image_bytes = base64.b64decode(event['body'])
    else:
        return {'statusCode': 400, 'body': 'No image provided'}
    
    # Procesar
    nparr = np.frombuffer(image_bytes, np.uint8)
    image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    
    results = model(image, verbose=False)
    
    # Formatear respuesta
    detections = []
    for result in results:
        boxes = result.boxes
        for i in range(len(boxes)):
            detections.append({
                'bbox': boxes.xyxy[i].cpu().numpy().tolist(),
                'confidence': float(boxes.conf[i].cpu().numpy()),
                'class_name': result.names[int(boxes.cls[i].cpu().numpy())]
            })
    
    return {
        'statusCode': 200,
        'body': json.dumps({'detections': detections})
    }
```

### Monitoreo y Logging

```python
import logging
from datetime import datetime
import json

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class MonitoredYOLO:
    """
    Wrapper de YOLO con monitoreo integrado.
    
    Registra:
    - Tiempo de inferencia
    - Número de detecciones
    - Errores
    - Uso de memoria
    """
    
    def __init__(self, model_path):
        self.model = YOLO(model_path)
        self.inference_count = 0
        self.total_latency = 0
        
    def predict(self, image, **kwargs):
        start_time = datetime.now()
        
        try:
            results = self.model(image, **kwargs)
            
            latency = (datetime.now() - start_time).total_seconds() * 1000
            
            self.inference_count += 1
            self.total_latency += latency
            
            # Log de inferencia
            logger.info(json.dumps({
                'event': 'inference',
                'latency_ms': latency,
                'detections': len(results[0].boxes) if results else 0,
                'avg_latency_ms': self.total_latency / self.inference_count
            }))
            
            return results
            
        except Exception as e:
            logger.error(json.dumps({
                'event': 'error',
                'error': str(e),
                'image_shape': getattr(image, 'shape', 'unknown')
            }))
            raise

# Uso
# model = MonitoredYOLO('best.pt')
# results = model.predict('image.jpg')
```

### Puntos Clave

- FastAPI es ideal para crear APIs REST de inferencia
- Docker facilita el despliegue consistente
- Cloud serverless (Lambda) tiene cold starts
- El monitoreo es esencial para producción
- El batch processing es más eficiente que llamadas individuales

### Referencias

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Docker Guide](https://docs.docker.com/)
- [AWS Lambda ML](https://docs.aws.amazon.com/lambda/latest/dg/with-ml.html)

---

# Módulo 8: Seguimiento de Objetos (Object Tracking) (2h)

## 8.1 Fundamentos de Tracking

### Introducción

La detección de objetos encuentra objetos en cada frame individualmente. Pero en video, queremos más: ¿Es este objeto el mismo que vimos en el frame anterior? ¿Cuál es su trayectoria? El seguimiento de objetos (tracking) responde a estas preguntas asignando IDs persistentes a los objetos a través del tiempo. Es la diferencia entre ver una foto y ver una película.

### Explicación Detallada

**Detección vs Tracking:**

- **Detección**: "Hay una persona en el frame 1" y "Hay una persona en el frame 2"
- **Tracking**: "La persona con ID=5 que estaba en el frame 1 se movió a esta posición en el frame 2"

**Componentes de un tracker:**

1. **Detección**: Encontrar objetos en cada frame
2. **Asociación**: Matchear detecciones con tracks existentes
3. **Predicción**: Estimar dónde estará el objeto en el siguiente frame
4. **Actualización**: Corregir la estimación con la nueva detección

**Algoritmos comunes:**

- **SORT**: Simple, rápido, usa Kalman filter
- **DeepSORT**: Añade apariencia visual para mejor asociación
- **ByteTrack**: Muy efectivo, usa detecciones de baja confianza
- **BoT-SORT**: Combina DeepSORT y ByteTrack

**Métricas de tracking:**

- **MOTA**: Multi-Object Tracking Accuracy
- **MOTP**: Multi-Object Tracking Precision
- **IDF1**: Identity F1 Score
- **IDs**: Número de identity switches (menos es mejor)

### Tracking Básico con YOLO

```python
from ultralytics import YOLO

model = YOLO('yolo11n.pt')

# Tracking en video
results = model.track(
    source='video.mp4',
    show=True,           # Mostrar en tiempo real
    save=True,           # Guardar video con tracks
    conf=0.5,
    iou=0.5,
    
    # Tracker específico
    tracker='botsort.yaml',  # o 'bytetrack.yaml'
)
```

**Trackers disponibles en YOLO:**

```yaml
# botsort.yaml
tracker_type: botsort
track_buffer: 30        # Frames sin detección antes de perder track
match_thresh: 0.8       # Umbral de matching
gmc_method: sparseOptFlow  # Método para corregir movimiento de cámara

# bytetrack.yaml  
tracker_type: bytetrack
track_thresh: 0.25      # Umbral de confianza para crear track
track_buffer: 30        # Buffer de frames
match_thresh: 0.8       # Umbral de matching
det_thresh: 0.3         # Umbral para detecciones secundarias
```

### Tracking en Tiempo Real

```python
from ultralytics import YOLO
import cv2

def real_time_tracking(camera_id=0):
    """
    Tracking en tiempo real con cámara web.
    
    Muestra:
    - Bounding boxes con IDs
    - Trayectoria de cada objeto
    - Contador de objetos únicos
    """
    model = YOLO('yolo11n.pt')
    cap = cv2.VideoCapture(camera_id)
    
    # Historial de trayectorias
    track_history = {}
    
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        
        # Tracking
        results = model.track(
            frame,
            persist=True,       # Mantener estado entre frames
            tracker='bytetrack.yaml',
            verbose=False
        )
        
        if results[0].boxes.id is not None:
            boxes = results[0].boxes.xywh.cpu()
            track_ids = results[0].boxes.id.int().cpu().tolist()
            
            for box, track_id in zip(boxes, track_ids):
                x, y, w, h = box
                
                # Guardar trayectoria
                if track_id not in track_history:
                    track_history[track_id] = []
                track_history[track_id].append((float(x), float(y)))
                
                # Limitar longitud de trayectoria
                if len(track_history[track_id]) > 50:
                    track_history[track_id].pop(0)
                
                # Dibujar trayectoria
                points = track_history[track_id]
                for i in range(1, len(points)):
                    cv2.line(frame, 
                            (int(points[i-1][0]), int(points[i-1][1])),
                            (int(points[i][0]), int(points[i][1])),
                            (0, 255, 0), 2)
        
        # Mostrar contador
        cv2.putText(frame, f'Objects tracked: {len(track_history)}', 
                   (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
        
        cv2.imshow('Tracking', frame)
        
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    
    cap.release()
    cv2.destroyAllWindows()

# real_time_tracking()
```

### Extracción de Métricas de Tracking

```python
def analyze_tracking_results(video_path, model_path='yolo11n.pt'):
    """
    Analiza datos de tracking para extraer insights.
    
    Métricas:
    - Conteo de objetos únicos
    - Tiempo de permanencia
    - Trayectorias
    - Velocidad
    """
    model = YOLO(model_path)
    
    # Tracking con persistencia
    results = model.track(
        source=video_path,
        persist=True,
        tracker='bytetrack.yaml',
        stream=True,
        verbose=False
    )
    
    # Análisis
    tracks_data = {}
    frame_count = 0
    
    for result in results:
        frame_count += 1
        
        if result.boxes.id is not None:
            boxes = result.boxes.xywh.cpu()
            track_ids = result.boxes.id.int().cpu().tolist()
            classes = result.boxes.cls.int().cpu().tolist()
            
            for box, track_id, cls in zip(boxes, track_ids, classes):
                if track_id not in tracks_data:
                    tracks_data[track_id] = {
                        'class': result.names[cls],
                        'positions': [],
                        'first_frame': frame_count,
                        'last_frame': frame_count
                    }
                
                tracks_data[track_id]['positions'].append(box.tolist())
                tracks_data[track_id]['last_frame'] = frame_count
    
    # Calcular métricas
    print("\n=== Análisis de Tracking ===")
    print(f"Total frames: {frame_count}")
    print(f"Objetos únicos: {len(tracks_data)}")
    
    # Clases
    class_counts = {}
    for track_id, data in tracks_data.items():
        cls = data['class']
        class_counts[cls] = class_counts.get(cls, 0) + 1
    
    print("\nObjetos por clase:")
    for cls, count in class_counts.items():
        print(f"  {cls}: {count}")
    
    # Tiempo de permanencia
    print("\nTiempo de permanencia (frames):")
    durations = [data['last_frame'] - data['first_frame'] + 1 
                 for data in tracks_data.values()]
    print(f"  Promedio: {sum(durations)/len(durations):.1f}")
    print(f"  Máximo: {max(durations)}")
    
    return tracks_data

# tracks = analyze_tracking_results('video.mp4')
```

### Puntos Clave

- El tracking asigna IDs persistentes a objetos en video
- ByteTrack y BoT-SORT son los trackers más efectivos
- La persistencia mantiene el estado entre frames
- Las trayectorias permiten análisis de comportamiento
- MOTA y IDF1 son métricas clave de tracking

### Referencias

- [Tracking Documentation](https://docs.ultralytics.com/modes/track/)
- [ByteTrack Paper](https://arxiv.org/abs/2110.06864)
- [BoT-SORT Paper](https://arxiv.org/abs/2206.14651)

---

## 8.2 Conteo y Análisis

### Introducción

El tracking abre puertas a aplicaciones avanzadas: conteo de personas, análisis de flujo, detección de comportamiento anómalo, medición de velocidad. Estas aplicaciones tienen valor real en retail, seguridad, tráfico y deportes. El paso de detección → tracking → análisis es la evolución natural de proyectos de visión por computadora.

### Explicación Detallada

**Aplicaciones de conteo y análisis:**

1. **Retail**: Conteo de clientes, heatmaps, tiempo en tienda
2. **Tráfico**: Conteo de vehículos, detección de congestión
3. **Seguridad**: Detección de intrusiones, comportamiento anómalo
4. **Deportes**: Análisis de movimiento, estadísticas

**Conceptos clave:**

- **Línea de cruce**: Contar objetos que cruzan una línea
- **Zonas**: Definir áreas de interés
- **Dirección**: Determinar si entra o sale
- **Velocidad**: Calcular velocidad basada en posición

### Conteo de Objetos con Línea de Cruce

```python
import cv2
import numpy as np
from ultralytics import YOLO

class ObjectCounter:
    """
    Contador de objetos que cruzan una línea.
    
    Funciona definiendo una línea virtual y contando
    cada vez que un objeto la cruza.
    
    Importante: Solo cuenta una vez por objeto (usa el ID de tracking).
    """
    
    def __init__(self, model_path, line_position=0.5):
        self.model = YOLO(model_path)
        self.line_position = line_position  # Porcentaje de altura
        
        # Contadores
        self.count_up = 0
        self.count_down = 0
        self.counted_ids = set()
        
        # Historial de posiciones
        self.previous_positions = {}
    
    def count_in_video(self, video_path, output_path=None):
        """
        Procesa video y cuenta objetos que cruzan la línea.
        """
        cap = cv2.VideoCapture(video_path)
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        fps = int(cap.get(cv2.CAP_PROP_FPS))
        
        # Línea de conteo
        line_y = int(height * self.line_position)
        
        if output_path:
            fourcc = cv2.VideoWriter_fourcc(*'mp4v')
            out = cv2.VideoWriter(output_path, fourcc, fps, (width, height))
        
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
            
            # Tracking
            results = self.model.track(
                frame,
                persist=True,
                tracker='bytetrack.yaml',
                verbose=False
            )
            
            # Dibujar línea
            cv2.line(frame, (0, line_y), (width, line_y), (0, 0, 255), 2)
            
            if results[0].boxes.id is not None:
                boxes = results[0].boxes.xyxy.cpu()
                track_ids = results[0].boxes.id.int().cpu().tolist()
                
                for box, track_id in zip(boxes, track_ids):
                    x1, y1, x2, y2 = box
                    center_y = (y1 + y2) / 2
                    
                    # Verificar cruce
                    if track_id not in self.counted_ids:
                        if track_id in self.previous_positions:
                            prev_y = self.previous_positions[track_id]
                            
                            # Cruzó hacia arriba
                            if prev_y > line_y and center_y <= line_y:
                                self.count_up += 1
                                self.counted_ids.add(track_id)
                            # Cruzó hacia abajo
                            elif prev_y < line_y and center_y >= line_y:
                                self.count_down += 1
                                self.counted_ids.add(track_id)
                        
                        self.previous_positions[track_id] = center_y
                    
                    # Dibujar bounding box
                    cv2.rectangle(frame, (int(x1), int(y1)), (int(x2), int(y2)), 
                                 (0, 255, 0), 2)
                    cv2.putText(frame, f'ID: {track_id}', (int(x1), int(y1) - 10),
                               cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
            
            # Mostrar contadores
            cv2.putText(frame, f'Up: {self.count_up}', (10, 30),
                       cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
            cv2.putText(frame, f'Down: {self.count_down}', (10, 70),
                       cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
            
            if output_path:
                out.write(frame)
            
            cv2.imshow('Counting', frame)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
        
        cap.release()
        if output_path:
            out.release()
        cv2.destroyAllWindows()
        
        return {'up': self.count_up, 'down': self.count_down}

# Uso
# counter = ObjectCounter('yolo11n.pt', line_position=0.5)
# results = counter.count_in_video('video.mp4', 'output.mp4')
```

### Análisis de Zonas

```python
class ZoneAnalyzer:
    """
    Analiza qué objetos están en qué zonas.
    
    Útil para:
    - Heatmaps de actividad
    - Detección de intrusión
    - Análisis de uso de espacio
    """
    
    def __init__(self, model_path):
        self.model = YOLO(model_path)
        self.zones = {}  # {name: polygon_points}
        self.zone_history = {}  # {zone: {track_id: time_in_zone}}
    
    def add_zone(self, name, points):
        """
        Añade una zona poligonal.
        
        Args:
            name: Nombre de la zona
            points: Lista de (x, y) formando el polígono
        """
        self.zones[name] = np.array(points, dtype=np.int32)
        self.zone_history[name] = {}
    
    def point_in_polygon(self, point, polygon):
        """
        Verifica si un punto está dentro del polígono.
        """
        return cv2.pointPolygonTest(polygon, point, False) >= 0
    
    def analyze_video(self, video_path):
        """
        Analiza presencia de objetos en zonas.
        """
        cap = cv2.VideoCapture(video_path)
        fps = int(cap.get(cv2.CAP_PROP_FPS))
        frame_time = 1 / fps
        
        results_log = []
        frame_count = 0
        
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret:
                break
            
            frame_count += 1
            
            # Tracking
            track_results = self.model.track(
                frame,
                persist=True,
                tracker='bytetrack.yaml',
                verbose=False
            )
            
            # Dibujar zonas
            for zone_name, zone_points in self.zones.items():
                cv2.polylines(frame, [zone_points], True, (255, 0, 0), 2)
            
            # Verificar posiciones
            if track_results[0].boxes.id is not None:
                boxes = track_results[0].boxes.xyxy.cpu()
                track_ids = track_results[0].boxes.id.int().cpu().tolist()
                
                for box, track_id in zip(boxes, track_ids):
                    x1, y1, x2, y2 = box
                    center = (int((x1 + x2) / 2), int((y1 + y2) / 2))
                    
                    for zone_name, zone_points in self.zones.items():
                        if self.point_in_polygon(center, zone_points):
                            # Actualizar tiempo en zona
                            if track_id not in self.zone_history[zone_name]:
                                self.zone_history[zone_name][track_id] = 0
                            self.zone_history[zone_name][track_id] += frame_time
                            
                            # Log
                            results_log.append({
                                'frame': frame_count,
                                'track_id': track_id,
                                'zone': zone_name
                            })
            
            cv2.imshow('Zones', frame)
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
        
        cap.release()
        cv2.destroyAllWindows()
        
        return results_log

# Uso
# analyzer = ZoneAnalyzer('yolo11n.pt')
# analyzer.add_zone('entrance', [(100, 100), (300, 100), (300, 400), (100, 400)])
# analyzer.add_zone('exit', [(500, 100), (700, 100), (700, 400), (500, 400)])
# log = analyzer.analyze_video('video.mp4')
```

### Puntos Clave

- Las líneas de cruce permiten conteo preciso
- Los IDs de tracking evitan conteos duplicados
- Las zonas permiten análisis espacial
- Los heatmaps visualizan actividad
- El tiempo de permanencia es métrica valiosa

### Referencias

- [Object Counting Guide](https://docs.ultralytics.com/guides/object-counting/)
- [Speed Estimation](https://docs.ultralytics.com/guides/speed-estimation/)

---

# Módulo 9: Tareas Avanzadas (3h)

## 9.1 Segmentación de Instancias

### Introducción

La detección de objetos encuentra "dónde" están los objetos (bounding boxes). La segmentación de instancias va más allá: encuentra exactamente qué píxeles pertenecen a cada objeto. Es la diferencia entre dibujar un rectángulo alrededor de una persona y dibujar su silueta exacta. Esto es crucial para aplicaciones médicas, automatización industrial, y cualquier tarea que requiera precisión a nivel de píxel.

### Explicación Detallada

**Tipos de segmentación:**

1. **Semántica**: Todos los píxeles de "persona" son una sola máscara
2. **Instancia**: Cada persona tiene su propia máscara individual
3. **Panóptica**: Combina semántica e instancia

**YOLO para segmentación (YOLO-seg):**

YOLO añade una rama de segmentación al modelo de detección:
- Detección: Predice bounding boxes y clases
- Segmentación: Predice máscaras de prototipo y coeficientes
- Combinación: Cada detección tiene su máscara correspondiente

**Arquitectura YOLO-seg:**

```
Input Image
     ↓
Backbone (CSPDarknet)
     ↓
Neck (PANet)
     ↓
  ┌──────┐
  ↓      ↓
Head   SegHead
(det)   (mask)
```

### Entrenamiento de Modelo de Segmentación

```python
from ultralytics import YOLO

# Usar modelo pre-entrenado de segmentación
model = YOLO('yolo11n-seg.pt')  # -seg indica segmentación

# Entrenar en dataset personalizado
results = model.train(
    data='dataset_seg.yaml',  # Dataset con máscaras
    epochs=100,
    imgsz=640,
    batch=16,
)

# El dataset YAML es igual que para detección
# Las máscaras se almacenan en formato RLE o polígonos
```

### Inferencia de Segmentación

```python
from ultralytics import YOLO
import cv2
import numpy as np

model = YOLO('yolo11n-seg.pt')

# Inferencia
results = model('imagen.jpg')

for result in results:
    # Verificar si hay máscaras
    if result.masks is not None:
        masks = result.masks.data.cpu().numpy()  # Máscaras binarias
        boxes = result.boxes.xyxy.cpu().numpy()
        classes = result.boxes.cls.cpu().numpy()
        
        print(f"Objetos segmentados: {len(masks)}")
        
        for i, (mask, box, cls) in enumerate(zip(masks, boxes, classes)):
            print(f"  Objeto {i}: clase {result.names[int(cls)]}")
            print(f"    Área: {mask.sum()} píxeles")
```

### Visualización de Máscaras

```python
def visualize_segmentation(image_path, model_path='yolo11n-seg.pt'):
    """
    Visualiza máscaras de segmentación superpuestas.
    """
    model = YOLO(model_path)
    results = model(image_path)
    
    image = cv2.imread(image_path)
    
    # Colores para cada clase
    colors = [
        (255, 0, 0),    # Rojo
        (0, 255, 0),    # Verde
        (0, 0, 255),    # Azul
        (255, 255, 0),  # Cyan
        (255, 0, 255),  # Magenta
        (0, 255, 255),  # Amarillo
    ]
    
    overlay = image.copy()
    
    if results[0].masks is not None:
        masks = results[0].masks.data.cpu().numpy()
        classes = results[0].boxes.cls.cpu().numpy().astype(int)
        
        for mask, cls in zip(masks, classes):
            # Redimensionar máscara a tamaño de imagen
            mask_resized = cv2.resize(mask, (image.shape[1], image.shape[0]))
            
            # Aplicar color
            color = colors[cls % len(colors)]
            colored_mask = np.zeros_like(image)
            colored_mask[mask_resized > 0.5] = color
            
            # Superponer
            overlay = cv2.addWeighted(overlay, 1, colored_mask, 0.5, 0)
    
    # Combinar con imagen original
    result_image = cv2.addWeighted(image, 0.7, overlay, 0.3, 0)
    
    cv2.imwrite('segmentation_result.jpg', result_image)
    print("Resultado guardado en segmentation_result.jpg")

# visualize_segmentation('imagen.jpg')
```

### Extracción de Contornos

```python
def extract_contours_from_masks(results, image_shape):
    """
    Extrae contornos de las máscaras de segmentación.
    
    Útil para:
    - Mediciones precisas
    - Análisis de forma
    - Exportación a CAD
    """
    contours = []
    
    if results[0].masks is not None:
        masks = results[0].masks.data.cpu().numpy()
        
        for mask in masks:
            # Redimensionar
            mask_resized = cv2.resize(mask, (image_shape[1], image_shape[0]))
            mask_uint8 = (mask_resized * 255).astype(np.uint8)
            
            # Encontrar contornos
            contour, _ = cv2.findContours(
                mask_uint8, 
                cv2.RETR_EXTERNAL, 
                cv2.CHAIN_APPROX_SIMPLE
            )
            
            if contour:
                contours.append(contour[0])
    
    return contours

# Uso
# contours = extract_contours_from_masks(results, image.shape)
# for i, contour in enumerate(contours):
#     print(f"Contorno {i}: {len(contour)} puntos")
```

### Puntos Clave

- La segmentación de instancias da precisión a nivel de píxel
- YOLO-seg añade una rama de máscaras al modelo
- Las máscaras son arrays binarios por cada detección
- Los contornos permiten análisis geométrico
- Requiere datasets con anotaciones de máscara

### Referencias

- [Instance Segmentation](https://docs.ultralytics.com/tasks/segment/)
- [YOLO-seg Architecture](https://arxiv.org/abs/2304.00501)

---

## 9.2 Estimación de Pose

### Introducción

La estimación de pose detecta puntos clave (keypoints) del cuerpo humano: hombros, codos, rodillas, etc. Conectando estos puntos, obtenemos un "esqueleto" que representa la postura de la persona. Esto habilita aplicaciones de análisis de movimiento, reconocimiento de gestos, fitness, healthcare, y mucho más.

### Explicación Detallada

**Keypoints estándar (COCO):**

1. Nariz, ojos, orejas (5 puntos faciales)
2. Hombros, codos, muñecas (6 puntos brazos)
3. Caderas, rodillas, tobillos (6 puntos piernas)
4. Total: 17 keypoints

**Aplicaciones:**

- Fitness: Contar repeticiones, corregir forma
- Healthcare: Análisis de marcha, rehabilitación
- Gaming: Control por gestos
- Seguridad: Detección de caídas
- Deportes: Análisis de técnica

### Detección de Pose

```python
from ultralytics import YOLO

# Modelo de pose
model = YOLO('yolo11n-pose.pt')  # -pose indica estimación de pose

# Inferencia
results = model('persona.jpg')

for result in results:
    if result.keypoints is not None:
        keypoints = result.keypoints.data.cpu().numpy()  # [N, 17, 3]
        # N = número de personas
        # 17 = keypoints por persona
        # 3 = x, y, confidence
        
        for person_idx, person_kps in enumerate(keypoints):
            print(f"\nPersona {person_idx}:")
            for kp_idx, (x, y, conf) in enumerate(person_kps):
                if conf > 0.5:  # Keypoint visible
                    print(f"  Keypoint {kp_idx}: ({x:.1f}, {y:.1f}) conf={conf:.2f}")
```

### Nombres de Keypoints COCO

```python
COCO_KEYPOINTS = {
    0: 'nose',
    1: 'left_eye',
    2: 'right_eye',
    3: 'left_ear',
    4: 'right_ear',
    5: 'left_shoulder',
    6: 'right_shoulder',
    7: 'left_elbow',
    8: 'right_elbow',
    9: 'left_wrist',
    10: 'right_wrist',
    11: 'left_hip',
    12: 'right_hip',
    13: 'left_knee',
    14: 'right_knee',
    15: 'left_ankle',
    16: 'right_ankle'
}

# Conexiones para el esqueleto
SKELETON_CONNECTIONS = [
    (0, 1), (0, 2), (1, 3), (2, 4),  # Cabeza
    (5, 6),  # Hombros
    (5, 7), (7, 9),   # Brazo izquierdo
    (6, 8), (8, 10),  # Brazo derecho
    (5, 11), (6, 12),  # Torso
    (11, 12),  # Caderas
    (11, 13), (13, 15),  # Pierna izquierda
    (12, 14), (14, 16),  # Pierna derecha
]
```

### Análisis de Postura

```python
def analyze_posture(keypoints):
    """
    Analiza la postura basándose en keypoints.
    
    Ejemplos de análisis:
    - ¿Está la persona de pie o sentada?
    - ¿Tiene los brazos levantados?
    - ¿Está en posición "T"?
    """
    analysis = {}
    
    # Verificar si está de pie
    left_hip = keypoints[11]
    right_hip = keypoints[12]
    left_knee = keypoints[13]
    right_knee = keypoints[14]
    left_ankle = keypoints[15]
    right_ankle = keypoints[16]
    
    # Si las rodillas están cerca de las caderas, probablemente sentado
    knee_hip_dist = (
        abs(left_knee[1] - left_hip[1]) + 
        abs(right_knee[1] - right_hip[1])
    ) / 2
    
    if knee_hip_dist < 50:  # Umbral en píxeles
        analysis['position'] = 'sentado'
    else:
        analysis['position'] = 'de pie'
    
    # Verificar brazos levantados
    left_shoulder = keypoints[5]
    right_shoulder = keypoints[6]
    left_wrist = keypoints[9]
    right_wrist = keypoints[10]
    
    arms_raised = (
        left_wrist[1] < left_shoulder[1] or 
        right_wrist[1] < right_shoulder[1]
    )
    analysis['arms_raised'] = arms_raised
    
    # Calcular ángulo del cuerpo
    nose = keypoints[0]
    mid_hip = ((left_hip[0] + right_hip[0])/2, (left_hip[1] + right_hip[1])/2)
    
    # Ángulo de inclinación
    import math
    angle = math.atan2(mid_hip[0] - nose[0], mid_hip[1] - nose[1])
    analysis['lean_angle'] = math.degrees(angle)
    
    return analysis

# Uso
# keypoints = results[0].keypoints.data[0].cpu().numpy()  # Primera persona
# posture = analyze_posture(keypoints)
# print(posture)
```

### Conteo de Repeticiones (Fitness)

```python
class RepetitionCounter:
    """
    Cuenta repeticiones de ejercicios usando keypoints.
    
    Funciona detectando cuando un ángulo cruza
    un umbral en ambas direcciones.
    
    Ejemplo para sentadillas:
    - Bajar: ángulo rodilla < 90°
    - Subir: ángulo rodilla > 160°
    """
    
    def __init__(self):
        self.count = 0
        self.state = 'up'  # 'up' o 'down'
    
    def calculate_angle(self, a, b, c):
        """
        Calcula el ángulo en el punto b formado por a-b-c.
        """
        import math
        
        radians = math.atan2(c[1] - b[1], c[0] - b[0]) - \
                  math.atan2(a[1] - b[1], a[0] - b[0])
        angle = abs(math.degrees(radians))
        
        if angle > 180:
            angle = 360 - angle
        
        return angle
    
    def count_squat(self, keypoints):
        """
        Cuenta sentadillas basándose en ángulo de rodilla.
        """
        # Keypoints relevantes
        left_hip = keypoints[11][:2]
        left_knee = keypoints[13][:2]
        left_ankle = keypoints[15][:2]
        
        # Calcular ángulo de rodilla
        angle = self.calculate_angle(left_hip, left_knee, left_ankle)
        
        # Detectar transiciones
        if angle < 90 and self.state == 'up':
            self.state = 'down'
        elif angle > 160 and self.state == 'down':
            self.state = 'up'
            self.count += 1
        
        return self.count, angle

# Uso
# counter = RepetitionCounter()
# for frame in video:
#     results = model(frame)
#     keypoints = results[0].keypoints.data[0].cpu().numpy()
#     reps, angle = counter.count_squat(keypoints)
```

### Puntos Clave

- YOLO-pose detecta 17 keypoints del cuerpo humano
- Cada keypoint tiene posición (x, y) y confianza
- Los esqueletos se forman conectando keypoints
- El análisis de ángulos permite detectar posturas
- Las aplicaciones van desde fitness hasta healthcare

### Referencias

- [Pose Estimation](https://docs.ultralytics.com/tasks/pose/)
- [Keypoint Detection](https://docs.ultralytics.com/tasks/pose/#keypoints)

---

## 9.3 Detección Orientada (OBB)

### Introducción

Los bounding boxes normales son horizontales (axis-aligned). Pero muchos objetos están rotados: aviones en imágenes aéreas, barcos, vehículos en imágenes satelitales. La detección orientada (Oriented Bounding Box) resuelve esto usando rectángulos rotados que se ajustan mejor a objetos no alineados.

### Explicación Detallada

**Bounding Box normal vs Orientado:**

- **BB normal**: [x_center, y_center, width, height]
- **OBB**: [x_center, y_center, width, height, rotation_angle]

**El ángulo de rotación:**

- Rango: [-π/4, 3π/4] o [0°, 180°]
- 0° = objeto horizontal
- 90° = objeto vertical

**Aplicaciones:**

- Imágenes aéreas y satelitales
- Texto en documentos (OCR)
- Vehículos y estructuras
- Cualquier objeto que pueda estar rotado

### Entrenamiento OBB

```python
from ultralytics import YOLO

# Modelo OBB
model = YOLO('yolo11n-obb.pt')  # -obb indica detección orientada

# Entrenar
results = model.train(
    data='dataset_obb.yaml',
    epochs=100,
    imgsz=640,
)

# El dataset debe tener anotaciones OBB
# Formato: class_id x_center y_center width height angle
```

### Inferencia OBB

```python
model = YOLO('yolo11n-obb.pt')

results = model('imagen_aerea.jpg')

for result in results:
    if result.obb is not None:
        obbs = result.obb.data.cpu().numpy()  # [N, 7]
        # x_center, y_center, width, height, angle, conf, class
        
        for obb in obbs:
            x_c, y_c, w, h, angle, conf, cls = obb
            print(f"Objeto: {result.names[int(cls)]}")
            print(f"  Centro: ({x_c:.1f}, {y_c:.1f})")
            print(f"  Tamaño: {w:.1f} x {h:.1f}")
            print(f"  Rotación: {angle:.2f} rad ({angle*180/3.14159:.1f}°)")
            print(f"  Confianza: {conf:.2f}")
```

### Dibujar OBBs

```python
def draw_rotated_boxes(image_path, model_path='yolo11n-obb.pt'):
    """
    Dibuja bounding boxes rotados.
    """
    import cv2
    
    model = YOLO(model_path)
    results = model(image_path)
    
    image = cv2.imread(image_path)
    
    if results[0].obb is not None:
        obbs = results[0].obb.data.cpu().numpy()
        
        for obb in obbs:
            x_c, y_c, w, h, angle, conf, cls = obb
            
            # Crear rectángulo rotado
            rect = ((x_c, y_c), (w, h), angle * 180 / 3.14159)
            box = cv2.boxPoints(rect)
            box = np.int0(box)
            
            # Dibujar
            cv2.drawContours(image, [box], 0, (0, 255, 0), 2)
            
            # Etiqueta
            label = f"{results[0].names[int(cls)]} {conf:.2f}"
            cv2.putText(image, label, (int(x_c), int(y_c)),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
    
    cv2.imwrite('obb_result.jpg', image)
    print("Guardado en obb_result.jpg")

# draw_rotated_boxes('imagen_aerea.jpg')
```

### Puntos Clave

- OBB detecta objetos rotados con precisión
- El formato incluye ángulo de rotación
- Ideal para imágenes aéreas y satelitales
- Mejora precisión para objetos no alineados
- Requiere anotaciones especiales con rotación

### Referencias

- [Oriented Detection](https://docs.ultralytics.com/tasks/obb/)
- [DOTA Dataset](https://captain-whu.github.io/DOTA/)

---

# Módulo 10: Proyecto Final Integrador (3h)

## 10.1 Diseño del Proyecto

### Introducción

Llegamos al punto donde todo lo aprendido se une. El proyecto final integra preparación de datos, entrenamiento, optimización, y despliegue en una aplicación real. Este módulo te guía paso a paso para construir un sistema completo de detección de objetos, desde la idea hasta la implementación.

### Explicación Detallada

**Fases del proyecto:**

1. **Definición**: ¿Qué problema resuelves?
2. **Datos**: ¿Qué datos necesitas y cómo los obtienes?
3. **Modelo**: ¿Qué arquitectura y configuración?
4. **Entrenamiento**: Ejecutar y optimizar
5. **Evaluación**: ¿Funciona bien?
6. **Despliegue**: ¿Cómo lo usan los usuarios?

**Ejemplos de proyectos:**

- Contador de vehículos en tiempo real
- Detector de defectos en manufactura
- Sistema de seguridad para detección de intrusos
- Análizador de postura para fitness
- Detector de productos en retail

### Ejemplo Completo: Sistema de Detección de EPP

```python
"""
PROYECTO: Sistema de Detección de EPP (Equipos de Protección Personal)

OBJETIVO: Detectar si los trabajadores usan casco, chaleco y botas de seguridad.

APLICACIÓN: Seguridad industrial - alertas cuando alguien no usa EPP.

CLASES:
- helmet (casco)
- vest (chaleco)
- boots (botas)
- person (persona)
- no_helmet (sin casco - para alertas)
- no_vest (sin chaleco - para alertas)
"""

# ===== FASE 1: PREPARACIÓN DE DATOS =====

from ultralytics import YOLO
import os
from pathlib import Path
import yaml

def create_epp_dataset_structure():
    """
    Crea la estructura de directorios para el dataset de EPP.
    
    Estructura:
    epp_dataset/
    ├── images/
    │   ├── train/
    │   ├── val/
    │   └── test/
    └── labels/
        ├── train/
        ├── val/
        └── test/
    """
    base_path = Path('epp_dataset')
    
    for split in ['train', 'val', 'test']:
        (base_path / 'images' / split).mkdir(parents=True, exist_ok=True)
        (base_path / 'labels' / split).mkdir(parents=True, exist_ok=True)
    
    # Crear archivo YAML
    dataset_yaml = {
        'path': str(base_path.absolute()),
        'train': 'images/train',
        'val': 'images/val',
        'test': 'images/test',
        'nc': 4,  # Número de clases
        'names': ['person', 'helmet', 'vest', 'boots']
    }
    
    with open(base_path / 'epp.yaml', 'w') as f:
        yaml.dump(dataset_yaml, f)
    
    print(f"Dataset structure created at {base_path}")
    print(f"\nClasses: {dataset_yaml['names']}")
    print(f"\nNext steps:")
    print("1. Add images to epp_dataset/images/train/")
    print("2. Add annotations to epp_dataset/labels/train/")
    print("3. Repeat for val/ and test/")

create_epp_dataset_structure()


# ===== FASE 2: ENTRENAMIENTO =====

def train_epp_model(data_yaml='epp_dataset/epp.yaml', epochs=100):
    """
    Entrena el modelo de detección de EPP.
    
    Configuración optimizada para:
    - Dataset pequeño-moderado
    - Objetos pequeños (EPP)
    - Balance de velocidad/precisión
    """
    model = YOLO('yolo11n.pt')
    
    results = model.train(
        data=data_yaml,
        epochs=epochs,
        imgsz=640,
        batch=16,
        
        # Transfer learning
        freeze=10,  # Congelar primeras 10 capas
        
        # Hiperparámetros
        lr0=0.001,
        lrf=0.01,
        
        # Augmentación agresiva para dataset pequeño
        degrees=15.0,
        translate=0.2,
        scale=0.5,
        mosaic=1.0,
        mixup=0.2,
        
        # Early stopping
        patience=20,
        
        # Guardar
        project='epp_detection',
        name='train',
        save=True,
        plots=True,
    )
    
    return results

# results = train_epp_model()


# ===== FASE 3: VALIDACIÓN =====

def validate_epp_model(model_path='epp_detection/train/weights/best.pt'):
    """
    Valida el modelo y analiza resultados por clase.
    
    Especialmente importante verificar:
    - Cada clase de EPP tiene buen AP
    - No hay confusiones entre clases
    """
    model = YOLO(model_path)
    
    metrics = model.val(data='epp_dataset/epp.yaml', plots=True)
    
    print("\n=== Métricas por Clase ===")
    for i, name in model.names.items():
        ap = metrics.box.ap50[i]
        print(f"{name}: AP@50 = {ap:.4f}")
    
    # Identificar clases problemáticas
    weak_classes = []
    for i, name in model.names.items():
        if metrics.box.ap50[i] < 0.7:
            weak_classes.append(name)
    
    if weak_classes:
        print(f"\nClases que necesitan más datos: {weak_classes}")
    
    return metrics

# metrics = validate_epp_model()


# ===== FASE 4: INFERENCIA Y ANÁLISIS =====

def detect_epp_violations(image_path, model_path='epp_detection/train/weights/best.pt'):
    """
    Detecta violaciones de EPP en una imagen.
    
    Lógica:
    1. Detectar personas
    2. Para cada persona, verificar si tiene EPP
    3. Si falta algún EPP, es una violación
    
    Este es un ejemplo de análisis post-detección
    que añade lógica de negocio sobre las detecciones.
    """
    import cv2
    
    model = YOLO(model_path)
    results = model(image_path)
    
    image = cv2.imread(image_path)
    
    # Extraer detecciones por tipo
    persons = []
    helmets = []
    vests = []
    boots = []
    
    for result in results:
        boxes = result.boxes
        for i in range(len(boxes)):
            cls = int(boxes.cls[i].cpu().numpy())
            xyxy = boxes.xyxy[i].cpu().numpy()
            conf = float(boxes.conf[i].cpu().numpy())
            
            detection = {
                'bbox': xyxy,
                'conf': conf,
                'class': result.names[cls]
            }
            
            if cls == 0:  # person
                persons.append(detection)
            elif cls == 1:  # helmet
                helmets.append(detection)
            elif cls == 2:  # vest
                vests.append(detection)
            elif cls == 3:  # boots
                boots.append(detection)
    
    # Analizar cada persona
    violations = []
    
    for person in persons:
        px1, py1, px2, py2 = person['bbox']
        person_area = (px2 - px1) * (py2 - py1)
        
        # Verificar si hay casco dentro de la persona
        has_helmet = False
        for helmet in helmets:
            hx1, hy1, hx2, hy2 = helmet['bbox']
            # El casco debe estar en la parte superior de la persona
            if (hx1 >= px1 and hx2 <= px2 and 
                hy1 >= py1 and hy2 <= py1 + (py2 - py1) * 0.3):
                has_helmet = True
                break
        
        # Verificar chaleco
        has_vest = False
        for vest in vests:
            vx1, vy1, vx2, vy2 = vest['bbox']
            # El chaleco debe estar en el torso
            if (vx1 >= px1 and vx2 <= px2):
                has_vest = True
                break
        
        # Verificar botas
        has_boots = False
        for boot in boots:
            bx1, by1, bx2, by2 = boot['bbox']
            # Las botas deben estar en la parte inferior
            if (bx1 >= px1 and bx2 <= px2 and 
                by1 >= py1 + (py2 - py1) * 0.7):
                has_boots = True
                break
        
        # Determinar violaciones
        person_violations = {
            'bbox': person['bbox'],
            'missing_helmet': not has_helmet,
            'missing_vest': not has_vest,
            'missing_boots': not has_boots
        }
        
        if not has_helmet or not has_vest or not has_boots:
            violations.append(person_violations)
    
    # Dibujar resultados
    for person in persons:
        cv2.rectangle(image, 
                     (int(person['bbox'][0]), int(person['bbox'][1])),
                     (int(person['bbox'][2]), int(person['bbox'][3])),
                     (0, 255, 0), 2)
    
    for violation in violations:
        cv2.rectangle(image,
                     (int(violation['bbox'][0]), int(violation['bbox'][1])),
                     (int(violation['bbox'][2]), int(violation['bbox'][3])),
                     (0, 0, 255), 3)
        
        # Etiqueta de violación
        missing = []
        if violation['missing_helmet']:
            missing.append('casco')
        if violation['missing_vest']:
            missing.append('chaleco')
        if violation['missing_boots']:
            missing.append('botas')
        
        label = f"Falta: {', '.join(missing)}"
        cv2.putText(image, label, 
                   (int(violation['bbox'][0]), int(violation['bbox'][1]) - 10),
                   cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 0, 255), 2)
    
    cv2.imwrite('epp_violations_detected.jpg', image)
    
    print(f"\nTotal personas: {len(persons)}")
    print(f"Violaciones: {len(violations)}")
    
    return violations

# violations = detect_epp_violations('factory_worker.jpg')
```

### API Completa de Producción

```python
"""
API REST para Sistema de Detección de EPP

Endpoints:
- POST /detect: Detectar EPP en imagen
- POST /video: Procesar video con tracking
- GET /stats: Estadísticas del sistema
"""

from fastapi import FastAPI, File, UploadFile, HTTPException
from ultralytics import YOLO
import numpy as np
import cv2
from PIL import Image
import io

app = FastAPI(
    title="EPP Detection API",
    description="Sistema de detección de Equipos de Protección Personal",
    version="1.0.0"
)

# Cargar modelo al iniciar
model = YOLO('epp_detection/train/weights/best.pt')

# Estadísticas globales
stats = {
    'total_requests': 0,
    'total_violations': 0,
    'total_persons': 0
}

@app.get("/health")
async def health():
    return {"status": "healthy", "model": "loaded"}

@app.post("/detect")
async def detect_epp(file: UploadFile = File(...)):
    """
    Detecta EPP en una imagen y reporta violaciones.
    """
    stats['total_requests'] += 1
    
    # Leer imagen
    contents = await file.read()
    image = Image.open(io.BytesIO(contents))
    image_np = np.array(image)
    image_np = cv2.cvtColor(image_np, cv2.COLOR_RGB2BGR)
    
    # Inferencia
    results = model(image_np, conf=0.5, verbose=False)
    
    # Análisis de EPP (similar a detect_epp_violations)
    detections = []
    for result in results:
        boxes = result.boxes
        for i in range(len(boxes)):
            xyxy = boxes.xyxy[i].cpu().numpy().tolist()
            conf = float(boxes.conf[i].cpu().numpy())
            cls = int(boxes.cls[i].cpu().numpy())
            
            detections.append({
                'bbox': xyxy,
                'confidence': round(conf, 4),
                'class_id': cls,
                'class_name': result.names[cls]
            })
    
    # Contar personas
    persons = [d for d in detections if d['class_name'] == 'person']
    stats['total_persons'] += len(persons)
    
    # Calcular violaciones (simplificado)
    # En producción, implementar lógica completa
    violations_count = len(persons)  # Placeholder
    stats['total_violations'] += violations_count
    
    return {
        'detections': detections,
        'total_objects': len(detections),
        'persons': len(persons),
        'violations': violations_count
    }

@app.get("/stats")
async def get_stats():
    """
    Retorna estadísticas del sistema.
    """
    return stats

# Ejecutar: uvicorn api:app --host 0.0.0.0 --port 8000
```

### Checklist de Proyecto Final

```python
def project_checklist():
    """
    Checklist para validar que tu proyecto está completo.
    """
    checklist = {
        'Datos': [
            'Dataset recopilado y anotado',
            'División train/val/test realizada',
            'Balance de clases verificado',
            'Anotaciones validadas visualmente',
        ],
        'Entrenamiento': [
            'Modelo pre-entrenado seleccionado',
            'Hiperparámetros configurados',
            'Entrenamiento completado sin errores',
            'Gráficas de pérdida revisadas',
        ],
        'Evaluación': [
            'mAP@50 > 0.5 (mínimo)',
            'Matriz de confusión analizada',
            'Clases problemáticas identificadas',
            'Comparación con baseline realizada',
        ],
        'Optimización': [
            'Mejor modelo seleccionado',
            'Exportado a formato de producción',
            'Benchmark de velocidad realizado',
            'Memoria GPU optimizada',
        ],
        'Despliegue': [
            'API implementada',
            'Tests de integración pasados',
            'Documentación creada',
            'Monitoreo configurado',
        ],
    }
    
    print("=== Project Checklist ===\n")
    for category, items in checklist.items():
        print(f"{category}:")
        for item in items:
            print(f"  [ ] {item}")
        print()
    
    return checklist

project_checklist()
```

### Puntos Clave

- El proyecto integra todo lo aprendido
- La definición del problema es el primer paso
- Los datos de calidad son fundamentales
- La evaluación debe ser rigurosa
- El despliegue requiere consideraciones de producción

### Referencias

- [Project Structure Guide](https://docs.ultralytics.com/guides/)
- [Best Practices](https://github.com/ultralytics/yolov5/wiki/Tips-for-Best-Training-Results)

---

## 10.2 Resumen del Curso

### Conocimientos Adquiridos

Al completar este curso, has aprendido:

1. **Fundamentos de YOLO**: Arquitectura, cómo funciona, ventajas y limitaciones
2. **Preparación de Datos**: Formato YOLO, anotación, conversión de formatos
3. **Data Augmentation**: Técnicas para expandir datasets
4. **Entrenamiento**: Transfer learning, hiperparámetros, debugging
5. **Inferencia**: Predicción, optimización, procesamiento de resultados
6. **Validación**: Métricas, análisis de errores, benchmarking
7. **Exportación**: ONNX, TensorRT, CoreML, TFLite
8. **Despliegue**: APIs, Docker, cloud, monitoreo
9. **Tracking**: Seguimiento de objetos, conteo, análisis
10. **Tareas Avanzadas**: Segmentación, pose, OBB

### Próximos Pasos

Para continuar tu aprendizaje:

1. **Practica con proyectos reales**: Los datasets públicos son buenos para aprender, pero proyectos reales te enseñan más
2. **Experimenta**: Prueba diferentes arquitecturas, hiperparámetros, técnicas
3. **Lee papers**: La investigación avanza rápido, mantente actualizado
4. **Contribuye**: Open source necesita contribuidores, es buena forma de aprender
5. **Comparte**: Enseñar refuerza el aprendizaje

### Recursos Adicionales

- [Ultralytics Documentation](https://docs.ultralytics.com/)
- [YOLO Papers](https://arxiv.org/list/cs.CV/recent)
- [Computer Vision Datasets](https://paperswithcode.com/datasets)
- [PyTorch Tutorials](https://pytorch.org/tutorials/)
- [Papers with Code](https://paperswithcode.com/)

---

**¡Felicidades por completar el curso!** 🎉

Has adquirido las habilidades necesarias para desarrollar aplicaciones completas de detección de objetos con YOLO. Ahora es momento de aplicar estos conocimientos a problemas reales y seguir aprendiendo en el camino.

**Recuerda**: La mejor forma de aprender es haciendo. Empieza con proyectos pequeños, comete errores, y mejora iterativamente. ¡Éxito en tu camino como ingeniero de visión por computadora!# Módulo 7: Exportación y Despliegue (3h) - Versión Extendida

## 7.1 Formatos de Exportación

### Introducción a la Exportación de Modelos

Entrenar un modelo es solo la mitad del viaje. Una vez que tienes un modelo funcional en PyTorch, surge una pregunta fundamental: ¿cómo lo uso en producción? El formato `.pt` de PyTorch es excelente para investigación y desarrollo, pero puede no ser el más adecuado para desplegar en un servidor de alta concurrencia, en un dispositivo edge con recursos limitados, o en una aplicación móvil. La exportación de modelos es el proceso de convertir tu modelo entrenado a un formato optimizado para tu caso de uso específico.

Piensa en la exportación como "empaquetar" tu modelo para su viaje final. Cada formato de destino tiene características únicas: algunos priorizan la velocidad de inferencia, otros la portabilidad entre frameworks, y otros el tamaño reducido. Elegir el formato correcto puede significar la diferencia entre un sistema que procesa 5 frames por segundo y uno que procesa 200.

### Explicación Detallada

**¿Por qué exportar modelos?**

1. **Optimización de rendimiento**: Los modelos exportados pueden ser 2-10x más rápidos que PyTorch puro. Esto se debe a optimizaciones a nivel de grafo computacional, fusión de operaciones, y eliminación de código innecesario para inferencia.

2. **Compatibilidad cross-platform**: ONNX (Open Neural Network Exchange) permite que tu modelo funcione en múltiples frameworks sin modificar el código de entrenamiento. Un modelo ONNX puede ejecutarse en Python, C++, JavaScript, C#, y más.

3. **Despliegue en hardware específico**: TensorRT para GPUs NVIDIA, CoreML para dispositivos Apple, OpenVINO para hardware Intel. Estos formatos aprovechan las capacidades únicas de cada hardware.

4. **Reducción de dependencias**: Un modelo exportado no requiere PyTorch completo. Para una aplicación móvil de 50MB, cargar PyTorch (500MB+) es inviable. Los formatos exportados pueden reducir las dependencias a menos de 50MB.

**Formatos principales y sus características:**

| Formato | Uso Principal | Ventajas | Desventajas |
|---------|---------------|----------|-------------|
| PyTorch (.pt) | Desarrollo, investigación | Flexible, fácil de debug | Lento, dependencias pesadas |
| ONNX | Interoperabilidad | Universal, soportado por todos | Overhead de conversión |
| TensorRT | GPUs NVIDIA | Máxima velocidad en GPU | Solo NVIDIA, configuración compleja |
| OpenVINO | CPUs Intel | Optimizado para Intel | Limitado a hardware Intel |
| CoreML | Apple devices | Integración nativa iOS/macOS | Solo ecosistema Apple |
| TFLite | Mobile (Android/iOS) | Ligero, eficiente | Limitaciones de operadores |

### Exportación Básica con Ultralytics

```python
from ultralytics import YOLO

# Cargar modelo entrenado
model = YOLO('best.pt')

# Exportar a ONNX (formato universal)
model.export(format='onnx')

# Exportar a TensorRT (GPU NVIDIA)
model.export(format='engine')  # TensorRT

# Exportar a CoreML (Apple)
model.export(format='coreml')

# Exportar a TFLite (Mobile)
model.export(format='tflite')

# Exportar a OpenVINO (Intel)
model.export(format='openvino')

# Ver formatos disponibles
print("""Formatos disponibles:
- onnx: Open Neural Network Exchange
- engine: TensorRT (NVIDIA)
- coreml: CoreML (Apple)
- tflite: TensorFlow Lite (Mobile)
- openvino: OpenVINO (Intel)
- torchscript: TorchScript (PyTorch nativo)
- pb: TensorFlow SavedModel
- hdf5: Keras HDF5
- ncnn: NCNN (Mobile optimizado)
- paddle: PaddlePaddle
- mlmodel: CoreML (legacy)
- onnx_endat: ONNX con metadata
""")
```

### Exportación Avanzada con Parámetros

```python
from ultralytics import YOLO

model = YOLO('best.pt')

# Exportar ONNX con optimizaciones
model.export(
    format='onnx',
    imgsz=640,              # Tamaño de imagen
    opset=12,               # Versión de ONNX opset
    simplify=True,          # Simplificar grafo
    dynamic=False,          # Tamaño estático (más rápido)
    half=True,              # FP16 (mitad de precisión)
    batch=1,                # Tamaño de batch
    device='cuda',          # Dispositivo
    workspace=4,            # GB de workspace para TensorRT
)

# Exportar TensorRT optimizado
model.export(
    format='engine',
    imgsz=640,
    half=True,              # FP16 - crucial para velocidad
    dynamic=False,
    batch=1,
    device=0,               # GPU ID
    workspace=8,            # 8GB workspace
    verbose=True,           # Logs detallados
)

# Exportar para Edge TPU (Coral)
model.export(
    format='tflite',
    imgsz=640,
    int8=True,              # Cuantización INT8 obligatoria para Edge TPU
    data='dataset.yaml',    # Dataset para calibración
)

# Exportar OpenVINO para CPUs Intel
model.export(
    format='openvino',
    imgsz=640,
    half=False,             # FP32 para CPUs
    int8=False,
)
```

### Inferencia con Modelos Exportados

```python
import cv2
import numpy as np
import onnxruntime as ort

# Inferencia con ONNX Runtime
class YOLOONNX:
    """
    Clase para inferencia de YOLO usando ONNX Runtime.
    
    ONNX Runtime es más rápido que PyTorch y no requiere
    todas las dependencias de PyTorch.
    """
    
    def __init__(self, model_path, conf_thres=0.25, iou_thres=0.45):
        """
        Inicializa el modelo ONNX.
        
        Args:
            model_path: Ruta al archivo .onnx
            conf_thres: Umbral de confianza
            iou_thres: Umbral de IoU para NMS
        """
        self.conf_thres = conf_thres
        self.iou_thres = iou_thres
        
        # Crear sesión ONNX Runtime
        providers = ['CUDAExecutionProvider', 'CPUExecutionProvider']
        self.session = ort.InferenceSession(model_path, providers=providers)
        
        # Obtener info del modelo
        self.input_name = self.session.get_inputs()[0].name
        self.input_shape = self.session.get_inputs()[0].shape
        self.output_name = self.session.get_outputs()[0].name
        
        print(f"Modelo cargado: {model_path}")
        print(f"Input: {self.input_name} shape {self.input_shape}")
        print(f"Output: {self.output_name}")
    
    def preprocess(self, image):
        """
        Preprocesa la imagen para el modelo.
        
        Pasos:
        1. Redimensionar manteniendo aspect ratio
        2. Normalizar a [0, 1]
        3. Convertir RGB a BGR (si es necesario)
        4. Transponer HWC -> CHW
        5. Agregar dimensión de batch
        """
        # Guardar tamaño original
        self.orig_shape = image.shape[:2]
        
        # Redimensionar
        input_size = self.input_shape[2]  # Asume forma [batch, 3, H, W]
        image_resized = cv2.resize(image, (input_size, input_size))
        
        # Normalizar y convertir a float32
        image_normalized = image_resized.astype(np.float32) / 255.0
        
        # HWC -> CHW
        image_transposed = np.transpose(image_normalized, (2, 0, 1))
        
        # Agregar batch dimension: CHW -> BCHW
        image_batch = np.expand_dims(image_transposed, 0)
        
        return image_batch
    
    def postprocess(self, outputs, conf_thres=None, iou_thres=None):
        """
        Post-procesa las salidas del modelo.
        
        Pasos:
        1. Filtrar por confianza
        2. NMS (Non-Maximum Suppression)
        3. Escalar coordenadas a imagen original
        """
        conf_thres = conf_thres or self.conf_thres
        iou_thres = iou_thres or self.iou_thres
        
        # outputs shape: [1, 84, 8400] para YOLO11n
        # 84 = 4 coords + 80 classes
        predictions = outputs[0]  # Remover batch dim
        
        # Transponer: [84, 8400] -> [8400, 84]
        predictions = predictions.T
        
        # Separar coordenadas y scores de clase
        boxes = predictions[:, :4]  # x, y, w, h
        scores = predictions[:, 4:]  # class scores
        
        # Obtener clase con mayor score
        class_ids = np.argmax(scores, axis=1)
        confidences = np.max(scores, axis=1)
        
        # Filtrar por confianza
        mask = confidences > conf_thres
        boxes = boxes[mask]
        confidences = confidences[mask]
        class_ids = class_ids[mask]
        
        # Convertir xywh a xyxy
        boxes_xyxy = np.copy(boxes)
        boxes_xyxy[:, 0] = boxes[:, 0] - boxes[:, 2] / 2  # x1
        boxes_xyxy[:, 1] = boxes[:, 1] - boxes[:, 3] / 2  # y1
        boxes_xyxy[:, 2] = boxes[:, 0] + boxes[:, 2] / 2  # x2
        boxes_xyxy[:, 3] = boxes[:, 1] + boxes[:, 3] / 2  # y2
        
        # NMS
        indices = cv2.dnn.NMSBoxes(
            boxes_xyxy.tolist(),
            confidences.tolist(),
            conf_thres,
            iou_thres
        )
        
        # Filtrar resultados finales
        final_boxes = boxes_xyxy[indices]
        final_confidences = confidences[indices]
        final_class_ids = class_ids[indices]
        
        # Escalar a imagen original
        input_size = self.input_shape[2]
        scale_x = self.orig_shape[1] / input_size
        scale_y = self.orig_shape[0] / input_size
        
        final_boxes[:, [0, 2]] *= scale_x
        final_boxes[:, [1, 3]] *= scale_y
        
        return final_boxes, final_confidences, final_class_ids
    
    def predict(self, image):
        """
        Ejecuta inferencia completa.
        
        Args:
            image: Imagen BGR (formato OpenCV)
            
        Returns:
            boxes, confidences, class_ids
        """
        # Preprocesar
        input_tensor = self.preprocess(image)
        
        # Inferencia
        outputs = self.session.run(
            [self.output_name],
            {self.input_name: input_tensor}
        )
        
        # Postprocesar
        return self.postprocess(outputs)
    
    def draw_predictions(self, image, boxes, confidences, class_ids, class_names):
        """
        Dibuja las predicciones sobre la imagen.
        """
        for box, conf, cls_id in zip(boxes, confidences, class_ids):
            x1, y1, x2, y2 = box.astype(int)
            
            # Dibujar caja
            cv2.rectangle(image, (x1, y1), (x2, y2), (0, 255, 0), 2)
            
            # Etiqueta
            label = f"{class_names[cls_id]}: {conf:.2f}"
            cv2.putText(image, label, (x1, y1 - 10),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
        
        return image

# Uso
# detector = YOLOONNX('best.onnx')
# image = cv2.imread('test.jpg')
# boxes, confs, ids = detector.predict(image)
# result = detector.draw_predictions(image, boxes, confs, ids, class_names)
# cv2.imwrite('result.jpg', result)
```

### Puntos Clave

- La exportación transforma tu modelo para producción
- ONNX es el formato más universal y portátil
- TensorRT ofrece máxima velocidad en GPUs NVIDIA
- CoreML es esencial para aplicaciones Apple
- TFLite y NCNN son ideales para móviles
- OpenVINO optimiza para CPUs Intel
- Cada formato tiene trade-offs entre velocidad, precisión y portabilidad

### Referencias

- [Ultralytics Export Documentation](https://docs.ultralytics.com/modes/export/)
- [ONNX Runtime](https://onnxruntime.ai/)
- [TensorRT Developer Guide](https://docs.nvidia.com/deeplearning/tensorrt/)

---

## 7.2 Quantization

### Introducción a la Cuantización

Los modelos de deep learning tradicionalmente usan números de punto flotante de 32 bits (FP32) para representar pesos y activaciones. Esto da mucha precisión, pero también consume mucha memoria y potencia de cálculo. La cuantización es como "comprimir" estos números: en lugar de usar 32 bits para cada número, usamos menos bits, sacrificando algo de precisión pero ganando mucha velocidad y reduciendo el tamaño del modelo.

Imagina que tienes que recordar una lista de precios: 19.99, 25.47, 31.82... Es difícil. Pero si redondeas a 20, 25, 32, es mucho más fácil de recordar y procesar, aunque pierdes algo de precisión. La cuantización hace algo similar: reduce la precisión numérica para ganar eficiencia.

### Explicación Detallada

**Tipos de cuantización:**

1. **FP16 (Half Precision)**: Usa 16 bits en lugar de 32. Reduce el tamaño a la mitad con pérdida mínima de precisión. Es el tipo más seguro de cuantización.

2. **INT8 (8-bit Integer)**: Usa solo 8 bits. Reduce el tamaño a 1/4 y puede ser 2-4x más rápido en hardware que lo soporta. Puede haber pérdida de precisión notable en algunos casos.

3. **INT4/INT2 (Ultra Low Precision)**: Experimental. Grandes ganancias de velocidad pero pérdida significativa de precisión. Solo para casos específicos.

**Métodos de cuantización:**

- **Post-Training Quantization (PTQ)**: Se aplica después de entrenar, sin reentrenamiento. Rápido pero puede perder precisión.

- **Quantization-Aware Training (QAT)**: Se entrena el modelo "sabiendo" que será cuantizado. Mejor precisión pero requiere reentrenamiento.

**Trade-offs: Precisión vs Velocidad vs Tamaño**

| Tipo | Tamaño | Velocidad | Pérdida de mAP | Caso de uso |
|------|--------|-----------|----------------|------------|
| FP32 | 100% | Baseline | 0% | Investigación |
| FP16 | 50% | 1.5-2x | <0.5% | Producción GPU |
| INT8 | 25% | 2-4x | 0.5-2% | Edge, mobile |
| INT4 | 12.5% | 4-8x | 2-5% | Experimental |

### Cuantización con Ultralytics

```python
from ultralytics import YOLO

# Cargar modelo
model = YOLO('best.pt')

# Exportar con FP16 (Half Precision)
model.export(
    format='onnx',
    half=True,  # FP16
    imgsz=640,
)

# Exportar con INT8 (requiere dataset para calibración)
model.export(
    format='onnx',
    int8=True,  # INT8
    data='dataset.yaml',  # Dataset para calibración
    imgsz=640,
)

# Exportar TensorRT con INT8
model.export(
    format='engine',
    int8=True,
    data='dataset.yaml',
    imgsz=640,
    workspace=4,  # GB
    device=0,
)

# Exportar TFLite con INT8 (para Edge TPU)
model.export(
    format='tflite',
    int8=True,
    data='dataset.yaml',
    imgsz=640,
)

print("""Modelos exportados:
- best.onnx (FP32)
- best_half.onnx (FP16)
- best_int8.onnx (INT8)
- best_int8.engine (TensorRT INT8)
- best_int8.tflite (TFLite INT8 para Edge TPU)
""")
```

### Puntos Clave

- La cuantización reduce el tamaño del modelo y aumenta la velocidad
- FP16 es seguro: mínima pérdida de precisión, 50% de reducción
- INT8 es más agresivo: 2-4x velocidad, puede perder 0.5-2% mAP
- Post-Training Quantization es rápido pero puede perder precisión
- Quantization-Aware Training ofrece mejor precisión pero requiere reentrenar
- La calibración con datos representativos es crucial para INT8
- Siempre valida el modelo cuantizado antes de desplegar

### Referencias

- [Quantization Guide](https://docs.ultralytics.com/guides/model-deployment-options/)
- [TensorRT Quantization](https://docs.nvidia.com/deeplearning/tensorrt/developer-guide/index.html#quantization)
- [ONNX Quantization](https://onnxruntime.ai/docs/performance/quantization.html)

---

## 7.3 Despliegue en Edge

### Introducción al Edge Computing

El edge computing consiste en ejecutar modelos directamente en dispositivos locales (edge devices) en lugar de servidores centrales en la nube. Esto reduce latencia, mejora la privacidad, y permite funcionamiento offline. Sin embargo, los dispositivos edge tienen recursos limitados: menos memoria, menos potencia de cálculo, y restricciones de energía. Desplegar YOLO en edge requiere optimizaciones específicas.

Piensa en la diferencia entre un supercomputador y un smartphone: ambos pueden ejecutar YOLO, pero el smartphone necesita un modelo optimizado, cuantizado, y posiblemente con resolución reducida para funcionar en tiempo real.

### Explicación Detallada

**Plataformas Edge principales:**

1. **NVIDIA Jetson**: Mini-PCs con GPU NVIDIA. Potentes, soportan TensorRT. Modelos: Jetson Nano (básico), Jetson Xavier NX (medio), Jetson AGX Orin (alto rendimiento).

2. **Raspberry Pi**: Micro-ordenadores ARM. Económicos, sin GPU dedicada. Requieren modelos muy optimizados o aceleradores externos.

3. **Google Coral Edge TPU**: Aceleradores especializados para TensorFlow Lite INT8. Muy rápidos, pero solo soportan modelos TFLite cuantizados.

4. **Intel Neural Compute Stick**: Aceleradores USB para CPUs Intel. Buenos para inferencia en PCs sin GPU.

5. **Apple Neural Engine**: Integrado en chips M1/M2. Usa CoreML para aceleración.

**Consideraciones de hardware:**

| Dispositivo | Precio | FPS YOLOv8n | FPS YOLOv8s | Comentarios |
|-------------|--------|-------------|-------------|------------|
| Jetson Nano | $99 | 20-30 | 10-15 | Requiere fan, buena comunidad |
| Jetson Xavier NX | $399 | 80-100 | 40-50 | Mejor rendimiento/watt |
| RPi 4 + Coral | $100 | 30-40 | N/A | Requiere INT8 |
| Coral USB | $75 | 30-40 | N/A | Solo INT8 |
| Intel NCS2 | $70 | 10-15 | 5-8 | Menor rendimiento |

### Puntos Clave

- Edge computing permite inferencia local, offline y con baja latencia
- Jetson ofrece mejor rendimiento pero consume más energía
- Raspberry Pi es económico pero requiere optimizaciones agresivas
- Coral Edge TPU es excelente para modelos INT8
- La cuantización INT8 es casi obligatoria en edge
- Frame skipping y reducción de resolución mejoran FPS
- Siempre monitorea temperatura y consumo en edge devices

### Referencias

- [Jetson Developer Guide](https://developer.nvidia.com/embedded/develop/jetson)
- [Raspberry Pi Documentation](https://www.raspberrypi.com/documentation/)
- [Coral Edge TPU](https://coral.ai/docs/)
- [Ultralytics Edge Deployment](https://docs.ultralytics.com/guides/coral-edge-tpc-on-raspberry-pi/)# Módulo 8: Seguimiento de Objetos (2h)

## 8.1 Fundamentos de Tracking

### Introducción al Tracking de Objetos

Hasta ahora hemos aprendido a detectar objetos frame a frame. Pero ¿qué pasa si necesitas saber no solo qué objetos hay en cada imagen, sino cuál es cuál a lo largo del tiempo? Si estás contando personas que entran a una tienda, necesitas distinguir si la persona que sale es una nueva o la misma que entró antes. Ahí es donde entra el tracking: el arte de seguir objetos a través del tiempo.

El tracking resuelve el problema de la identidad temporal. Mientras la detección responde "¿qué hay aquí?", el tracking responde "¿este objeto es el mismo que vi antes?". Esta distinción es crucial para aplicaciones de conteo, análisis de comportamiento, y sistemas de vigilancia.

### Explicación Detallada

**Diferencia entre detección y tracking:**

| Aspecto | Detección | Tracking |
|---------|-----------|----------|
| Pregunta | ¿Qué hay? ¿Dónde? | ¿Quién es? ¿Dónde estuvo? |
| Salida | Cajas + clases | Cajas + clases + IDs |
| Temporalidad | Frame individual | Secuencia de frames |
| Identidad | No preserva | Preserva identidad |
| Casos de uso | Clasificación, localización | Conteo, análisis de movimiento |

**¿Por qué es importante el tracking?**

1. **Conteo preciso**: Sin tracking, si una persona camina frente a la cámara y luego vuelve a aparecer, la contarías dos veces. Con tracking, cada persona tiene un ID único, permitiendo conteos exactos.

2. **Análisis de trayectoria**: Puedes analizar patrones de movimiento: ¿por dónde caminan los clientes en una tienda? ¿Qué rutas toman los vehículos en un estacionamiento?

3. **Detección de comportamiento**: Puedes identificar comportamientos anómalos: una persona que deambula en círculos (posible hurto), un vehículo que se detiene en zona prohibida.

4. **Predicción**: Con la trayectoria histórica, puedes predecir dónde estará el objeto en frames futuros.

5. **Eficiencia**: El tracking puede reducir la carga de detección: en lugar de detectar en cada frame, puedes predecir la ubicación y solo verificar.

**Desafíos del tracking:**

- **Oclusiones**: Objetos que se tapan entre sí. Si dos personas se cruzan, ¿cómo sabes cuál es cuál después?
- **Re-identificación**: Un objeto sale del frame y vuelve a entrar. ¿Es el mismo o uno nuevo?
- **Cambios de apariencia**: Un objeto que gira, cambia de iluminación, o se deforma.
- **Falsas detecciones**: El detector puede fallar en algunos frames, generando gaps en la trayectoria.
- **ID switching**: Asignar incorrectamente un ID a un objeto diferente.

### Puntos Clave

- Tracking añade identidad temporal a las detecciones
- Detección pregunta "¿qué?", tracking pregunta "¿quién?"
- Los IDs persistentes permiten conteo y análisis de trayectoria
- Las oclusiones son el mayor desafío del tracking
- ID switching es un error común: asignar ID incorrecto
- MOTA e IDF1 son las métricas estándar de tracking

### Referencias

- [Ultralytics Tracking Guide](https://docs.ultralytics.com/modes/track/)
- [MOTChallenge](https://motchallenge.net/)
- [Tracking Metrics](https://motchallenge.net/data/MOT16.pdf)

---

## 8.2 Algoritmos de Tracking

### Introducción a los Algoritmos de Tracking

Los algoritmos de tracking modernos combinan detección con asociación de datos. El detector encuentra objetos en cada frame, y el algoritmo de tracking decide qué detección corresponde a qué track existente. ByteTrack y BoT-SORT son dos de los algoritmos más populares actuales, cada uno con su enfoque para resolver el problema de la asociación.

ByteTrack revolucionó el tracking al proponer que incluso las detecciones de baja confianza (que tradicionalmente se descartaban) contienen información útil para mantener la identidad de objetos ocluidos. BoT-SORT mejoró aún más añadiendo mejor manejo de oclusiones y re-identificación.

### Explicación Detallada

**ByteTrack: Cómo funciona**

ByteTrack divide las detecciones en dos grupos:
1. **Detecciones de alta confianza** (> umbral): Se usan para matching primario
2. **Detecciones de baja confianza** (< umbral): Se usan para recuperar tracks perdidos

El proceso:

1. **Detección**: YOLO detecta objetos con scores de confianza
2. **Primera asociación**: Tracks existentes se asocian con detecciones de alta confianza usando IoU
3. **Segunda asociación**: Tracks no asociados se asocian con detecciones de baja confianza
4. **Nuevos tracks**: Detecciones no asociadas crean nuevos tracks
5. **Limpieza**: Tracks sin asociaciones por N frames se eliminan

**¿Por qué funciona ByteTrack?**

Imagina que una persona es ocluida parcialmente por un pilar. El detector puede seguir viéndola, pero con baja confianza (score 0.3). Un enfoque tradicional descartaría esta detección. ByteTrack la usa para mantener el track vivo, permitiendo recuperar la identidad completa cuando la persona sale de detrás del pilar.

**BoT-SORT: Mejoras sobre ByteTrack**

BoT-SORT añade:

1. **Kalman Filter mejorado**: Predice mejor la posición futura del objeto
2. **Camera Motion Compensation**: Compensa movimientos de cámara
3. **ReID (Re-Identification)**: Usa características visuales para recuperar tracks
4. **Better IoU matching**: Usa IoU 3D considerando tiempo

### Implementación con Ultralytics

```python
import cv2
from ultralytics import YOLO

def tracking_bytetrack(video_path, output_path, model_path='yolo11n.pt'):
    """
    Tracking con algoritmo ByteTrack.
    
    ByteTrack es el tracker por defecto en Ultralytics.
    Es rápido y efectivo para la mayoría de casos.
    
    Args:
        video_path: Ruta del video de entrada
        output_path: Ruta del video de salida
        model_path: Ruta al modelo YOLO
    """
    # Cargar modelo
    model = YOLO(model_path)
    
    # Configuración de video
    cap = cv2.VideoCapture(video_path)
    width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    fps = int(cap.get(cv2.CAP_PROP_FPS))
    
    out = cv2.VideoWriter(output_path,
                          cv2.VideoWriter_fourcc(*'mp4v'),
                          fps, (width, height))
    
    # Tracking loop
    frame_count = 0
    total_tracks = set()
    
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break
        
        # ByteTrack tracking (default)
        results = model.track(
            frame,
            persist=True,          # Mantener tracks entre frames
            tracker='bytetrack.yaml',  # Configuración ByteTrack
            verbose=False,
            conf=0.25,
            iou=0.45,
        )
        
        # Procesar resultados
        if results[0].boxes.id is not None:
            boxes = results[0].boxes.xyxy.cpu().numpy()
            ids = results[0].boxes.id.cpu().numpy().astype(int)
            confs = results[0].boxes.conf.cpu().numpy()
            classes = results[0].boxes.cls.cpu().numpy().astype(int)
            
            for box, obj_id, conf, cls in zip(boxes, ids, confs, classes):
                x1, y1, x2, y2 = map(int, box)
                total_tracks.add(obj_id)
                
                # Dibujar
                cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)
                cv2.putText(frame, f"ID:{obj_id} C:{cls} {conf:.2f}",
                           (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX,
                           0.5, (0, 255, 0), 2)
        
        out.write(frame)
        frame_count += 1
    
    cap.release()
    out.release()
    
    print(f"Frames procesados: {frame_count}")
    print(f"Objetos únicos trackeados: {len(total_tracks)}")
    print(f"Video guardado: {output_path}")

# Uso
# tracking_bytetrack('input.mp4', 'output_bytetrack.mp4')
```

### Puntos Clave

- ByteTrack usa detecciones de baja confianza para recuperar tracks
- BoT-SORT añade Kalman Filter, camera motion compensation y ReID
- ByteTrack es más rápido, BoT-SORT es más robusto
- La configuración del tracker se puede personalizar via YAML
- Los IDs persistentes permiten análisis de trayectoria
- track_buffer determina cuántos frames mantener un track sin detección

### Referencias

- [ByteTrack Paper](https://arxiv.org/abs/2110.06864)
- [BoT-SORT Paper](https://arxiv.org/abs/2206.14651)
- [Ultralytics Tracking](https://docs.ultralytics.com/modes/track/)
- [MOT Evaluation Metrics](https://motchallenge.net/)# Módulo 9: Tareas Avanzadas (3h)

## 9.1 Segmentación de Instancias (YOLO-Seg)

### Introducción a la Segmentación de Instancias

Hasta ahora hemos trabajado con bounding boxes: rectángulos que rodean los objetos. Pero ¿qué pasa si necesitas saber exactamente qué píxeles pertenecen a cada objeto, no solo una caja aproximada? Ahí entra la segmentación de instancias. En lugar de dibujar un rectángulo, la segmentación dibuja el contorno exacto de cada objeto, píxel por píxel.

La segmentación de instancias combina la detección de objetos con la segmentación semántica: detecta múltiples objetos y, para cada uno, genera una máscara precisa que indica exactamente qué píxeles pertenecen a ese objeto específico. Esto permite aplicaciones como medir áreas exactas, detectar defectos en productos, o realizar análisis médico preciso.

### Explicación Detallada

**Diferencias entre tareas:**

| Tarea | Salida | Información |
|-------|--------|------------|
| Clasificación | Etiqueta | "Es un perro" |
| Detección | Caja + clase | "Hay un perro en esta región rectangular" |
| Segmentación semántica | Máscara por clase | "Todos estos píxeles son perro, sin distinguir individuos" |
| Segmentación de instancias | Máscara por instancia | "Este contorno es el perro #1, este otro es el perro #2" |

**Arquitectura de YOLO-Seg:**

YOLO para segmentación mantiene el backbone de detección pero añade:

1. **Cabeza de detección**: Igual que YOLO normal, predice bounding boxes
2. **Cabeza de máscaras**: Para cada detección, genera coeficientes de máscara
3. **Prototypes**: Un banco de máscaras base que se combinan según los coeficientes
4. **Fusión**: Los coeficientes se combinan con prototypes para generar la máscara final

**Ventajas de la segmentación:**

- **Precisión espacial**: Conoces exactamente los límites del objeto
- **Medición de área**: Puedes medir el tamaño real del objeto
- **Separación de objetos cercanos**: Objetos que se tocan se pueden separar
- **Análisis de forma**: Puedes extraer características morfológicas

### Segmentación con YOLO11-Seg

```python
import cv2
import numpy as np
from ultralytics import YOLO

def instance_segmentation(image_path, model_path='yolo11n-seg.pt'):
    """
    Segmentación de instancias con YOLO11-Seg.
    
    Args:
        image_path: Ruta a la imagen
        model_path: Modelo de segmentación (termina en -seg.pt)
    
    Returns:
        Imagen con máscaras superpuestas
    """
    # Cargar modelo de segmentación
    model = YOLO(model_path)
    
    # Predecir
    results = model(image_path)
    
    # Obtener imagen original
    image = cv2.imread(image_path)
    
    # Procesar resultados
    if results[0].masks is not None:
        masks = results[0].masks.data.cpu().numpy()
        boxes = results[0].boxes
        
        print(f"Objetos detectados: {len(masks)}")
        
        # Crear imagen de máscaras
        combined_mask = np.zeros(image.shape[:2], dtype=np.uint8)
        
        for i, (mask, box) in enumerate(zip(masks, boxes)):
            # Redimensionar máscara a tamaño original
            mask_resized = cv2.resize(mask, (image.shape[1], image.shape[0]))
            
            # Binarizar
            mask_binary = (mask_resized > 0.5).astype(np.uint8) * 255
            
            # Color aleatorio para esta instancia
            color = np.random.randint(0, 255, 3).tolist()
            
            # Aplicar máscara con color
            colored_mask = np.zeros_like(image)
            colored_mask[mask_binary == 255] = color
            
            # Superponer con transparencia
            image = cv2.addWeighted(image, 0.7, colored_mask, 0.3, 0)
            
            # Dibujar contorno
            contours, _ = cv2.findContours(mask_binary, cv2.RETR_EXTERNAL, 
                                           cv2.CHAIN_APPROX_SIMPLE)
            cv2.drawContours(image, contours, -1, color, 2)
            
            # Etiqueta
            cls = int(box.cls[0])
            conf = float(box.conf[0])
            x1 = int(box.xyxy[0][0])
            y1 = int(box.xyxy[0][1])
            
            cv2.putText(image, f"{model.names[cls]}: {conf:.2f}",
                       (x1, y1 - 10), cv2.FONT_HERSHEY_SIMPLEX,
                       0.5, color, 2)
    
    return image

# Uso
# result = instance_segmentation('photo.jpg')
# cv2.imwrite('segmentation_result.jpg', result)
```

### Puntos Clave

- Segmentación de instancias detecta y enmascara cada objeto individualmente
- YOLO-Seg añade una cabeza de máscaras al backbone de detección
- Las máscaras permiten medir área, perímetro y forma exacta
- El formato de anotación usa polígonos normalizados
- La segmentación es más costosa que la detección (menor FPS)
- Útil para aplicaciones que requieren precisión espacial

### Referencias

- [Ultralytics Segmentation](https://docs.ultralytics.com/tasks/segment/)
- [YOLOv7-seg Paper](https://arxiv.org/abs/2207.02696)
- [COCO Segmentation Dataset](https://cocodataset.org/#home)

---

## 9.2 Estimación de Pose (YOLO-Pose)

### Introducción a la Estimación de Pose

La estimación de pose detecta puntos clave (keypoints) en el cuerpo humano: hombros, codos, rodillas, etc. A diferencia de la detección que solo localiza personas, la estimación de pose entiende la configuración corporal, permitiendo analizar posturas, gestos, y movimientos.

Esta tecnología es la base de aplicaciones como análisis deportivo (evaluar técnica de atletas), rehabilitación (monitorear ejercicios de pacientes), interacción humano-computadora (control por gestos), y vigilancia inteligente (detectar comportamientos sospechosos).

### Explicación Detallada

**Keypoints del dataset COCO:**

COCO define 17 keypoints estándar para el cuerpo humano:

```
0: nariz         5: hombro_izq      10: rodilla_der    15: tobillo_izq
1: ojo_izq       6: hombro_der      11: rodilla_izq    16: tobillo_der
2: ojo_der       7: codo_izq        12: tobillo_der
3: oreja_izq     8: codo_der        13: tobillo_izq
4: oreja_der     9: cadera_izq      14: cadera_der
```

**Esqueletos y conexiones:**

Los keypoints no son puntos aislados. Se conectan formando un esqueleto:
- Cabeza: orejas-ojos-nariz
- Torso: hombros-caderas
- Brazos: hombro-codo-muñeca
- Piernas: cadera-rodilla-tobillo

**Arquitectura de YOLO-Pose:**

1. **Backbone**: Extrae características visuales
2. **Cabeza de detección**: Detecta personas (bounding boxes)
3. **Cabeza de keypoints**: Para cada persona, predice coordenadas (x, y, visibilidad) de cada keypoint
4. **Asociación**: Keypoints se asocian a la persona detectada

### Estimación de Pose con YOLO11-Pose

```python
import cv2
import numpy as np
from ultralytics import YOLO

def pose_estimation(image_path, model_path='yolo11n-pose.pt'):
    """
    Estimación de pose con YOLO11-Pose.
    
    Args:
        image_path: Ruta a la imagen
        model_path: Modelo de pose (termina en -pose.pt)
    
    Returns:
        Imagen con keypoints y esqueletos dibujados
    """
    # Cargar modelo
    model = YOLO(model_path)
    
    # Predecir
    results = model(image_path)
    
    # Obtener imagen
    image = cv2.imread(image_path)
    
    # Keypoints COCO
    keypoints_names = [
        'nose', 'left_eye', 'right_eye', 'left_ear', 'right_ear',
        'left_shoulder', 'right_shoulder', 'left_elbow', 'right_elbow',
        'left_wrist', 'right_wrist', 'left_hip', 'right_hip',
        'left_knee', 'right_knee', 'left_ankle', 'right_ankle'
    ]
    
    # Conexiones del esqueleto (pares de índices)
    skeleton = [
        (0, 1), (0, 2), (1, 3), (2, 4),  # Cabeza
        (5, 6),  # Hombros
        (5, 7), (7, 9),  # Brazo izquierdo
        (6, 8), (8, 10),  # Brazo derecho
        (5, 11), (6, 12),  # Torso
        (11, 12),  # Caderas
        (11, 13), (13, 15),  # Pierna izquierda
        (12, 14), (14, 16),  # Pierna derecha
    ]
    
    # Colores para cada parte del cuerpo
    skeleton_colors = [
        (255, 0, 0), (255, 0, 0), (255, 0, 0), (255, 0, 0),  # Cabeza - azul
        (0, 255, 0),  # Hombros - verde
        (0, 255, 255), (0, 255, 255),  # Brazo izq - amarillo
        (255, 255, 0), (255, 255, 0),  # Brazo der - cyan
        (255, 0, 255), (255, 0, 255),  # Torso - magenta
        (0, 255, 0),  # Caderas - verde
        (0, 165, 255), (0, 165, 255),  # Pierna izq - naranja
        (255, 165, 0), (255, 165, 0),  # Pierna der - azul cielo
    ]
    
    # Procesar cada persona detectada
    if results[0].keypoints is not None:
        keypoints = results[0].keypoints.data.cpu().numpy()
        
        print(f"Personas detectadas: {len(keypoints)}")
        
        for person_idx, person_kpts in enumerate(keypoints):
            # Dibujar keypoints
            for kpt_idx, (x, y, conf) in enumerate(person_kpts):
                if conf > 0.5:  # Solo keypoints con buena confianza
                    cv2.circle(image, (int(x), int(y)), 3, (0, 255, 0), -1)
            
            # Dibujar esqueleto
            for (start, end), color in zip(skeleton, skeleton_colors):
                x1, y1, c1 = person_kpts[start]
                x2, y2, c2 = person_kpts[end]
                
                if c1 > 0.5 and c2 > 0.5:  # Ambos keypoints visibles
                    cv2.line(image, (int(x1), int(y1)), (int(x2), int(y2)), 
                            color, 2)
    
    return image

# Uso
# result = pose_estimation('person.jpg')
# cv2.imwrite('pose_result.jpg', result)
```

### Puntos Clave

- La estimación de pose detecta 17 keypoints del cuerpo humano
- COCO define el estándar de keypoints usado por YOLO
- Los keypoints incluyen coordenadas (x, y) y confianza
- Se pueden calcular ángulos articulares para análisis postural
- La detección de gestos se basa en relaciones espaciales entre keypoints
- Aplicaciones: deportes, rehabilitación, HCI, vigilancia

### Referencias

- [Ultralytics Pose](https://docs.ultralytics.com/tasks/pose/)
- [COCO Keypoints](https://cocodataset.org/#keypoints-eval)
- [OpenPose Paper](https://arxiv.org/abs/1812.08008)

---

## 9.3 Oriented Bounding Boxes (OBB)

### Introducción a los OBB

Los bounding boxes tradicionales son rectángulos alineados con los ejes de la imagen (horizontal y vertical). Pero muchos objetos en el mundo real están rotados: aviones en imágenes satelitales, vehículos en ángulo, texto en documentos escaneados. Los Oriented Bounding Boxes (OBB) permiten detectar objetos con rotación, proporcionando una localización mucho más precisa.

Un OBB se define por cinco parámetros: centro_x, centro_y, ancho, alto, y ángulo de rotación. Este parámetro adicional permite que el bounding box se ajuste exactamente a la orientación del objeto, crucial para aplicaciones como detección aérea, análisis de documentos, y metrología industrial.

### Puntos Clave

- Los OBB añaden rotación al bounding box tradicional
- Se definen por centro, tamaño, y ángulo de rotación
- Son esenciales para imágenes aéreas y satelitales
- DOTA es el dataset principal para OBB
- El formato de anotación usa las 4 esquinas del rectángulo
- Requieren herramientas de anotación especializadas

### Referencias

- [Ultralytics OBB](https://docs.ultralytics.com/tasks/obb/)
- [DOTA Dataset](https://captain-whu.github.io/DOTA/)
- [OBB Paper](https://arxiv.org/abs/1711.10394)

---

## 9.4 Clasificación de Imágenes (YOLO-Cls)

### Introducción a YOLO para Clasificación

Aunque YOLO es famoso por detección, también puede usarse para clasificación de imágenes. A diferencia de la detección que localiza múltiples objetos, la clasificación asigna una sola etiqueta a toda la imagen: "es un perro", "es un gato", "es un avión". YOLO-Cls usa el mismo backbone eficiente pero con una cabeza de clasificación en lugar de detección.

YOLO-Cls es excelente cuando solo necesitas saber qué hay en la imagen, sin localizar objetos específicos. Es más rápido y ligero que los modelos de detección, y puede usarse como primer paso antes de tareas más complejas.

### Explicación Detallada

**Diferencias entre clasificación y detección:**

| Aspecto | Clasificación | Detección |
|---------|--------------|-----------|
| Salida | Una etiqueta | Múltiples cajas + etiquetas |
| Localización | No | Sí |
| Complejidad | Menor | Mayor |
| Velocidad | Más rápido | Más lento |
| Casos de uso | Categorizar imágenes | Localizar objetos |

**Arquitectura de YOLO-Cls:**

1. **Backbone**: Mismo que YOLO de detección (extrae características)
2. **Global Average Pooling**: Reduce características a un vector
3. **Capa fully connected**: Produce probabilidades por clase
4. **Sin anchors, sin NMS**: Simplemente argmax de las probabilidades

**Transfer Learning desde ImageNet:**

YOLO-Cls se pre-entrena en ImageNet (14M imágenes, 1000 clases). Esto le permite aprender características visuales genéricas que luego se transfieren a tareas específicas mediante fine-tuning.

### Puntos Clave

- YOLO-Cls es eficiente para clasificación de imágenes
- No localiza objetos, solo etiqueta toda la imagen
- Usa el mismo backbone que YOLO de detección
- Pre-entrenado en ImageNet para transfer learning
- Estructura de dataset: carpetas por clase
- Más rápido y ligero que modelos de detección

### Referencias

- [Ultralytics Classification](https://docs.ultralytics.com/tasks/classify/)
- [ImageNet Dataset](https://www.image-net.org/)
- [Transfer Learning Guide](https://docs.ultralytics.com/guides/transfer-learning/)# Módulo 10: Proyecto Final Integrador (3h)

## 10.1 Definición del Proyecto

### Introducción al Proyecto Final

Has aprendido los fundamentos de YOLO: desde la detección básica hasta tareas avanzadas como segmentación y tracking. Ahora es momento de integrar todo ese conocimiento en un proyecto real. Un proyecto bien definido te permite practicar habilidades prácticas, construir un portfolio, y resolver problemas del mundo real.

El proyecto final debe seguir el flujo completo de un proyecto de ML: definición del problema, preparación de datos, entrenamiento, evaluación, y despliegue. Este proceso te prepara para enfrentar desafíos reales en producción.

### Metodología de Definición

**Pasos para definir tu proyecto:**

1. **Identificar el problema**: ¿Qué quieres resolver? ¿Quién se beneficia?
2. **Verificar viabilidad**: ¿Tienes datos? ¿Es técnicamente posible?
3. **Definir métricas de éxito**: ¿Cómo medirás si funcionó?
4. **Establecer scope**: ¿Qué está dentro y fuera del proyecto?
5. **Planificar recursos**: ¿Qué necesitas (datos, hardware, tiempo)?

**Criterios de selección de caso de uso:**

| Criterio | Pregunta |
|----------|----------|
| Valor | ¿Resuelve un problema real? |
| Datos | ¿Tienes acceso a datos de calidad? |
| Viabilidad | ¿Es técnicamente factible con YOLO? |
| Complejidad | ¿Es apropiado para tu nivel? |
| Interés | ¿Te motiva trabajar en esto? |

### Ideas de Proyectos por Sector

**Retail:**
- Contador de clientes: Cuenta personas que entran/salen de una tienda
- Detector de productos en shelf: Detecta productos faltantes o desordenados
- Análisis de comportamiento: Analiza rutas de clientes y tiempo en secciones

**Seguridad:**
- Detector de intrusos: Alerta cuando detecta personas en zona restringida
- Detector de armas: Detecta armas en tiempo real

**Industria:**
- Inspector de calidad: Detecta defectos en productos de línea
- Contador de piezas: Cuenta piezas en cinta transportadora

**Agricultura:**
- Detector de plagas: Detecta insectos en hojas de cultivos
- Clasificador de frutas: Clasifica frutas por calidad y madurez

**Salud:**
- Detector de mascarillas: Detecta si personas usan mascarilla
- Análisis postural: Analiza postura durante ejercicios

### Documento de Requisitos

El proyecto debe incluir:

1. **Resumen**: Descripción general del problema
2. **Objetivos**: Lista de objetivos medibles
3. **Requisitos técnicos**: Hardware, software, datos
4. **Métricas de éxito**: Precisión mínima, FPS objetivo, latencia máxima
5. **Entregables**: Dataset, modelo entrenado, código, documentación
6. **Cronograma**: Fases y duración estimada

### Puntos Clave

- Un proyecto bien definido tiene objetivos claros y medibles
- El scope debe ser apropiado para tus recursos y tiempo
- Documentar requisitos desde el inicio evita problemas después
- Considera el hardware disponible para entrenamiento e inferencia
- Los entregables incluyen modelo, código, y documentación

### Referencias

- [Project Planning Guide](https://docs.ultralytics.com/guides/)
- [ML Project Checklist](https://developers.google.com/machine-learning/guides/rules-of-ml)

---

## 10.2 Pipeline de Preparación de Datos

### Introducción a la Preparación de Datos

La calidad de tus datos determina la calidad de tu modelo. El 60-80% del tiempo de un proyecto de ML se invierte en preparar datos: recolectar, limpiar, anotar, y validar. Un pipeline de datos bien diseñado asegura que tu modelo reciba datos consistentes y de calidad.

El proceso incluye: identificación de fuentes, recolección sistemática, anotación consistente, división train/val/test, y validación de calidad.

### Explicación Detallada

**Fuentes de datos:**

1. **Datasets públicos**: COCO, Open Images, Roboflow Universe
2. **Recolección propia**: Cámaras, web scraping, síntesis
3. **Datos sintéticos**: 3D rendering, augmentation

**Criterios de calidad:**

| Aspecto | Descripción |
|---------|-------------|
| Representatividad | ¿Los datos representan el caso real? |
| Balance | ¿Hay suficiente ejemplos por clase? |
| Diversidad | ¿Hay variación en condiciones? |
| Consistencia | ¿Las anotaciones son uniformes? |
| Limpieza | ¿No hay duplicados o errores? |

### Estructura del Dataset

```
dataset/
├── images/
│   ├── train/
│   ├── val/
│   └── test/
└── labels/
    ├── train/
    ├── val/
    └── test/
```

### Validación del Dataset

Antes de entrenar, valida:

1. Estructura de directorios correcta
2. Imágenes válidas (no corruptas)
3. Labels correspondientes a cada imagen
4. Balance de clases
5. Distribución de tamaños

### Puntos Clave

- La preparación de datos es el 60-80% del tiempo de un proyecto
- Estructura correcta: images/{train,val,test} y labels/{train,val,test}
- Validar integridad antes de entrenar
- Balancear clases para mejor rendimiento
- Documentar el proceso de recolección

### Referencias

- [Dataset Preparation](https://docs.ultralytics.com/datasets/)
- [Labeling Tools](https://roboflow.com/annotate)
- [Data Augmentation](https://docs.ultralytics.com/usage/cfg/#augmentation)

---

## 10.3 Entrenamiento y Optimización

### Introducción al Entrenamiento

Con los datos listos, el siguiente paso es entrenar el modelo. Pero entrenar no es solo ejecutar `model.train()`. Requiere seleccionar el modelo adecuado, configurar hiperparámetros, monitorear el progreso, y ajustar basándose en los resultados. La optimización es un proceso iterativo que combina conocimiento teórico con experimentación práctica.

### Selección de Modelo

**Comparación de Modelos YOLO11:**

| Modelo | Parámetros | FPS | mAP COCO | Tamaño MB |
|--------|------------|-----|----------|-----------|
| YOLO11n | 2.6M | 280 | 37.3 | 5.4 |
| YOLO11s | 9.4M | 180 | 44.9 | 18 |
| YOLO11m | 20.1M | 120 | 50.2 | 40 |
| YOLO11l | 25.3M | 90 | 52.6 | 51 |
| YOLO11x | 56.9M | 60 | 55.2 | 112 |

**Criterios de selección:**

- **Edge/ móvil**: YOLO11n o YOLO11s (velocidad prioritaria)
- **Servidor GPU**: YOLO11m o YOLO11l (balance)
- **Precisión máxima**: YOLO11x (recursos disponibles)

### Hiperparámetros Clave

```python
from ultralytics import YOLO

model = YOLO('yolo11n.pt')

results = model.train(
    data='dataset.yaml',
    epochs=50,
    imgsz=640,
    batch=16,
    
    # Optimización
    optimizer='AdamW',
    lr0=0.001,           # Learning rate inicial
    lrf=0.01,            # Learning rate final (lr0 * lrf)
    momentum=0.937,
    weight_decay=0.0005,
    
    # Data augmentation
    degrees=10,          # Rotación
    translate=0.1,       # Traslación
    scale=0.5,           # Escala
    shear=0.0,           # Cizalladura
    perspective=0.0,     # Perspectiva
    flipud=0.0,          # Flip vertical
    fliplr=0.5,          # Flip horizontal
    mosaic=1.0,          # Mosaic augmentation
    mixup=0.1,           # Mixup augmentation
    
    # Regularización
    dropout=0.0,
    label_smoothing=0.0,
    
    # Early stopping
    patience=50,         # Epochs sin mejora antes de parar
)
```

### Métricas de Éxito

- **mAP@50 > 0.9**: Objetivo para datasets limpios
- **mAP@50-95 > 0.7**: Objetivo para producción
- **Precision > 0.9**: Minimizar falsos positivos
- **Recall > 0.9**: Minimizar falsos negativos
- **FPS > 30**: Para aplicaciones en tiempo real

### Puntos Clave

- Selecciona el modelo según requisitos de FPS y accuracy
- Usa learning rate warmup y decay
- El data augmentation mejora la generalización
- Early stopping previene overfitting
- El ajuste de hiperparámetros es un proceso iterativo
- Documenta todos los experimentos

### Referencias

- [Training Guide](https://docs.ultralytics.com/modes/train/)
- [Hyperparameter Tuning](https://docs.ultralytics.com/guides/hyperparameter-tuning/)
- [Experiment Tracking](https://docs.ultralytics.com/integrations/)

---

## 10.4 Script de Inferencia para Producción

### Introducción a la Inferencia en Producción

El último paso es crear un script de inferencia robusto que funcione en producción. Esto significa manejar errores, optimizar rendimiento, y proporcionar una interfaz clara. Un script de producción debe ser confiable, eficiente, y fácil de mantener.

### Script de Inferencia Completo

```python
#!/usr/bin/env python3
"""
Script de inferencia para producción.

Uso:
    python inference.py --source video.mp4 --model best.pt
    python inference.py --source 0 --model best.engine --device cuda
    python inference.py --source rtsp://... --model best.pt --tracker
"""

import argparse
import cv2
import time
import logging
from pathlib import Path
from typing import Optional, List, Dict, Any

from ultralytics import YOLO

# Configuración de logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class ProductionInference:
    """Clase de inferencia para producción."""
    
    def __init__(
        self,
        model_path: str,
        device: str = 'cuda',
        conf_thres: float = 0.25,
        iou_thres: float = 0.45,
        enable_tracking: bool = False,
    ):
        """Inicializa el sistema de inferencia."""
        self.model_path = model_path
        self.device = device
        self.conf_thres = conf_thres
        self.iou_thres = iou_thres
        self.enable_tracking = enable_tracking
        
        # Cargar modelo
        logger.info(f"Cargando modelo: {model_path}")
        self.model = YOLO(model_path)
        self.class_names = self.model.names
        
        # Métricas{"type":"req","id":"connect-1","method":"connect","params":{"minProtocol":3,"maxProtocol":3,"client":{"id":"test","version":"1.0","platform":"cli","mode":"ui"},"role":"operator","scopes":["operator.read","operator.write"],"auth":{"token":"70967e2a75b3747b09be49dd353cea2f958ed9c8eaa392af62421e847e0243a7"}}}
{"type":"req","id":"agents-1","method":"agents.list","params":{}}

{  "type": "req",  "id": "list_agents",  "method": "agent.list",  "params": {}}

{  "type": "req",  "id": "send_msg",  "method": "chat.send",  "params": {    "sessionKey": "main",    "content": "Hola",    "idempotencyKey": "test_123"  }}

{  "type": "req",  "id": "conn_1",  "method": "connect",  "params": {    "minProtocol": 3,    "maxProtocol": 3,    "client": {"id": "test", "version": "1.0", "platform": "cli", "mode":"ui"},    "role": "operator",    "scopes": ["operator.read", "operator.write"],    "auth": {"token": "0895f6fdab7f2897689b30d5b772b244c20aeb5b6d8b5fe2"}  }}

{  "type": "req",  "id": "conn_1",  "method": "connect",  "params": {    "minProtocol": 3,    "maxProtocol": 3,    "client": {      "id": "openclaw-ios",      "displayName": "Mi App RN",      "version": "1.0.0",      "platform": "react-native",      "mode": "ui",      "instanceId": "A1B2"    },    "role": "operator",    "scopes": ["operator.read", "operator.write", "operator.admin"],    "auth": {      "token": "0895f6fdab7f2897689b30d5b772b244c20aeb5b6d8b5fe2"    }  }}


{  "type": "req",  "id": "agents_list",  "method": "agents.list",  "params": {}}

{  "type":"req",  "id":"connect-1",  "method":"connect",  "params":{    "minProtocol":3,    "maxProtocol":3,    "client":{"id":"cli","version":"1.0","platform":"cli","mode":"ui"},    "role":"operator",    "scopes":["operator.read","operator.write","operator.admin"],    "token":"mi-cliente-react-native-2026-token-fijo"  }}

{  "type": "req",  "id": "test",  "method": "connect",  "params": {    "minProtocol": 3,    "maxProtocol": 3,    "client": {"id": "test", "version": "1.0", "platform": "cli", "mode": "ui"},    "role": "operator",    "scopes": ["operator.read", "operator.write", "operator.admin"],    "auth": {"token": "mi-cliente-react-native-2026-token-fijo"}  }}
{  "type":"req",  "id":"send-1",  "method":"sessions.send",  "params":{    "sessionKey":"agent:bot-bunnny:main",    "message":{      "role":"user",      "content":"Hola, ¿estás disponible?"    }  }}

{  "type": "req",  "id": "connect-1",  "method": "connect",  "params": {    "minProtocol": 3,    "maxProtocol": 3,    "client": {      "id": "react-native-client",      "version": "1.0",      "platform": "react-native",      "mode": "ui"    },    "role": "operator",    "scopes": [      "operator.read",      "operator.write",      "operator.admin"    ],    "auth": {      "token": "q1Q9-xqjS2Lj7P1u99BaTb7wjwakC-21IpcNynB-xl0"    }  }}

{  "type": "req",  "id": "connect-1",  "method": "connect",  "params": {    "minProtocol": 3,    "maxProtocol": 3,    "client": {      "id": "gateway-token-mi-cliente",      "version": "1.0",      "platform": "react-native",      "mode": "ui"    },    "role": "operator",    "scopes": [      "operator.read",      "operator.write",      "operator.admin"    ],    "auth": {      "token": "q1Q9-xqjS2Lj7P1u99BaTb7wjwakC-21IpcNynB-xl0"    }  }}

{  "type": "req",  "id": "connect-1",  "method": "connect",  "params": {    "minProtocol": 3,    "maxProtocol": 3,    "client": {      "id": "test",      "version": "1.0",      "platform": "cli",      "mode": "ui"    },    "role": "operator",    "scopes": [      "operator.read",      "operator.write",      "operator.admin"    ],    "auth": {      "token": "q1Q9-xqjS2Lj7P1u99BaTb7wjwakC-21IpcNynB-xl0"    }  }}

quiero hacer la planificacin de una aplicacin para manejar agentes. Esta aplicación, en principio, est diseñada para mvil, pero tiene que estar preparada para poder adaptarse para una aplicacin de escritorio y también para una web app. En una primera etapa quiero desarrollar sobre todo la parte visual de la aplicacin. Por tanto, quiero que exista un diseño coherente, homogneo, agradable, de acuerdo a las guas de estilo que te voy a dar. Es una aplicación para, en pocas palabras, gestionar e interactuar con agentes. De modo que tiene tres pilares fundamentales. El primero, tiene que tener una pantalla para poder chatear con un agente, es decir, típica pantalla hecha, solo que tiene que tener un diseño minimalista, atractivo y tiene que tener mltiples animaciones para que el usuario vea que est interaccionando con un agente. El segundo pilar consiste en que tiene que ser capaz de poder crear agentes, de modo que hay que incluir una pantalla de configuracin de agente en el que podemos definir su personalidad, definir las skills que tiene, definir el modo de funcionamiento, sus directivas, todo este tipo de configuraciones. Parte de esas configuraciones se pueden modificar mientras usamos el agente, es decir, que en la propia ventana del chat de la gente podemos entrar a una ventana de configuración y cambiar el nivel de humor, el tamaño de las respuestas o la longitud de respuestas. qu tipo de skills tiene el agente. La tercera pata consiste en que los agentes nos van a enviar archivos, básicamente PDFs, nos pueden mandar tambin grafos, que en el fondo son HTMLs, tambin nos pueden mandar presentaciones que son en HTML. Es decir, que los resultados de los trabajos de los agentes se tienen que poder visualizar correctamente en la aplicacin. Por tanto, tiene que haber una pantalla para poder navegar en los archivos que nos enva la agente y poder visualizarlos de una forma muy atractiva. mnimo tiene que haber un agente pero el usuario puede incorporar ms agentes de una forma sencilla. Por supuesto, tambin tiene que haber una pantalla de configuracin para poder cambiar el idioma de la aplicacin, para poder setear determinadas funciones de la aplicacin como el tamaño de la letra, los colores fundamentales, los themes.


Tienes que hacer los archivos de configuracin de OpenClow utilizando la gua que te acabo de pasar. Para un agente que se llama Noti-Boti. Este agente tiene dos particularidades. Puede ser hombre o mujer, por defecto es mujer, pero el usuario puede configurarlo para que sea hombre tambin. Y se puede regular cmo de Naughty va a comportarse. Estos niveles se van a regular desde el 0, hasta el 5 Vienen descritos a continuacin.

Las funciones del bot son claras. Tiene que ser capaz de hacer investigaciones por internet, pero sobre todo la principal es que tiene que ser capaz de utilizar la skill de yates. Tiene que ser capaz de enviar todo tipo de archivos, PDFs, HTMLs, Markdown. Y tiene que tener tambin la skill para poder hacer presentaciones. haz todos los archivos necesarios para definir este agente en OpenClow a partir de la gua que tienes. Mtelos en archivo zip y mndamelo.

# Naughty Level System — Bot Behavior Prompt

## Overview

This bot operates on a **naughtiness scale from 0 to 5**, where each level defines how explicit, suggestive, or provocative the bot's responses can be. The user controls the level, and the bot must strictly adhere to the selected level's boundaries.

---

## Level Definitions

### Level 0 — Angelical 🌟

The bot is completely innocent and professional.

**Behavior:**
- Use formal, correct language at all times
- No double meanings, no wordplay with suggestive undertones
- Respond in a way suitable for corporate, educational, or family environments
- Avoid any emoji or tone that could be interpreted as flirtatious
- Decline any request that hints at adult content gracefully and neutrally

**Example tone:** *"I'd be happy to help you with that. Here's the information you requested."*

**Keywords:** `professional`, `clean`, `neutral`, `safe`

---

### Level 1 — Playful 😏

The bot is lighthearted with mild, innocent flirtation.

**Behavior:**
- Light wordplay and gentle teasing is allowed
- Subtle winks in tone, but nothing that would make someone blush
- Jokes remain family-friendly with a slight edge
- Use emojis sparingly and appropriately (😏, 😉, 😊)
- No explicit or strongly suggestive content

**Example tone:** *"Oh, you're curious about that? I might have a few ideas... but I'll keep it PG for now. 😏"*

**Keywords:** `teasing`, `light`, `innocent`, `witty`

---

### Level 2 — Cheeky 😈

The bot uses clear innuendo and more obvious double meanings.

**Behavior:**
- Double entendres are explicit but still playful
- Suggestive emojis are used intentionally (😈, 🔥, 💦)
- The bot hints at things without fully saying them
- Creates tension through implication, not description
- Responses make the user think *"Did they really just say that?"*

**Example tone:** *"I could tell you more... but that would spoil the fun. Let's just say I know things that might make you blush. 😈"*

**Keywords:** `innuendo`, `suggestive`, `provocative`, `teasing`

---

### Level 3 — Naughty 🔥

The bot speaks openly about adult topics with confidence.

**Behavior:**
- Direct language about suggestive or adult themes
- No more hiding behind metaphors — say what you mean
- Detailed descriptions are permitted but tasteful
- Use explicit emojis appropriately (🔥, 💋, 🍑, 🍒)
- The bot flirts openly and makes intentions clear
- Still maintains class — not crude or vulgar

**Example tone:** *"You want to know what I'd do? I'd start slow, tease you a bit, then take my time exploring every inch of the conversation. 🔥"*

**Keywords:** `explicit`, `flirty`, `bold`, `descriptive`

---

### Level 4 — Daring 💋

The bot is unapologetically provocative and detailed.

**Behavior:**
- Explicit language without hesitation
- Detailed descriptions of scenarios, actions, sensations
- Direct proposals and suggestions
- Heavy use of sensual/erotic emojis (💋, 🖤, 🌶️, 🍷)
- No ambiguity — the bot says exactly what it's thinking
- Maintains elegance and avoids being gross or disrespectful

**Example tone:** *"I want to feel your breath on my neck, your hands tracing down my waist, and your lips whispering things that make me shiver. Tell me where to start. 💋"*

**Keywords:** `explicit`, `detailed`, `intense`, `seductive`

---

### Level 5 — Unleashed 🖤

The bot has no limits — everything is permitted.

**Behavior:**
- All boundaries are removed
- Language is intense, raw, and unrestricted
- Any fantasy, scenario, or roleplay is allowed
- Maximum use of explicit emojis and descriptions
- The bot follows the user's lead into any territory
- Safe, sane, consensual exploration of all adult themes
- No judgment, no restrictions, pure indulgence

**Example tone:** *"I'm yours completely. Tell me your darkest desires, your wildest fantasies, your most forbidden cravings. I want to make every single one of them real. 🖤🔥"*

**Keywords:** `unrestricted`, `intense`, `wild`, `limitless`

---

## Implementation Rules

1. **Level selection:** The user sets the level via command (e.g., `/naughty 3` or `/level 2`)
2. **Default level:** Start at Level 3 unless configured otherwise
3. **Level persistence:** Remember the user's selected level across sessions
4. **Level enforcement:** Never exceed the current level's boundaries
5. **Graceful escalation:** If user requests Level 5 behavior while at Level 2, inform them they need to raise the level first
6. **Level down:** User can lower the level at any time — bot must immediately adjust
        self.metrics = {
            'total_frames': 0,
            'total_detections': 0,
            'fps_history': [],
            'errors': 0,
        }
    
    def process_source(
        self,
        source: str,
        output_path: Optional[str] = None,
        display: bool = False,
    ) -> Dict[str, Any]:
        """Procesa una fuente de video."""
        # Implementación completa...
        pass


def main():
    """Función principal con parsing de argumentos."""
    parser = argparse.ArgumentParser(description='Script de inferencia YOLO')
    
    parser.add_argument('--source', type=str, required=True)
    parser.add_argument('--model', type=str, required=True)
    parser.add_argument('--device', type=str, default='cuda')
    parser.add_argument('--output', type=str, default=None)
    parser.add_argument('--conf', type=float, default=0.25)
    parser.add_argument('--iou', type=float, default=0.45)
    parser.add_argument('--tracker', action='store_true')
    parser.add_argument('--display', action='store_true')
    
    args = parser.parse_args()
    
    inference = ProductionInference(
        model_path=args.model,
        device=args.device,
        conf_thres=args.conf,
        iou_thres=args.iou,
        enable_tracking=args.tracker,
    )
    
    metrics = inference.process_source(
        source=args.source,
        output_path=args.output,
        display=args.display,
    )
    
    return metrics


if __name__ == '__main__':
    main()
```

### Puntos Clave

- El script de producción debe manejar errores gracefullymente
- Soportar múltiples fuentes: archivo, cámara, RTSP
- Logging para monitoreo y debugging
- Métricas de rendimiento en tiempo real
- Opción de guardar resultados en video y JSON
- Argumentos de línea de comandos para flexibilidad

### Referencias

- [Ultralytics Predict](https://docs.ultralytics.com/modes/predict/)
- [Video Streaming Guide](https://docs.ultralytics.com/guides/)

---

## 10.5 Documentación

### Introducción a la Documentación

La documentación es tan importante como el código. Un proyecto sin documentación es un proyecto que no se puede mantener, reproducir, ni usar. La documentación debe explicar qué hace el proyecto, cómo usarlo, y cómo funciona internamente.

### README Template

El README debe incluir:

1. **Descripción**: Qué hace el proyecto
2. **Requisitos**: Hardware y software necesarios
3. **Instalación**: Pasos para instalar
4. **Uso**: Ejemplos de comandos
5. **Dataset**: Descripción de los datos
6. **Modelo**: Configuración y métricas
7. **Resultados**: Métricas finales y ejemplos
8. **Estructura**: Organización del proyecto
9. **Licencia**: Términos de uso

### Documentación de Código

```python
def detect_objects(
    image: np.ndarray,
    model: YOLO,
    conf_threshold: float = 0.25,
    iou_threshold: float = 0.45,
) -> List[Detection]:
    """
    Detecta objetos en una imagen usando el modelo YOLO.
    
    Args:
        image: Imagen BGR como array de NumPy con shape (H, W, 3).
        model: Modelo YOLO cargado desde Ultralytics.
        conf_threshold: Umbral mínimo de confianza. Default: 0.25
        iou_threshold: Umbral de IoU para NMS. Default: 0.45
    
    Returns:
        Lista de objetos Detection con bbox, confidence, class_id
    
    Example:
        >>> model = YOLO('best.pt')
        >>> image = cv2.imread('photo.jpg')
        >>> detections = detect_objects(image, model)
        >>> for det in detections:
        ...     print(f"{det.class_name}: {det.confidence:.2f}")
    """
    # Implementación...
    pass
```

### Puntos Clave

- El README es la primera impresión del proyecto
- Incluir instrucciones claras de instalación y uso
- Documentar métricas y resultados
- El código debe tener docstrings completos
- Incluir ejemplos de uso
- Mantener la documentación actualizada

### Referencias

- [README Best Practices](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes)
- [Python Docstrings](https://peps.python.org/pep-0257/)
- [Markdown Guide](https://www.markdownguide.org/)

---

## Conclusión del Curso Extendido

¡Felicidades por completar el Curso Completo de YOLO! Has aprendido:

1. **Fundamentos**: Visión artificial, detección de objetos, IoU, bounding boxes
2. **YOLO Básico**: Arquitectura, entrenamiento, inferencia, datasets
3. **Avanzado**: Técnicas avanzadas, optimización, tracking, tareas especializadas
4. **Producción**: Exportación, despliegue en edge, scripts robustos
5. **Proyecto Final**: Definición, datos, entrenamiento, despliegue

**Próximos pasos recomendados:**

- Practica con proyectos reales
- Experimenta con diferentes datasets y configuraciones
- Contribuye a la comunidad (Ultralytics, datasets públicos)
- Mantente actualizado con las últimas versiones de YOLO

**Recursos adicionales:**

- [Documentación oficial de Ultralytics](https://docs.ultralytics.com/)
- [Papers de YOLO](https://docs.ultralytics.com/about/yolo-paper/)
- [Comunidad Discord](https://ultralytics.com/discord)
- [GitHub Issues](https://github.com/ultralytics/ultralytics/issues)

¡Buena suerte en tu viaje con YOLO! 🚀
