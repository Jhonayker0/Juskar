import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _ordersFolder = 'orders';

  /// Subir múltiples imágenes a Firebase Storage y retornar las URLs
  static Future<List<String>> uploadOrderImages(List<File> imageFiles) async {
    if (imageFiles.isEmpty) return [];
    
    try {
      List<String> imageUrls = [];
      
      for (File imageFile in imageFiles) {
        final url = await uploadOrderImage(imageFile);
        if (url != null) {
          imageUrls.add(url);
        }
      }
      
      return imageUrls;
    } catch (e) {
      throw Exception('Error al subir imágenes: $e');
    }
  }

  /// Subir imagen a Firebase Storage y retornar la URL
  static Future<String?> uploadOrderImage(File imageFile) async {
    try {
      // Generar un nombre único para la imagen
      const uuid = Uuid();
      final fileName = '${uuid.v4()}.jpg';
      final path = '$_ordersFolder/$fileName';

      // Crear referencia al archivo
      final ref = _storage.ref().child(path);

      // Configurar metadatos
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Subir archivo
      final uploadTask = ref.putFile(imageFile, metadata);
      final snapshot = await uploadTask;

      // Obtener URL de descarga
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  /// Eliminar imagen de Firebase Storage
  static Future<void> deleteOrderImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Error al eliminar imagen: $e');
    }
  }

  /// Seleccionar una o varias imágenes desde galería
  static Future<List<File>?> pickImagesFromGallery() async {
    try {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        return pickedFiles.map((file) => File(file.path)).toList();
      }
      return null;
    } catch (e) {
      throw Exception('Error al seleccionar imagen: $e');
    }
  }

  /// Seleccionar imagen desde cámara
  static Future<File?> pickImageFromCamera() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Error al tomar foto: $e');
    }
  }

  /// Mostrar diálogo para seleccionar fuente de imagen
  static Future<List<File>?> showImageSourceDialog(BuildContext context) async {
    final String? result = await showDialog<String?>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Seleccionar imágenes',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF7C7BFF)),
                title: const Text('Galería', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.of(dialogContext).pop('gallery');
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF7C7BFF)),
                title: const Text('Cámara', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.of(dialogContext).pop('camera');
                },
              ),
            ],
          ),
        );
      },
    );

    // Manejar la selección fuera del diálogo
    if (result == null) return null;
    
    if (result == 'gallery') {
      return await pickImagesFromGallery();
    } else if (result == 'camera') {
      final image = await pickImageFromCamera();
      return image == null ? null : [image];
    }
    
    return null;
  }
}