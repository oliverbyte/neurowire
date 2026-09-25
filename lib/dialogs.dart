import 'package:flutter/material.dart';

import 'l10n/app_strings.dart';

/// Shows a text-input dialog and returns the entered value, or null if cancelled.
Future<String?> promptText(
  BuildContext context, {
  required String title,
  String hint = '',
  String initial = '',
}) {
  final controller = TextEditingController(text: initial);
  final strings = AppStrings.of(context);
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(hintText: hint),
        onSubmitted: (value) => Navigator.pop(ctx, value),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(strings.cancel)),
        TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: Text(strings.save)),
      ],
    ),
  );
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  String? confirmLabel,
}) async {
  final strings = AppStrings.of(context);
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(strings.cancel)),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(confirmLabel ?? strings.delete)),
      ],
    ),
  );
  return result ?? false;
}
