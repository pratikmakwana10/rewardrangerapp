import 'package:flutter/material.dart';

const Color scaffoldBackgroundColor = Color.fromARGB(223, 6, 0, 42);

final ThemeData darkTheme = ThemeData(
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromRGBO(20, 34, 74, 1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 255, 255, 255),
    brightness: Brightness.dark,
    onPrimary: scaffoldBackgroundColor,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: scaffoldBackgroundColor,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
    ),
  ),
  useMaterial3: true,
  scaffoldBackgroundColor: scaffoldBackgroundColor,
);
