import 'package:flutter/material.dart';

/// Modelo para un elemento del índice principal.
class ExampleItem {
  const ExampleItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    required this.category,
  });

  final int id;
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final String category;
}