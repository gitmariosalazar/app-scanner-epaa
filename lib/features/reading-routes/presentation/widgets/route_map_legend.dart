import 'package:flutter/material.dart';

class RouteMapLegend extends StatefulWidget {
  const RouteMapLegend({super.key});

  @override
  State<RouteMapLegend> createState() => _RouteMapLegendState();
}

class _RouteMapLegendState extends State<RouteMapLegend> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? cs.surfaceContainer : Colors.white).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.palette_rounded, size: 14, color: cs.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Leyenda de Colores',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 6),
                  const Divider(height: 1),
                  const SizedBox(height: 6),
                  _LegendItem(color: Colors.green.shade600, label: 'Leída / Tomada (Verde)'),
                  _LegendItem(color: const Color(0xFF1E88E5), label: 'Pendiente / No tomada (Azul)'),
                  _LegendItem(color: Colors.orange.shade700, label: 'Con Novedad / Alerta'),
                  _LegendItem(color: Colors.purple.shade600, label: 'Saltada / Omitida'),
                  _LegendItem(
                    color: Colors.blue.shade700,
                    label: 'Mi ubicación GPS',
                    isCircle: true,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isCircle;

  const _LegendItem({
    required this.color,
    required this.label,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isCircle ? null : BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
