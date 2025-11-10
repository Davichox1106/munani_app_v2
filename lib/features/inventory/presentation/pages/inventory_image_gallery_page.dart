import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class InventoryImageGalleryPage extends StatefulWidget {
  final String inventoryId;
  final String title;
  final List<String> imageUrls;

  const InventoryImageGalleryPage({
    super.key,
    required this.inventoryId,
    required this.title,
    required this.imageUrls,
  });

  @override
  State<InventoryImageGalleryPage> createState() => _InventoryImageGalleryPageState();
}

class _InventoryImageGalleryPageState extends State<InventoryImageGalleryPage> {
  late final PageController _pageController;
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentIndex.dispose();
    super.dispose();
  }

  List<String> get _images => widget.imageUrls;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _images.isEmpty
                ? _buildPlaceholder()
                : Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _images.length,
                          onPageChanged: (index) => _currentIndex.value = index,
                          itemBuilder: (context, index) {
                            final imagePath = _images[index];
                            final imageWidget = _buildImage(imagePath);
                            if (index == 0) {
                              return Hero(
                                tag: 'inventory-thumb-${widget.inventoryId}',
                                child: imageWidget,
                              );
                            }
                            return imageWidget;
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      ValueListenableBuilder<int>(
                        valueListenable: _currentIndex,
                        builder: (_, current, __) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_images.length, (index) {
                              final isActive = current == index;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: isActive ? 18 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isActive ? AppColors.primaryOrange : Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.broken_image_outlined, size: 56, color: AppColors.textSecondary),
        SizedBox(height: 12),
        Text(
          'Sin imágenes disponibles',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String path) {
    final isRemote = path.startsWith('http');
    final imageWidget = isRemote
        ? Image.network(
            path,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, size: 40, color: AppColors.textSecondary),
            ),
          )
        : Image.file(
            File(path),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, size: 40, color: AppColors.textSecondary),
            ),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Container(
          color: Colors.black,
          child: imageWidget,
        ),
      ),
    );
  }
}








