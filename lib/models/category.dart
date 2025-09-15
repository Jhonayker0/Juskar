import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String nombre;
  final Color color;

  Category({
    required this.id,
    required this.nombre,
    required this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      nombre: json['nombre'],
      color: Color(json['color']),
    );
  }

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      nombre: data['nombre'] ?? '',
      color: Color(data['color'] ?? 0xFF2196F3),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'color': color.value,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'color': color.value,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
