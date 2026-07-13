import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio de persistencia del estado del juego Trivial en Supabase.
///
/// Tabla `trivial_states` (una fila por usuario):
///   user_id      uuid primary key
///   score        int
///   questions    jsonb   (lista de mapas de Trivial.toMap())
///   updated_at   timestamptz default now()
///
/// RLS: el usuario solo lee/escribe su propia fila.
class TrivialSupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  static const _table = 'trivial_states';

  static User? get currentUser => _client.auth.currentUser;

  static String? get currentEmail => currentUser?.email;

  static bool get isLoggedIn => currentUser != null;

  static Stream<AuthState> get authChanges =>
      _client.auth.onAuthStateChange;

  static Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  static Future<void> signOut() async => _client.auth.signOut();

  /// Sube el estado actual del juego a Supabase (upsert por user_id).
  static Future<void> saveState(int score, List<Map<String, dynamic>> questions) async {
    final user = currentUser;
    if (user == null) throw StateError('No hay sesión');
    await _client.from(_table).upsert({
      'user_id': user.id,
      'score': score,
      'questions': questions,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// Lee el estado guardado del usuario actual. Devuelve null si no hay.
  static Future<({int score, List<Map<String, dynamic>> questions})?> loadState() async {
    final user = currentUser;
    if (user == null) return null;
    final res = await _client
        .from(_table)
        .select('score, questions')
        .eq('user_id', user.id)
        .maybeSingle();
    if (res == null) return null;
    final score = (res['score'] as num?)?.toInt() ?? 0;
    final questions = (res['questions'] as List? ?? [])
        .map((e) => e as Map<String, dynamic>)
        .toList();
    return (score: score, questions: questions);
  }
}