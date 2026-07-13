import 'package:flutter/material.dart';
import 'package:mi_app/main.dart' show kFirebaseSupported;

import 'auth_page.dart';
import 'firestore_page.dart';
import 'storage_page.dart';
import 'analytics_page.dart';

/// Página menú que agrupa todos los ejemplos de Firebase.
///
/// Cada botón navega a una demo independiente que muestra un servicio
/// de Firebase distinto. El objetivo es didáctico: ver cómo se inicializa,
/// se usa y se integra con Flutter.
class FirebaseMenuPage extends StatelessWidget {
  const FirebaseMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final demos = <_DemoEntry>[
      _DemoEntry(
        title: 'Authentication',
        subtitle: 'Registro, login y estado de sesión con FirebaseAuth.',
        icon: Icons.lock_outline,
        page: const AuthPage(),
      ),
      _DemoEntry(
        title: 'Cloud Firestore',
        subtitle: 'CRUD de notas con suscripción en tiempo real.',
        icon: Icons.cloud_outlined,
        page: const FirestorePage(),
      ),
      _DemoEntry(
        title: 'Storage',
        subtitle: 'Subida de imagen con progreso a Firebase Storage.',
        icon: Icons.upload_file,
        page: const StoragePage(),
      ),
      _DemoEntry(
        title: 'Analytics + Crashlytics',
        subtitle: 'Registro de eventos y reporte de errores.',
        icon: Icons.analytics_outlined,
        page: const AnalyticsPage(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: !kFirebaseSupported
          ? const _UnsupportedPlatformView()
          : ListView.separated(
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

class _UnsupportedPlatformView extends StatelessWidget {
  const _UnsupportedPlatformView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.desktop_access_disabled, size: 64),
            const SizedBox(height: 16),
            Text(
              'Firebase no está disponible en esta plataforma',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Los plugins de FlutterFire solo tienen implementación nativa '
              'para Android, iOS, macOS y Web. Corre la app en uno de esos '
              'targets para usar las demos de Firebase.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
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