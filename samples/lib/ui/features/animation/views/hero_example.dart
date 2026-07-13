import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/code_dialog.dart';

/// Modelo de datos para los elementos de la lista.
class _HeroItem {
  const _HeroItem({
    required this.id,
    required this.title,
    required this.color,
    required this.icon,
  });

  final int id;
  final String title;
  final Color color;
  final IconData icon;
}

/// Ejemplo de Hero Animation en Flutter.
///
/// Muestra una lista de elementos. Al tocar uno, navega a una pantalla
/// de detalle donde el icono compartido realiza una transición Hero.
/// Este widget gestiona su propia navegación, por lo que no usa ExampleScreen.
class HeroExample extends StatefulWidget {
  const HeroExample({super.key});

  @override
  State<HeroExample> createState() => _HeroExampleState();
}

class _HeroExampleState extends State<HeroExample> {
  final List<_HeroItem> _items = const [
    _HeroItem(
      id: 1,
      title: 'Montaña',
      color: Colors.green,
      icon: Icons.terrain,
    ),
    _HeroItem(
      id: 2,
      title: 'Océano',
      color: Colors.blue,
      icon: Icons.water,
    ),
    _HeroItem(
      id: 3,
      title: 'Sol',
      color: Colors.orange,
      icon: Icons.wb_sunny,
    ),
    _HeroItem(
      id: 4,
      title: 'Luna',
      color: Colors.indigo,
      icon: Icons.nightlight_round,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hero Animation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'Ver código',
            onPressed: () => CodeDialog.show(
              context,
              'Hero Animation',
              '''
// En la lista: envolver el widget compartido con Hero
Hero(
  tag: 'item-\$itemId',
  child: Icon(icon, size: 48),
)

// En la pantalla de detalle: el mismo tag
Hero(
  tag: 'item-\$itemId',
  child: Icon(icon, size: 160),
)

// Navegación con MaterialPageRoute
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => DetailPage(itemId: itemId),
  ),
);
''',
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Hero(
                tag: 'hero-item-${item.id}',
                child: CircleAvatar(
                  backgroundColor: item.color,
                  child: Icon(item.icon, color: Colors.white),
                ),
              ),
              title: Text(item.title),
              subtitle: const Text('Toca para ver la transición Hero'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openDetail(context, item),
            ),
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, _HeroItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _HeroDetailPage(item: item),
      ),
    );
  }
}

/// Pantalla de detalle con el elemento Hero ampliado.
class _HeroDetailPage extends StatelessWidget {
  const _HeroDetailPage({required this.item});

  final _HeroItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'hero-item-${item.id}',
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  size: 120,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              item.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'El icono compartido entre las dos pantallas '
                'realiza una transición Hero suave.',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
