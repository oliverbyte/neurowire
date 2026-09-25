import 'package:flutter/material.dart';

/// Hand-rolled localization for the small set of UI strings used in the app
/// (German default, English alternative) — no codegen/ARB files needed for
/// this scope.
class AppStrings {
  final Locale locale;

  const AppStrings(this.locale);

  static const supportedLocales = [Locale('de'), Locale('en')];

  static AppStrings of(BuildContext context) => Localizations.of<AppStrings>(context, AppStrings)!;

  bool get _en => locale.languageCode == 'en';

  String get tagline => _en ? 'Spot the trigger. Respond in a healthy way.' : 'Trigger erkennen. Gesund reagieren.';
  String get editButtons => _en ? 'Edit buttons' : 'Buttons bearbeiten';
  String get done => _en ? 'Done' : 'Fertig';
  String get newButtonTitle => _en ? 'New button' : 'Neuer Button';
  String get newButtonHint => _en ? 'e.g. Anger' : 'z.B. Wut';
  String get newButtonDefaultItem => _en ? 'Breathe' : 'Atmen';
  String get renameTitle => _en ? 'Rename' : 'Umbenennen';
  String get deleteButtonTitle => _en ? 'Delete button?' : 'Button löschen?';
  String deleteButtonContent(String label) =>
      _en ? '"$label" and its checklist will be removed.' : '"$label" und seine Checkliste werden entfernt.';

  String get editChecklist => _en ? 'Edit checklist' : 'Checkliste bearbeiten';
  String get addItemTitle => _en ? 'Add item' : 'Punkt hinzufügen';
  String get addItemHint => _en ? 'e.g. Go for a walk' : 'z.B. Spazieren gehen';
  String get editItemTitle => _en ? 'Edit item' : 'Punkt bearbeiten';
  String get deleteItemTitle => _en ? 'Delete item?' : 'Punkt löschen?';
  String deleteItemContent(String text) =>
      _en ? '"$text" will be removed from the checklist.' : '"$text" wird aus der Checkliste entfernt.';
  String get emptyChecklist => _en ? 'No items yet. Tap + to add one.' : 'Keine Punkte. Tippe auf + zum Hinzufügen.';
  String progressLabel(int done, int total) => _en ? '$done of $total done' : '$done von $total erledigt';

  String get save => _en ? 'Save' : 'Speichern';
  String get cancel => _en ? 'Cancel' : 'Abbrechen';
  String get delete => _en ? 'Delete' : 'Löschen';

  String get language => _en ? 'Language' : 'Sprache';
  String get languageSystem => _en ? 'Automatic' : 'Automatisch';
  String get languageGerman => 'Deutsch';
  String get languageEnglish => 'English';
}

class AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppStringsDelegate();

  @override
  bool isSupported(Locale locale) => AppStrings.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);

  @override
  bool shouldReload(AppStringsDelegate old) => false;
}
