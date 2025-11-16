import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    final baseColorScheme = ColorScheme.fromSeed(seedColor: Colors.indigo);

    return ThemeData(
      colorScheme: baseColorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: baseColorScheme.surface,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: baseColorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }
}

