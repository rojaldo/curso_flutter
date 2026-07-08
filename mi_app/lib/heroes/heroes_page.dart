import 'package:flutter/material.dart';
import 'package:mi_app/heroes/heroes_form.dart';
import 'package:mi_app/heroes/heroes_list.dart';

class HeroesPage extends StatelessWidget {

  const HeroesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heroes'),
      ),
      body: Center(
        child: HeroFormWidget()
      ),
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
  List<String> heroes = [
    'Superman',
    'Batman',
    'Wonder Woman',
    'Flash',
    'Green Lantern',
    'Aquaman',
    'Cyborg',
  ];

  @override
  Widget build(BuildContext context) {
    // formulario con campo de texto para nuevo heroe, boton de añadir y lista de heroes
    return (Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HeroesFormWidget(controller: _controller, onAddHero: _addHero),
        Expanded(
          child: HeroesListWidget(heroes: heroes),
        ),
      ],
    ));
  }
  
  void _addHero() {
    // get text from the text field and add it to the list of heroes
    // then clear the text field
    // then update the state of the widget
    setState(() {
      heroes.add(_controller.text);
      _controller.clear();
    });
  }
}



