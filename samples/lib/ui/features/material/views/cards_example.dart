import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

class CardsExample extends StatelessWidget {
  const CardsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Cards y Elevación',
      description:
          'Card es un contenedor con esquinas redondeadas y sombra. '
          'La propiedad elevation controla la profundidad de la sombra. '
          'InkWell añade el efecto de onda al tocar dentro de una Card.',
      code: '''Card(
  elevation: 4,
  child: InkWell(
    onTap: () {},
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Text('Card con ripple'),
    ),
  ),
)

Card(
  elevation: 8,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  child: ...,
)''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Diferentes elevaciones',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [0, 2, 4, 8, 16].map((elevation) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    elevation: elevation.toDouble(),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: Center(
                        child: Text(
                          '$elevation',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ),
                  Text('elevation: $elevation',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Card con InkWell (tocar para ver el ripple)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 4,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.touch_app, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Toca aquí para ver el efecto de onda (ripple) de InkWell dentro de un Card.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Card con forma personalizada',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: Colors.deepPurple, width: 2),
            ),
            color: Colors.deepPurple.shade50,
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(Icons.style, color: Colors.deepPurple, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Este Card tiene borderRadius de 24, un borde morado y color de fondo personalizado.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
