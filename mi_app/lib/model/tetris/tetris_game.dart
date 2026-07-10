import 'dart:math';

import 'package:mi_app/model/tetris/next_piece_iterator.dart';
import 'package:mi_app/model/tetris/pile.dart';
import 'package:mi_app/model/tetris/pile_builder.dart';
import 'package:mi_app/model/tetris/pile_event.dart';
import 'package:mi_app/model/tetris/score.dart';
import 'package:mi_app/model/tetris/tetris_piece.dart';
import 'package:mi_app/model/tetris/tetris_piece_factory.dart';

class TetrisGame {
  TetrisGame({Random? random}) : _random = random ?? Random() {
    restart();
  }

  static const int boardWidth = 10;
  static const int boardHeight = 20;

  final Random _random;
  final TetrisPieceFactory _factory = TetrisPieceFactory();
  final PileBuilder _pileBuilder = PileBuilder();

  late NextPieceIterator _iterator;
  late TetrisPiece currentPiece;
  late TetrisPiece nextPiece;
  late BoardPosition currentPosition;
  late Pile pile;
  final Score score = Score();
  bool isGameOver = false;

  void moveLeft() => _move(-1, 0);

  void moveRight() => _move(1, 0);

  void softDrop() => tick();

  void rotate() {
    if (isGameOver) {
      return;
    }
    final rotated = currentPiece.rotate();
    if (_isValid(rotated, currentPosition)) {
      currentPiece = rotated;
    }
  }

  void tick() {
    if (isGameOver) {
      return;
    }
    final nextPosition = currentPosition.translate(0, 1);
    if (_isValid(currentPiece, nextPosition)) {
      currentPosition = nextPosition;
      return;
    }
    _lockCurrentPiece();
  }

  void restart() {
    _iterator = NextPieceIterator(factory: _factory, random: _random);
    pile = const Pile(width: boardWidth, height: boardHeight);
    score.reset();
    isGameOver = false;
    currentPiece = _iterator.next();
    nextPiece = _iterator.peek();
    currentPosition = _spawnPosition(currentPiece);
  }

  List<BoardCell> get currentCells {
    return [
      for (final offset in currentPiece.cells)
        BoardCell(
          x: currentPosition.x + offset.x,
          y: currentPosition.y + offset.y,
          type: currentPiece.type,
        ),
    ];
  }

  void _move(int dx, int dy) {
    if (isGameOver) {
      return;
    }
    final nextPosition = currentPosition.translate(dx, dy);
    if (_isValid(currentPiece, nextPosition)) {
      currentPosition = nextPosition;
    }
  }

  void _lockCurrentPiece() {
    final result = _pileBuilder.lockPiece(
      pile: pile,
      piece: currentPiece,
      position: currentPosition,
    );
    pile = result.pile;
    for (final event in result.events) {
      score.onPileEvent(event);
      _iterator.onPileEvent(event);
    }
    if (result.events.any((event) => event is PieceLocked)) {
      currentPiece = nextPiece;
      nextPiece = _iterator.peek();
      currentPosition = _spawnPosition(currentPiece);
      isGameOver = !_isValid(currentPiece, currentPosition);
    }
  }

  BoardPosition _spawnPosition(TetrisPiece piece) {
    final maxX = piece.cells.map((cell) => cell.x).reduce(max);
    return BoardPosition(((boardWidth - maxX - 1) / 2).floor(), 0);
  }

  bool _isValid(TetrisPiece piece, BoardPosition position) {
    for (final offset in piece.cells) {
      final x = position.x + offset.x;
      final y = position.y + offset.y;
      if (x < 0 || x >= boardWidth || y < 0 || y >= boardHeight) {
        return false;
      }
      if (pile.contains(x, y)) {
        return false;
      }
    }
    return true;
  }
}
