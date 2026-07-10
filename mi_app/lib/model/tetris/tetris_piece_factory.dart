import 'package:flutter/material.dart';
import 'package:mi_app/model/tetris/piece_behavior.dart';
import 'package:mi_app/model/tetris/tetris_piece.dart';

class TetrisPieceFactory {
  TetrisPiece create(TetrisPieceType type) {
    return TetrisPiece(
      type: type,
      behavior: _behavior(type),
      color: _color(type),
    );
  }

  PieceBehavior _behavior(TetrisPieceType type) {
    return switch (type) {
      TetrisPieceType.i => const MatrixPieceBehavior([
        [
          CellOffset(0, 1),
          CellOffset(1, 1),
          CellOffset(2, 1),
          CellOffset(3, 1),
        ],
        [
          CellOffset(2, 0),
          CellOffset(2, 1),
          CellOffset(2, 2),
          CellOffset(2, 3),
        ],
        [
          CellOffset(0, 2),
          CellOffset(1, 2),
          CellOffset(2, 2),
          CellOffset(3, 2),
        ],
        [
          CellOffset(1, 0),
          CellOffset(1, 1),
          CellOffset(1, 2),
          CellOffset(1, 3),
        ],
      ]),
      TetrisPieceType.o => const MatrixPieceBehavior([
        [
          CellOffset(0, 0),
          CellOffset(1, 0),
          CellOffset(0, 1),
          CellOffset(1, 1),
        ],
      ]),
      TetrisPieceType.t => const MatrixPieceBehavior([
        [
          CellOffset(1, 0),
          CellOffset(0, 1),
          CellOffset(1, 1),
          CellOffset(2, 1),
        ],
        [
          CellOffset(1, 0),
          CellOffset(1, 1),
          CellOffset(2, 1),
          CellOffset(1, 2),
        ],
        [
          CellOffset(0, 1),
          CellOffset(1, 1),
          CellOffset(2, 1),
          CellOffset(1, 2),
        ],
        [
          CellOffset(1, 0),
          CellOffset(0, 1),
          CellOffset(1, 1),
          CellOffset(1, 2),
        ],
      ]),
      TetrisPieceType.s => const MatrixPieceBehavior([
        [
          CellOffset(1, 0),
          CellOffset(2, 0),
          CellOffset(0, 1),
          CellOffset(1, 1),
        ],
        [
          CellOffset(1, 0),
          CellOffset(1, 1),
          CellOffset(2, 1),
          CellOffset(2, 2),
        ],
        [
          CellOffset(1, 1),
          CellOffset(2, 1),
          CellOffset(0, 2),
          CellOffset(1, 2),
        ],
        [
          CellOffset(0, 0),
          CellOffset(0, 1),
          CellOffset(1, 1),
          CellOffset(1, 2),
        ],
      ]),
      TetrisPieceType.z => const MatrixPieceBehavior([
        [
          CellOffset(0, 0),
          CellOffset(1, 0),
          CellOffset(1, 1),
          CellOffset(2, 1),
        ],
        [
          CellOffset(2, 0),
          CellOffset(1, 1),
          CellOffset(2, 1),
          CellOffset(1, 2),
        ],
        [
          CellOffset(0, 1),
          CellOffset(1, 1),
          CellOffset(1, 2),
          CellOffset(2, 2),
        ],
        [
          CellOffset(1, 0),
          CellOffset(0, 1),
          CellOffset(1, 1),
          CellOffset(0, 2),
        ],
      ]),
      TetrisPieceType.j => const MatrixPieceBehavior([
        [
          CellOffset(0, 0),
          CellOffset(0, 1),
          CellOffset(1, 1),
          CellOffset(2, 1),
        ],
        [
          CellOffset(1, 0),
          CellOffset(2, 0),
          CellOffset(1, 1),
          CellOffset(1, 2),
        ],
        [
          CellOffset(0, 1),
          CellOffset(1, 1),
          CellOffset(2, 1),
          CellOffset(2, 2),
        ],
        [
          CellOffset(1, 0),
          CellOffset(1, 1),
          CellOffset(0, 2),
          CellOffset(1, 2),
        ],
      ]),
      TetrisPieceType.l => const MatrixPieceBehavior([
        [
          CellOffset(2, 0),
          CellOffset(0, 1),
          CellOffset(1, 1),
          CellOffset(2, 1),
        ],
        [
          CellOffset(1, 0),
          CellOffset(1, 1),
          CellOffset(1, 2),
          CellOffset(2, 2),
        ],
        [
          CellOffset(0, 1),
          CellOffset(1, 1),
          CellOffset(2, 1),
          CellOffset(0, 2),
        ],
        [
          CellOffset(0, 0),
          CellOffset(1, 0),
          CellOffset(1, 1),
          CellOffset(1, 2),
        ],
      ]),
    };
  }

  Color _color(TetrisPieceType type) {
    return switch (type) {
      TetrisPieceType.i => Colors.cyan,
      TetrisPieceType.o => Colors.yellow,
      TetrisPieceType.t => Colors.purple,
      TetrisPieceType.s => Colors.green,
      TetrisPieceType.z => Colors.red,
      TetrisPieceType.j => Colors.blue,
      TetrisPieceType.l => Colors.orange,
    };
  }
}
