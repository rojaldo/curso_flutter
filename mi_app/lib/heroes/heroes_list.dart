import 'package:flutter/material.dart';

class HeroesListWidget extends StatelessWidget {
  final List<String> heroes;

  const HeroesListWidget({super.key, required this.heroes});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: heroes.length,
      itemBuilder: (context, index) {
        return ListTile(title: Text(heroes[index]));
      },
    );
  }
}
