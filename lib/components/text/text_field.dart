import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/utils/responsive_utils.dart';

/// Widget unificado para campos de texto editables y de solo lectura.
/// Reemplaza tanto EditTextField como ReadOnlyField.
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData leftIcon;
  final String? hintText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final String? Function(String?)? validator;
  final TextStyle? textStyle;
  final bool isReadOnly;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.leftIcon,
    this.hintText,
    this.keyboardType,
    this.maxLines,
    this.validator,
    this.textStyle,
    this.isReadOnly = false,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = !isReadOnly;

    const iconPaddingLeft = 8.0;
    final iconSize = ResponsiveUtils.iconExtraSmall(context);
    final borderRadius = BorderRadius.circular(
      ResponsiveUtils.extraSmallBorderRadiusValue(context),
    );

    // Espacio interno consistente para el texto
    final contentPadding = EdgeInsets.only(
      left: iconSize + iconPaddingLeft + 4,
      right: 12,
      top: isReadOnly ? 8 : 12,
      bottom: isReadOnly ? 8 : 12,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta
        Text(
          label,
          style: (textStyle ?? ResponsiveUtils.bodySmall(context)).copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(
              isReadOnly ? 0.7 : 0.8,
            ),
          ),
        ),
        ResponsiveUtils.vSpace(context, 0.0035),

        // Campo de texto con icono superpuesto
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              maxLines: maxLines ?? 1,
              readOnly: isReadOnly,
              enabled: isEnabled,
              validator: isReadOnly
                  ? null
                  : validator, // No validar si es read-only
              style: (textStyle ?? ResponsiveUtils.bodyMedium(context))
                  .copyWith(
                    color: isReadOnly
                        ? theme.colorScheme.onSurface.withOpacity(0.85)
                        : null,
                  ),
              decoration: InputDecoration(
                hintText: hintText,
                contentPadding: contentPadding,
                filled: !isReadOnly,
                fillColor: isReadOnly
                    ? null
                    : theme.colorScheme.surface.withOpacity(0.6),
                border: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(
                      isReadOnly ? 0.4 : 0.5,
                    ),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(
                      isReadOnly ? 0.4 : 0.5,
                    ),
                    width: 1,
                  ),
                ),
                focusedBorder: isReadOnly
                    ? null
                    : OutlineInputBorder(
                        borderRadius: borderRadius,
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide: BorderSide(
                    color: theme.colorScheme.error,
                    width: 2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide: BorderSide(
                    color: theme.colorScheme.error,
                    width: 2,
                  ),
                ),
              ),
            ),

            // Icono a la izquierda
            Positioned(
              left: iconPaddingLeft,
              child: Icon(
                leftIcon,
                size: iconSize,
                color: theme.colorScheme.onSurface.withOpacity(
                  isReadOnly ? 0.7 : 0.6,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
