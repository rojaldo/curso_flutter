import 'package:flutter/material.dart';

class KeyboardWidget extends StatelessWidget {
  final ValueChanged<String> onButtonPressed;

  const KeyboardWidget({super.key, required this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const rows = 4;
        const columns = 4;
        const gap = 8.0;

        final buttonSize =
            ((constraints.maxWidth - gap * (columns - 1)) / columns)
                .clamp(0.0, double.infinity);
        final rowSize =
            ((constraints.maxHeight - gap * (rows - 1)) / rows)
                .clamp(0.0, double.infinity);
        final circleSize = buttonSize < rowSize ? buttonSize : rowSize;

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton('7', circleSize),
                _buildButton('8', circleSize),
                _buildButton('9', circleSize),
                _buildButton('/', circleSize),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton('4', circleSize),
                _buildButton('5', circleSize),
                _buildButton('6', circleSize),
                _buildButton('*', circleSize),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton('1', circleSize),
                _buildButton('2', circleSize),
                _buildButton('3', circleSize),
                _buildButton('-', circleSize),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton('AC', circleSize),
                _buildButton('0', circleSize),
                _buildButton('=', circleSize),
                _buildButton('+', circleSize),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildButton(String value, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        onPressed: () => onButtonPressed(value),
        child: Text(value),
      ),
    );
  }
}