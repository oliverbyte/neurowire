import 'dart:math';

import 'package:flutter/material.dart';

import 'palette.dart';

String generateId() {
  // Avoid `1 << 32`: bitwise shifts truncate to 32 bits on web (dart2js),
  // producing 0 there instead of the VM's large value, which crashes Random.nextInt.
  final rand = Random().nextInt(0x7FFFFFFF);
  return '${DateTime.now().microsecondsSinceEpoch}_$rand';
}

class ChecklistItem {
  final String id;
  String text;

  ChecklistItem({required this.id, required this.text});

  factory ChecklistItem.create(String text) =>
      ChecklistItem(id: generateId(), text: text);

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        id: json['id'] as String,
        text: json['text'] as String,
      );

  Map<String, dynamic> toJson() => {'id': id, 'text': text};
}

class Trigger {
  final String id;
  String label;
  final int colorValue;
  final int iconIndex;
  final List<ChecklistItem> items;

  Trigger({
    required this.id,
    required this.label,
    required this.items,
    required this.colorValue,
    required this.iconIndex,
  });

  Color get color => Color(colorValue);

  factory Trigger.create(
    String label,
    List<String> itemTexts, {
    required int colorValue,
    required int iconIndex,
  }) =>
      Trigger(
        id: generateId(),
        label: label,
        items: itemTexts.map(ChecklistItem.create).toList(),
        colorValue: colorValue,
        iconIndex: iconIndex,
      );

  factory Trigger.fromJson(Map<String, dynamic> json, {int fallbackIndex = 0}) => Trigger(
        id: json['id'] as String,
        label: json['label'] as String,
        colorValue: json['colorValue'] as int? ?? BrandPalette.colorForIndex(fallbackIndex).toARGB32(),
        iconIndex: json['iconIndex'] as int? ?? fallbackIndex,
        items: (json['items'] as List)
            .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'colorValue': colorValue,
        'iconIndex': iconIndex,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

/// Seed content shown on first launch, matching the given UI locale
/// (German content by default, English when `locale` is English).
List<Trigger> defaultTriggers(Locale locale) {
  final english = locale.languageCode == 'en';
  return [
    Trigger.create(
      'Stress',
      english
          ? ['Breathe', 'Drink water', 'Step outside', 'Loosen your shoulders']
          : ['Atmen', 'Trinken', 'Kurz raus', 'Schultern lockern'],
      colorValue: 0xFFEF5350,
      iconIndex: 0,
    ),
    Trigger.create(
      'Hunger',
      english
          ? ['Drink a glass of water', 'Wait 10 minutes', 'Choose something healthy']
          : ['Glas Wasser trinken', '10 Min. warten', 'Gesund wählen'],
      colorValue: 0xFFFFA726,
      iconIndex: 1,
    ),
    Trigger.create(
      english ? 'Tired' : 'Müde',
      english
          ? ['Stand up', 'Open a window', 'Stretch', 'Drink water']
          : ['Aufstehen', 'Fenster öffnen', 'Strecken', 'Wasser trinken'],
      colorValue: 0xFF5C6BC0,
      iconIndex: 2,
    ),
  ];
}
