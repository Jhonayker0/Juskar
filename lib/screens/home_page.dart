import 'package:flutter/material.dart';
import 'package:juskar/models/order.dart' as OrderModel;
import 'package:juskar/services/firebase_order_service.dart';
import 'package:juskar/widgets/order_card.dart';
import 'package:juskar/utils/order_sort_option.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showPendingOrders = true;
  bool _showCompletedOrders = true;
  String _searchQuery = '';
  OrderSortOption _currentSortOption = OrderSortOption.fecha;

  List<OrderModel.Order> _filterAndSortOrders(List<OrderModel.Order> orders) {
    // Filtrar por búsqueda
    var filteredOrders = orders.where((order) {
      if (_searchQuery.isEmpty) return true;
      return order.pedidoCliente.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             order.pedidoDetalle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             order.pedidoLeyenda.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Ordenar según la opción seleccionada
    switch (_currentSortOption) {
      case OrderSortOption.fecha:
        filteredOrders.sort((a, b) => a.pedidoFecha.compareTo(b.pedidoFecha));
        break;
      case OrderSortOption.categoria:
        filteredOrders.sort((a, b) => a.pedidoCategoria.compareTo(b.pedidoCategoria));
        break;
      case OrderSortOption.precio:
        filteredOrders.sort((a, b) => b.pedidoValor.compareTo(a.pedidoValor)); // Mayor a menor
        break;
      case OrderSortOption.cliente:
        filteredOrders.sort((a, b) => a.pedidoCliente.compareTo(b.pedidoCliente));
        break;
    }
    
    return filteredOrders;
  }

  Future<void> _toggleOrderCompletion(String orderId, bool completed) async {
    try {
      await FirebaseOrderService.toggleOrderStatus(orderId, completed);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(completed ? 'Pedido marcado como completado' : 'Pedido marcado como pendiente'),
            backgroundColor: completed ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderSortOption>(
            icon: const Icon(Icons.sort),
            onSelected: (OrderSortOption option) {
              setState(() {
                _currentSortOption = option;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: OrderSortOption.fecha,
                child: Text('Ordenar por fecha'),
              ),
              const PopupMenuItem(
                value: OrderSortOption.categoria,
                child: Text('Ordenar por categoría'),
              ),
              const PopupMenuItem(
                value: OrderSortOption.precio,
                child: Text('Ordenar por precio'),
              ),
              const PopupMenuItem(
                value: OrderSortOption.cliente,
                child: Text('Ordenar por cliente'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar pedidos...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF333333),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          
          // Contenido principal con StreamBuilder
          Expanded(
            child: StreamBuilder<List<OrderModel.Order>>(
              stream: FirebaseOrderService.getOrders(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar pedidos',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(color: Colors.grey[400]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final allOrders = snapshot.data ?? [];
                
                if (allOrders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay pedidos',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Los pedidos aparecerán aquí cuando se agreguen',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  );
                }

                // Filtrar y ordenar pedidos
                final filteredOrders = _filterAndSortOrders(allOrders);
                final pendingOrders = filteredOrders.where((order) => !order.pedidoCompleto).toList();
                final completedOrders = filteredOrders.where((order) => order.pedidoCompleto).toList();

                return RefreshIndicator(
                  onRefresh: () async {
                    // Los datos se actualizan automáticamente con el Stream
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView(
                    children: [
                      // Sección "Por hacer"
                      if (pendingOrders.isNotEmpty)
                        _buildSectionHeader(
                          'Por hacer',
                          pendingOrders.length,
                          () {
                            setState(() {
                              _showPendingOrders = !_showPendingOrders;
                            });
                          },
                          _showPendingOrders,
                        ),
                      
                      if (_showPendingOrders)
                        ...pendingOrders.map((order) => OrderCard(
                          order: order,
                          onToggleCompletion: () => _toggleOrderCompletion(order.id, !order.pedidoCompleto),
                        )),

                      if (pendingOrders.isNotEmpty && completedOrders.isNotEmpty)
                        const SizedBox(height: 16),

                      // Sección "Completado"
                      if (completedOrders.isNotEmpty)
                        _buildSectionHeader(
                          'Completado',
                          completedOrders.length,
                          () {
                            setState(() {
                              _showCompletedOrders = !_showCompletedOrders;
                            });
                          },
                          _showCompletedOrders,
                        ),
                      
                      if (_showCompletedOrders)
                        ...completedOrders.map((order) => OrderCard(
                          order: order,
                          onToggleCompletion: () => _toggleOrderCompletion(order.id, !order.pedidoCompleto),
                        )),

                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, VoidCallback onTap, bool isExpanded) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF333333),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: const Color(0xFF7C7BFF),
              ),
              const SizedBox(width: 8),
              Text(
                '$title ($count)',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C7BFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
