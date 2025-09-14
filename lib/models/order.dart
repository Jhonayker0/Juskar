import 'package:juskar/models/category.dart';

class Order {
  final String id;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final Category categoria;
  final String cliente;
  final String contacto;
  final String tamano;
  final String leyenda;
  final int edad;
  final double valor;
  final double abono;
  final String domicilio;
  final bool completado;

  Order({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.categoria,
    required this.cliente,
    required this.contacto,
    required this.tamano,
    required this.leyenda,
    required this.edad,
    required this.valor,
    required this.abono,
    required this.domicilio,
    this.completado = false,
  });

  // Calculamos el saldo pendiente
  double get saldoPendiente => valor - abono;

  // Copia del objeto con algunos campos modificados
  Order copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    DateTime? fecha,
    Category? categoria,
    String? cliente,
    String? contacto,
    String? tamano,
    String? leyenda,
    int? edad,
    double? valor,
    double? abono,
    String? domicilio,
    bool? completado,
  }) {
    return Order(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      fecha: fecha ?? this.fecha,
      categoria: categoria ?? this.categoria,
      cliente: cliente ?? this.cliente,
      contacto: contacto ?? this.contacto,
      tamano: tamano ?? this.tamano,
      leyenda: leyenda ?? this.leyenda,
      edad: edad ?? this.edad,
      valor: valor ?? this.valor,
      abono: abono ?? this.abono,
      domicilio: domicilio ?? this.domicilio,
      completado: completado ?? this.completado,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fecha: DateTime.parse(json['fecha']),
      categoria: Category.fromJson(json['categoria']),
      cliente: json['cliente'],
      contacto: json['contacto'],
      tamano: json['tamano'],
      leyenda: json['leyenda'],
      edad: json['edad'],
      valor: json['valor'].toDouble(),
      abono: json['abono'].toDouble(),
      domicilio: json['domicilio'],
      completado: json['completado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
      'categoria': categoria.toJson(),
      'cliente': cliente,
      'contacto': contacto,
      'tamano': tamano,
      'leyenda': leyenda,
      'edad': edad,
      'valor': valor,
      'abono': abono,
      'domicilio': domicilio,
      'completado': completado,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
