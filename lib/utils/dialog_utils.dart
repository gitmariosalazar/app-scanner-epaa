import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/utils/responsive_utils.dart';

class DialogUtils {
  /// Muestra un diálogo de resultado (éxito, error, etc.) responsivo y atractivo
  static void showResultDialog(
    BuildContext context,
    String message,
    IconData icon,
    Color color,
  ) {
    final radius = context.largeBorderRadiusValue;
    final iconSize = context.iconLarge;
    final fontSize = context.titleMedium.fontSize ?? 20;
    final buttonHeight = context.buttonHeight;
    final sidePad = context.mediumSpacing * 1.7;
    final verticalPad = context.mediumSpacing * 1.3;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        backgroundColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sidePad,
            vertical: verticalPad,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.11),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(iconSize * 0.21),
                child: Icon(icon, size: iconSize, color: color),
              ),
              context.vSpace(0.018),
              Text(
                message,
                style: context.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                  color: color,
                  letterSpacing: 0.1,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              context.vSpace(0.018),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(radius * 0.6),
                    ),
                    elevation: 0,
                    minimumSize: Size(120, buttonHeight),
                    padding: EdgeInsets.symmetric(
                      vertical: context.smallSpacing * 0.9,
                      horizontal: context.mediumSpacing * 1.2,
                    ),
                  ),
                  icon: const Icon(Icons.close),
                  label: Text(
                    'Cerrar',
                    style: context.buttonText.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Future.microtask(() {
                      if (Navigator.of(dialogContext).mounted) {
                        dialogContext.go('/lecturas');
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required Future<bool> Function() onConfirm,
    required List<Map<String, String>> fields,
  }) {
    final theme = Theme.of(context);
    final radius = context.largeBorderRadiusValue;
    final sidePad = context.mediumSpacing * 1.2;
    final verticalPad = context.mediumSpacing * 1.1;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          backgroundColor: Color.lerp(Colors.white, Colors.blueAccent, 0.5),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sidePad,
              vertical: verticalPad,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blueAccent,
                      size: 22,
                    ),
                    context.hSpace(0.03),
                    Text(
                      'Confirmar Guardado',
                      style: context.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                context.vSpace(0.017),
                Text(
                  'Por favor, revise los datos antes de guardar:',
                  style: context.bodyMedium.copyWith(
                    color: const Color.fromARGB(221, 83, 135, 255),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                context.vSpace(0.013),
                ...fields.map(
                  (field) => _confirmationField(
                    context,
                    field['label']!,
                    field['value']!,
                  ),
                ),
                context.vSpace(0.025),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(
                          color: theme.colorScheme.error,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radius * 0.55),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.mediumSpacing,
                          vertical: context.smallSpacing * 1.2,
                        ),
                        textStyle: context.buttonText.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      icon: const Icon(Icons.cancel, size: 20),
                      label: const Text('Cancelar'),
                    ),
                    context.hSpace(0.06),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radius * 0.55),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.mediumSpacing * 1.2,
                          vertical: context.smallSpacing * 1.4,
                        ),
                        textStyle: context.buttonText.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: () async {
                        final confirmed = await onConfirm();
                        if (confirmed && context.mounted) {
                          Navigator.of(dialogContext).pop(true);
                        }
                      },
                      icon: const Icon(Icons.save, size: 20),
                      label: const Text('Guardar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _confirmationField(
    BuildContext context,
    String label,
    String value,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.smallSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: context.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'No especificado',
              style: context.bodyMedium.copyWith(
                fontWeight: FontWeight.normal,
                fontSize: 12,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
