import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

class GestureExample extends StatefulWidget {
  const GestureExample({super.key});

  @override
  State<GestureExample> createState() => _GestureExampleState();
}

class _GestureExampleState extends State<GestureExample>
    with SingleTickerProviderStateMixin {
  Color _boxColor = Colors.blue;
  double _boxSize = 120;
  Offset _boxPosition = const Offset(0, 0);
  String _lastGesture = 'Ninguno';

  late AnimationController _rippleController;
  bool _showRipple = false;
  Offset _ripplePosition = Offset.zero;

  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _rippleController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showRipple = false;
        });
        _rippleController.reset();
      }
    });
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _changeColor() {
    setState(() {
      _boxColor = _colors[(_colors.indexOf(_boxColor) + 1) % _colors.length];
      _lastGesture = 'Tap';
    });
  }

  void _toggleSize() {
    setState(() {
      _boxSize = _boxSize == 120 ? 180 : 120;
      _lastGesture = 'Double tap';
    });
  }

  void _triggerRipple(LongPressStartDetails details) {
    setState(() {
      _lastGesture = 'Long press';
      _showRipple = true;
      _ripplePosition = details.localPosition;
    });
    _rippleController.forward(from: 0);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _lastGesture = 'Pan / drag';
      _boxPosition += details.delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Gestos',
      description:
          'Ejemplo interactivo de GestureDetector. '
          'Toca, pulsa dos veces, manten pulsado o arrastra la caja para ver las respuestas.',
      code: '''GestureDetector(
  onTap: () {
    setState(() => _color = Colors.red);
  },
  onDoubleTap: () {
    setState(() => _size = 200);
  },
  onLongPress: () {
    setState(() => _showRipple = true);
  },
  onPanUpdate: (details) {
    setState(() {
      _position += details.delta;
    });
  },
  child: Container(
    width: _size,
    height: _size,
    color: _color,
  ),
)''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ultimo gesto detectado:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            _lastGesture,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ripple effect
                if (_showRipple)
                  Positioned(
                    left: _ripplePosition.dx - 50,
                    top: _ripplePosition.dy - 50,
                    child: AnimatedBuilder(
                      animation: _rippleController,
                      builder: (context, child) {
                        return Container(
                          width: 100 + (_rippleController.value * 100),
                          height: 100 + (_rippleController.value * 100),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.yellow.withOpacity(
                              1 - _rippleController.value,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                // Gesture box
                Transform.translate(
                  offset: _boxPosition,
                  child: GestureDetector(
                    onTap: _changeColor,
                    onDoubleTap: _toggleSize,
                    onLongPressStart: _triggerRipple,
                    onPanUpdate: _onPanUpdate,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: _boxSize,
                      height: _boxSize,
                      decoration: BoxDecoration(
                        color: _boxColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.touch_app,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Instrucciones',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          const Text('- Toca: cambia el color'),
          const Text('- Doble tap: cambia el tamano'),
          const Text('- Pulsacion larga: muestra onda'),
          const Text('- Arrastra: mueve la caja'),
        ],
      ),
    );
  }
}
