import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final List<File> imageFiles;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrls,
    required this.imageFiles,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int get totalImages => widget.imageUrls.length + widget.imageFiles.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} de $totalImages',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: totalImages,
            itemBuilder: (context, index) {
              return InteractiveViewer(
                panEnabled: true,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: _buildImage(index),
                ),
              );
            },
          ),
          if (totalImages > 1) _buildImageIndicators(),
        ],
      ),
    );
  }

  Widget _buildImage(int index) {
    if (index < widget.imageUrls.length) {
      // Mostrar imagen desde URL
      return Image.network(
        widget.imageUrls[index],
        fit: BoxFit.contain,
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
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  'Error al cargar imagen',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      // Mostrar archivo local
      final localIndex = index - widget.imageUrls.length;
      return Image.file(
        widget.imageFiles[localIndex],
        fit: BoxFit.contain,
      );
    }
  }

  Widget _buildImageIndicators() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          totalImages,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == index
                  ? Colors.white
                  : Colors.white.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }
}