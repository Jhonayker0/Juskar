import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales basados en el mockup
  static const Color primaryColor = Color(0xFF7C7BFF); // Púrpura del botón +
  static const Color backgroundColor = Color.fromARGB(255, 70, 74, 159); // Fondo oscuro
  static const Color cardColor = Color(0xFF2A2A2A); // Color de las tarjetas
  static const Color textPrimaryColor = Colors.white;
  static const Color textSecondaryColor = Color.fromARGB(255, 233, 228, 228);
  static const Color searchBarColor = Color(0xFF333333);
  
  // Colores de estado (categorías)
  static const Color blueCategory = Color(0xFF7C7BFF);
  static const Color redCategory = Color(0xFFFF6B6B);
  static const Color orangeCategory = Color(0xFFFFB347);
  static const Color pinkCategory = Color(0xFFFF8FAB);
  static const Color greenCategory = Color(0xFF4ECDC4);
  static const Color brownCategory = Color(0xFF8B4513);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.deepPurple,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimaryColor),
      ),
      
      // Text theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimaryColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimaryColor,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textPrimaryColor,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: textSecondaryColor,
          fontSize: 12,
        ),
      ),
      
      // Input decoration theme (para search bar)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: searchBarColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(
          color: textSecondaryColor,
          fontSize: 14,
        ),
        prefixIconColor: textSecondaryColor,
      ),
      
      // Floating Action Button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      
      // Bottom Navigation Bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Elevated Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
  
  // Método para obtener color de categoría
  static Color getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'no confirmado':
        return blueCategory;
      case 'cupcake':
        return redCategory;
      case 'pendiente':
        return orangeCategory;
      case 'arequipe':
        return pinkCategory;
      case 'confirmado':
        return greenCategory;
      case 'chocolate':
        return brownCategory;
      default:
        return primaryColor;
    }
  }
}
