import 'package:flutter/material.dart';
import 'package:mi_app/heroes/heroes_form.dart';
import 'package:mi_app/heroes/heroes_list.dart';
import 'package:mi_app/heroes/heroes_provider.dart';
import 'package:provider/provider.dart';

class HeroesPage extends StatelessWidget {
  const HeroesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Heroes')),
      body: Center(child: HeroFormWidget()),
    );
  }
}

class HeroFormWidget extends StatefulWidget {
  const HeroFormWidget({super.key});

  @override
  State<HeroFormWidget> createState() => _HeroFormWidgetState();
}

class _HeroFormWidgetState extends State<HeroFormWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heroes = context.watch<HeroesProvider>().heroes;

    return (Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HeroesFormWidget(controller: _controller, onAddHero: _addHero),
        Expanded(child: HeroesListWidget(heroes: heroes)),
      ],
    ));
  }

  void _addHero() {
    context.read<HeroesProvider>().addHero(_controller.text);
    _controller.clear();
  }
}
