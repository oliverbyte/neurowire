// Basic smoke test for the NeuroWire app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:neurowire/locale_controller.dart';
import 'package:neurowire/main.dart';

void main() {
  testWidgets('Home screen shows default trigger buttons', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    // flutter_test defaults to an English locale; force German so the
    // German seed content asserted below is deterministic.
    tester.platformDispatcher.localesTestValue = [const Locale('de')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    final localeController = LocaleController();
    await localeController.load();
    await tester.pumpWidget(NeuroWireApp(localeController: localeController));
    await tester.pumpAndSettle();

    expect(find.text('Stress'), findsOneWidget);
    expect(find.text('Hunger'), findsOneWidget);
    expect(find.text('Müde'), findsOneWidget);

    // Tapping a trigger opens its checklist, unchecked.
    await tester.tap(find.text('Stress'));
    await tester.pumpAndSettle();

    expect(find.text('Atmen'), findsOneWidget);
    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox).first);
    expect(checkbox.value, isFalse);
  });
}
