import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const black = Color(0xFF0F0F0F);
  const offWhite = Color(0xFFFAF9F7);
  const gold = Color(0xFFC9A84C);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: black,
    brightness: Brightness.light,
    primary: black,
    onPrimary: Colors.white,
    secondary: gold,
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: black,
    surfaceContainerHighest: const Color(0xFFF2F1EF),
    error: const Color(0xFFD32F2F),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: offWhite,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: offWhite,
      foregroundColor: black,
      titleTextStyle: TextStyle(
        color: black,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFF0EFED)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: black, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD32F2F)),
      ),
      labelStyle: const TextStyle(color: Color(0xFF888888), fontSize: 14),
      floatingLabelStyle: const TextStyle(color: black, fontSize: 12),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        elevation: 0,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: black,
        textStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: black,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: black,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      side: const BorderSide(color: Color(0xFFE8E8E8)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFF0EFED),
      thickness: 1,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: black,
      unselectedItemColor: Color(0xFFAAAAAA),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle:
          TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
      unselectedLabelStyle:
          TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
    ),
  );
}