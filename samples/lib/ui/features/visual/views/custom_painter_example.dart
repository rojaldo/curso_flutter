import 'dart:math' show pi, cos, sin;
import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de CustomPainter en Flutter.
///
/// Dibuja un gráfico de líneas, círculos, arcos, triángulo y estrella.
/// Es interactivo: toca el canvas para cambiar colores y datos.
class CustomPainterExample extends StatefulWidget {
  const CustomPainterExample({super.key});

  @override
  State<CustomPainterExample> createState() => _CustomPainterExampleState();
}

class _CustomPainterExampleState extends State<CustomPainterExample> {
  int _colorIndex = 0;
  int _dataSeed = 0;

  final List<Color> _lineColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];

  final List<Color> _fillColors = [
    Colors.blue.shade100,
    Colors.red.shade100,
    Colors.green.shade100,
    Colors.purple.shade100,
    Colors.orange.shade100,
  ];

  void _cycleColors() {
    setState(() {
      _colorIndex = (_colorIndex + 1) % _lineColors.length;
      _dataSeed++;
    });
  }

  List<double> _generateData() {
    final base = [20.0, 60.0, 40.0, 80.0, 50.0, 90.0, 30.0];
    return base.map((v) {
      final shift = (_dataSeed * 7) % 30;
      return ((v + shift) % 100).clamp(10.0, 95.0);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final data = _generateData();

    return ExampleScreen(
      title: 'CustomPainter',
      description:
          'CustomPainter te permite dibujar directamente sobre el canvas '
          'usando primitivas gráficas: líneas, círculos, arcos, paths y más. '
          'Ideal para gráficos, formas complejas y visualizaciones personalizadas.',
      code: '''class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Dibujar línea
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, 0),
      paint,
    );

    // Dibujar círculo
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      50,
      paint,
    );

    // Dibujar arco
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: 60,
      ),
      0, pi, false, paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

// Uso
CustomPaint(
  size: Size(200, 200),
  painter: MyPainter(),
)''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: _cycleColors,
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: CustomPaint(
                size: const Size(double.infinity, 280),
                painter: _DemoPainter(
                  lineColor: _lineColors[_colorIndex],
                  fillColor: _fillColors[_colorIndex],
                  data: data,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Toca el canvas para cambiar colores y datos',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              Chip(
                avatar: Icon(Icons.show_chart, size: 18, color: _lineColors[_colorIndex]),
                label: const Text('Gráfico de líneas'),
              ),
              Chip(
                avatar: Icon(Icons.circle_outlined, size: 18, color: _lineColors[_colorIndex]),
                label: const Text('Círculos y arcos'),
              ),
              Chip(
                avatar: Icon(Icons.star_border, size: 18, color: _lineColors[_colorIndex]),
                label: const Text('Triángulo y estrella'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DemoPainter extends CustomPainter {
  _DemoPainter({
    required this.lineColor,
    required this.fillColor,
    required this.data,
  });

  final Color lineColor;
  final Color fillColor;
  final List<double> data;

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Dividir el canvas en 3 secciones horizontales
    final sectionHeight = height / 3;

    // ---- Sección 1: Gráfico de líneas ----
    _drawLineChart(
      canvas,
      Rect.fromLTWH(0, 0, width, sectionHeight),
    );

    // ---- Sección 2: Círculos y arcos ----
    _drawCirclesAndArcs(
      canvas,
      Rect.fromLTWH(0, sectionHeight, width, sectionHeight),
    );

    // ---- Sección 3: Triángulo y estrella ----
    _drawShapes(
      canvas,
      Rect.fromLTWH(0, sectionHeight * 2, width, sectionHeight),
    );
  }

  void _drawLineChart(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = fillColor.withAlpha(150)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final padding = 16.0;
    final chartWidth = rect.width - padding * 2;
    final chartHeight = rect.height - padding * 2;
    final dx = chartWidth / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = rect.left + padding + i * dx;
      final y = rect.bottom - padding - (data[i] / 100) * chartHeight;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, rect.bottom - padding);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(
      rect.left + padding + (data.length - 1) * dx,
      rect.bottom - padding,
    );
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Puntos
    final pointPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = rect.left + padding + i * dx;
      final y = rect.bottom - padding - (data[i] / 100) * chartHeight;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }

    // Etiqueta
    _drawLabel(canvas, rect, 'Gráfico de líneas');
  }

  void _drawCirclesAndArcs(Canvas canvas, Rect rect) {
    final center = rect.center;

    // Círculo relleno
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx - 60, center.dy), 30, fillPaint);

    // Círculo con borde grueso
    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(center.dx - 60, center.dy), 30, strokePaint);

    // Arco (semicírculo)
    final arcRect = Rect.fromCircle(center: Offset(center.dx + 40, center.dy), radius: 35);
    canvas.drawArc(arcRect, pi, pi, false, strokePaint);

    // Arco pequeño relleno
    final smallArcPaint = Paint()
      ..color = lineColor.withAlpha(180)
      ..style = PaintingStyle.fill;
    final smallArcRect = Rect.fromCircle(center: Offset(center.dx + 100, center.dy), radius: 20);
    canvas.drawArc(smallArcRect, -pi / 2, pi, true, smallArcPaint);

    _drawLabel(canvas, rect, 'Círculos y arcos');
  }

  void _drawShapes(Canvas canvas, Rect rect) {
    final center = rect.center;

    // Triángulo
    final trianglePath = Path()
      ..moveTo(center.dx - 70, center.dy + 25)
      ..lineTo(center.dx - 40, center.dy - 25)
      ..lineTo(center.dx - 100, center.dy - 25)
      ..close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(trianglePath, fillPaint);

    final strokePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(trianglePath, strokePaint);

    // Estrella de 5 puntas
    final starPath = _createStarPath(Offset(center.dx + 50, center.dy), 30, 15);
    canvas.drawPath(starPath, fillPaint);
    canvas.drawPath(starPath, strokePaint);

    _drawLabel(canvas, rect, 'Triángulo y estrella');
  }

  Path _createStarPath(Offset center, double outerRadius, double innerRadius) {
    final path = Path();
    const points = 5;
    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * pi / points) - pi / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  void _drawLabel(Canvas canvas, Rect rect, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(rect.left + 8, rect.top + 4));
  }

  @override
  bool shouldRepaint(covariant _DemoPainter old) {
    return old.lineColor != lineColor ||
        old.fillColor != fillColor ||
        old.data != data;
  }
}
