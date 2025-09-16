import 'dart:io';
import 'package:flutter/material.dart';
import 'package:juskar/models/order.dart' as order_model;
import 'package:juskar/models/category.dart';
import 'package:juskar/services/firebase_order_service.dart';
import 'package:juskar/services/firebase_category_service.dart';
import 'package:juskar/services/firebase_storage_service.dart';
import 'package:juskar/widgets/image_carousel.dart';

class CreateOrderPage extends StatefulWidget {
  final order_model.Order? orderToEdit;
  
  const CreateOrderPage({super.key, this.orderToEdit});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Controladores de texto
  final _tituloController = TextEditingController();
  final _detalleController = TextEditingController();
  final _clienteController = TextEditingController();
  final _contactoController = TextEditingController();
  final _domicilioController = TextEditingController();
  final _leyendaController = TextEditingController();
  final _librasController = TextEditingController();
  final _valorController = TextEditingController();
  final _abonoController = TextEditingController();
  
  // Variables de estado
  DateTime _fechaEntrega = DateTime.now().add(const Duration(days: 1));
  String? _selectedCategoryId;
  Category? _selectedCategory;
  bool _pedidoConfirma = false;
  List<File> _selectedImages = []; // Cambiado de File? a List<File>
  bool _isLoading = false;
  bool _isUploadingImage = false;
  int _currentImageIndex = 0; // Para el carrusel

  // Modo edición
  bool get isEditMode => widget.orderToEdit != null;

  @override
  void initState() {
    super.initState();
    _abonoController.text = '0';
    
    // Si estamos editando, prellenar los campos
    if (isEditMode) {
      _initializeForEdit();
    }
  }

