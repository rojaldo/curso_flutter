import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mi_app/model/trivial.dart';
import 'package:mi_app/trivial/trivial_card.dart';
import 'package:mi_app/trivial/trivial_provider.dart';
import 'package:mi_app/trivial/trivial_supabase_service.dart';
import 'package:provider/provider.dart';

class TrivialPage extends StatefulWidget {
  const TrivialPage({super.key});

  @override
  State<TrivialPage> createState() => _TrivialPageState();
}

class _TrivialPageState extends State<TrivialPage> {
  late final PagingController<int, Trivial> _pagingController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _pagingController = PagingController<int, Trivial>(
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
      fetchPage: (pageKey) => context.read<TrivialProvider>().fetchPage(pageKey),
    );
    // Si hay sesión guardada, restaura el estado desde Supabase antes de
    // dejar que el PagingController pida la primera página.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeRestore());
  }

  Future<void> _maybeRestore() async {
    if (!TrivialSupabaseService.isLoggedIn) return;
    try {
      final saved = await TrivialSupabaseService.loadState();
      if (!mounted) return;
      if (saved != null && saved.questions.isNotEmpty) {
        context.read<TrivialProvider>().loadFromSavedState(
              saved.score,
              saved.questions,
            );
        _pagingController.refresh();
      }
    } catch (_) {
      // Si falla la restauración, no bloquea el juego local.
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _onCloudPressed() async {
    if (!TrivialSupabaseService.isLoggedIn) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => const _LoginDialog(),
      );
      if (!mounted || ok != true) return;
    }
    setState(() => _saving = true);
    String? error;
    try {
      await context.read<TrivialProvider>().saveToSupabase();
    } catch (e) {
      error = '$e';
    }
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error != null ? 'Error: $error' : 'Estado guardado en Supabase'),
        backgroundColor: error != null ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrivialProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trivial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: provider.loading
                ? null
                : () async {
                    await provider.refresh();
                    _pagingController.refresh();
                  },
          ),
          const _AuthIndicator(),
        ],
      ),
      // FAB score a la derecha (siempre visible).
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // FAB nube a la izquierda: sube el estado a Supabase.
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: _saveStateButton(),
          ),
          _scoreFab(provider.score),
        ],
      ),
      body: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) {
          return RefreshIndicator(
            onRefresh: () async {
              await provider.refresh();
              _pagingController.refresh();
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = _columnsFor(constraints.maxWidth);
                if (columns == 1) {
                  return PagedListView<int, Trivial>(
                    state: state,
                    fetchNextPage: fetchNextPage,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    builderDelegate: PagedChildBuilderDelegate<Trivial>(
                      itemBuilder: (context, item, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TrivialCard(
                          question: item,
                          index: index,
                          onAnswer: (a) =>
                              provider.respondByIndex(index, a),
                        ),
                      ),
                      firstPageProgressIndicatorBuilder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                      newPageProgressIndicatorBuilder: (_) => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      firstPageErrorIndicatorBuilder: (_) => Center(
                        child: Text('Error: ${provider.error ?? ""}'),
                      ),
                      noItemsFoundIndicatorBuilder: (_) =>
                          const Center(child: Text('Sin preguntas')),
                    ),
                  );
                }
                return PagedGridView<int, Trivial>(
                  state: state,
                  fetchNextPage: fetchNextPage,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  showNewPageProgressIndicatorAsGridChild: false,
                  showNewPageErrorIndicatorAsGridChild: false,
                  showNoMoreItemsIndicatorAsGridChild: false,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: _aspectFor(columns),
                  ),
                  builderDelegate: PagedChildBuilderDelegate<Trivial>(
                    itemBuilder: (context, item, index) => TrivialCard(
                      question: item,
                      index: index,
                      onAnswer: (a) => provider.respondByIndex(index, a),
                    ),
                    firstPageProgressIndicatorBuilder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                    newPageProgressIndicatorBuilder: (_) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    firstPageErrorIndicatorBuilder: (_) => Center(
                      child: Text('Error: ${provider.error ?? ""}'),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _saveStateButton() {
    return FloatingActionButton(
      heroTag: 'trivial_save',
      tooltip: 'Guardar estado en Supabase',
      onPressed: _saving ? null : _onCloudPressed,
      child: _saving
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.cloud_upload),
    );
  }

  Widget _scoreFab(int score) {
    return FloatingActionButton(
      heroTag: 'trivial_score',
      onPressed: null,
      tooltip: 'Puntuación: +2 acierto, -1 fallo',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: FittedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 18),
              Text(
                '$score',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _columnsFor(double width) {
    if (width >= 1100) return 3;
    if (width >= 700) return 2;
    return 1;
  }

  double _aspectFor(int columns) {
    return switch (columns) {
      3 => 0.62,
      2 => 0.75,
      _ => 0.0,
    };
  }
}

/// Indicador de sesión en el AppBar: avatar + email si logueado,
/// icono de persona tachada si no.
class _AuthIndicator extends StatelessWidget {
  const _AuthIndicator();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: TrivialSupabaseService.isLoggedIn,
      stream: TrivialSupabaseService.authChanges
          .map((event) => event.session?.user != null),
      builder: (context, snap) {
        final loggedIn = snap.data ?? false;
        if (!loggedIn) {
          return IconButton(
            icon: const Icon(Icons.person_off),
            tooltip: 'Sin sesión',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const _LoginDialog(),
            ),
          );
        }
        final email = TrivialSupabaseService.currentEmail ?? '—';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  email,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Modal de login con email + password.
class _LoginDialog extends StatefulWidget {
  const _LoginDialog();

  @override
  State<_LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<_LoginDialog> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await TrivialSupabaseService.signIn(_email.text, _password.text);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Iniciar sesión en Supabase'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
              onSubmitted: (_) => _submit(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: const Text('Entrar'),
        ),
      ],
    );
  }
}