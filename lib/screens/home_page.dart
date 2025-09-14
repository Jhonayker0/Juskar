import 'package:flutter/material.dart';
import 'package:juskar/models/order.dart';
import 'package:juskar/services/mock_data_service.dart';
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
  List<Order> _allOrders = [];
  String _searchQuery = '';
  OrderSortOption _currentSortOption = OrderSortOption.fecha;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      _allOrders = MockDataService.getOrders();
    });
  }

  void _toggleOrderCompletion(String orderId) {
    setState(() {
      MockDataService.toggleOrderCompletion(orderId);
      _loadOrders(); // Recargar la lista
    });
  }

  List<Order> _sortOrders(List<Order> orders) {
    List<Order> sortedOrders = List.from(orders);
    
    switch (_currentSortOption) {
      case OrderSortOption.fecha:
        sortedOrders.sort((a, b) => a.fecha.compareTo(b.fecha));
        break;
      case OrderSortOption.categoria:
        sortedOrders.sort((a, b) => a.categoria.name.compareTo(b.categoria.name));
        break;
      case OrderSortOption.precio:
        sortedOrders.sort((a, b) => b.valor.compareTo(a.valor)); // Mayor a menor
        break;
      case OrderSortOption.cliente:
        sortedOrders.sort((a, b) => a.cliente.compareTo(b.cliente));
        break;
    }
    
    return sortedOrders;
  }

  List<Order> get _pendingOrders {
    var orders = _allOrders.where((order) => !order.completado).toList();
    if (_searchQuery.isNotEmpty) {
      orders = orders.where((order) =>
          order.titulo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.cliente.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    return _sortOrders(orders);
  }

  List<Order> get _completedOrders {
    var orders = _allOrders.where((order) => order.completado).toList();
    if (_searchQuery.isNotEmpty) {
      orders = orders.where((order) =>
          order.titulo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          order.cliente.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    return _sortOrders(orders);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página Principal'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: const AssetImage('assets/Logo.jpg'),
              backgroundColor: Colors.grey[800],
            ),
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
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar pedido...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF333333),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Dropdown de ordenamiento
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  'Ordenar por:',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF333333),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<OrderSortOption>(
                      value: _currentSortOption,
                      dropdownColor: const Color(0xFF333333),
                      style: const TextStyle(color: Colors.white),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      items: OrderSortOption.values.map((OrderSortOption option) {
                        return DropdownMenuItem<OrderSortOption>(
                          value: option,
                          child: Text(option.displayName),
                        );
                      }).toList(),
                      onChanged: (OrderSortOption? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _currentSortOption = newValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de pedidos
          Expanded(
            child: ListView(
              children: [
                // Sección "Por hacer"
                _buildSectionHeader(
                  title: 'Por hacer',
                  count: _pendingOrders.length,
                  isExpanded: _showPendingOrders,
                  onToggle: () {
                    setState(() {
                      _showPendingOrders = !_showPendingOrders;
                    });
                  },
                ),
                if (_showPendingOrders) ...[
                  ..._pendingOrders.map((order) => OrderCard(
                    order: order,
                    onToggleCompletion: () => _toggleOrderCompletion(order.id),
                  )),
                ],

                const SizedBox(height: 20),

                // Sección "Completado"
                _buildSectionHeader(
                  title: 'Completado',
                  count: _completedOrders.length,
                  isExpanded: _showCompletedOrders,
                  onToggle: () {
                    setState(() {
                      _showCompletedOrders = !_showCompletedOrders;
                    });
                  },
                ),
                if (_showCompletedOrders) ...[
                  ..._completedOrders.map((order) => OrderCard(
                    order: order,
                    onToggleCompletion: () => _toggleOrderCompletion(order.id),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF333333),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C7BFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
