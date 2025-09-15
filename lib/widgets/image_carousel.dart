import 'dart:io';
import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {
  final List<File> images;
  final VoidCallback? onAddImage;
  final void Function(int index)? onRemoveImage;
  final bool isLoading;

  const ImageCarousel({
    Key? key,
    required this.images,
    this.onAddImage,
    this.onRemoveImage,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
          : widget.images.isEmpty
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
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return Image.file(
            widget.images[index],
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }

  Widget _buildNavigationButtons() {
    if (widget.images.length <= 1) return const SizedBox();

    return Positioned.fill(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botón anterior
          if (_currentIndex > 0)
            Positioned(
              left: 8,
              child: Container(
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
              ),
            ),
          // Botón siguiente
          if (_currentIndex < widget.images.length - 1)
            Positioned(
              right: 8,
              child: Container(
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
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageIndicators() {
    if (widget.images.length <= 1) return const SizedBox();

    return Positioned(
      bottom: 8,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.images.length,
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
    if (widget.images.isEmpty) return const SizedBox();

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
                widget.onRemoveImage?.call(_currentIndex);
              },
            ),
          ),
        ],
      ),
    );
  }
}