// lib/core/theme/app_theme.dart
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return FlexThemeData.light(
      scheme: FlexScheme.redWine,
      textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      useMaterial3: true,
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    return FlexThemeData.dark(
      scheme: FlexScheme.redWine,
      textTheme: GoogleFonts.interTextTheme(Theme.of(context).primaryTextTheme),
      useMaterial3: true,
    );
  }
}