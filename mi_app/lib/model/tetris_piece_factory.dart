enum TetrisPieceType { O, I, T, S, Z, J, L }


// interface tetris piece
class TetrisPiece {
  //rotate function
  void rotate() {
    // Implement rotation logic here
  }

  TetrisPiece();
}

// Class O piece
class OPiece extends TetrisPiece {
  final List<List<int>> _shape = [
    [0,0,0,0,0],
    [0,1,1,0,0],
    [0,1,1,0,0],
    [0,0,0,0,0],
    [0,0,0,0,0],
  ];
  @override
  void rotate() {
    // O piece does not rotate
  }

  List<List<int>> get shape => _shape;
}

// Class I piece
class IPiece extends TetrisPiece {
  List<List<int>> _shape = [
    [0,0,0,0,0],
    [0,0,0,0,0],
    [1,1,1,1,0],
    [0,0,0,0,0],
    [0,0,0,0,0],
  ];
  int rotationState = 0; // 0: horizontal, 1: vertical
  @override
  void rotate() {
    rotationState = (rotationState + 1) % 2;
    if (rotationState == 0) {
      // Rotate to vertical
      _shape = [
        [0,0,1,0,0],
        [0,0,1,0,0],
        [0,0,1,0,0],
        [0,0,1,0,0],
        [0,0,0,0,0],
      ];
      rotationState = 1;
    } else {
      // Rotate to horizontal
      _shape = [
        [0,0,0,0,0],
        [0,0,0,0,0],
        [1,1,1,1,0],
        [0,0,0,0,0],
        [0,0,0,0,0],
      ];
      rotationState = 0;
    }
  }

  List<List<int>> get shape => _shape;
}

// Class T piece
class TPiece extends TetrisPiece {
  List<List<int>> _shape = [
    [0,0,0,0,0],
    [0,1,1,1,0],
    [0,0,1,0,0],
    [0,0,0,0,0],
    [0,0,0,0,0],
  ];
  int rotationState = 0; // 0: up, 1: right, 2: down, 3: left
  @override
  void rotate() {
    rotationState = (rotationState + 1) % 4;
    switch (rotationState) {
      case 0:
        _shape = [
          [0,0,0,0,0],
          [0,0,0,1,0],
          [0,0,1,1,0],
          [0,0,0,1,0],
          [0,0,0,0,0],
        ];
        break;
      case 1:
        _shape = [
          [0,0,0,0,0],
          [0,0,0,0,0],  
          [0,0,1,0,0],
          [0,1,1,1,0],
          [0,0,0,0,0],
        ];
        break;
      case 2:
        _shape = [  
          [0,0,0,0,0],
          [0,1,0,0,0],
          [0,1,1,0,0],
          [0,1,0,0,0],
          [0,0,0,0,0],
        ];
        break;
      case 3:
        _shape = [
          [0,0,0,0,0],
          [0,1,1,1,0],
          [0,0,1,0,0],
          [0,0,0,0,0],
          [0,0,0,0,0],
        ];
        break;
        default:
        break;
    }
  }

  List<List<int>> get shape => _shape;
}


TetrisPiece tetrisFactory(TetrisPieceType type) {
  switch (type) {
    case TetrisPieceType.O:
      return OPiece();
    case TetrisPieceType.I:
      return IPiece();
    case TetrisPieceType.T:
      return TPiece();
    default:
      throw Exception('Invalid Tetris piece type');
  }
}