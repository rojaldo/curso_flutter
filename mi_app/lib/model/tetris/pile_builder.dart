import 'package:mi_app/model/tetris/pile.dart';
import 'package:mi_app/model/tetris/pile_event.dart';
import 'package:mi_app/model/tetris/tetris_piece.dart';

class PileBuildResult {
  const PileBuildResult({required this.pile, required this.events});

  final Pile pile;
  final List<PileEvent> events;
}

class PileBuilder {
  PileBuildResult lockPiece({
    required Pile pile,
    required TetrisPiece piece,
    required BoardPosition position,
  }) {
    final merged = [
      ...pile.cells,
      for (final offset in piece.cells)
        BoardCell(
          x: position.x + offset.x,
          y: position.y + offset.y,
          type: piece.type,
        ),
    ];

    final fullRows = <int>[
      for (var y = 0; y < pile.height; y++)
        if (merged
                .where((cell) => cell.y == y)
                .map((cell) => cell.x)
                .toSet()
                .length ==
            pile.width)
          y,
    ];

    final cleared = _clearRows(merged, fullRows);
    final events = <PileEvent>[const PieceLocked()];
    if (fullRows.isNotEmpty) {
      events.add(LinesCleared(fullRows.length));
    }

    return PileBuildResult(
      pile: Pile(width: pile.width, height: pile.height, cells: cleared),
      events: events,
    );
  }

  List<BoardCell> _clearRows(List<BoardCell> cells, List<int> fullRows) {
    if (fullRows.isEmpty) {
      return cells;
    }

    return [
      for (final cell in cells)
        if (!fullRows.contains(cell.y))
          BoardCell(
            x: cell.x,
            y: cell.y + fullRows.where((row) => row > cell.y).length,
            type: cell.type,
          ),
    ];
  }
}
