import 'dart:io';
import 'package:flutter/material.dart';
import 'package:juskar/widgets/full_screen_image_viewer.dart';

class ImageCarousel extends StatefulWidget {
  final List<File> images;
  final List<String> imageUrls; // URLs de imágenes existentes
  final VoidCallback? onAddImage;
  final void Function(int index)? onRemoveImage;
  final void Function(int index)? onRemoveUrl; // Callback para remover URLs
  final bool isLoading;

  const ImageCarousel({
    Key? key,
    required this.images,
    this.imageUrls = const [],
    this.onAddImage,
    this.onRemoveImage,
    this.onRemoveUrl,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // Combinar ambas listas para obtener el total de imágenes
  int get totalImages => widget.imageUrls.length + widget.images.length;
  bool get hasImages => totalImages > 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openFullScreenViewer(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          imageUrls: widget.imageUrls,
          imageFiles: widget.images,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF404040),
          width: 1,
        ),
      ),
      child: widget.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7C7BFF),
              ),
            )
          : !hasImages
              ? _buildEmptyState()
              : Stack(
                  children: [
                    _buildImageCarousel(),
                    _buildNavigationButtons(),
                    _buildImageIndicators(),
                    _buildRemoveButton(),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: widget.onAddImage,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 48,
            color: Colors.white54,
          ),
          SizedBox(height: 8),
          Text(
            'Toca para agregar imágenes',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: totalImages,
        itemBuilder: (context, index) {
          // Primero mostrar las URLs existentes, luego los archivos locales
          if (index < widget.imageUrls.length) {
            // Mostrar imagen desde URL
            return GestureDetector(
              onTap: () => _openFullScreenViewer(index),
              child: Image.network(
                widget.imageUrls[index],
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF7C7BFF),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Error al cargar imagen',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          } else {
            // Mostrar archivo local
            final localIndex = index - widget.imageUrls.length;
            return GestureDetector(
              onTap: () => _openFullScreenViewer(index),
              child: Image.file(
                widget.images[localIndex],
                fit: BoxFit.cover,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildNavigationButtons() {
    if (totalImages <= 1) return const SizedBox();

    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Botón anterior
            if (_currentIndex > 0)
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              )
            else
              const SizedBox(width: 40), // Espacio para mantener centrado el otro botón
            // Botón siguiente
            if (_currentIndex < totalImages - 1)
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              )
            else
              const SizedBox(width: 40), // Espacio para mantener centrado el otro botón
          ],
        ),
      ),
    );
  }

  Widget _buildImageIndicators() {
    if (totalImages <= 1) return const SizedBox();

    return Positioned(
      bottom: 8,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          totalImages,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == index
                  ? const Color(0xFF7C7BFF)
                  : Colors.white54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRemoveButton() {
    if (!hasImages) return const SizedBox();

    return Positioned(
      top: 8,
      right: 8,
      child: Row(
        children: [
          // Botón agregar imagen
          Container(
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white, size: 20),
              onPressed: widget.onAddImage,
            ),
          ),
          const SizedBox(width: 4),
          // Botón eliminar imagen actual
          Container(
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () {
                // Determinar si es una URL o un archivo local
                if (_currentIndex < widget.imageUrls.length) {
                  // Eliminar URL
                  widget.onRemoveUrl?.call(_currentIndex);
                } else {
                  // Eliminar archivo local
                  final localIndex = _currentIndex - widget.imageUrls.length;
                  widget.onRemoveImage?.call(localIndex);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}