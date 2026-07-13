// Esta página muestra cómo obtener una lista de personajes de Star Wars
// desde la SWAPI (https://swapi.dev/) usando el paquete http, y cómo
// implementar paginación basada en el campo `next` que devuelve la API.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sample_app/model/star_wars_character.dart';

class StarWarsPage extends StatefulWidget {
  const StarWarsPage({super.key, this.client});

  final http.Client? client;

  @override
  State<StarWarsPage> createState() => _StarWarsPageState();
}

class _StarWarsPageState extends State<StarWarsPage> {
  late final PagingController<int, StarWarsCharacter> _pagingController =
      PagingController<int, StarWarsCharacter>(
    getNextPageKey: (state) {
      if (state.lastPageIsEmpty) return null;
      return state.nextIntPageKey;
    },
    fetchPage: _fetchCharacters,
  );

  @override
  void initState() {
    super.initState();
    _pagingController.fetchNextPage();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  /// Obtiene una página de personajes desde [firstPage].
  ///
  /// SWAPI devuelve `{ "count": int, "next": String|null, "previous": String|null, "results": List }`.
  /// Acumulamos results y guardamos next para la siguiente carga.
  Future<List<StarWarsCharacter>> _fetchCharacters(int pageKey) async {
    try {
      final response = await (widget.client ?? http.Client()).get(
        Uri.parse('https://swapi.dev/api/people/?page=$pageKey'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> results = body['results'] as List<dynamic>;

        return results
            .map((json) =>
                StarWarsCharacter.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> _refresh() async {
    _pagingController.refresh();
    _pagingController.fetchNextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Star Wars — Personajes')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: PagingListener<int, StarWarsCharacter>(
          controller: _pagingController,
          builder: (context, state, fetchNextPage) {
            return PagedListView<int, StarWarsCharacter>(
              state: state,
              fetchNextPage: fetchNextPage,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              builderDelegate: PagedChildBuilderDelegate<StarWarsCharacter>(
                itemBuilder: (context, character, index) =>
                    CharacterExpansionTile(character: character),
                firstPageProgressIndicatorBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                newPageProgressIndicatorBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Cargando más personajes...'),
                      ],
                    ),
                  ),
                ),
                firstPageErrorIndicatorBuilder: (context) => _ErrorView(
                  message: state.error?.toString() ??
                      'No se pudieron cargar los personajes.',
                  onRetry: _refresh,
                ),
                newPageErrorIndicatorBuilder: (context) => _ErrorView(
                  message: state.error?.toString() ??
                      'No se pudieron cargar más personajes.',
                  onRetry: () => _pagingController.fetchNextPage(),
                ),
                noMoreItemsIndicatorBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No hay más personajes 🎬')),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Tile desplegable que muestra un personaje y, al expandirse, su detalle.
class CharacterExpansionTile extends StatelessWidget {
  const CharacterExpansionTile({super.key, required this.character});

  final StarWarsCharacter character;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
          child: Text('${character.id}'),
        ),
        title: Text(character.name),
        subtitle: Text(
          'Altura: ${character.height} cm · Peso: ${character.mass} kg',
        ),
        children: [
          _Detail(label: 'Color de pelo', value: character.hairColor),
          _Detail(label: 'Color de piel', value: character.skinColor),
          _Detail(label: 'Color de ojos', value: character.eyeColor),
          _Detail(label: 'Año de nacimiento', value: character.birthYear),
          _Detail(label: 'Género', value: character.gender),
          _Detail(label: 'Id SWAPI', value: '${character.id}'),
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}