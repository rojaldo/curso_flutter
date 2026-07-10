import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/model/tetris/tetris_game.dart';

void main() {
  test('starts with empty pile, score, current piece and next piece', () {
    final game = TetrisGame(random: Random(1));

    expect(game.pile.cells, isEmpty);
    expect(game.score.points, 0);
    expect(game.currentPiece, isNotNull);
    expect(game.nextPiece, isNotNull);
    expect(game.isGameOver, isFalse);
  });

  test('moves, rotates, soft drops and restarts', () {
    final game = TetrisGame(random: Random(1));
    final startX = game.currentPosition.x;
    final startY = game.currentPosition.y;
    final startRotation = game.currentPiece.rotation;

    game.moveLeft();
    expect(game.currentPosition.x, startX - 1);

    game.moveRight();
    expect(game.currentPosition.x, startX);

    game.rotate();
    expect(game.currentPiece.rotation, isNot(startRotation));

    game.softDrop();
    expect(game.currentPosition.y, startY + 1);

    game.restart();
    expect(game.pile.cells, isEmpty);
    expect(game.score.points, 0);
    expect(game.isGameOver, isFalse);
  });

  test('locks a piece when ticking into the pile bottom', () {
    final game = TetrisGame(random: Random(1));
    for (var i = 0; i < 25; i++) {
      game.tick();
    }

    expect(game.pile.cells, isNotEmpty);
    expect(game.currentPosition.y, 0);
  });
}
