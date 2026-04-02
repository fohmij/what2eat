import 'package:flutter/material.dart';

class AppTheme {
  static const _green = Color(0xFF057B3A);

  // + viele weitere…
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,

      primary: Color.fromARGB(255, 75, 176, 80),
      onPrimary: Colors.white,

      secondary: Color(0xFF4CAF50),
      onSecondary: Colors.white,

      surface: Colors.white,
      onSurface: Colors.black,

      error: Colors.red,
      onError: Colors.white,
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,

      primary: Colors.green,
      // primary: Color.fromARGB(255, 54, 238, 244),
      onPrimary: Colors.black,

      secondary: Color(0xFF4CAF50),
      onSecondary: Colors.white,

      surface: Color.fromARGB(255, 25, 25, 35),
      onSurface: Colors.white,

      error: Colors.red,
      onError: Colors.black,
    ),
  );
}
