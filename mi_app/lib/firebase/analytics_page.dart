import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

/// Demo de Firebase Analytics + Crashlytics.
///
/// Muestra:
/// - Log de eventos personalizados con `logEvent(name, parameters)`.
/// - Eventos de pantalla con `logScreenView`.
/// - Identificación de usuario con `setUserId` (Crashlytics + Analytics).
/// - Reporte de error personalizado con `recordError`.
/// - Botón para forzar una excepción nativa — Crashlytics la captura
///   automáticamente en release/debug (con plugin configurado).
class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  final _analytics = FirebaseAnalytics.instance;
  final _crashlytics = FirebaseCrashlytics.instance;
  final List<String> _log = [];

  void _append(String line) {
    setState(() => _log.insert(0, line));
  }

  Future<void> _logScreen() async {
    await _analytics.logScreenView(
      screenName: 'AnalyticsPage',
      screenClass: 'AnalyticsPage',
    );
    _append('logScreenView(AnalyticsPage) enviado');
  }

  Future<void> _logCustomEvent() async {
    await _analytics.logEvent(
      name: 'demo_button_tap',
      parameters: {'button_id': 'custom_event', 'ts': DateTime.now().toIso8601String()},
    );
    _append('logEvent(demo_button_tap) enviado');
  }

  Future<void> _setUserId() async {
    await _analytics.setUserId(id: 'demo_user_42');
    await _crashlytics.setUserIdentifier('demo_user_42');
    _append('setUserId("demo_user_42") en Analytics + Crashlytics');
  }

  Future<void> _recordError() async {
    await _crashlytics.recordError(
      Exception('Error de prueba reportado manualmente'),
      StackTrace.current,
      reason: 'demo: botón "reportar error"',
      fatal: false,
    );
    _append('recordError() enviado a Crashlytics');
  }

  Future<void> _forceCrash() async {
    // Crashlytics captura excepciones no manejadas. Lanzamos una
    // deliberada para verificar el reporte en la consola.
    _append('Lanzando excepción no manejada…');
    await Future.delayed(const Duration(milliseconds: 100));
    throw StateError('Crash forzado para demo de Crashlytics');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics + Crashlytics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.tonalIcon(
              onPressed: _logScreen,
              icon: const Icon(Icons.screen_rotation),
              label: const Text('logScreenView'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: _logCustomEvent,
              icon: const Icon(Icons.event),
              label: const Text('logEvent(demo_button_tap)'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: _setUserId,
              icon: const Icon(Icons.person),
              label: const Text('setUserId("demo_user_42")'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _recordError,
              icon: const Icon(Icons.bug_report),
              label: const Text('recordError (no fatal)'),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _forceCrash,
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              icon: const Icon(Icons.warning),
              label: const Text('Forzar crash (excepción)'),
            ),
            const SizedBox(height: 16),
            Text('Log local de acciones:',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _log.length,
                itemBuilder: (_, i) => ListTile(
                  dense: true,
                  leading: const Icon(Icons.check_circle_outline, size: 18),
                  title: Text(_log[i], style: const TextStyle(fontSize: 13)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}