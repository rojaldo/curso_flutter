import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de BottomNavigationBar.
///
/// Muestra una barra de navegación inferior con 4 pestañas
/// que actualizan el contenido mostrado.
class BottomNavExample extends StatefulWidget {
  const BottomNavExample({super.key});

  @override
  State<BottomNavExample> createState() => _BottomNavExampleState();
}

class _BottomNavExampleState extends State<BottomNavExample> {
  int _selectedIndex = 0;

  final String code = '''
BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: (index) => setState(() => _selectedIndex = index),
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
    BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
  ],
)
'''; // ignore: unreachable_from_main

  final List<_NavPage> _pages = const [
    _NavPage(icon: Icons.home, label: 'Inicio', color: Colors.blue),
    _NavPage(icon: Icons.search, label: 'Buscar', color: Colors.green),
    _NavPage(icon: Icons.person, label: 'Perfil', color: Colors.orange),
    _NavPage(icon: Icons.settings, label: 'Ajustes', color: Colors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    final page = _pages[_selectedIndex];

    return ExampleScreen(
      title: 'BottomNavigationBar',
      description:
          'Barra de navegación inferior con 4 pestañas. '
          'Toca los iconos para cambiar de contenido.',
      code: code,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 180,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(page.icon, size: 64, color: page.color),
                const SizedBox(height: 12),
                Text(
                  page.label,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Buscar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Ajustes',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavPage {
  const _NavPage({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;
}
