import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Demo de Supabase Realtime (Postgres Changes).
///
/// Muestra:
/// - Suscripción a cambios en la tabla `notes` con `channel(...).on(...)`.
/// - Filtrado por usuario: `eq('user_id', userId)`.
/// - Tipos de evento: INSERT, UPDATE, DELETE.
/// - Log en pantalla de cada evento recibido en tiempo real.
///
/// Requisito previo: Realtime habilitado para la tabla `notes` (hecho en la
/// migración con `alter publication supabase_realtime add table public.notes`)
/// y Auth para identificar al usuario.
class SupabaseRealtimePage extends StatefulWidget {
  const SupabaseRealtimePage({super.key});

  @override
  State<SupabaseRealtimePage> createState() => _SupabaseRealtimePageState();
}

class _SupabaseRealtimePageState extends State<SupabaseRealtimePage> {
  RealtimeChannel? _channel;
  final List<String> _events = [];
  int _inserts = 0;
  int _updates = 0;
  int _deletes = 0;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    _channel = Supabase.instance.client
        .channel('notes-realtime-demo')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) {
            setState(() {
              _inserts++;
              _events.insert(
                0,
                'INSERT: ${(payload.newRecord['text'] ?? '')}',
              );
            });
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'notes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) {
            setState(() {
              _updates++;
              _events.insert(
                0,
                'UPDATE: ${payload.newRecord}',
              );
            });
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'notes',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) {
            setState(() {
              _deletes++;
              _events.insert(
                0,
                'DELETE: ${payload.oldRecord['id']}',
              );
            });
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    if (_channel != null) {
      Supabase.instance.client.removeChannel(_channel!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Supabase Realtime')),
      body: user == null
          ? const Center(
              child: Text('Inicia sesión en Auth para suscribirte a cambios.'),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Escuchando cambios en public.notes filtrado por tu uid.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _counter('INSERT', _inserts, Colors.green),
                      const SizedBox(width: 8),
                      _counter('UPDATE', _updates, Colors.orange),
                      const SizedBox(width: 8),
                      _counter('DELETE', _deletes, Colors.red),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Eventos (abre la página Postgres para generarlos):',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _events.length,
                      itemBuilder: (_, i) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.bolt, size: 18),
                        title: Text(_events[i], style: const TextStyle(fontSize: 13)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _counter(String label, int value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text('$value',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      )),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}