import 'package:flutter/material.dart';

class HeroesPage extends StatelessWidget {

  const HeroesPage({super.key});

  static const List<String> heroes = [
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heroes'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: heroes.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(heroes[index]),
            );
          },
        ),
      ),
    );
  }
}