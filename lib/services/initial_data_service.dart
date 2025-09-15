import 'package:flutter/material.dart';
import 'package:juskar/models/category.dart';
import 'package:juskar/services/firebase_category_service.dart';

class InitialDataService {
  static Future<void> createDefaultCategories() async {
    try {
      // Verificar si ya existen categorías
      final existingCategories = await FirebaseCategoryService.getCategories().first;
      
      if (existingCategories.isNotEmpty) {
        print('Ya existen categorías, omitiendo creación de datos iniciales');
        return;
      }

      // Crear categorías por defecto
      final defaultCategories = [
        Category(
          id: '',
          nombre: 'Tortas',
          color: const Color(0xFFE91E63),
        ),
        Category(
          id: '',
          nombre: 'Pasteles',
          color: const Color(0xFF2196F3),
        ),
        Category(
          id: '',
          nombre: 'Cupcakes',
          color: const Color(0xFF4CAF50),
        ),
        Category(
          id: '',
          nombre: 'Panes',
          color: const Color(0xFFFF9800),
        ),
        Category(
          id: '',
          nombre: 'Chocolate',
          color: const Color(0xFF8B4513),
        ),
        Category(
          id: '',
          nombre: 'Galletas',
          color: const Color(0xFF9C27B0),
        ),
      ];

      for (final category in defaultCategories) {
        await FirebaseCategoryService.addCategory(category);
        print('Categoría creada: ${category.nombre}');
      }

      print('Categorías por defecto creadas exitosamente');
    } catch (e) {
      print('Error al crear categorías por defecto: $e');
    }
  }
}