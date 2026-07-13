import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo de animaciones explícitas en Flutter.
///
/// Demuestra AnimationController, RotationTransition, Tween
/// y CurvedAnimation con diferentes curvas.
class ExplicitAnimationExample extends StatefulWidget {
  const ExplicitAnimationExample({super.key});

  @override
  State<ExplicitAnimationExample> createState() =>
      _ExplicitAnimationExampleState();
}

class _ExplicitAnimationExampleState extends State<ExplicitAnimationExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<Offset> _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _rotation = Tween<double>(begin: 0, end: 2 * 3.1416).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _position = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _play() => _controller.forward();
  void _reverse() => _controller.reverse();
  void _reset() => _controller.reset();

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Animaciones Explícitas',
      description:
          'Las animaciones explícitas te dan control total mediante '
          'un AnimationController. Puedes reproducir, invertir y detener '
          'la animación en cualquier momento.',
      code: '''
// 1. Crear el controller en un StatefulWidget
class _MyState extends State<MyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// 2. Definir una animación con Tween
final rotation = Tween<double>(
  begin: 0,
  end: 2 * pi,
).animate(_controller);

// 3. Aplicar una curva
final curved = CurvedAnimation(
  parent: _controller,
  curve: Curves.easeInOut,
);

// 4. Usar RotationTransition
RotationTransition(
  turns: curved,
  child: Container(width: 80, height: 80, color: Colors.blue),
)

// 5. Controlar la animación
_controller.forward();   // reproducir
_controller.reverse();   // invertir
_controller.reset();     // reiniciar
''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // RotationTransition
          Container(
            alignment: Alignment.center,
            height: 120,
            child: RotationTransition(
              turns: _rotation,
              child: Container(
                width: 80,
                height: 80,
                color: Colors.blue,
                alignment: Alignment.center,
                child: const Text(
                  'Girar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tween position
          Container(
            alignment: Alignment.center,
            height: 80,
            child: SlideTransition(
              position: _position,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Curves demo
          _buildCurveDemo('easeIn', Curves.easeIn),
          _buildCurveDemo('easeOut', Curves.easeOut),
          _buildCurveDemo('easeInOut', Curves.easeInOut),
          _buildCurveDemo('bounceIn', Curves.bounceIn),
          _buildCurveDemo('elasticIn', Curves.elasticIn),
          const SizedBox(height: 16),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _play,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Reproducir'),
              ),
              ElevatedButton.icon(
                onPressed: _reverse,
                icon: const Icon(Icons.replay),
                label: const Text('Invertir'),
              ),
              ElevatedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.stop),
                label: const Text('Reiniciar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurveDemo(String name, Curve curve) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(name, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 1),
              curve: curve,
              builder: (context, value, child) {
                return LinearProgressIndicator(value: value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
