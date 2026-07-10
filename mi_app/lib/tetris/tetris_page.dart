import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mi_app/model/tetris/pile.dart';
import 'package:mi_app/model/tetris/tetris_game.dart';
import 'package:mi_app/model/tetris/tetris_piece.dart';
import 'package:mi_app/tetris/tetris_board_painter.dart';
import 'package:mi_app/tetris/tetris_controls.dart';

class TetrisPage extends StatefulWidget {
  const TetrisPage({super.key});

  @override
  State<TetrisPage> createState() => _TetrisPageState();
}

class _TetrisPageState extends State<TetrisPage> {
  late TetrisGame _game;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _game = TetrisGame();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      _run(_game.tick);
    });
  }

  void _run(VoidCallback command) {
    setState(command);
  }

  void _restart() {
    _run(_game.restart);
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final cells = <BoardCell>[..._game.pile.cells, ..._game.currentCells];

    return Scaffold(
      appBar: AppBar(title: const Text('Tetris')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Score: ${_game.score.points}'),
                  Text('Next: ${_pieceName(_game.nextPiece.type)}'),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: TetrisGame.boardWidth / TetrisGame.boardHeight,
                    child: GestureDetector(
                      onTap: () => _run(_game.rotate),
                      onHorizontalDragEnd: _handleHorizontalDrag,
                      onVerticalDragEnd: _handleVerticalDrag,
                      child: CustomPaint(
                        painter: TetrisBoardPainter(
                          width: TetrisGame.boardWidth,
                          height: TetrisGame.boardHeight,
                          cells: cells,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_game.isGameOver)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Game over',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              TetrisControls(
                onLeft: () => _run(_game.moveLeft),
                onRight: () => _run(_game.moveRight),
                onRotate: () => _run(_game.rotate),
                onDown: () => _run(_game.softDrop),
                onRestart: _restart,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleHorizontalDrag(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < 0) {
      _run(_game.moveLeft);
    } else if (velocity > 0) {
      _run(_game.moveRight);
    }
  }

  void _handleVerticalDrag(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity > 0) {
      _run(_game.softDrop);
    }
  }

  String _pieceName(TetrisPieceType type) => type.name.toUpperCase();
}
