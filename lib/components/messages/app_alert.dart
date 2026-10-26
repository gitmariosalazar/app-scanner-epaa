import 'package:flutter/material.dart';

enum AlertType { success, info, warning, error }

class AppAlert extends StatelessWidget {
  final String? title;
  final String message;
  final AlertType type;
  final VoidCallback? onClose;
  final Widget? action;

  const AppAlert({
    super.key,
    this.title,
    required this.message,
    this.type = AlertType.info,
    this.onClose,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (baseColor, icon) = _getAlertVisuals(type);

    // Ajustes cromáticos profesionales para Modo Claro vs Modo Oscuro
    final backgroundColor = isDark
        ? baseColor.withValues(alpha: 0.15)
        : baseColor.withValues(alpha: 0.10);

    final borderColor = isDark
        ? baseColor.withValues(alpha: 0.30)
        : baseColor.withValues(alpha: 0.25);

    final iconColor = isDark ? _lightenColor(baseColor, 0.2) : baseColor;

    final titleColor = isDark
        ? Colors.white.withValues(alpha: 0.95)
        : _darkenColor(baseColor, 0.35);

    final textColor = isDark
        ? Colors.white.withValues(alpha: 0.80)
        : _darkenColor(baseColor, 0.25);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: title != null
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13.5,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (action != null) ...[const SizedBox(width: 8), action!],
          if (onClose != null) ...[
            const SizedBox(width: 4),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onClose,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Colores base de acento e iconos
  (Color, IconData) _getAlertVisuals(AlertType type) {
    return switch (type) {
      AlertType.success => (
        const Color(0xFF2E7D32),
        Icons.check_circle_outline_rounded,
      ),
      AlertType.info => (const Color(0xFF0288D1), Icons.info_outline_rounded),
      AlertType.warning => (
        const Color(0xFFED6C02),
        Icons.warning_amber_rounded,
      ),
      AlertType.error => (const Color(0xFFD32F2F), Icons.error_outline_rounded),
    };
  }

  // Utilidades simples para ajustar luminancia del texto
  Color _darkenColor(Color c, double factor) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - factor).clamp(0.0, 1.0))
        .toColor();
  }

  Color _lightenColor(Color c, double factor) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness + factor).clamp(0.0, 1.0))
        .toColor();
  }
}