  void _initializeForEdit() {
    final order = widget.orderToEdit!;
    _tituloController.text = order.pedidoCliente;
    _detalleController.text = order.pedidoDetalle;
    _clienteController.text = order.pedidoCliente;
    _contactoController.text = order.pedidoContacto;
    _domicilioController.text = order.pedidoDomicilio;
    _leyendaController.text = order.pedidoLeyenda;
    _librasController.text = order.pedidoLibras;
    _valorController.text = order.pedidoValor.toString();
    _abonoController.text = order.pedidoAbono.toString();
    _fechaEntrega = order.pedidoFecha;
    _selectedCategoryId = order.pedidoCategoria;
    _pedidoConfirma = order.pedidoConfirma;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _detalleController.dispose();
    _clienteController.dispose();
    _contactoController.dispose();
    _domicilioController.dispose();
    _leyendaController.dispose();
    _librasController.dispose();
    _valorController.dispose();
    _abonoController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaEntrega,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF7C7BFF),
              onPrimary: Colors.white,
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fechaEntrega = picked;
      });
    }
  }

  Future<void> _selectImage() async {
    if (!mounted) return;
    
    try {
      setState(() {
        _isUploadingImage = true;
      });

      final image = await FirebaseStorageService.showImageSourceDialog(context);
      
      if (mounted) {
        setState(() {
          if (image != null) {
            _selectedImages.add(image);
          }
          _isUploadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      setState(() {
        _selectedImages.removeAt(index);
        // Ajustar el índice actual si es necesario
        if (_currentImageIndex >= _selectedImages.length && _selectedImages.isNotEmpty) {
          _currentImageIndex = _selectedImages.length - 1;
        } else if (_selectedImages.isEmpty) {
          _currentImageIndex = 0;
        }
      });
    }
  }

  void _showCategorySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Seleccionar Categoría',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<Category>>(
                stream: FirebaseCategoryService.getCategories(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text(
                      'Error al cargar categorías',
                      style: TextStyle(color: Colors.red),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final categories = snapshot.data ?? [];

                  if (categories.isEmpty) {
                    return const Text(
                      'No hay categorías disponibles',
                      style: TextStyle(color: Colors.grey),
                    );
                  }

                  return Column(
                    children: categories.map((category) {
                      return ListTile(
                        leading: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: category.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        title: Text(
                          category.nombre,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: _selectedCategoryId == category.id
                            ? const Icon(Icons.check, color: Color(0xFF7C7BFF))
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = category.id;
                            _selectedCategory = category;
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Borrar pedido',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            '¿Estás seguro de borrar este pedido?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearForm();
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF7C7BFF),
              ),
              child: const Text(
                'Borrar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _tituloController.clear();
    _detalleController.clear();
    _clienteController.clear();
    _contactoController.clear();
    _domicilioController.clear();
    _leyendaController.clear();
    _librasController.clear();
    _valorController.clear();
    _abonoController.text = '0';
    setState(() {
      _fechaEntrega = DateTime.now().add(const Duration(days: 1));
      _selectedCategoryId = null;
      _selectedCategory = null;
      _pedidoConfirma = false;
      _selectedImages.clear();
      _currentImageIndex = 0;
    });
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una categoría'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> imageUrls = [];
      
      // Subir imágenes si fueron seleccionadas
      if (_selectedImages.isNotEmpty) {
        imageUrls = await FirebaseStorageService.uploadOrderImages(_selectedImages);
      } else if (isEditMode) {
        // Mantener las imágenes existentes si no se seleccionaron nuevas
        imageUrls = widget.orderToEdit!.imagenesUrls;
      }

      // Crear o actualizar el pedido
      final order = order_model.Order(
        id: isEditMode ? widget.orderToEdit!.id : '', // Usar ID existente si editamos
        imagenesUrls: imageUrls,
        pedidoAbono: double.tryParse(_abonoController.text) ?? 0.0,
        pedidoCliente: _clienteController.text.trim(),
        pedidoCompleto: isEditMode ? widget.orderToEdit!.pedidoCompleto : false, // Mantener estado si editamos
        pedidoConfirma: _pedidoConfirma,
        pedidoContacto: _contactoController.text.trim(),
        pedidoDetalle: _detalleController.text.trim(),
        pedidoDomicilio: _domicilioController.text.trim(),
        pedidoFecha: _fechaEntrega,
        pedidoLeyenda: _leyendaController.text.trim(),
        pedidoLibras: _librasController.text.trim(),
        pedidoValor: double.tryParse(_valorController.text) ?? 0.0,
        pedidoCategoria: _selectedCategoryId!,
      );

      if (isEditMode) {
        await FirebaseOrderService.updateOrder(order);
      } else {
        await FirebaseOrderService.addOrder(order);
      }

      if (mounted) {
        _showMessage(isEditMode ? 'Pedido actualizado exitosamente' : 'Pedido creado exitosamente');
        
        if (!isEditMode) {
          // Solo limpiar formulario si estamos creando
          _clearForm();
        } else {
          // Si estamos editando, volver a la pantalla anterior
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Error al ${isEditMode ? 'actualizar' : 'crear'} pedido: $e', isError: true);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Confirmar eliminación',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            '¿Estás seguro de que quieres eliminar este pedido? Esta acción no se puede deshacer.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await _deleteOrder();
    }
  }

  Future<void> _deleteOrder() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseOrderService.deleteOrder(widget.orderToEdit!.id);
      
      if (mounted) {
        _showMessage('Pedido eliminado exitosamente');
        Navigator.of(context).pop(); // Volver a la pantalla anterior
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Error al eliminar pedido: $e', isError: true);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditMode ? 'Editar Pedido' : 'Crear Pedido'),
          centerTitle: true,
        ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título principal (editable)
              _buildEditableTitle(),
              const SizedBox(height: 20),
              
              // Descripción
              _buildDescription(),
              const SizedBox(height: 24),

              // Fecha de entrega
              _buildDateField(),
              const SizedBox(height: 16),

              // Categoría
              _buildCategoryField(),
              const SizedBox(height: 16),

              // Cliente
              _buildClientField(),
              const SizedBox(height: 16),

              // Contacto
              _buildContactField(),
              const SizedBox(height: 16),

              // Domicilio
              _buildAddressField(),
              const SizedBox(height: 16),

              // Leyenda
              _buildLegendField(),
              const SizedBox(height: 16),

              // Libras
              _buildWeightField(),
              const SizedBox(height: 16),

              // Valor y Abono
              _buildPriceFields(),
              const SizedBox(height: 16),

              // Confirmación
              _buildConfirmationField(),
              const SizedBox(height: 24),

              // Imagen
              _buildImageSection(),
              const SizedBox(height: 24),

              // Botones
              _buildActionButtons(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      ), // Cierre del WillPopScope
    );
  }

  Widget _buildEditableTitle() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextFormField(
        controller: _tituloController,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          hintText: 'Título del pedido',
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          suffixIcon: Icon(Icons.edit, color: Colors.white54),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'El título es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción del pedido:',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _detalleController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Describe los detalles del pedido...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFF333333),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
            suffixIcon: const Icon(Icons.edit, color: Colors.white54),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La descripción es obligatoria';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField() {
    final formattedDate = '${_fechaEntrega.day.toString().padLeft(2, '0')}/${_fechaEntrega.month.toString().padLeft(2, '0')}/${_fechaEntrega.year}';
    
    return Row(
      children: [
        const Icon(Icons.schedule, color: Colors.white),
        const SizedBox(width: 12),
        const Text(
          'Fecha de entrega:',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              formattedDate,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Row(
      children: [
        const Icon(Icons.category, color: Colors.white),
        const SizedBox(width: 12),
        const Text(
          'Categoría:',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _showCategorySelector,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _selectedCategory?.color ?? const Color(0xFFFF9800),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _selectedCategory?.nombre ?? 'Seleccionar',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientField() {
    return _buildFieldWithIcon(
      icon: Icons.person,
      label: 'Cliente:',
      controller: _clienteController,
      hintText: 'Nombre del cliente',
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'El nombre del cliente es obligatorio';
        }
        return null;
      },
    );
  }

  Widget _buildContactField() {
    return _buildFieldWithIcon(
      icon: Icons.phone,
      label: 'Contacto:',
      controller: _contactoController,
      hintText: 'Teléfono del cliente',
      keyboardType: TextInputType.phone,
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.location_on, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Dirección de entrega:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _domicilioController,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Dirección completa de entrega',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFF333333),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.message, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Mensaje especial:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _leyendaController,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Texto personalizado para el pedido',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFF333333),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightField() {
    return _buildFieldWithIcon(
      icon: Icons.scale,
      label: 'Peso (libras):',
      controller: _librasController,
      hintText: '2.5 lbs',
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildPriceFields() {
    return Column(
      children: [
        _buildFieldWithIcon(
          icon: Icons.attach_money,
          label: 'Valor total:',
          controller: _valorController,
          hintText: '150000',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El valor es obligatorio';
            }
            if (double.tryParse(value) == null) {
              return 'Ingresa un valor válido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildFieldWithIcon(
          icon: Icons.payment,
          label: 'Abono:',
          controller: _abonoController,
          hintText: '50000',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final abono = double.tryParse(value);
              final valor = double.tryParse(_valorController.text);
              if (abono == null) {
                return 'Ingresa un abono válido';
              }
              if (valor != null && abono > valor) {
                return 'El abono no puede ser mayor al valor total';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConfirmationField() {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline, color: Colors.white),
        const SizedBox(width: 12),
        const Text(
          'Pedido confirmado:',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const Spacer(),
        Switch(
          value: _pedidoConfirma,
          onChanged: (value) {
            setState(() {
              _pedidoConfirma = value;
            });
          },
          activeColor: const Color(0xFF7C7BFF),
          inactiveThumbColor: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.photo_camera, color: Colors.white),
            SizedBox(width: 12),
            Text(
              'Imagen del producto:',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Carrusel de imágenes
        ImageCarousel(
          images: _selectedImages,
          onAddImage: _selectImage,
          onRemoveImage: _removeImage,
          isLoading: _isUploadingImage,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botón borrar pedido
        if (_hasAnyData())
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _showDeleteDialog,
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text(
                'Borrar pedido',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ),
        
        const SizedBox(height: 12),

        // Botones de acción
        if (isEditMode) ...[
          // Botón eliminar pedido (solo en modo edición)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _showDeleteConfirmation,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Eliminar Pedido',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Botón principal (crear/actualizar)
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C7BFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    isEditMode ? 'Actualizar Pedido' : 'Crear Pedido',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldWithIcon({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: const Color(0xFF333333),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              suffixIcon: const Icon(Icons.edit, color: Colors.white54, size: 16),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  bool _hasAnyData() {
    return _tituloController.text.isNotEmpty ||
           _detalleController.text.isNotEmpty ||
           _clienteController.text.isNotEmpty ||
           _contactoController.text.isNotEmpty ||
           _domicilioController.text.isNotEmpty ||
           _leyendaController.text.isNotEmpty ||
           _librasController.text.isNotEmpty ||
           _valorController.text.isNotEmpty ||
           (_abonoController.text.isNotEmpty && _abonoController.text != '0') ||
           _selectedCategory != null ||
           _selectedImages.isNotEmpty;
  }
}
