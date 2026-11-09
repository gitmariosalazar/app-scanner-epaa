import 'package:flutter/material.dart';

class RouteProgressBar extends StatelessWidget {
  final int total;
  final int completed;
  final int novelty;
  final int pending;
  final double percentage;
  final double height;
  final bool showStats;

  const RouteProgressBar({
    super.key,
    required this.total,
    required this.completed,
    required this.novelty,
    required this.pending,
    required this.percentage,
    this.height = 10.0,
    this.showStats = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final completedFactor = total > 0
        ? (completed / total).clamp(0.0, 1.0)
        : 0.0;
    final noveltyFactor = total > 0 ? (novelty / total).clamp(0.0, 1.0) : 0.0;
    final validPercentage = percentage.clamp(0.0, 100.0);

    // Colores adaptativos
    final completedColor = isDark
        ? const Color(0xFF4CAF50)
        : Colors.green.shade600;
    final noveltyColor = isDark
        ? const Color(0xFFFF9800)
        : Colors.orange.shade700;
    final pendingColor = isDark
        ? Colors.blueGrey.shade300
        : Colors.blueGrey.shade400;
    final trackColor = isDark
        ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
        : cs.surfaceContainerHighest.withValues(alpha: 0.7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showStats) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Avance de la Ruta',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
              _PercentageBadge(
                percentage: validPercentage,
                isDark: isDark,
                primary: cs.primary,
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],

        // Barra de progreso multi-segmento mejorada
        Container(
          height: height,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(color: Color(cs.outline.value), width: 1),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: Row(
              children: [
                if (completedFactor > 0)
                  Flexible(
                    flex: (completedFactor * 1000).round().clamp(1, 1000),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            completedColor,
                            completedColor.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                if (noveltyFactor > 0)
                  Flexible(
                    flex: (noveltyFactor * 1000).round().clamp(1, 1000),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            noveltyColor,
                            noveltyColor.withValues(alpha: 0.85),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                // Espacio restante (pendientes)
                if (1.0 - (completedFactor + noveltyFactor) > 0.001)
                  Flexible(
                    flex: ((1.0 - completedFactor - noveltyFactor) * 1000)
                        .round()
                        .clamp(1, 1000),
                    child: const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
        ),

        if (showStats) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatItem(
                dotColor: completedColor,
                label: 'Leídas',
                count: completed,
                isDark: isDark,
              ),
              _StatItem(
                dotColor: noveltyColor,
                label: 'Novedades',
                count: novelty,
                isDark: isDark,
              ),
              _StatItem(
                dotColor: pendingColor,
                label: 'Pendientes',
                count: pending,
                isDark: isDark,
              ),
              _StatItem(
                dotColor: cs.primary,
                label: 'Total',
                count: total,
                isDark: isDark,
                isTotal: true,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _PercentageBadge extends StatelessWidget {
  final double percentage;
  final bool isDark;
  final Color primary;

  const _PercentageBadge({
    required this.percentage,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = percentage >= 100;
    final bgColor = isComplete
        ? (isDark
              ? const Color(0xFF1B5E20).withValues(alpha: 0.35)
              : Colors.green.shade50)
        : primary.withValues(alpha: isDark ? 0.22 : 0.12);
    final textColor = isComplete
        ? (isDark ? const Color(0xFF81C784) : Colors.green.shade800)
        : primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isComplete
              ? (isDark
                    ? const Color(0xFF4CAF50).withValues(alpha: 0.4)
                    : Colors.green.shade200)
              : primary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Text(
        '${percentage.toStringAsFixed(1)}%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
          color: textColor,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final Color dotColor;
  final String label;
  final int count;
  final bool isDark;
  final bool isTotal;

  const _StatItem({
    required this.dotColor,
    required this.label,
    required this.count,
    required this.isDark,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: dotColor.withValues(alpha: 0.35),
                blurRadius: 3,
                spreadRadius: 0.5,
              ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: theme.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '$count',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: isTotal ? cs.primary : cs.onSurface,
          ),
        ),
      ],
    );
  }
}
