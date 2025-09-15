import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTestData {
  static Future<void> addSampleOrders() async {
    final firestore = FirebaseFirestore.instance;
    
    final sampleOrders = [
      {
        'imageFoto': '',
        'pedidoAbono': 50000,
        'pedidoCliente': 'María González',
        'pedidoCompleto': false,
        'pedidoConfirma': true,
        'pedidoContacto': '+57 300 123 4567',
        'pedidoDetalle': 'Torta de chocolate de 3 pisos con relleno de arequipe y cobertura de chocolate',
        'pedidoDomicilio': 'Calle 45 #12-34, Apartamento 501',
        'pedidoFecha': Timestamp.fromDate(DateTime.now().add(const Duration(days: 2))),
        'pedidoLeyenda': 'Feliz Cumpleaños Ana',
        'pedidoLibras': '3',
        'pedidoValor': 120000,
        'pedidoCategoria': 'tortas',
      },
      {
        'imageFoto': '',
        'pedidoAbono': 25000,
        'pedidoCliente': 'Carlos Mendoza',
        'pedidoCompleto': false,
        'pedidoConfirma': true,
        'pedidoContacto': '+57 311 987 6543',
        'pedidoDetalle': '12 cupcakes de vainilla con decoración temática de unicornios',
        'pedidoDomicilio': 'Carrera 15 #78-90',
        'pedidoFecha': Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
        'pedidoLeyenda': '',
        'pedidoLibras': '1.5',
        'pedidoValor': 60000,
        'pedidoCategoria': 'cupcakes',
      },
      {
        'imageFoto': '',
        'pedidoAbono': 80000,
        'pedidoCliente': 'Ana Rodríguez',
        'pedidoCompleto': true,
        'pedidoConfirma': true,
        'pedidoContacto': '+57 320 555 1234',
        'pedidoDetalle': 'Pastel de tres leches decorado con flores de azúcar',
        'pedidoDomicilio': 'Avenida 68 #25-12',
        'pedidoFecha': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        'pedidoLeyenda': 'Para mi amor',
        'pedidoLibras': '2.5',
        'pedidoValor': 90000,
        'pedidoCategoria': 'pasteles',
      },
      {
        'imageFoto': '',
        'pedidoAbono': 0,
        'pedidoCliente': 'Luis Morales',
        'pedidoCompleto': false,
        'pedidoConfirma': false,
        'pedidoContacto': '+57 301 444 7890',
        'pedidoDetalle': 'Pan integral artesanal, 2 barras grandes',
        'pedidoDomicilio': '',
        'pedidoFecha': Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
        'pedidoLeyenda': '',
        'pedidoLibras': '1',
        'pedidoValor': 15000,
        'pedidoCategoria': 'panes',
      },
    ];
    
    try {
      for (final order in sampleOrders) {
        await firestore.collection('pedidos').add(order);
      }
      print('✅ Datos de prueba agregados exitosamente');
    } catch (e) {
      print('❌ Error al agregar datos de prueba: $e');
    }
  }
  
  static Future<void> clearAllOrders() async {
    final firestore = FirebaseFirestore.instance;
    
    try {
      final querySnapshot = await firestore.collection('pedidos').get();
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      print('✅ Todos los pedidos eliminados exitosamente');
    } catch (e) {
      print('❌ Error al eliminar pedidos: $e');
    }
  }
}
