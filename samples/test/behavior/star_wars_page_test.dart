// Tests de comportamiento de la página StarWarsPage.
//
// Se inyecta un http.Client mockeado (mocktail) para simular SWAPI:
//   - Caso OK: el cliente devuelve 200 + lista de personajes → aparecen nombres.
//   - Caso error HTTP: el cliente devuelve 500 → la UI muestra error + reintentar.
//   - Caso excepción de red: el cliente lanza → la UI muestra error.
//
// Nota: el PagingController auto-fetcha páginas hasta llenar la viewport.
// Como los tests usan un viewport pequeño, devolvemos [] en page>=2 para
// parar la paginación y evitar duplicados.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:sample_app/ui/features/exercises/views/star_wars_page.dart';

class _MockClient extends Mock implements http.Client {}

void main() {
  late _MockClient client;

  setUp(() {
    client = _MockClient();
    registerFallbackValue(Uri.parse('https://swapi.dev/api/people/'));
  });

  testWidgets('muestra personajes cuando la API responde 200', (tester) async {
    when(() => client.get(any())).thenAnswer((invocation) async {
      final url = invocation.positionalArguments[0] as Uri;
      if (url.toString().contains('page=2')) {
        return http.Response('{"results":[]}', 200);
      }
      final body = jsonEncode({
        'count': 2,
        'next': null,
        'previous': null,
        'results': [
          {
            'name': 'Luke Skywalker',
            'height': '172',
            'mass': '77',
            'hair_color': 'blond',
            'skin_color': 'fair',
            'eye_color': 'blue',
            'birth_year': '19BBY',
            'gender': 'male',
            'url': 'https://swapi.dev/api/people/1/',
          },
          {
            'name': 'C-3PO',
            'height': '167',
            'mass': '75',
            'hair_color': 'n/a',
            'skin_color': 'gold',
            'eye_color': 'yellow',
            'birth_year': '112BBY',
            'gender': 'n/a',
            'url': 'https://swapi.dev/api/people/2/',
          },
        ],
      });
      return http.Response(body, 200);
    });

    await tester.pumpWidget(
      MaterialApp(home: StarWarsPage(client: client)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Luke Skywalker'), findsOneWidget);
    expect(find.text('C-3PO'), findsOneWidget);
  });

  testWidgets('muestra vista de error cuando la API responde 500',
      (tester) async {
    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response('Server error', 500));

    await tester.pumpWidget(
      MaterialApp(home: StarWarsPage(client: client)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Error al cargar'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('muestra vista de error cuando el cliente lanza excepción',
      (tester) async {
    when(() => client.get(any())).thenThrow(Exception('No internet'));

    await tester.pumpWidget(
      MaterialApp(home: StarWarsPage(client: client)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Error al cargar'), findsOneWidget);
  });

  testWidgets('pulsar "Reintentar" tras error vuelve a llamar a la API',
      (tester) async {
    var callCount = 0;
    when(() => client.get(any())).thenAnswer((_) async {
      callCount++;
      throw Exception('always fails');
    });

    await tester.pumpWidget(
      MaterialApp(home: StarWarsPage(client: client)),
    );
    await tester.pumpAndSettle();

    expect(callCount, 1);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();
    expect(callCount, greaterThan(1));
  });

  testWidgets('muestra avatar con id del personaje', (tester) async {
    when(() => client.get(any())).thenAnswer((invocation) async {
      final url = invocation.positionalArguments[0] as Uri;
      if (url.toString().contains('page=2')) {
        return http.Response('{"results":[]}', 200);
      }
      final body = jsonEncode({
        'count': 1,
        'next': null,
        'previous': null,
        'results': [
          {
            'name': 'Leia Organa',
            'height': '150',
            'mass': '49',
            'hair_color': 'brown',
            'skin_color': 'light',
            'eye_color': 'brown',
            'birth_year': '19BBY',
            'gender': 'female',
            'url': 'https://swapi.dev/api/people/5/',
          },
        ],
      });
      return http.Response(body, 200);
    });

    await tester.pumpWidget(
      MaterialApp(home: StarWarsPage(client: client)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Leia Organa'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });
}