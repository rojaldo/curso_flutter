import 'package:flutter/material.dart';
import 'package:mi_app/model/tetris/piece_behavior.dart';

enum TetrisPieceType { i, o, t, s, z, j, l }

class CellOffset {
  const CellOffset(this.x, this.y);

  final int x;
  final int y;

  @override
  bool operator ==(Object other) {
    return other is CellOffset && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}

class TetrisPiece {
  const TetrisPiece({
    required this.type,
    required this.behavior,
    required this.color,
    this.rotation = 0,
  });

  final TetrisPieceType type;
  final PieceBehavior behavior;
  final Color color;
  final int rotation;

  List<CellOffset> get cells => behavior.cellsForRotation(rotation);

  TetrisPiece rotate() {
    return TetrisPiece(
      type: type,
      behavior: behavior,
      color: color,
      rotation: (rotation + 1) % 4,
    );
  }
}
