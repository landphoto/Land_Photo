import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData build() {
    final seed = const Color(0xFF00DBC5); // تركواز ناعم
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: seed,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0B0F14),
      textTheme: const TextTheme(
        headlineMedium:
            TextStyle(fontWeight: FontWeight.w700, letterSpacing: .2),
        titleLarge: TextStyle(fontWeight: FontWeight.w600),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: Colors.white.withOpacity(.06),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF00DBC5)),
        ),
      ),
    );
  }
}