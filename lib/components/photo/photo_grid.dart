import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_application/shared/files/domain/repositories/file_repository.dart';
import 'package:flutter_application/shared/files/presentation/use_file_preview.dart';

class PhotoGallery extends ConsumerStatefulWidget {
  final List<String>
  imagePaths; // Rutas relativas (ej: "images/incidents/xxx.jpg")
  final String? title;

  const PhotoGallery({super.key, required this.imagePaths, this.title});

  @override
  ConsumerState<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends ConsumerState<PhotoGallery> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.imagePaths.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay fotos disponibles'),
          ],
        ),
      );
    }

    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              widget.title!,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),

        SizedBox(
          height: 340,
          child: PageView.builder(
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: widget.imagePaths.length,

            itemBuilder: (context, index) {
              final path = widget.imagePaths[index];
              print('📸 Intentando cargar: $path');

              return GestureDetector(
                onTap: () => _showFullScreen(context, index),
                child: Consumer(
                  builder: (context, ref, child) {
                    final previewState = ref.watch(useFilePreviewProvider);

                    if (previewState.blobUrl == null && !previewState.loading) {
                      print('🔄 Iniciando load para: $path');
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ref
                            .read(useFilePreviewProvider.notifier)
                            .load(FileCategory.incidents, path);
                      });
                    }

                    print(
                      'Blob URL: ${previewState.blobUrl} | Loading: ${previewState.loading} | Error: ${previewState.error}',
                    );

                    return CachedNetworkImage(
                      imageUrl: previewState.blobUrl ?? '',
                      fit: BoxFit.contain,
                      placeholder: (_, __) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.broken_image_rounded,
                        size: 60,
                        color: Colors.red,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        // Indicadores
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.imagePaths.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index ? cs.primary : cs.outline,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFullScreen(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenPhotoGallery(
          imagePaths: widget.imagePaths,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

// ==================== FULL SCREEN GALLERY ====================

class FullScreenPhotoGallery extends ConsumerStatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const FullScreenPhotoGallery({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<FullScreenPhotoGallery> createState() =>
      _FullScreenPhotoGalleryState();
}

class _FullScreenPhotoGalleryState
    extends ConsumerState<FullScreenPhotoGallery> {
  late PageController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.85),
        title: Text('${_currentIndex + 1} / ${widget.imagePaths.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _controller,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemCount: widget.imagePaths.length,
        itemBuilder: (context, index) {
          final path = widget.imagePaths[index];

          return Consumer(
            builder: (context, ref, child) {
              final previewState = ref.watch(useFilePreviewProvider);

              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 5,
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: previewState.blobUrl ?? '',
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const CircularProgressIndicator(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
