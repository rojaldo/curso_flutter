import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Demuestra el árbol de widgets: Widget → Element → RenderObject.
///
/// Muestra visualmente cómo Flutter construye tres árboles paralelos
/// y cómo la clave de rendimiento es minimizar reconstrucciones.
class WidgetTreeExample extends StatelessWidget {
  const WidgetTreeExample({super.key});

  @override
  Widget build(BuildContext context) {
    const code = '''
// Flutter mantiene 3 árboles internos:

// 1. Widget Tree (inmutable, se recrea cada frame)
Container(color: Colors.blue, child: Text('Hola'))

// 2. Element Tree (gestor de estado, persiste)
// Cada Element guarda la referencia al Widget y al RenderObject
// Solo se actualiza cuando el Widget cambia

// 3. RenderObject Tree (dibuja pixels, persiste)
// Calcula layout, paint y hit testing
// Se actualiza solo cuando sus propiedades cambian

// Flujo de actualización:
// setState() → nuevo Widget → Element compara →
//   si mismo tipo → actualiza RenderObject
//   si distinto tipo → destruye y recrea Element + RenderObject

// const ayuda: si el Widget es idéntico, Flutter
// lo reutiliza sin siquiera comparar propiedades.
const Text('Hola');  // ←Nunca se reconstruye
Text('Hola');         // ←Se reconstruye cada vez
''';

    return ExampleScreen(
      title: 'Árbol de Widgets — Widget → Element → RenderObject',
      description: 'Flutter mantiene tres árboles internos: Widgets (descripciones '
          'inmutables), Elements (gestores de estado que persisten), y RenderObjects '
          '(que calculan layout y dibujan pixels). Toca cada nodo para ver su rol.',
      code: code,
      child: const _WidgetTreeDemo(),
    );
  }
}

class _WidgetTreeDemo extends StatefulWidget {
  const _WidgetTreeDemo();

  @override
  State<_WidgetTreeDemo> createState() => _WidgetTreeDemoState();
}

class _WidgetTreeDemoState extends State<_WidgetTreeDemo> {
  String? _selectedNode;
  int _rebuildCount = 0;

