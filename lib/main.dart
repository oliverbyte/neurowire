import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'home_screen.dart';
import 'l10n/app_strings.dart';
import 'locale_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeController = LocaleController();
  await localeController.load();
  runApp(NeuroWireApp(localeController: localeController));
}

class NeuroWireApp extends StatelessWidget {
  final LocaleController localeController;

  const NeuroWireApp({super.key, required this.localeController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: localeController,
      builder: (context, _) {
        return MaterialApp(
          title: 'NeuroWire',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            useMaterial3: true,
          ),
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: const [
            AppStringsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: localeController.override,
          localeResolutionCallback: (deviceLocale, supported) {
            if (localeController.override != null) return localeController.override;
            return LocaleController.resolveSystemLocale(deviceLocale == null ? null : [deviceLocale]);
          },
          home: HomeScreen(localeController: localeController),
        );
      },
    );
  }
}
