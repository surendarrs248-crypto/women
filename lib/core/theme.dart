import 'package:flutter/material.dart';

import 'constants.dart';

ThemeData sakhiTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: C.night,
    colorScheme: base.colorScheme.copyWith(
      primary: C.rose,
      secondary: C.amber,
      surface: C.night2,
      error: C.roseDeep,
    ),
    textTheme: base.textTheme.apply(bodyColor: C.ink, displayColor: C.ink),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.black.withValues(alpha: .30),
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      hintStyle: const TextStyle(color: C.faint),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(C.rSm),
        borderSide: BorderSide(color: C.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(C.rSm),
        borderSide: const BorderSide(color: C.violet),
      ),
    ),
    dividerColor: C.line,
    splashFactory: InkSparkle.splashFactory,
  );
}