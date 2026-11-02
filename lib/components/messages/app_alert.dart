import 'package:flutter/material.dart';

enum AlertType { success, info, warning, error }

enum AlertSize { xs, sm, md, lg, xl }

class AppAlert extends StatelessWidget {
  final String? title;
  final String message;
  final AlertType type;
  final AlertSize size;
  final VoidCallback? onClose;
  final Widget? action;

  const AppAlert({
    super.key,
    this.title,
    required this.message,
    this.type = AlertType.info,
    this.size = AlertSize.md, // ← default = el tamaño actual
    this.onClose,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (baseColor, icon) = _getAlertVisuals(type);
    final s = _AlertMetrics.from(size);

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
      padding: EdgeInsets.symmetric(
        horizontal: s.horizontalPadding,
        vertical: s.verticalPadding,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(s.radius),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: title != null
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: s.iconSize),
          SizedBox(width: s.gap),
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
                      fontSize: s.titleSize,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: s.titleGap),
                ],
                Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: s.messageSize,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          if (action != null) ...[SizedBox(width: s.gap * 0.7), action!],
          if (onClose != null) ...[
            SizedBox(width: s.gap * 0.4),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onClose,
              child: Padding(
                padding: EdgeInsets.all(s.closePadding),
                child: Icon(
                  Icons.close,
                  size: s.closeSize,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

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

/// Métricas internas por tamaño (todo centralizado y fácil de ajustar)
class _AlertMetrics {
  final double horizontalPadding;
  final double verticalPadding;
  final double radius;
  final double iconSize;
  final double gap;
  final double titleSize;
  final double messageSize;
  final double titleGap;
  final double closeSize;
  final double closePadding;

  const _AlertMetrics({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.radius,
    required this.iconSize,
    required this.gap,
    required this.titleSize,
    required this.messageSize,
    required this.titleGap,
    required this.closeSize,
    required this.closePadding,
  });

  factory _AlertMetrics.from(AlertSize size) {
    return switch (size) {
      AlertSize.xs => const _AlertMetrics(
        horizontalPadding: 10,
        verticalPadding: 8,
        radius: 6,
        iconSize: 16,
        gap: 8,
        titleSize: 12,
        messageSize: 11.5,
        titleGap: 1,
        closeSize: 14,
        closePadding: 2,
      ),
      AlertSize.sm => const _AlertMetrics(
        horizontalPadding: 12,
        verticalPadding: 10,
        radius: 7,
        iconSize: 18,
        gap: 10,
        titleSize: 13,
        messageSize: 12.5,
        titleGap: 1.5,
        closeSize: 16,
        closePadding: 3,
      ),
      AlertSize.md => const _AlertMetrics(
        // ← tamaño actual (default)
        horizontalPadding: 16,
        verticalPadding: 12,
        radius: 8,
        iconSize: 22,
        gap: 12,
        titleSize: 14,
        messageSize: 13.5,
        titleGap: 2,
        closeSize: 18,
        closePadding: 4,
      ),
      AlertSize.lg => const _AlertMetrics(
        horizontalPadding: 18,
        verticalPadding: 14,
        radius: 10,
        iconSize: 24,
        gap: 14,
        titleSize: 15.5,
        messageSize: 14.5,
        titleGap: 3,
        closeSize: 20,
        closePadding: 5,
      ),
      AlertSize.xl => const _AlertMetrics(
        horizontalPadding: 22,
        verticalPadding: 16,
        radius: 12,
        iconSize: 28,
        gap: 16,
        titleSize: 17,
        messageSize: 15.5,
        titleGap: 4,
        closeSize: 22,
        closePadding: 6,
      ),
    };
  }
}
