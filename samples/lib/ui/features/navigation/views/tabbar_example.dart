import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de TabBar y TabBarView.
///
/// Usa DefaultTabController para sincronizar una fila de pestañas
/// con un conjunto de páginas deslizables.
class TabbarExample extends StatelessWidget {
  const TabbarExample({super.key});

  final String code = '''
DefaultTabController(
  length: 3,
  child: Column(
    children: [
      TabBar(
        tabs: [
          Tab(icon: Icon(Icons.home), text: 'Inicio'),
          Tab(icon: Icon(Icons.favorite), text: 'Favoritos'),
          Tab(icon: Icon(Icons.notifications), text: 'Alertas'),
        ],
      ),
      Expanded(
        child: TabBarView(
          children: [
            // contenido de cada pestaña
          ],
        ),
      ),
    ],
  ),
)
'''; // ignore: unreachable_from_main

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: ExampleScreen(
        title: 'TabBar & TabBarView',
        description:
            'Pestañas con iconos y texto. Desliza horizontalmente '
            'o toca una pestaña para cambiar de contenido.',
        code: code,
        child: const SizedBox(
          height: 280,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.home), text: 'Inicio'),
                  Tab(icon: Icon(Icons.favorite), text: 'Favoritos'),
                  Tab(icon: Icon(Icons.notifications), text: 'Alertas'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _TabContent(
                      icon: Icons.home,
                      label: 'Inicio',
                      color: Colors.blue,
                    ),
                    _TabContent(
                      icon: Icons.favorite,
                      label: 'Favoritos',
                      color: Colors.red,
                    ),
                    _TabContent(
                      icon: Icons.notifications,
                      label: 'Alertas',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: color),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}
