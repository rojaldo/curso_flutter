import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/model/tetris/tetris_piece_factory.dart';
import 'package:mi_app/model/tetris/tetris_piece.dart';

void main() {
  group('TetrisPieceFactory', () {
    test('creates the seven Tetris piece types', () {
      final factory = TetrisPieceFactory();

      for (final type in TetrisPieceType.values) {
        final piece = factory.create(type);

        expect(piece.type, type);
        expect(piece.cells, hasLength(4));
        expect(piece.color, isA<Color>());
      }
    });

    test('rotates pieces through their behavior bridge', () {
      final piece = TetrisPieceFactory().create(TetrisPieceType.t);

      final rotated = piece.rotate();

      expect(rotated.type, TetrisPieceType.t);
      expect(rotated.rotation, 1);
      expect(rotated.cells, isNot(equals(piece.cells)));
    });

    test('keeps O piece stable when rotating', () {
      final piece = TetrisPieceFactory().create(TetrisPieceType.o);

      final rotated = piece.rotate();

      expect(rotated.cells, equals(piece.cells));
    });
  });
}
