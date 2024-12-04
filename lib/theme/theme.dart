import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.cyan.shade800,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Colors.blueGrey, // Button color
      textTheme: ButtonTextTheme.primary, // Text color on buttons
    ),
  );
}
