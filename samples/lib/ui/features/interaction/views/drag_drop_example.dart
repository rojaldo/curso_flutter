import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

class DragDropExample extends StatefulWidget {
  const DragDropExample({super.key});

  @override
  State<DragDropExample> createState() => _DragDropExampleState();
}

class _DragDropExampleState extends State<DragDropExample> {
  final List<String> _sourceItems = ['🔴 Rojo', '🔵 Azul', '🟢 Verde', '🟡 Amarillo'];
  final List<String> _targetItems = [];
  String? _hoveredTarget;

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Draggable y DragTarget',
      description:
          'Draggable permite arrastrar widgets. DragTarget recibe los elementos '
          'soltados y muestra feedback visual. Arrastra los colores de la zona '
          'izquierda a la zona derecha.',
      code: '''Draggable<String>(
  data: 'item',
  feedback: Material(
    child: Container(...),
  ),
  childWhenDragging: Opacity(opacity: 0.5, child: ...),
  child: Container(...),
)

DragTarget<String>(
  onWillAcceptWithDetails: (details) => true,
  onAcceptWithDetails: (details) {
    // Recibe el elemento
  },
  builder: (context, candidateData, rejectedData) {
    return Container(
      color: candidateData.isNotEmpty ? Colors.green.shade100 : Colors.grey.shade200,
      child: ...,
    );
  },
)''',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source zone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Origen',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: _sourceItems.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Draggable<String>(
                          data: item,
                          feedback: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          childWhenDragging: Opacity(
                            opacity: 0.3,
                            child: _buildDragItem(item),
                          ),
                          child: _buildDragItem(item),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Target zone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Destino',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DragTarget<String>(
                  onWillAcceptWithDetails: (details) => true,
                  onAcceptWithDetails: (details) {
                    setState(() {
                      _sourceItems.remove(details.data);
                      _targetItems.add(details.data);
                    });
                  },
                  onLeave: (_) {
                    setState(() => _hoveredTarget = null);
                  },
                  builder: (context, candidateData, rejectedData) {
                    final isHovering = candidateData.isNotEmpty;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isHovering
                            ? Colors.green.shade100
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isHovering
                              ? Colors.green.shade400
                              : Colors.blue.shade200,
                          width: isHovering ? 2 : 1,
                        ),
                      ),
                      child: _targetItems.isEmpty
                          ? const SizedBox(
                              height: 120,
                              child: Center(
                                child: Text(
                                  'Arrastra elementos aquí',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          : Column(
                              children: _targetItems.map((item) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: _buildDragItem(item),
                                );
                              }).toList(),
                            ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _sourceItems.addAll(_targetItems);
                      _targetItems.clear();
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Restablecer'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragItem(String item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(item, textAlign: TextAlign.center),
    );
  }
}
