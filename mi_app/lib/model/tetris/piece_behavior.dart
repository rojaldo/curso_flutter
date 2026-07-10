import 'package:mi_app/model/tetris/tetris_piece.dart';

abstract class PieceBehavior {
  const PieceBehavior();

  List<CellOffset> cellsForRotation(int rotation);
}

class MatrixPieceBehavior extends PieceBehavior {
  const MatrixPieceBehavior(this.rotations);

  final List<List<CellOffset>> rotations;

  @override
  List<CellOffset> cellsForRotation(int rotation) {
    return rotations[rotation % rotations.length];
  }
}
