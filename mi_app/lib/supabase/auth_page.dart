import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Demo de Supabase Auth (GoTrue).
///
/// Muestra:
/// - Alta de usuario con email + password (`signUp`).
/// - Login con email + password (`signInWithPassword`).
/// - Cierre de sesión (`signOut`).
/// - Reacción al estado de sesión con un [StreamBuilder] sobre
///   `Supabase.instance.client.auth.onAuthStateChange`, que emite cada cambio
///   de sesión (login, logout, token refrescado, etc.).
///
/// Requisito previo: tener Auth habilitado (viene activo por defecto en
/// cualquier proyecto Supabase nuevo, no hay que tocar nada).
class SupabaseAuthPage extends StatefulWidget {
  const SupabaseAuthPage({super.key});

  @override
  State<SupabaseAuthPage> createState() => _SupabaseAuthPageState();
}

class _SupabaseAuthPageState extends State<SupabaseAuthPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() op, String ok) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await op();
      if (mounted) setState(() => _message = ok);
    } on AuthException catch (e) {
      if (mounted) setState(() => _message = '${e.code}: ${e.message}');
    } catch (e) {
      if (mounted) setState(() => _message = 'Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    return Scaffold(
      appBar: AppBar(title: const Text('Supabase Auth')),
      body: StreamBuilder<AuthState>(
        stream: client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = snapshot.data?.session;
          final user = session?.user;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (user == null) _signedOutView() else _signedInView(user),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _signedInView(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Sesión iniciada', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('UID: ${user.id}'),
        Text('Email: ${user.email ?? "—"}'),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: _busy
              ? null
              : () => _run(
                    () => Supabase.instance.client.auth.signOut(),
                    'Sesión cerrada',
                  ),
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
        ),
        if (_message != null) ...[
          const SizedBox(height: 12),
          Text(_message!, style: const TextStyle(color: Colors.blue)),
        ],
      ],
    );
  }

  Widget _signedOutView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _email,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _password,
          decoration: const InputDecoration(labelText: 'Password (mín. 6)'),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _busy
              ? null
              : () => _run(
                    () => Supabase.instance.client.auth.signUp(
                      email: _email.text.trim(),
                      password: _password.text.trim(),
                    ),
                    'Registro correcto. Revisa el email si pide confirmación.',
                  ),
          icon: const Icon(Icons.person_add),
          label: const Text('Registrarse'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _busy
              ? null
              : () => _run(
                    () => Supabase.instance.client.auth.signInWithPassword(
                      email: _email.text.trim(),
                      password: _password.text.trim(),
                    ),
                    'Sesión iniciada',
                  ),
          icon: const Icon(Icons.login),
          label: const Text('Iniciar sesión'),
        ),
        if (_busy) const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Center(child: CircularProgressIndicator()),
        ),
        if (_message != null) ...[
          const SizedBox(height: 12),
          Text(_message!, style: const TextStyle(color: Colors.red)),
        ],
      ],
    );
  }
}