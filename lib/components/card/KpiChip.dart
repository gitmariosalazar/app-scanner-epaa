import 'package:flutter/material.dart';

/// Chip de KPI reutilizable y profesional.
///
/// Ejemplo de uso:
/// ```dart
/// KpiChip(
///   label: 'Completadas',
///   value: '24',
///   icon: Icons.check_circle_outline,
///   color: Colors.green,
///   onTap: () => print('Tocado'),
/// )
/// ```
class KpiChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  /// Color de fondo del chip. Si es null usa `colorScheme.primary`.
  final Color? color;

  /// Color del texto e icono. Por defecto blanco.
  final Color? foregroundColor;

  /// Padding interno.
  final EdgeInsetsGeometry padding;

  /// Radio de borde.
  final double borderRadius;

  /// Si se muestra la sombra.
  final bool showShadow;

  /// Tamaño del icono.
  final double iconSize;

  /// Tamaño del valor (número).
  final double valueFontSize;

  /// Tamaño del label.
  final double labelFontSize;

  /// Callback al tocar el chip. Si es null, el chip no es clickeable.
  final VoidCallback? onTap;

  const KpiChip({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.foregroundColor,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
    this.borderRadius = 12,
    this.showShadow = true,
    this.iconSize = 16,
    this.valueFontSize = 17,
    this.labelFontSize = 9,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = color ?? cs.primary;
    final fg = foregroundColor ?? Colors.white;

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: bg.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg.withValues(alpha: 0.9), size: iconSize),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: fg,
              fontSize: valueFontSize,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: fg.withValues(alpha: 0.85),
              fontSize: labelFontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );

    // Si no hay onTap, devolvemos el contenido normal (sin InkWell)
    if (onTap == null) return content;

    // Versión clickeable con feedback visual
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: content,
      ),
    );
  }
}
