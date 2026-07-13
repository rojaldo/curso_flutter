import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo de animaciones implícitas en Flutter.
///
/// Demuestra AnimatedContainer, AnimatedOpacity, AnimatedPadding
/// y AnimatedCrossFade. Cada animación se dispara con un botón.
class ImplicitAnimationExample extends StatefulWidget {
  const ImplicitAnimationExample({super.key});

  @override
  State<ImplicitAnimationExample> createState() =>
      _ImplicitAnimationExampleState();
}

class _ImplicitAnimationExampleState extends State<ImplicitAnimationExample> {
  bool _isExpanded = false;
  bool _isVisible = true;
  bool _isPadded = false;
  bool _showFirst = true;

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Animaciones Implícitas',
      description:
          'Las animaciones implícitas ocurren automáticamente cuando '
          'cambia una propiedad animable. No necesitas un AnimationController.',
      code: '''
// AnimatedContainer: cambia tamaño, color y forma
AnimatedContainer(
  duration: const Duration(milliseconds: 500),
  curve: Curves.easeInOut,
  width: _isExpanded ? 200 : 100,
  height: _isExpanded ? 200 : 100,
  decoration: BoxDecoration(
    color: _isExpanded ? Colors.blue : Colors.red,
    borderRadius: BorderRadius.circular(
      _isExpanded ? 20 : 50,
    ),
  ),
  child: const Center(child: Text('Container')),
)

// AnimatedOpacity: fundido in/out
AnimatedOpacity(
  duration: const Duration(milliseconds: 500),
  opacity: _isVisible ? 1.0 : 0.0,
  child: const Text('Hola'),
)

// AnimatedPadding: anima el relleno
AnimatedPadding(
  duration: const Duration(milliseconds: 500),
  padding: EdgeInsets.all(_isPadded ? 32 : 8),
  child: Container(color: Colors.green),
)

// AnimatedCrossFade: transición cruzada
AnimatedCrossFade(
  duration: const Duration(milliseconds: 500),
  firstChild: const Icon(Icons.favorite, size: 80),
  secondChild: const Icon(Icons.star, size: 80),
  crossFadeState: _showFirst
      ? CrossFadeState.showFirst
      : CrossFadeState.showSecond,
)
''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // AnimatedContainer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                width: _isExpanded ? 120 : 80,
                height: _isExpanded ? 120 : 80,
                decoration: BoxDecoration(
                  color: _isExpanded ? Colors.blue : Colors.red,
                  borderRadius: BorderRadius.circular(
                    _isExpanded ? 12 : 50,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Container',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                child: Text(_isExpanded ? 'Encoger' : 'Expandir'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // AnimatedOpacity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _isVisible ? 1.0 : 0.0,
                child: Container(
                  width: 100,
                  height: 50,
                  color: Colors.purple,
                  alignment: Alignment.center,
                  child: const Text(
                    'Opacidad',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _isVisible = !_isVisible),
                child: Text(_isVisible ? 'Ocultar' : 'Mostrar'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // AnimatedPadding
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                color: Colors.grey.shade300,
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(_isPadded ? 32 : 8),
                  child: Container(
                    width: 60,
                    height: 40,
                    color: Colors.green,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _isPadded = !_isPadded),
                child: Text(_isPadded ? 'Reducir padding' : 'Aumentar padding'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // AnimatedCrossFade
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 500),
                firstChild: const Icon(
                  Icons.favorite,
                  size: 80,
                  color: Colors.red,
                ),
                secondChild: const Icon(
                  Icons.star,
                  size: 80,
                  color: Colors.amber,
                ),
                crossFadeState: _showFirst
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
              ),
              ElevatedButton(
                onPressed: () => setState(() => _showFirst = !_showFirst),
                child: Text(_showFirst ? 'Mostrar estrella' : 'Mostrar corazón'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
