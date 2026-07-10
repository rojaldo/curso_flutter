import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/model/tetris/pile.dart';
import 'package:mi_app/model/tetris/pile_builder.dart';
import 'package:mi_app/model/tetris/pile_event.dart';
import 'package:mi_app/model/tetris/tetris_piece.dart';
import 'package:mi_app/model/tetris/tetris_piece_factory.dart';

void main() {
  test('locks a piece into a new pile and emits pieceLocked', () {
    final piece = TetrisPieceFactory().create(TetrisPieceType.o);
    final result = PileBuilder().lockPiece(
      pile: const Pile(width: 10, height: 20),
      piece: piece,
      position: const BoardPosition(4, 18),
    );

    expect(result.pile.cells, hasLength(4));
    expect(result.events, contains(isA<PieceLocked>()));
  });

  test('clears completed lines and drops rows above', () {
    final existing = List.generate(
      8,
      (x) => BoardCell(x: x, y: 19, type: TetrisPieceType.i),
    )..add(const BoardCell(x: 0, y: 18, type: TetrisPieceType.t));

    final result = PileBuilder().lockPiece(
      pile: Pile(width: 10, height: 20, cells: existing),
      piece: TetrisPieceFactory().create(TetrisPieceType.o),
      position: const BoardPosition(8, 18),
    );

    expect(result.events.whereType<LinesCleared>().single.count, 1);
    expect(result.pile.cells.any((cell) => cell.y == 19), isTrue);
    expect(result.pile.cells, hasLength(3));
  });
}
