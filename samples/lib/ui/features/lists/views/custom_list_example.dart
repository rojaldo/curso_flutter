import 'package:flutter/material.dart';
import 'package:sample_app/ui/core/example_screen.dart';

/// Lista con items custom: tarjetas con avatar, subtítulo, chip y trailing.
class CustomListExample extends StatelessWidget {
  const CustomListExample({super.key});

  @override
  Widget build(BuildContext context) {
    const contacts = [
      _Contact('Ana García', 'ana@correo.es', 'Diseño', Icons.palette),
      _Contact('Luis López', 'luis@correo.es', 'Backend', Icons.storage),
      _Contact('María Ruiz', 'maria@correo.es', 'QA', Icons.bug_report),
      _Contact('Pedro Sánchez', 'pedro@correo.es', 'DevOps', Icons.cloud),
      _Contact('Laura Torres', 'laura@correo.es', 'Frontend', Icons.web),
      _Contact('Carlos Navarro', 'carlos@correo.es', 'Datos', Icons.analytics),
    ];

    const code = '''
ListView.builder(
  itemCount: contacts.length,
  itemBuilder: (context, index) {
    final c = contacts[index];
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(child: Icon(c.icon)),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name),
                  Text(c.email, style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            Chip(label: Text(c.role)),
          ],
        ),
      ),
    );
  },
)''';

    return ExampleScreen(
      title: 'Lista con items custom',
      description: 'No estás limitado a ListTile. Puedes construir filas '
          'completamente personalizadas con Card, Row, Chip, y cualquier widget.',
      code: code,
      child: SizedBox(
        height: 400,
        child: ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final c = contacts[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.primaries[index % Colors.primaries.length],
                      child: Icon(c.icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(c.email, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    ),
                    Chip(
                      label: Text(c.role, style: const TextStyle(fontSize: 11)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Contact {
  const _Contact(this.name, this.email, this.role, this.icon);
  final String name;
  final String email;
  final String role;
  final IconData icon;
}