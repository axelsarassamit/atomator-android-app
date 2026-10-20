import 'package:flutter/material.dart';

const atomatorAccent = Color(0xFF50D9E6);
const atomatorSurface = Color(0xFF161B22);

final atomatorTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0D1117),
  primaryColor: atomatorAccent,
  colorScheme: const ColorScheme.dark(
    primary: atomatorAccent,
    onPrimary: Color(0xFF00363D),
    secondary: Color(0xFF78DEAC),
    surface: atomatorSurface,
    onSurface: Color(0xFFE7EDF5),
    error: Color(0xFFFFB4AB),
    outline: Color(0xFF506071),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0D1117),
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
  ),
  cardTheme: CardThemeData(
    color: atomatorSurface,
    elevation: 0,
    margin: const EdgeInsets.symmetric(vertical: 6),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: const BorderSide(color: Color(0xFF293543)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: atomatorSurface,
    contentPadding: const EdgeInsets.all(16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF506071)),
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: atomatorSurface,
    indicatorColor: atomatorAccent.withAlpha(35),
    height: 72,
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => TextStyle(
        fontSize: 11,
        fontWeight:
            states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
      ),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(48, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      color: Color(0xFFE7EDF5),
      letterSpacing: -0.8,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xFFE7EDF5),
    ),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFC3CEDA)),
    bodySmall: TextStyle(fontSize: 12, color: Color(0xFFA2B1C2), height: 1.5),
  ),
);
