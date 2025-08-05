import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Colors.green; 
  static const Color secondaryColor = Color.fromARGB(213, 72, 238, 119); 
  static const Color scaffoldBackground = Color(0xFFF5F7FA); 
  static const Color cardColor = Colors.white;

  
  static const TextStyle titleText = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle subtitleText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black54,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  static const TextStyle captionText = TextStyle(
    fontSize: 12,
    color: Colors.black45,
  );

  static final ThemeData themeData = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: scaffoldBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
    cardTheme: const CardThemeData(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
      margin: EdgeInsets.symmetric(vertical: 6),
    ),
    iconTheme: const IconThemeData(color: primaryColor),
    textTheme: const TextTheme(
      titleLarge: titleText,
      titleMedium: subtitleText,
      bodyMedium: bodyText,
      bodySmall: captionText,
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),

      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),

      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),

      floatingLabelStyle: TextStyle(color: primaryColor),

      prefixStyle: TextStyle(color: primaryColor),
    ),
  );
}
