import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

class StackExample extends StatefulWidget {
  const StackExample({super.key});

  @override
  State<StackExample> createState() => _StackExampleState();
}

class _StackExampleState extends State<StackExample> {
  double _top = 20;
  double _left = 20;
  int _notifications = 3;

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Stack & Positioned',
      description:
          'Stack superpone widgets unos sobre otros. Usa Positioned '
          'para colocar elementos en coordenadas exactas. Ideal para badges, '
          'overlays y diseños en capas.',
      code: '''Stack(
  children: [
    Container(width: 200, height: 200, color: Colors.blue),
    Positioned(
      top: 20,
      left: 20,
      child: Container(width: 80, height: 80, color: Colors.red),
    ),
    Positioned(
      bottom: 10,
      right: 10,
      child: Icon(Icons.favorite, color: Colors.white),
    ),
  ],
)''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Interactive positioned demo
          Container(
            color: Colors.grey.shade200,
            height: 220,
            child: Stack(
              children: [
                Container(
                  color: Colors.blue,
                  width: double.infinity,
                  height: double.infinity,
                  child: const Center(
                    child: Text(
                      'Fondo',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
                Positioned(
                  top: _top,
                  left: _left,
                  child: Container(
                    width: 80,
                    height: 80,
                    color: Colors.red,
                    child: const Center(
                      child: Text(
                        'Caja',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 10,
                  right: 10,
                  child: Icon(Icons.star, color: Colors.yellow, size: 40),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildSlider('Top', _top, 0, 140,
              (v) => setState(() => _top = v)),
          _buildSlider('Left', _left, 0, 260,
              (v) => setState(() => _left = v)),
          const Divider(height: 24),
          // Badge overlay demo
          Text('Badge sobre icono',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.notifications, size: 48),
                  if (_notifications > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: () => setState(() => _notifications--),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            '$_notifications',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => setState(() => _notifications = 5),
                child: const Text('Restablecer badge'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Toca el badge rojo para disminuir la cuenta.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 50, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            label: value.toStringAsFixed(0),
            onChanged: onChanged,
          ),
        ),
        SizedBox(width: 40, child: Text(value.toStringAsFixed(0))),
      ],
    );
  }
}
