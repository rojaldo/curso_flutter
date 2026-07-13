/// Modelo de dominio para un personaje de Star Wars.
///
/// Mapea los campos del endpoint `/people/` de la SWAPI
/// (https://swapi.dev/documentation#people).
class StarWarsCharacter {
  StarWarsCharacter({
    required this.name,
    required this.height,
    required this.mass,
    required this.hairColor,
    required this.skinColor,
    required this.eyeColor,
    required this.birthYear,
    required this.gender,
    required this.url,
  });

  /// Nombre del personaje.
  final String name;

  /// Altura en centímetros ("unknown" si SWAPI no la sabe).
  final String height;

  /// Peso en kilogramos ("unknown" si SWAPI no lo sabe).
  final String mass;

  /// Color de pelo ("unknown" si aplica).
  final String hairColor;

  /// Color de piel.
  final String skinColor;

  /// Color de ojos.
  final String eyeColor;

  /// Año de nacimiento (formato BBY/ABY o "unknown").
  final String birthYear;

  /// Género ("male", "female", "n/a", "unknown"...).
  final String gender;

  /// URL del recurso en SWAPI (contiene el id al final).
  final String url;

  factory StarWarsCharacter.fromJson(Map<String, dynamic> json) {
    return StarWarsCharacter(
      name: json['name'] as String? ?? '',
      height: json['height'] as String? ?? '',
      mass: json['mass'] as String? ?? '',
      hairColor: json['hair_color'] as String? ?? '',
      skinColor: json['skin_color'] as String? ?? '',
      eyeColor: json['eye_color'] as String? ?? '',
      birthYear: json['birth_year'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  /// Id numérico extraído de `url` (ej: ".../people/1/" → 1).
  /// Útil como avatar con número y como clave estable de la lista.
  int get id {
    final match = RegExp(r'/people/(\d+)/').firstMatch(url);
    return match == null ? 0 : int.tryParse(match.group(1)!) ?? 0;
  }
}