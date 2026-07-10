import 'package:flutter/material.dart';
import 'package:mi_app/model/tetris/pile.dart';
import 'package:mi_app/model/tetris/tetris_piece_factory.dart';

class TetrisBoardPainter extends CustomPainter {
  TetrisBoardPainter({
    required this.width,
    required this.height,
    required this.cells,
  });

  final int width;
  final int height;
  final List<BoardCell> cells;

  final TetrisPieceFactory _factory = TetrisPieceFactory();

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / width;
    final boardHeight = cellSize * height;
    final background = Paint()..color = Colors.black87;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, boardHeight), background);

    final gridPaint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke;
    for (var x = 0; x <= width; x++) {
      canvas.drawLine(
        Offset(x * cellSize, 0),
        Offset(x * cellSize, boardHeight),
        gridPaint,
      );
    }
    for (var y = 0; y <= height; y++) {
      canvas.drawLine(
        Offset(0, y * cellSize),
        Offset(size.width, y * cellSize),
        gridPaint,
      );
    }

    for (final cell in cells) {
      final color = _factory.create(cell.type).color;
      final rect = Rect.fromLTWH(
        cell.x * cellSize + 1,
        cell.y * cellSize + 1,
        cellSize - 2,
        cellSize - 2,
      );
      canvas.drawRect(rect, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant TetrisBoardPainter oldDelegate) {
    return oldDelegate.cells != cells;
  }
}
