import 'package:flutter/material.dart';

class AppTheme {

  static const Color primaryColor = Color(0xFF2E7D32); 
  static const Color primaryLight = Color(0xFF60AD5E); 
  static const Color primaryDark = Color(0xFF005005); 
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Colors.black87;
  static const Color cardColor = Color(0xFFDFF5E1);
  static const Color buttonColor = Color(0xFF007F00); 

  // Tema global
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: primaryColor,
        secondary: primaryLight,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: textColor),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
  style: ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith<Color>(
      (states) {
        if (states.contains(WidgetState.pressed)) return primaryDark;
        if (states.contains(WidgetState.hovered)) return primaryLight;
        return primaryColor;
      },
    ),
    foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
    textStyle: WidgetStateProperty.all<TextStyle>(
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    padding: WidgetStateProperty.all<EdgeInsets>(
      const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
    ),
    elevation: WidgetStateProperty.all(4),
    overlayColor: WidgetStateProperty.all(primaryDark.withOpacity(0.1)),
  ),
),



      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primaryDark, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: const TextStyle(color: textColor),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
    );
  }

  
  static const TextStyle titleText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static const TextStyle labelText = TextStyle(
    fontSize: 16,
    color: textColor,
  );

  static const TextStyle errorText = TextStyle(
    fontSize: 14,
    color: Colors.red,
  );
}
