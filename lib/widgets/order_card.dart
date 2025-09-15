import 'package:flutter/material.dart';
import 'package:juskar/models/order.dart' as OrderModel;

class OrderCard extends StatelessWidget {
  final OrderModel.Order order;
  final VoidCallback? onToggleCompletion;

  const OrderCard({
    super.key,
    required this.order,
    this.onToggleCompletion,
  });

  @override
  Widget build(BuildContext context) {
    // Formato de fecha más simple
    final dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final dayName = dayNames[order.pedidoFecha.weekday - 1];
    final formattedDate = '$dayName ${order.pedidoFecha.day.toString().padLeft(2, '0')}/${order.pedidoFecha.month.toString().padLeft(2, '0')}';
    
    // Determinar color de categoría (básico)
    Color getCategoryColor(String categoria) {
      switch (categoria.toLowerCase()) {
        case 'tortas':
          return const Color(0xFFE91E63);
        case 'pasteles':
          return const Color(0xFF2196F3);
        case 'cupcakes':
          return const Color(0xFF4CAF50);
        case 'panes':
          return const Color(0xFFFF9800);
        default:
          return const Color(0xFF9C27B0);
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estado y categoría
            Row(
              children: [
                // Círculo de completado/pendiente
                GestureDetector(
                  onTap: onToggleCompletion,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: order.pedidoCompleto ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: order.pedidoCompleto
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Color(0xFF1E1E1E),
                          )
                        : null,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Cliente
                Expanded(
                  child: Text(
                    order.pedidoCliente,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Chip de categoría
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: getCategoryColor(order.pedidoCategoria),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    order.pedidoCategoria,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Detalles del pedido
            Text(
              order.pedidoDetalle,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            if (order.pedidoLeyenda.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Leyenda: ${order.pedidoLeyenda}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Footer con información adicional
            Row(
              children: [
                // Fecha
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 2,
                  child: Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Peso - hacer más compacto
                if (order.pedidoLibras.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.scale,
                    size: 14,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    child: Text(
                      '${order.pedidoLibras}lb',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                
                // Precio - hacer más compacto
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C7BFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '\$${order.pedidoValor.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            
            // Información de contacto y domicilio (si está disponible)
            if (order.pedidoContacto.isNotEmpty || order.pedidoDomicilio.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (order.pedidoContacto.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.pedidoContacto,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    if (order.pedidoDomicilio.isNotEmpty) ...[
                      if (order.pedidoContacto.isNotEmpty) const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              order.pedidoDomicilio,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
