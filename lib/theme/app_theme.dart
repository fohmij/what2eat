import 'package:flutter/material.dart';

class AppTheme {
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

    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: const BorderSide(
        color: Color.fromARGB(255, 200, 200, 200),
        width: 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 41, 95, 44),
        fontSize: 13,
      ),

      backgroundColor: Colors.transparent,
      selectedColor: Color.fromARGB(255, 0, 255, 8).withAlpha(70),
      checkmarkColor: Colors.white,
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Color.fromARGB(255, 161, 161, 161)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Color.fromARGB(255, 200, 200, 200)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(
          color: Color.fromARGB(255, 75, 176, 80), 
          width: 2,
        ),
      ),

      labelStyle: TextStyle(color: Colors.black),

      floatingLabelStyle: TextStyle(color: Color.fromARGB(255, 75, 176, 80)),

      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: const BorderSide(color: Color.fromARGB(255, 49, 49, 49), width: 1),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      labelStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontSize: 13,
      ),
      backgroundColor: Colors.transparent,
      selectedColor: Color.fromARGB(40, 100, 255, 0),
      checkmarkColor: Colors.white,
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(color: Color.fromARGB(255, 100, 100, 100)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(
          color: Color.fromARGB(255, 75, 176, 80), // 👈 dein primary
          width: 2,
        ),
      ),

      labelStyle: TextStyle(color: Colors.grey),

      floatingLabelStyle: TextStyle(color: Color.fromARGB(255, 75, 176, 80)),

      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
  );
}
