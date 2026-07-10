class CompositeTetrisPiece{
  final List<List<int>> _shape;
  final rotationsList = <List<List<int>>>[];

  CompositeTetrisPiece(this._shape){
    _getRotations();

  }

  void _getRotations(){
    //rotate 3 times and add to the list of rotations
    var tempPiece = _shape;
    for (var i = 0; i < 4; i++){
      rotationsList.add(tempPiece);
      tempPiece = _rotateMatrix(tempPiece);
    }
  }
  List<List<int>> _rotateMatrix(List<List<int>> matrix) {
    final n = matrix.length;
    final rotated = List.generate(n, (_) => List<int>.filled(n, 0));
    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        rotated[j][n - i - 1] = matrix[i][j];
      }
    }
    return rotated;
  }

  void rotate() {
    //rotate the piece to the next rotation in the list
    final currentIndex = rotationsList.indexOf(_shape);
    final nextIndex = (currentIndex + 1) % rotationsList.length;
    _shape.clear();
    _shape.addAll(rotationsList[nextIndex]);
  }
}

class TetrisBuilder {

  TetrisBuilder() {
    // Initialize the builder
  }

  CompositeTetrisPiece buildPiece(List<List<int>> shape) {
    return CompositeTetrisPiece(shape);
  }

   
}

void main() {
  var builder = TetrisBuilder();
  var piece = builder.buildPiece([[0,0,0,0,0],
                                  [0,1,1,1,0],
                                  [0,1,1,1,0],
                                  [0,0,0,0,0],
                                  [0,0,0,0,0]]);
  print(piece.rotationsList);
}

