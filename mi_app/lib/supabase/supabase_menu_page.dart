import 'package:flutter/material.dart';

import 'auth_page.dart';
import 'postgres_page.dart';
import 'storage_page.dart';
import 'realtime_page.dart';

/// Página menú que agrupa todos los ejemplos de Supabase.
///
/// Cada botón navega a una demo independiente que muestra una capacidad
/// de Supabase. El objetivo es didáctico: ver cómo se inicializa, se usa
/// y se integra con Flutter, en paralelo a las demos de Firebase.
class SupabaseMenuPage extends StatelessWidget {
  const SupabaseMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final demos = <_DemoEntry>[
      _DemoEntry(
        title: 'Auth',
        subtitle: 'Registro, login y estado de sesión con GoTrue.',
        icon: Icons.lock_outline,
        page: const SupabaseAuthPage(),
      ),
      _DemoEntry(
        title: 'Postgres (PostgREST)',
        subtitle: 'CRUD de notas vía API REST sobre Postgres con RLS.',
        icon: Icons.storage_outlined,
        page: const SupabasePostgresPage(),
      ),
      _DemoEntry(
        title: 'Storage',
        subtitle: 'Subida de imagen a un bucket público con progreso.',
        icon: Icons.upload_file,
        page: const SupabaseStoragePage(),
      ),
      _DemoEntry(
        title: 'Realtime',
        subtitle: 'Suscripción a cambios de la tabla notes en vivo.',
        icon: Icons.bolt_outlined,
        page: const SupabaseRealtimePage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: demos.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final d = demos[i];
          return ListTile(
            leading: Icon(d.icon, size: 32),
            title: Text(d.title),
            subtitle: Text(d.subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => d.page),
            ),
          );
        },
      ),
    );
  }
}

class _DemoEntry {
  const _DemoEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.page,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget page;
}