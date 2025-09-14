import 'package:flutter/material.dart';
import 'package:juskar/models/category.dart';
import 'package:juskar/models/order.dart';

class MockDataService {
  static final List<Category> _categories = [
    Category(
      id: '1',
      name: 'No confirmado',
      color: const Color(0xFF7C7BFF), // Azul/púrpura del mockup
    ),
    Category(
      id: '2',
      name: 'Cupcake',
      color: const Color(0xFFFF6B6B), // Rojo del mockup
    ),
    Category(
      id: '3',
      name: 'Pendiente',
      color: const Color(0xFFFFB347), // Naranja del mockup
    ),
    Category(
      id: '4',
      name: 'Arequipe',
      color: const Color(0xFFFF8FAB), // Rosa del mockup
    ),
    Category(
      id: '5',
      name: 'Confirmado',
      color: const Color(0xFF4ECDC4), // Verde turquesa
    ),
    Category(
      id: '6',
      name: 'Chocolate',
      color: const Color(0xFF8B4513), // Café chocolate
    ),
  ];

  static final List<Order> _orders = [
    Order(
      id: '1',
      titulo: 'Torta en crema con Flores de Papel',
      descripcion: 'Torta decorada con flores de papel comestibles',
      fecha: DateTime(2024, 10, 9),
      categoria: _categories[0], // No confirmado
      cliente: 'María González',
      contacto: '3001234567',
      tamano: 'Mediana',
      leyenda: 'Feliz Cumpleaños',
      edad: 25,
      valor: 120000,
      abono: 60000,
      domicilio: 'Calle 123 #45-67',
      completado: false,
    ),
    Order(
      id: '2',
      titulo: 'Cupcakes en crema con colores',
      descripcion: 'Set de 12 cupcakes con crema de colores',
      fecha: DateTime(2024, 11, 9),
      categoria: _categories[1], // Cupcake
      cliente: 'Carlos Rodríguez',
      contacto: '3009876543',
      tamano: 'Docena',
      leyenda: 'Celebración',
      edad: 8,
      valor: 80000,
      abono: 40000,
      domicilio: 'Carrera 50 #20-30',
      completado: false,
    ),
    Order(
      id: '3',
      titulo: 'Torta en crema con Topper',
      descripcion: 'Torta con decoración topper personalizado',
      fecha: DateTime(2024, 9, 15), // Fecha más cercana
      categoria: _categories[2], // Pendiente
      cliente: 'Ana López',
      contacto: '3005555555',
      tamano: 'Grande',
      leyenda: 'Aniversario',
      edad: 30,
      valor: 150000, // Precio más alto
      abono: 75000,
      domicilio: 'Avenida 80 #15-25',
      completado: false,
    ),
    Order(
      id: '4',
      titulo: 'Torta Arequipe',
      descripcion: 'Deliciosa torta con relleno de arequipe',
      fecha: DateTime(2024, 9, 13),
      categoria: _categories[3], // Arequipe
      cliente: 'Luis Martínez',
      contacto: '3007777777',
      tamano: 'Personal',
      leyenda: 'Para mamá',
      edad: 55,
      valor: 90000,
      abono: 90000,
      domicilio: 'Calle 70 #40-50',
      completado: true,
    ),
    Order(
      id: '5',
      titulo: 'Torta Chocolate Premium',
      descripcion: 'Torta de chocolate con ganache',
      fecha: DateTime(2024, 9, 16), // Fecha futura
      categoria: _categories[5], // Chocolate
      cliente: 'Sandra Pérez',
      contacto: '3002222222',
      tamano: 'Mediana',
      leyenda: 'Graduación',
      edad: 22,
      valor: 200000, // Precio más alto
      abono: 55000,
      domicilio: 'Transversal 30 #10-20',
      completado: false,
    ),
    Order(
      id: '6',
      titulo: 'Mini Cupcakes Vainilla',
      descripcion: 'Set de 24 mini cupcakes de vainilla',
      fecha: DateTime(2024, 9, 14), // Hoy
      categoria: _categories[1], // Cupcake
      cliente: 'Andrea Ruiz',
      contacto: '3008888888',
      tamano: 'Mini x24',
      leyenda: 'Baby Shower',
      edad: 0,
      valor: 65000, // Precio más bajo
      abono: 30000,
      domicilio: 'Calle 45 #12-18',
      completado: false,
    ),
  ];

  // Obtener todas las categorías
  static List<Category> getCategories() {
    return List.from(_categories);
  }

  // Obtener categoría por ID
  static Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtener todos los pedidos
  static List<Order> getOrders() {
    return List.from(_orders);
  }

  // Obtener pedidos por completado/no completado
  static List<Order> getOrdersByCompletion(bool completed) {
    return _orders.where((order) => order.completado == completed).toList();
  }

  // Obtener pedidos por categoría
  static List<Order> getOrdersByCategory(String categoryId) {
    return _orders.where((order) => order.categoria.id == categoryId).toList();
  }

  // Buscar pedidos por título
  static List<Order> searchOrders(String query) {
    if (query.isEmpty) return getOrders();
    
    return _orders.where((order) => 
      order.titulo.toLowerCase().contains(query.toLowerCase()) ||
      order.cliente.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Alternar estado completado de un pedido
  static void toggleOrderCompletion(String orderId) {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(
        completado: !_orders[index].completado,
      );
    }
  }

  // Agregar nuevo pedido
  static void addOrder(Order order) {
    _orders.add(order);
  }

  // Actualizar pedido existente
  static void updateOrder(Order updatedOrder) {
    final index = _orders.indexWhere((order) => order.id == updatedOrder.id);
    if (index != -1) {
      _orders[index] = updatedOrder;
    }
  }

  // Eliminar pedido
  static void deleteOrder(String orderId) {
    _orders.removeWhere((order) => order.id == orderId);
  }
}
