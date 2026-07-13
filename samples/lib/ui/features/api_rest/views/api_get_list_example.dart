import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_app/ui/core/example_screen.dart';

/// Ejemplo didáctico de API GET para obtener una lista de usuarios.
///
/// Realiza una petición GET a JSONPlaceholder, muestra un indicador de carga,
/// permite pull-to-refresh y maneja errores con un botón de reintentar.
class ApiGetListExample extends StatefulWidget {
  const ApiGetListExample({super.key});

  @override
  State<ApiGetListExample> createState() => _ApiGetListExampleState();
}

class _ApiGetListExampleState extends State<ApiGetListExample> {
  List<User> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/users'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          _users = jsonList.map((json) => User.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Error HTTP: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de conexión: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'API GET — Lista',
      description:
          'Este ejemplo consume una API REST real usando http.get para obtener '
          'una lista de usuarios. Incluye pull-to-refresh y manejo de errores.',
      code: '''import 'package:http/http.dart' as http;
import 'dart:convert';

final response = await http.get(
  Uri.parse('https://jsonplaceholder.typicode.com/users'),
);

if (response.statusCode == 200) {
  final List<dynamic> jsonList = jsonDecode(response.body);
  final users = jsonList.map((j) => User.fromJson(j)).toList();
} else {
  throw Exception('Error: \${response.statusCode}');
}

class User {
  final String name;
  final String email;
  final String phone;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}''',
      child: SizedBox(
        height: 380,
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando usuarios...'),
                  ],
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.signal_wifi_off,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error al cargar',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _fetchUsers,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchUsers,
                    child: ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(user.name[0]),
                            ),
                            title: Text(user.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.email),
                                Text(
                                  user.phone,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

/// Modelo de dominio para un usuario.
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  final int id;
  final String name;
  final String email;
  final String phone;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
    );
  }
}
