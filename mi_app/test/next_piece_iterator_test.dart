import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/model/tetris/next_piece_iterator.dart';
import 'package:mi_app/model/tetris/pile_event.dart';
import 'package:mi_app/model/tetris/tetris_piece.dart';
import 'package:mi_app/model/tetris/tetris_piece_factory.dart';

void main() {
  test('generates fair bags of 140 pieces with 20 of each type', () {
    final iterator = NextPieceIterator(
      factory: TetrisPieceFactory(),
      random: Random(1),
    );

    final counts = <TetrisPieceType, int>{};
    for (var i = 0; i < 140; i++) {
      final type = iterator.next().type;
      counts[type] = (counts[type] ?? 0) + 1;
    }

    for (final type in TetrisPieceType.values) {
      expect(counts[type], 20);
    }
  });

  test('regenerates another fair bag after the first bag is exhausted', () {
    final iterator = NextPieceIterator(
      factory: TetrisPieceFactory(),
      random: Random(2),
    );

    for (var i = 0; i < 140; i++) {
      iterator.next();
    }

    final counts = <TetrisPieceType, int>{};
    for (var i = 0; i < 140; i++) {
      final type = iterator.next().type;
      counts[type] = (counts[type] ?? 0) + 1;
    }

    for (final type in TetrisPieceType.values) {
      expect(counts[type], 20);
    }
  });

  test('advances when observing a pieceLocked event', () {
    final factory = _RecordingTetrisPieceFactory();
    final iterator = NextPieceIterator(factory: factory, random: Random(3));
    iterator.next();
    final callsBeforeEvent = factory.createCalls;

    iterator.onPileEvent(const PieceLocked());

    expect(factory.createCalls, callsBeforeEvent + 1);
  });
}

class _RecordingTetrisPieceFactory extends TetrisPieceFactory {
  int createCalls = 0;

  @override
  TetrisPiece create(TetrisPieceType type) {
    createCalls++;
    return super.create(type);
  }
}