  @override
  Widget build(BuildContext context) {
    _rebuildCount++;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Reconstrucciones del árbol: $_rebuildCount',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        // Three trees side by side
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTreeColumn('Widget Tree', Colors.blue, [
              ('Container', _selectedNode == 'w-container', () => _selectNode('w-container', 'Widget: Container(color: blue, padding: 16)\nInmutable — se recrea cada frame')),
              ('Padding', _selectedNode == 'w-padding', () => _selectNode('w-padding', 'Widget: Padding(padding: 16)\nInmutable — describe espaciado')),
              ('Text', _selectedNode == 'w-text', () => _selectNode('w-text', 'Widget: Text("Hola Mundo")\nInmutable — describe contenido de texto')),
            ])),
            Expanded(child: _buildTreeColumn('Element Tree', Colors.orange, [
              ('ContainerElement', _selectedNode == 'e-container', () => _selectNode('e-container', 'Element: gestiona el Container\nPersiste entre frames\nCompara widget viejo vs nuevo')),
              ('PaddingElement', _selectedNode == 'e-padding', () => _selectNode('e-padding', 'Element: gestiona el Padding\nPersiste entre frames\nActualiza RenderPadding si cambia')),
              ('TextElement', _selectedNode == 'e-text', () => _selectNode('e-text', 'Element: gestiona el Text\nPersiste entre frames\nSolo reconstruye si el Widget cambia')),
            ])),
            Expanded(child: _buildTreeColumn('RenderObject Tree', Colors.green, [
              ('RenderDecoratedBox', _selectedNode == 'r-decorated', () => _selectNode('r-decorated', 'RenderObject: dibuja decoración\nCalcula tamaño y pinta pixels\nPersiste — solo se actualiza si cambian propiedades')),
              ('RenderPadding', _selectedNode == 'r-padding', () => _selectNode('r-padding', 'RenderObject: calcula layout con padding\nPerformLayout → asigna posición y tamaño\nPersiste entre frames')),
              ('RenderParagraph', _selectedNode == 'r-paragraph', () => _selectNode('r-paragraph', 'RenderObject: dibuja texto\nCalcula tamaño del texto\nPinta los glyphs en pantalla')),
            ])),
          ],
        ),
        const Divider(height: 24),
        // Info panel
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _selectedNode != null
              ? Text(_getNodeInfo(_selectedNode!), style: const TextStyle(fontSize: 13))
              : const Text('Toca un nodo del árbol para ver su descripción.',
                  style: TextStyle(color: Colors.grey)),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () {
            setState(() {});
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Reconstruir (setState)'),
        ),
        const SizedBox(height: 4),
        const Text(
          'Pulsa "Reconstruir" y observa que el contador aumenta.\n'
          'Los Widgets se recrean, pero Elements y RenderObjects\n'
          'se actualizan sin destruirse (si el tipo no cambia).',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  void _selectNode(String nodeId, String info) {
    setState(() => _selectedNode = nodeId);
  }

  String _getNodeInfo(String nodeId) {
    switch (nodeId) {
      case 'w-container':
        return '🟦 Widget: Container(color: blue, padding: 16)\n\n'
            '• Inmutable — se crea uno nuevo cada frame\n'
            '• Descripción de lo que debe aparecer\n'
            '• Barato de crear (sin lógica pesada)';
      case 'w-padding':
        return '🟦 Widget: Padding(padding: 16)\n\n'
            '• Inmutable — describe espaciado interno\n'
            '• Si las propiedades no cambian, Flutter puede\n'
            '  saltar la actualización con const';
      case 'w-text':
        return '🟦 Widget: Text("Hola Mundo")\n\n'
            '• Inmutable — describe el texto a mostrar\n'
            '• Si el texto no cambia, const evita reconstrucción';
      case 'e-container':
        return '🟧 Element: gestiona el Container\n\n'
            '• Persiste entre frames\n'
            '• Compara widget.anterior vs widget.nuevo\n'
            '• Si son iguales → no hace nada\n'
            '• Si cambian propiedades → actualiza RenderObject';
      case 'e-padding':
        return '🟧 Element: gestiona el Padding\n\n'
            '• Persiste entre frames\n'
            '• Si el padding cambia → marca RenderPadding\n'
            '  como needing layout';
      case 'e-text':
        return '🟧 Element: gestiona el Text\n\n'
            '• Persiste entre frames\n'
            '• Solo reconstruye si el Widget cambia\n'
            '• Mantiene la referencia al RenderParagraph';
      case 'r-decorated':
        return '🟩 RenderObject: RenderDecoratedBox\n\n'
            '• Calcula tamaño y dibuja decoración\n'
            '• Persiste — solo se actualiza si cambian propiedades\n'
            '• Realiza el paint() real en el Canvas';
      case 'r-padding':
        return '🟩 RenderObject: RenderPadding\n\n'
            '• PerformLayout: asigna posición y tamaño al hijo\n'
            '• Persiste entre frames\n'
            '• Solo recalcula layout si cambian constraints o padding';
      case 'r-paragraph':
        return '🟩 RenderObject: RenderParagraph\n\n'
            '• Calcula tamaño del texto (lineas, ancho)\n'
            '• Pinta los glyphs en pantalla\n'
            '• Persiste — solo repinta si el texto cambia';
      default:
        return '';
    }
  }

  Widget _buildTreeColumn(String title, Color color, List<(String, bool, VoidCallback)> nodes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
        ),
        const SizedBox(height: 4),
        ...nodes.map((node) {
          final (label, isSelected, onTap) = node;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.3) : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: isSelected ? Border.all(color: color) : null,
                ),
                child: Text(label, style: TextStyle(fontSize: 11, color: color)),
              ),
            ),
          );
        }),
      ],
    );
  }
}