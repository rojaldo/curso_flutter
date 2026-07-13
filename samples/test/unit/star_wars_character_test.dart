// Tests unitarios del modelo StarWarsCharacter.
//
// Valida fromJson (incluyendo defaults seguros) y el getter `id`
// que extrae el identificador numérico desde la URL de SWAPI.

import 'package:flutter_test/flutter_test.dart';
import 'package:sample_app/model/star_wars_character.dart';

void main() {
  group('StarWarsCharacter.fromJson — payload completo', () {
    test('parsea todos los campos correctamente', () {
      final json = {
        'name': 'Luke Skywalker',
        'height': '172',
        'mass': '77',
        'hair_color': 'blond',
        'skin_color': 'fair',
        'eye_color': 'blue',
        'birth_year': '19BBY',
        'gender': 'male',
        'url': 'https://swapi.dev/api/people/1/',
      };

      final c = StarWarsCharacter.fromJson(json);

      expect(c.name, 'Luke Skywalker');
      expect(c.height, '172');
      expect(c.mass, '77');
      expect(c.hairColor, 'blond');
      expect(c.skinColor, 'fair');
      expect(c.eyeColor, 'blue');
      expect(c.birthYear, '19BBY');
      expect(c.gender, 'male');
      expect(c.url, 'https://swapi.dev/api/people/1/');
    });
  });

  group('StarWarsCharacter.fromJson — defaults seguros', () {
    test('JSON vacío produce strings vacíos en todos los campos', () {
      final c = StarWarsCharacter.fromJson({});

      expect(c.name, '');
      expect(c.height, '');
      expect(c.mass, '');
      expect(c.hairColor, '');
      expect(c.skinColor, '');
      expect(c.eyeColor, '');
      expect(c.birthYear, '');
      expect(c.gender, '');
      expect(c.url, '');
    });

    test('valores null en el JSON caen al default vacío', () {
      final c = StarWarsCharacter.fromJson({
        'name': null,
        'height': null,
        'mass': null,
        'url': null,
      });

      expect(c.name, '');
      expect(c.height, '');
      expect(c.mass, '');
      expect(c.url, '');
    });
  });

  group('StarWarsCharacter.id — extracción desde URL', () {
    test('URL válida devuelve el id numérico', () {
      final c = StarWarsCharacter.fromJson({
        'url': 'https://swapi.dev/api/people/42/',
      });
      expect(c.id, 42);
    });

    test('id 1 para Luke', () {
      final c = StarWarsCharacter.fromJson({
        'url': 'https://swapi.dev/api/people/1/',
      });
      expect(c.id, 1);
    });

    test('URL sin patrón /people/N/ devuelve 0', () {
      final c = StarWarsCharacter.fromJson({
        'url': 'https://swapi.dev/api/starships/12/',
      });
      expect(c.id, 0);
    });

    test('url vacía devuelve 0', () {
      final c = StarWarsCharacter.fromJson({'url': ''});
      expect(c.id, 0);
    });

    test('id grande (3 cifras) se parsea bien', () {
      final c = StarWarsCharacter.fromJson({
        'url': 'https://swapi.dev/api/people/836/',
      });
      expect(c.id, 836);
    });
  });

  group('StarWarsCharacter — valores "unknown" de la API', () {
    test('height y mass "unknown" se guardan tal cual (no se inventan)', () {
      final c = StarWarsCharacter.fromJson({
        'height': 'unknown',
        'mass': 'unknown',
        'name': 'Yoda',
        'url': 'https://swapi.dev/api/people/20/',
      });

      expect(c.height, 'unknown');
      expect(c.mass, 'unknown');
      expect(c.id, 20);
    });
  });
}