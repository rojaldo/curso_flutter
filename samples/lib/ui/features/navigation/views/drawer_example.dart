import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de Drawer.
///
/// Muestra un Scaffold con un menú lateral (Drawer) que incluye
/// cabecera de usuario y elementos de navegación interactivos.
class DrawerExample extends StatelessWidget {
  const DrawerExample({super.key});

  final String code = '''
Scaffold(
  appBar: AppBar(title: Text('App')),
  drawer: Drawer(
    child: ListView(
      children: [
        DrawerHeader(child: Text('Usuario')),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Inicio'),
          onTap: () { /* ... */ },
        ),
      ],
    ),
  ),
  body: ...,
)
'''; // ignore: unreachable_from_main

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'Drawer',
      description:
          'Menú lateral de navegación. Toca el icono de menú '
          'para abrir el drawer y seleccionar una opción.',
      code: code,
      child: const SizedBox(
        height: 400,
        child: _DrawerDemo(),
      ),
    );
  }
}

class _DrawerDemo extends StatefulWidget {
  const _DrawerDemo();

  @override
  State<_DrawerDemo> createState() => _DrawerDemoState();
}

class _DrawerDemoState extends State<_DrawerDemo> {
  String _selected = 'Inicio';

  final List<_DrawerItem> _items = const [
    _DrawerItem(icon: Icons.home, label: 'Inicio'),
    _DrawerItem(icon: Icons.person, label: 'Perfil'),
    _DrawerItem(icon: Icons.settings, label: 'Ajustes'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selected),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    child: Icon(Icons.person, size: 32),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Juan Pérez',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('juan@ejemplo.com'),
                ],
              ),
            ),
            for (final item in _items)
              ListTile(
                leading: Icon(item.icon),
                title: Text(item.label),
                selected: _selected == item.label,
                onTap: () => _select(item.label),
              ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.touch_app, size: 48),
            const SizedBox(height: 16),
            Text(
              'Pantalla: $_selected',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }

  void _select(String label) {
    setState(() => _selected = label);
    Navigator.of(context).pop();
  }
}

class _DrawerItem {
  const _DrawerItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}
