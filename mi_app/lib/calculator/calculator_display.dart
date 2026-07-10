import 'package:flutter/material.dart';

class DisplayWidget extends StatelessWidget {
  final String display;

  const DisplayWidget({super.key, required this.display});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.all(16),
      child: Text(display, style: const TextStyle(fontSize: 32)),
    );
  }
}
