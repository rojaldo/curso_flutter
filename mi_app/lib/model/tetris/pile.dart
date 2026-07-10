import 'package:mi_app/model/tetris/tetris_piece.dart';

class BoardPosition {
  const BoardPosition(this.x, this.y);

  final int x;
  final int y;

  BoardPosition translate(int dx, int dy) => BoardPosition(x + dx, y + dy);
}

class BoardCell {
  const BoardCell({required this.x, required this.y, required this.type});

  final int x;
  final int y;
  final TetrisPieceType type;

  @override
  bool operator ==(Object other) {
    return other is BoardCell &&
        other.x == x &&
        other.y == y &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(x, y, type);
}

class Pile {
  const Pile({
    required this.width,
    required this.height,
    this.cells = const [],
  });

  final int width;
  final int height;
  final List<BoardCell> cells;

  bool contains(int x, int y) {
    return cells.any((cell) => cell.x == x && cell.y == y);
  }
}
