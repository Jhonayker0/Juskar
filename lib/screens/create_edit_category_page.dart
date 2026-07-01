import 'package:flutter/material.dart';
import 'package:juskar/models/category.dart';

class CreateEditCategoryPage extends StatefulWidget {
  final Category? category; // null para crear, category para editar

  const CreateEditCategoryPage({
    super.key,
    this.category,
  });

  @override
  State<CreateEditCategoryPage> createState() => _CreateEditCategoryPageState();
}

class _CreateEditCategoryPageState extends State<CreateEditCategoryPage> {
  final TextEditingController _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;
  
  // Colores disponibles según el mockup
  final List<Color> _availableColors = [
    const Color(0xFFF1C40F), // Amarillo
    const Color(0xFF2ECC71), // Verde
    const Color(0xFF1ABC9C), // Verde agua
    const Color(0xFF3498DB), // Azul
    const Color(0xFF5DADE2), // Azul claro
    const Color(0xFFE67E22), // Naranja
    const Color(0xFF9B59B6), // Púrpura
    const Color(0xFFE91E63), // Rosa
    const Color(0xFFFF6B6B), // Rojo
    const Color(0xFF95A5A6), // Gris
    const Color(0xFF34495E), // Gris oscuro
    const Color(0xFF8B4513), // Café
  ];

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.category!.nombre;
      _selectedColor = widget.category!.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Categoría' : 'Crear nueva categoría'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo nombre
            const Text(
              'Nombre:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'nombre de la categoría...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF333333),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Selector de color
            const Text(
              'Color:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            
            // Grid de colores
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableColors.map((color) {
                final isSelected = _selectedColor.value == color.value;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            
            // Botón borrar (solo si está editando)
            if (_isEditing)
              GestureDetector(
                onTap: () {
                  _showDeleteConfirmation(context);
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Borrar categoría',
                      style: TextStyle(
                        color: Colors.red[400],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            
            const Spacer(),
            
            // Botones inferiores
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Color(0xFF7C7BFF),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _nameController.text.trim().isNotEmpty 
                        ? _saveCategory 
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C7BFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      _isEditing ? 'Guardar Cambios' : 'Crear Categoría',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ), // Cierra Column
      ), // Cierra Padding
    ), // Cierra SafeArea
  ); // Cierra Scaffold
  }

  void _saveCategory() {
    if (_nameController.text.trim().isEmpty) return;

    final category = Category(
      id: _isEditing ? widget.category!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      nombre: _nameController.text.trim(),
      color: _selectedColor,
    );

    Navigator.of(context).pop(category);
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Eliminar Categoría',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar la categoría "${widget.category!.nombre}"?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF7C7BFF)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar dialog
                Navigator.of(context).pop('delete'); // Regresar con indicación de borrado
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
