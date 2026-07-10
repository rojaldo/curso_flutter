import 'dart:math';

import 'package:mi_app/model/tetris/pile_event.dart';
import 'package:mi_app/model/tetris/tetris_piece.dart';
import 'package:mi_app/model/tetris/tetris_piece_factory.dart';

class NextPieceIterator implements PileObserver {
  NextPieceIterator({required this.factory, Random? random})
    : _random = random ?? Random() {
    _regenerateBag();
  }

  final TetrisPieceFactory factory;
  final Random _random;
  final List<TetrisPieceType> _bag = [];
  int _index = 0;

  TetrisPiece next() {
    if (_index >= _bag.length) {
      _regenerateBag();
    }
    return factory.create(_bag[_index++]);
  }

  TetrisPiece peek() {
    if (_index >= _bag.length) {
      _regenerateBag();
    }
    return factory.create(_bag[_index]);
  }

  @override
  void onPileEvent(PileEvent event) {
    if (event is PieceLocked) {
      next();
    }
  }

  void _regenerateBag() {
    _bag
      ..clear()
      ..addAll([
        for (final type in TetrisPieceType.values)
          for (var i = 0; i < 20; i++) type,
      ]);
    _bag.shuffle(_random);
    _index = 0;
  }
}
