import 'package:flutter/material.dart';

/// Curated brand palette so every trigger button gets its own recognizable
/// color + icon pairing (assigned once at creation, then persisted).
class BrandPalette {
  static const List<Color> colors = [
    Color(0xFFEF5350), // red
    Color(0xFFFFA726), // amber
    Color(0xFF5C6BC0), // indigo
    Color(0xFF26A69A), // teal
    Color(0xFFAB47BC), // purple
    Color(0xFF42A5F5), // blue
    Color(0xFFEC407A), // pink
    Color(0xFF66BB6A), // green
    Color(0xFF8D6E63), // brown
    Color(0xFF26C6DA), // cyan
  ];

  static const List<IconData> icons = [
    Icons.bolt_rounded,
    Icons.restaurant_rounded,
    Icons.bedtime_rounded,
    Icons.self_improvement_rounded,
    Icons.favorite_rounded,
    Icons.spa_rounded,
    Icons.mood_rounded,
    Icons.psychology_rounded,
    Icons.nightlight_round,
    Icons.local_fire_department_rounded,
  ];

  static Color colorForIndex(int index) => colors[index % colors.length];
  static IconData iconForIndex(int index) => icons[index % icons.length];
}
