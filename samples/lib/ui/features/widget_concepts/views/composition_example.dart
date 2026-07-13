import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Demuestra el principio de composición: construir widgets complejos
/// a partir de widgets simples que hacen una sola cosa.
class CompositionExample extends StatelessWidget {
  const CompositionExample({super.key});

  @override
  Widget build(BuildContext context) {
    const code = '''
// Flutter NO tiene un "SuperButtonWithIconAndBadge".
// En su lugar, COMPNES widgets simples:

ElevatedButton(
  onPressed: () {},
  child: Row(                        // ← Layout
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.mail),              // ← Icono
      SizedBox(width: 8),            // ← Espaciado
      Text('Mensajes'),              // ← Texto
      Badge(                          // ← Badge
        label: Text('3'),
        child: SizedBox(),           // ← Hijo vacío (solo muestra badge)
      ),
    ],
  ),
)

// Cada widget hace UNA cosa:
// Row → organiza horizontalmente
// Icon → muestra un icono
// SizedBox → espacio fijo
// Text → muestra texto
// Badge → muestra un indicador
// ElevatedButton → maneja toque y estilo de botón
''';

    return ExampleScreen(
      title: 'Composición — Widgets que hacen una cosa',
      description: 'En Flutter no hay "super-widgets". Cada widget hace una sola cosa '
          'y se combinan por composición. Toca cada botón para ver qué widgets '
          'lo componen.',
      code: code,
      child: const _CompositionDemo(),
    );
  }
}

class _CompositionDemo extends StatefulWidget {
  const _CompositionDemo();

  @override
  State<_CompositionDemo> createState() => _CompositionDemoState();
}

class _CompositionDemoState extends State<_CompositionDemo> {
  String? _selectedExample;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Ejemplos interactivos
        _ExampleCard(
          title: 'Botón con icono y badge',
          isSelected: _selectedExample == 'button',
          onTap: () => setState(() => _selectedExample = 'button'),
          child: ElevatedButton(
            onPressed: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mail, size: 18),
                const SizedBox(width: 8),
                const Text('Mensajes'),
                const SizedBox(width: 4),
                Badge(
                  label: const Text('3'),
                  child: const SizedBox(width: 8, height: 8),
                ),
              ],
            ),
          ),
          breakdown: const [
            'ElevatedButton → estilo y acción de toque',
            'Row → organiza horizontalmente',
            'Icon → muestra el icono',
            'SizedBox → espacio fijo entre elementos',
            'Text → muestra "Mensajes"',
            'Badge → muestra el indicador "3"',
          ],
        ),
        const SizedBox(height: 8),
        _ExampleCard(
          title: 'Tarjeta con avatar y acciones',
          isSelected: _selectedExample == 'card',
          onTap: () => setState(() => _selectedExample = 'card'),
          child: Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('Juan Pérez'),
              subtitle: const Text('Desarrollador Flutter'),
              trailing: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ),
          ),
          breakdown: const [
            'Card → sombra y bordes redondeados',
            'ListTile → layout estándar de lista (leading/title/subtitle/trailing)',
            'CircleAvatar → círculo con icono',
            'Icon(Icons.person) → icono dentro del avatar',
            'Text → título y subtítulo',
            'IconButton → botón de acción',
          ],
        ),
        const SizedBox(height: 8),
        _ExampleCard(
          title: 'Chip eliminable',
          isSelected: _selectedExample == 'chip',
          onTap: () => setState(() => _selectedExample = 'chip'),
          child: Chip(
            avatar: const CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Text('F', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
            label: const Text('Flutter'),
            onDeleted: () {},
          ),
          breakdown: const [
            'Chip → contenedor estilizado con acción de eliminar',
            'CircleAvatar → avatar circular a la izquierda',
            'Text("F") → letra dentro del avatar',
            'Text("Flutter") → etiqueta del chip',
            'onDeleted → acción al tocar la X',
          ],
        ),
        const Divider(height: 24),
        Text(
          'Principio clave:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'Cada widget hace UNA cosa bien.\n'
            'Combinas widgets simples para crear UI compleja.\n'
            'No herencias profundas — solo composición.\n\n'
            'Container = Padding + DecoratedBox + ConstrainedBox\n'
            'Card = Material + Padding + ShapeDecoration\n'
            'ListTile = Row + Expanded + Icon + Text',
            style: TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.child,
    required this.breakdown,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;
  final List<String> breakdown;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.deepPurple : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Center(child: child),
            if (isSelected) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 4),
              const Text('Descomposición:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 4),
              ...breakdown.map((line) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('  • ', style: TextStyle(fontSize: 12)),
                        Expanded(child: Text(line, style: const TextStyle(fontSize: 12))),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}