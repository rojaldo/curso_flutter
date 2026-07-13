import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sample_app/ui/core/example_screen.dart';

// IMPORTANT: Asegúrate de tener la dependencia en pubspec.yaml:
// dependencies:
//   http: ^1.2.0

/// Ejemplo didáctico de HTTP y JSON en Flutter.
///
/// Obtiene usuarios desde JSONPlaceholder, los muestra en una lista,
/// maneja estados de carga y error, y permite pull-to-refresh.
class HttpJsonExample extends StatefulWidget {
  const HttpJsonExample({super.key});

  @override
  State<HttpJsonExample> createState() => _HttpJsonExampleState();
}

class _HttpJsonExampleState extends State<HttpJsonExample> {
  late Future<List<User>> _futureUsers;

  @override
  void initState() {
    super.initState();
    _futureUsers = _fetchUsers();
  }

  Future<List<User>> _fetchUsers() async {
    const url = 'https://jsonplaceholder.typicode.com/users';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Error HTTP: ${response.statusCode}');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _futureUsers = _fetchUsers();
    });
    await _futureUsers;
  }

  void _simulateNetworkError() {
    setState(() {
      _futureUsers = Future.error(
        SocketException('Sin conexión a Internet (simulado)'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExampleScreen(
      title: 'HTTP & JSON',
      description:
          'Este ejemplo consume una API REST real usando el paquete http. '
          'Realiza una petición GET, decodifica el JSON con jsonDecode, '
          'y mapea los objetos a un modelo de Dart.',
      code: '''import 'package:http/http.dart' as http;
import 'dart:convert';

final response = await http.get(
  Uri.parse('https://api.example.com/users'),
);

if (response.statusCode == 200) {
  final List<dynamic> jsonList = jsonDecode(response.body);
  final users = jsonList.map((j) => User.fromJson(j)).toList();
} else {
  throw Exception('Error: \${response.statusCode}');
}

// Modelo
class User {
  final String name;
  final String email;
  final String company;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      company: json['company']['name'],
    );
  }
}''',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Controles
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Recargar'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _simulateNetworkError,
                icon: const Icon(Icons.wifi_off),
                label: const Text('Simular error'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lista de usuarios
          SizedBox(
            height: 320,
            child: FutureBuilder<List<User>>(
              future: _futureUsers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando usuarios...'),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
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
                          'Error de conexión',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay usuarios'));
                }

                final users = snapshot.data!;

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
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
                                user.company,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
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
                );
              },
            ),
          ),
        ],
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
    required this.company,
  });

  final int id;
  final String name;
  final String email;
  final String company;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      company: (json['company'] as Map<String, dynamic>)['name'] as String,
    );
  }
}
