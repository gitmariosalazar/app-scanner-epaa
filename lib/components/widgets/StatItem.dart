import 'package:flutter/material.dart';

/// Componente reutilizable para mostrar un indicador o métrica con valor, etiqueta
/// y soporte opcional para interacción táctil (onTap).
class StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color? labelColor;
  final bool bold;
  final VoidCallback? onTap;

  const StatItem({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.labelColor,
    this.bold = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultLabelColor = theme.colorScheme.onSurfaceVariant;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: bold ? 14 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: labelColor ?? defaultLabelColor,
            fontSize: 9,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );

    if (onTap == null) {
      return Expanded(child: content);
    }

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: color.withValues(alpha: 0.15),
          highlightColor: color.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: content,
          ),
        ),
      ),
    );
  }
}
