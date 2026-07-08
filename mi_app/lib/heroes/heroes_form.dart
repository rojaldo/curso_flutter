import 'package:flutter/material.dart';

class HeroesFormWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAddHero;

  const HeroesFormWidget({super.key, required this.controller, required this.onAddHero});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'New Hero',
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onAddHero,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}