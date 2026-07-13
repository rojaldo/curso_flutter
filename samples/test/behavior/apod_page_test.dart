// Tests de comportamiento de la página ApodPage.
//
// Se inyecta un http.Client mockeado (mocktail) para no depender de red:
//   - Caso OK: el cliente devuelve 200 + JSON → la UI muestra título y fecha.
//   - Caso error HTTP: el cliente devuelve 500 → la UI muestra "Error".
//   - Caso excepción: el cliente lanza → la UI muestra "Error".
//   - Loading: con Completer controlamos cuándo se resuelve el Future.
//
// Para que el FutureBuilder reconstruya, se bombardea con pumpAndSettle.

import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:sample_app/ui/features/exercises/views/apod_page.dart';

class _MockClient extends Mock implements http.Client {}

void main() {
  late _MockClient client;

  setUp(() {
    client = _MockClient();
    registerFallbackValue(Uri.parse('https://api.nasa.gov/planetary/apod'));
  });

  testWidgets('muestra el título y la fecha cuando la API responde 200',
      (tester) async {
    final body = jsonEncode({
      'title': 'Galactic Wonder',
      'date': '2024-06-01',
      'explanation': 'Una explicación.',
      'media_type': 'image',
      'service_version': 'v1',
    });
    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response(body, 200));

    await tester.pumpWidget(
      MaterialApp(home: ApodPage(client: client)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Galactic Wonder'), findsOneWidget);
    expect(find.text('2024-06-01'), findsOneWidget);
  });

  testWidgets('muestra error cuando la API responde 500', (tester) async {
    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response('Server error', 500));

    await tester.pumpWidget(
      MaterialApp(home: ApodPage(client: client)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Error'), findsWidgets);
  });

  testWidgets('muestra error cuando el cliente lanza una excepción',
      (tester) async {
    when(() => client.get(any())).thenThrow(Exception('No internet'));

    await tester.pumpWidget(
      MaterialApp(home: ApodPage(client: client)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Error'), findsWidgets);
  });

  testWidgets('muestra CircularProgressIndicator mientras carga',
      (tester) async {
    final completer = Completer<http.Response>();
    when(() => client.get(any())).thenAnswer((_) => completer.future);

    await tester.pumpWidget(
      MaterialApp(home: ApodPage(client: client)),
    );
    // Primer frame: el FutureBuilder está en waiting.
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Completamos para que el test termine limpio.
    completer.complete(http.Response(
      jsonEncode({
        'title': 'Done',
        'date': '2024-06-02',
        'explanation': 'x',
        'media_type': 'image',
        'service_version': 'v1',
      }),
      200,
    ));
    await tester.pumpAndSettle();
  });

  testWidgets('no renderiza Image.network cuando imageUrl está vacío',
      (tester) async {
    final body = jsonEncode({
      'title': 'No Image APOD',
      'date': '2024-06-03',
      'explanation': 'Sin imagen.',
      'media_type': 'image',
      'service_version': 'v1',
    });
    when(() => client.get(any()))
        .thenAnswer((_) async => http.Response(body, 200));

    await tester.pumpWidget(
      MaterialApp(home: ApodPage(client: client)),
    );
    await tester.pumpAndSettle();

    expect(find.text('No Image APOD'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}