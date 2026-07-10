import 'package:flutter/material.dart';

class TetrisControls extends StatelessWidget {
  const TetrisControls({
    super.key,
    required this.onLeft,
    required this.onRight,
    required this.onRotate,
    required this.onDown,
    required this.onRestart,
  });

  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onRotate;
  final VoidCallback onDown;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        IconButton.filled(
          onPressed: onLeft,
          icon: const Icon(Icons.arrow_left),
        ),
        IconButton.filled(
          onPressed: onRight,
          icon: const Icon(Icons.arrow_right),
        ),
        IconButton.filled(
          onPressed: onRotate,
          icon: const Icon(Icons.rotate_right),
        ),
        IconButton.filled(
          onPressed: onDown,
          icon: const Icon(Icons.arrow_downward),
        ),
        ElevatedButton(onPressed: onRestart, child: const Text('Restart')),
      ],
    );
  }
}
