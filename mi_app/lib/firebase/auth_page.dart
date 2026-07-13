import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Demo de Firebase Authentication.
///
/// Muestra:
/// - Alta de usuario con email + password (`createUserWithEmailAndPassword`).
/// - Login con email + password (`signInWithEmailAndPassword`).
/// - Cierre de sesión (`signOut`).
/// - Reacción al estado de sesión con un [StreamBuilder] sobre
///   `authStateChanges()`, que emite el usuario actual o `null`.
///
/// Requisito previo: tener habilitado el proveedor Email/Password en
/// Firebase Console → Authentication → Sign-in method.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
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
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _message = '${e.code}: ${e.message}');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Auth')),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
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
        Text('UID: ${user.uid}'),
        Text('Email: ${user.email ?? "—"}'),
        if (user.emailVerified) const Text('Email verificado ✓'),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: _busy
              ? null
              : () => _run(
                    () => FirebaseAuth.instance.signOut(),
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
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _busy
              ? null
              : () => _run(
                    () => FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _email.text.trim(),
                      password: _password.text.trim(),
                    ),
                    'Usuario creado',
                  ),
          icon: const Icon(Icons.person_add),
          label: const Text('Registrarse'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _busy
              ? null
              : () => _run(
                    () => FirebaseAuth.instance.signInWithEmailAndPassword(
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