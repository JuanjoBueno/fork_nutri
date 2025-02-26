import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xff00B894);
  static const Color secondary = Colors.white;

  static final ThemeData lightTheme = ThemeData.light().copyWith(
    // textFormFileTheme
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: primary,
      selectionColor: primary,
      selectionHandleColor: primary,
    ),
    // elevatedButtonTheme
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: secondary,
            shape: const StadiumBorder(),
            elevation: 8,
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ))),
    // inputDecorationTheme
    inputDecorationTheme: InputDecorationTheme(
      prefixIconColor: WidgetStateColor.resolveWith((Set<WidgetState> states) =>
          states.contains(WidgetState.error)
              ? const Color.fromARGB(255, 205, 108, 108)
              : primary),
      suffixIconColor: WidgetStateColor.resolveWith((Set<WidgetState> states) =>
          states.contains(WidgetState.error)
              ? const Color.fromARGB(255, 205, 108, 108)
              : primary),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.7),
      floatingLabelStyle: WidgetStateTextStyle.resolveWith(
        (Set<WidgetState> states) => TextStyle(
          color: states.contains(WidgetState.error)
              ? const Color.fromARGB(255, 205, 108, 108)
              : primary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: primary,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: primary,
          width: 2.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: const Color.fromARGB(255, 205, 108, 108),
          width: 2,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(
          color: Colors.grey,
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 20,
      ),
    ),
    // textButtonTheme
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary)),
    //alertDialogTheme
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 24,
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: primary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: TextStyle(
        color: Colors.grey[700],
        fontSize: 16,
      ),
    ),
  );
}
