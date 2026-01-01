import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application/utils/responsive_utils.dart';
import 'package:image_picker/image_picker.dart';

class AppColors {
  static const primary = Color(0xFF0288D1);
  static const error = Color(0xFFE57373);
  static const cardSecondaryBackground = Color(0xFFE3F2FD);
  static const textPrimary = Color(0xFF212121);
}

class ImagesSection extends StatelessWidget {
  final List<File> attachedImages;
  final String mode;
  final Function(File) onImageAdded;
  final Function(int) onImageRemoved;

  const ImagesSection({
    super.key,
    required this.attachedImages,
    required this.mode,
    required this.onImageAdded,
    required this.onImageRemoved,
  });

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (pickedImage != null) {
      onImageAdded(File(pickedImage.path));
    }
  }

  Widget _buildAddImageButton(BuildContext context, double size) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.cardSecondaryBackground.withOpacity(0.75),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.45),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.add_a_photo_rounded,
          size: size * 0.48,
          color: AppColors.primary.withOpacity(0.82),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double imageSize = ResponsiveUtils.isTablet(context) ? 90.0 : 55.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cargar Imágenes',
          style: ResponsiveUtils.bodyLarge(
            context,
          ).copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        ResponsiveUtils.vSpace(context, 0.01),
        SizedBox(
          height: imageSize,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: attachedImages.length + 1,
            separatorBuilder: (_, __) =>
                SizedBox(width: ResponsiveUtils.smallSpacing(context)),
            itemBuilder: (context, index) {
              if (index == attachedImages.length) {
                return _buildAddImageButton(context, imageSize);
              } else {
                final file = attachedImages[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        file,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.error.withOpacity(0.3),
                            child: Center(
                              child: Text(
                                'Error al cargar imagen',
                                style: ResponsiveUtils.bodySmall(
                                  context,
                                ).copyWith(color: AppColors.error),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => onImageRemoved(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
