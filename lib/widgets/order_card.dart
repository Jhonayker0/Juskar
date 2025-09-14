import 'package:flutter/material.dart';
import 'package:juskar/models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onToggleCompletion;

  const OrderCard({
    super.key,
    required this.order,
    this.onToggleCompletion,
  });

  @override
  Widget build(BuildContext context) {
    // Formato simple de fecha
    final dayNames = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    final dayName = dayNames[order.fecha.weekday - 1];
    final formattedDate = '$dayName ${order.fecha.day.toString().padLeft(2, '0')}/${order.fecha.month.toString().padLeft(2, '0')}';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Círculo de completado/pendiente
            GestureDetector(
              onTap: onToggleCompletion,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: order.completado ? Colors.white : Colors.transparent,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: order.completado
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Color(0xFF1E1E1E),
                      )
                    : null,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Contenido principal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título del pedido
                  Text(
                    order.titulo,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Fecha
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Chip de categoría
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: order.categoria.color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                order.categoria.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
