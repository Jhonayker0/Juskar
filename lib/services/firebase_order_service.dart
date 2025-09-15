import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:juskar/models/order.dart' as OrderModel;

class FirebaseOrderService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'pedidos';

  // Obtener todos los pedidos
  static Stream<List<OrderModel.Order>> getOrders() {
    return _firestore
        .collection(_collection)
        .orderBy('pedidoFecha', descending: true)
        .snapshots()
        .map((snapshot) {
          final orders = <OrderModel.Order>[];
          for (final doc in snapshot.docs) {
            try {
              orders.add(OrderModel.Order.fromFirestore(doc));
            } catch (e) {
              print('Error al convertir documento ${doc.id}: $e');
              print('Datos del documento: ${doc.data()}');
              // Continuamos con el siguiente documento en lugar de fallar todo
            }
          }
          return orders;
        });
  }

  // Obtener pedidos por estado (completado/pendiente)
  static Stream<List<OrderModel.Order>> getOrdersByStatus(bool completed) {
    return _firestore
        .collection(_collection)
        .where('pedidoCompleto', isEqualTo: completed ? 1 : 0)
        .orderBy('pedidoFecha', descending: true)
        .snapshots()
        .map((snapshot) {
          final orders = <OrderModel.Order>[];
          for (final doc in snapshot.docs) {
            try {
              orders.add(OrderModel.Order.fromFirestore(doc));
            } catch (e) {
              print('Error al convertir documento ${doc.id}: $e');
              print('Datos del documento: ${doc.data()}');
              // Continuamos con el siguiente documento en lugar de fallar todo
            }
          }
          return orders;
        });
  }

  // Obtener pedidos completados
  static Stream<List<OrderModel.Order>> getCompletedOrders() {
    return getOrdersByStatus(true);
  }

  // Obtener pedidos pendientes
  static Stream<List<OrderModel.Order>> getPendingOrders() {
    return getOrdersByStatus(false);
  }

  // Obtener pedidos por categoría
  static Stream<List<OrderModel.Order>> getOrdersByCategory(String categoryId) {
    return _firestore
        .collection(_collection)
        .where('pedidoCategoria', isEqualTo: categoryId)
        .orderBy('pedidoFecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.Order.fromFirestore(doc))
            .toList());
  }

  // Buscar pedidos por cliente
  static Stream<List<OrderModel.Order>> searchOrdersByClient(String clientName) {
    return _firestore
        .collection(_collection)
        .where('pedidoCliente', isGreaterThanOrEqualTo: clientName)
        .where('pedidoCliente', isLessThanOrEqualTo: clientName + '\uf8ff')
        .orderBy('pedidoCliente')
        .orderBy('pedidoFecha', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.Order.fromFirestore(doc))
            .toList());
  }

  // Agregar nuevo pedido
  static Future<String> addOrder(OrderModel.Order order) async {
    try {
      final docRef = await _firestore.collection(_collection).add(order.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear el pedido: $e');
    }
  }

  // Actualizar pedido existente
  static Future<void> updateOrder(OrderModel.Order order) async {
    try {
      await _firestore.collection(_collection).doc(order.id).update(order.toFirestore());
    } catch (e) {
      throw Exception('Error al actualizar el pedido: $e');
    }
  }

  // Cambiar estado de completado del pedido
  static Future<void> toggleOrderStatus(String orderId, bool completed) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'pedidoCompleto': completed ? 1 : 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al cambiar el estado del pedido: $e');
    }
  }

  // Eliminar pedido
  static Future<void> deleteOrder(String orderId) async {
    try {
      await _firestore.collection(_collection).doc(orderId).delete();
    } catch (e) {
      throw Exception('Error al eliminar el pedido: $e');
    }
  }

  // Obtener pedido por ID
  static Future<OrderModel.Order?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(orderId).get();
      if (doc.exists) {
        return OrderModel.Order.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener el pedido: $e');
    }
  }

  // Obtener estadísticas básicas
  static Future<Map<String, int>> getOrderStats() async {
    try {
      final allOrders = await _firestore.collection(_collection).get();
      final completed = allOrders.docs.where((doc) {
        final data = doc.data();
        return data['pedidoCompleto'] == 1 || data['pedidoCompleto'] == true;
      }).length;
      
      return {
        'total': allOrders.docs.length,
        'completed': completed,
        'pending': allOrders.docs.length - completed,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }
}
