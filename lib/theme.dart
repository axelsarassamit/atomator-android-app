import 'package:flutter/material.dart';

final atomatorTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0D1117),
  primaryColor: const Color(0xFF00BCD4),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF00BCD4),
    secondary: Color(0xFF4CAF50),
    surface: Color(0xFF161B22),
    error: Color(0xFFEF5350),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF161B22),
    elevation: 0,
  ),
  cardTheme: const CardThemeData(
    color: Color(0xFF161B22),
    elevation: 2,
    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00BCD4)),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFB0BEC5)),
    bodySmall: TextStyle(fontSize: 12, color: Color(0xFF78909C)),
  ),
);
