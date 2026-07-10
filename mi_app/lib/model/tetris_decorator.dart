class TetrisPiece {
  final List<List<int>> shape;

  TetrisPiece(this.shape);
}

class RotateDecorator {
  final TetrisPiece _piece;

  RotateDecorator(this._piece);

  //calculate rotation
  void rotate() {
    final n = _piece.shape.length;
    final rotated = List.generate(n, (_) => List<int>.filled(n, 0));
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        rotated[j][n - i - 1] = _piece.shape[i][j];
      }
    }
    _piece.shape.clear();
    _piece.shape.addAll(rotated);
  }
}
