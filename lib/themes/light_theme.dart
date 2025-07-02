import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.teal,
  primaryColor: const Color(0xFF2E7D8A),
  scaffoldBackgroundColor: const Color(0xFFF8FCFC),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2E7D8A),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF4CAF50),
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2E7D8A),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF0F8F8),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF2E7D8A), width: 2),
    ),
    labelStyle: const TextStyle(color: Color(0xFF666666)),
  ),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF2E7D8A),
    secondary: Color(0xFF4CAF50),
    surface: Colors.white,
    error: Color(0xFFE57373),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Color(0xFF333333),
    onError: Colors.white,
  ),
);
