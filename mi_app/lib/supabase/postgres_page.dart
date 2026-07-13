import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Demo de Postgres vía PostgREST (la API REST auto-generada de Supabase).
///
/// Muestra:
/// - Inserción (`insert`) y borrado (`delete`) en la tabla `notes`.
/// - Lectura reactiva con `stream()` (Postgres Changes) — cualquier fila nueva
///   o borrada se refleja al instante sin recargar.
///
/// Requisito previo: Auth habilitado (la página pide login si no lo hay) y
/// la tabla `notes` con RLS que permita al usuario autenticado leer/escribir
/// solo sus propias filas. La política usa `auth.uid() = user_id`.
class SupabasePostgresPage extends StatefulWidget {
  const SupabasePostgresPage({super.key});

  @override
  State<SupabasePostgresPage> createState() => _SupabasePostgresPageState();
}

class _SupabasePostgresPageState extends State<SupabasePostgresPage> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _add(String userId) async {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    await Supabase.instance.client.from('notes').insert({
      'user_id': userId,
      'text': text,
    });
    _text.clear();
  }

  Future<void> _delete(String id) async {
    await Supabase.instance.client.from('notes').delete().eq('id', id);
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Supabase Postgres')),
      body: user == null
          ? const Center(
              child: Text('Inicia sesión en Auth para usar Postgres.'),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _text,
                          decoration: const InputDecoration(
                            labelText: 'Nueva nota',
                          ),
                          onSubmitted: (_) => _add(user.id),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _add(user.id),
                        icon: const Icon(Icons.add_circle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    // stream() sobre Postgres Changes: el servidor envía
                    // un snapshot nuevo cada vez que la tabla cambia.
                    // Requiere Realtime habilitado para la tabla (ya hecho
                    // en la migración).
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: Supabase.instance.client
                          .from('notes')
                          .stream(
                            primaryKey: const ['id'],
                            // Equivalente a escuchar cualquier cambio en la
                            // tabla filtrada por el usuario actual.
                          )
                          .eq('user_id', user.id)
                          .order('created_at'),
                      builder: (context, snap) {
                        if (snap.hasError) {
                          return Center(child: Text('Error: ${snap.error}'));
                        }
                        final rows = snap.data ?? const [];
                        if (rows.isEmpty) {
                          return const Center(
                            child: Text('Sin notas. Añade la primera.'),
                          );
                        }
                        return ListView.separated(
                          itemCount: rows.length,
                          separatorBuilder: (_, _) =>
                              const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final row = rows[i];
                            final id = row['id'] as String;
                            final text = (row['text'] ?? '') as String;
                            return ListTile(
                              title: Text(text),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _delete(id),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}