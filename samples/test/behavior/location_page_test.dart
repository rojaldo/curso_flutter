// Smoke test de LocationPage.
//
// geolocator usa platform channels que no existen en flutter_test, por lo
// que isLocationServiceEnabled() lanza MissingPluginException. La página
// lo captura y muestra un mensaje de error. Este smoke test verifica
// solo que la página se monta y renderiza SIN explotar.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sample_app/ui/features/exercises/views/location_page.dart';

void main() {
  testWidgets('se monta y muestra el AppBar', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LocationPage()));
    await tester.pump();
    // Permite que el Future de geolocator falle silenciosamente.
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Localización'), findsOneWidget);
  });

  testWidgets('renderiza sin lanzar excepciones no capturadas',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LocationPage()));
    // Si la página lanza una excepción no capturada, pumpWidget la reporta
    // como test failure. Solo verificar que no crashea.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
  });
}