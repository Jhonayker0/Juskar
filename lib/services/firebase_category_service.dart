import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:juskar/models/category.dart';

class FirebaseCategoryService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'categorias';

  // Obtener todas las categorías
  static Stream<List<Category>> getCategories() {
    return _firestore
        .collection(_collection)
        .orderBy('nombre')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Category.fromFirestore(doc))
            .toList());
  }

  // Agregar nueva categoría
  static Future<String> addCategory(Category category) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        'nombre': category.nombre,
        'color': category.color.value,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear la categoría: $e');
    }
  }

  // Actualizar categoría existente
  static Future<void> updateCategory(Category category) async {
    try {
      await _firestore.collection(_collection).doc(category.id).update({
        'nombre': category.nombre,
        'color': category.color.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al actualizar la categoría: $e');
    }
  }

  // Eliminar categoría
  static Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection(_collection).doc(categoryId).delete();
    } catch (e) {
      throw Exception('Error al eliminar la categoría: $e');
    }
  }

  // Obtener categoría por ID
  static Future<Category?> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(categoryId).get();
      if (doc.exists) {
        return Category.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener la categoría: $e');
    }
  }

  // Verificar si existe una categoría con el mismo nombre
  static Future<bool> categoryNameExists(String name, {String? excludeId}) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('nombre', isEqualTo: name);

      final snapshot = await query.get();
      
      if (excludeId != null) {
        // Si estamos editando, excluir la categoría actual
        return snapshot.docs.any((doc) => doc.id != excludeId);
      }
      
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error al verificar el nombre de la categoría: $e');
    }
  }
}
