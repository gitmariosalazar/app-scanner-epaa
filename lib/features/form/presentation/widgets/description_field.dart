import 'package:flutter/material.dart';
import 'package:flutter_application/components/text/text_field.dart';
import 'package:flutter_application/utils/responsive_utils.dart';

class DescriptionField extends StatelessWidget {
  final TextEditingController descriptionController;
  final String mode;

  const DescriptionField({
    super.key,
    required this.descriptionController,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: descriptionController,
      label:
          'Descripción o Novedades${mode == 'manual' ? ' (Requerido)' : ' (Opcional)'}',
      leftIcon: Icons.description,
      maxLines: ResponsiveUtils.isTablet(context) ? 5 : 3,
      hintText: mode == 'manual'
          ? 'Ingrese una descripción detallada...'
          : 'Ingrese una descripción o novedad...',
      validator: mode == 'manual'
          ? (value) {
              /*
              if (value == null || value.isEmpty) {
                return 'Por favor, ingrese una descripción';
              }
              */
              return null;
            }
          : null,
    );
  }
}
