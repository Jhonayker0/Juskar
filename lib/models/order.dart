import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String id;
  final List<String> imagenesUrls; // Cambiado de String? a List<String>
  final double pedidoAbono;
  final String pedidoCliente;
  final bool pedidoCompleto; // 1 = true, 0 = false
  final bool pedidoConfirma;
  final String pedidoContacto;
  final String pedidoDetalle;
  final String pedidoDomicilio;
  final DateTime pedidoFecha;
  final String pedidoLeyenda;
  final String pedidoLibras;
  final double pedidoValor;
  final String pedidoCategoria; // ID de la categoría

  Order({
    required this.id,
    this.imagenesUrls = const [], // Lista vacía por defecto
    required this.pedidoAbono,
    required this.pedidoCliente,
    required this.pedidoCompleto,
    required this.pedidoConfirma,
    required this.pedidoContacto,
    required this.pedidoDetalle,
    required this.pedidoDomicilio,
    required this.pedidoFecha,
    required this.pedidoLeyenda,
    required this.pedidoLibras,
    required this.pedidoValor,
    required this.pedidoCategoria,
  });

  // Calculamos el saldo pendiente
  double get saldoPendiente => pedidoValor - pedidoAbono;

  // Factory para crear desde Firestore
  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Función helper para convertir a String de manera segura
    String safeString(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is List) return value.join(', ');
      return value.toString();
    }
    
    // Función helper para convertir a bool de manera segura
    bool safeBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }
    
    // Función helper para convertir a double de manera segura
    double safeDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }
    // Función helper para convertir a List<String> de manera segura
    List<String> safeStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
      if (value is String && value.isNotEmpty) {
        return [value]; // Compatibilidad con formato anterior
      }
      return [];
    }
    
    return Order(
      id: doc.id,
      imagenesUrls: safeStringList(data['imagenesUrls'] ?? data['imageFoto']), // Compatibilidad
      pedidoAbono: safeDouble(data['pedidoAbono']),
      pedidoCliente: safeString(data['pedidoCliente']),
      pedidoCompleto: safeBool(data['pedidoCompleto']),
      pedidoConfirma: safeBool(data['pedidoConfirma']),
      pedidoContacto: safeString(data['pedidoContacto']),
      pedidoDetalle: safeString(data['pedidoDetalle']),
      pedidoDomicilio: safeString(data['pedidoDomicilio']),
      pedidoFecha: data['pedidoFecha'] != null 
          ? (data['pedidoFecha'] as Timestamp).toDate()
          : DateTime.now(),
      pedidoLeyenda: safeString(data['pedidoLeyenda']),
      pedidoLibras: safeString(data['pedidoLibras']),
      pedidoValor: safeDouble(data['pedidoValor']),
      pedidoCategoria: safeString(data['pedidoCategoria']),
    );
  }

  // Método para convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'imagenesUrls': imagenesUrls,
      'pedidoAbono': pedidoAbono,
      'pedidoCliente': pedidoCliente,
      'pedidoCompleto': pedidoCompleto ? 1 : 0,
      'pedidoConfirma': pedidoConfirma,
      'pedidoContacto': pedidoContacto,
      'pedidoDetalle': pedidoDetalle,
      'pedidoDomicilio': pedidoDomicilio,
      'pedidoFecha': Timestamp.fromDate(pedidoFecha),
      'pedidoLeyenda': pedidoLeyenda,
      'pedidoLibras': pedidoLibras,
      'pedidoValor': pedidoValor,
      'pedidoCategoria': pedidoCategoria,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Copia del objeto con algunos campos modificados
  Order copyWith({
    String? id,
    List<String>? imagenesUrls,
    double? pedidoAbono,
    String? pedidoCliente,
    bool? pedidoCompleto,
    bool? pedidoConfirma,
    String? pedidoContacto,
    String? pedidoDetalle,
    String? pedidoDomicilio,
    DateTime? pedidoFecha,
    String? pedidoLeyenda,
    String? pedidoLibras,
    double? pedidoValor,
    String? pedidoCategoria,
  }) {
    return Order(
      id: id ?? this.id,
      imagenesUrls: imagenesUrls ?? this.imagenesUrls,
      pedidoAbono: pedidoAbono ?? this.pedidoAbono,
      pedidoCliente: pedidoCliente ?? this.pedidoCliente,
      pedidoCompleto: pedidoCompleto ?? this.pedidoCompleto,
      pedidoConfirma: pedidoConfirma ?? this.pedidoConfirma,
      pedidoContacto: pedidoContacto ?? this.pedidoContacto,
      pedidoDetalle: pedidoDetalle ?? this.pedidoDetalle,
      pedidoDomicilio: pedidoDomicilio ?? this.pedidoDomicilio,
      pedidoFecha: pedidoFecha ?? this.pedidoFecha,
      pedidoLeyenda: pedidoLeyenda ?? this.pedidoLeyenda,
      pedidoLibras: pedidoLibras ?? this.pedidoLibras,
      pedidoValor: pedidoValor ?? this.pedidoValor,
      pedidoCategoria: pedidoCategoria ?? this.pedidoCategoria,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
