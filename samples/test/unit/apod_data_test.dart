// Tests unitarios del modelo ApodData.
//
// Valida el factory fromJson: parsing completo, valores por defecto
// cuando faltan claves, y tipos opcionales (imageUrl, copyright, hdUrl).

import 'package:flutter_test/flutter_test.dart';
import 'package:sample_app/model/apod_data.dart';

void main() {
  group('ApodData.fromJson — payload completo', () {
    test('parsea todos los campos correctamente', () {
      final json = {
        'title': 'The Milky Way over Cathedral Gorge',
        'date': '2024-01-15',
        'explanation': 'Una explicación larga del cielo nocturno.',
        'url': 'https://example.com/image.jpg',
        'hdurl': 'https://example.com/hd.jpg',
        'media_type': 'image',
        'service_version': 'v1',
        'copyright': 'Jane Doe',
      };

      final data = ApodData.fromJson(json);

      expect(data.title, 'The Milky Way over Cathedral Gorge');
      expect(data.date, '2024-01-15');
      expect(data.explanation, 'Una explicación larga del cielo nocturno.');
      expect(data.imageUrl, 'https://example.com/image.jpg');
      expect(data.hdUrl, 'https://example.com/hd.jpg');
      expect(data.mediaType, 'image');
      expect(data.serviceVersion, 'v1');
      expect(data.copyright, 'Jane Doe');
    });
  });

  group('ApodData.fromJson — payload mínimo', () {
    test('usa strings vacíos cuando faltan las claves requeridas', () {
      final data = ApodData.fromJson({});

      expect(data.title, '');
      expect(data.date, '');
      expect(data.explanation, '');
      expect(data.mediaType, '');
      expect(data.serviceVersion, '');
    });

    test('imageUrl vacío si falta url pero las otras claves están', () {
      final data = ApodData.fromJson({
        'title': 'X',
        'date': '2024-01-01',
        'explanation': 'Y',
        'media_type': 'image',
        'service_version': 'v1',
      });

      expect(data.imageUrl, '');
    });
  });

  group('ApodData.fromJson — opcionales', () {
    test('copyright y hdUrl son null cuando no vienen', () {
      final data = ApodData.fromJson({
        'title': 'X',
        'date': '2024-01-01',
        'explanation': 'Y',
        'media_type': 'image',
        'service_version': 'v1',
        'url': 'https://example.com/i.jpg',
      });

      expect(data.copyright, isNull);
      expect(data.hdUrl, isNull);
    });

    test('copyright null explícito se respeta', () {
      final data = ApodData.fromJson({
        'copyright': null,
        'title': 'X',
        'date': '2024-01-01',
        'explanation': 'Y',
        'media_type': 'image',
        'service_version': 'v1',
      });

      expect(data.copyright, isNull);
    });
  });

  group('ApodData.fromJson — tipo de medio', () {
    test('video: media_type "video" se guarda correctamente', () {
      final data = ApodData.fromJson({
        'title': 'Astronomy Video',
        'date': '2024-02-01',
        'explanation': 'Un video.',
        'media_type': 'video',
        'service_version': 'v1',
        'url': 'https://youtube.com/xyz',
      });

      expect(data.mediaType, 'video');
      expect(data.imageUrl, 'https://youtube.com/xyz');
    });
  });
}