import 'package:flutter/material.dart';
import 'package:juskar/models/order.dart' as OrderModel;
import 'package:juskar/services/firebase_category_service.dart';
import 'package:juskar/models/category.dart';

class OrderCard extends StatelessWidget {
  final OrderModel.Order order;
  final VoidCallback? onToggleCompletion;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onToggleCompletion,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Formato de fecha más simple
    final dayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    final dayName = dayNames[order.pedidoFecha.weekday - 1];
    final formattedDate = '$dayName ${order.pedidoFecha.day.toString().padLeft(2, '0')}/${order.pedidoFecha.month.toString().padLeft(2, '0')}';
    
    // Formato de hora AM/PM
    final hour = order.pedidoFecha.hour;
    final minute = order.pedidoFecha.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final formattedTime = '${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $period';
    
    final formattedDateTime = '$formattedDate - $formattedTime';

    return GestureDetector(
      onTap: onTap,
      child: Card(
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
                  _CategoryChip(categoryId: order.pedidoCategoria),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Peso del pedido
              if (order.pedidoLibras.isNotEmpty) 
                Row(
                  children: [
                    Icon(
                      Icons.scale,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Peso: ${order.pedidoLibras}',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
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
                      formattedDateTime,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Descripción - compacta
                  if (order.pedidoDetalle.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text(
                        order.pedidoDetalle,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String categoryId;

  const _CategoryChip({required this.categoryId});

  @override
  Widget build(BuildContext context) {
    // Validar que categoryId no esté vacío
    if (categoryId.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF607D8B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          'Sin categoría',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return FutureBuilder<Category?>(
      future: FirebaseCategoryService.getCategoryById(categoryId),
      builder: (context, snapshot) {
        String displayText = 'Cargando...';
        Color chipColor = const Color(0xFF607D8B);

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            final category = snapshot.data!;
            displayText = category.nombre;
            chipColor = category.color; // Usar el color real de la categoría
          } else if (snapshot.hasError) {
            displayText = 'Error';
            chipColor = Colors.red;
          } else {
            // No se encontró la categoría
            displayText = 'Sin categoría';
            chipColor = const Color(0xFF757575);
          }
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            displayText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}
