import 'package:flutter/material.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_connection_item.dart';

class RouteMapBottomSheet extends StatelessWidget {
  final RouteConnectionItem connection;
  final VoidCallback onTakeReading;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onClose;

  const RouteMapBottomSheet({
    super.key,
    required this.connection,
    required this.onTakeReading,
    required this.onPrevious,
    required this.onNext,
    required this.onClose,
  });

  Color _getStatusColor() {
    switch (connection.estado) {
      case 'LEIDA':
        return Colors.green.shade600;
      case 'NOVEDAD':
        return Colors.orange.shade700;
      case 'SALTADA':
      case 'OMITIDA':
        return Colors.purple.shade600;
      case 'PENDIENTE':
      default:
        return const Color(0xFF0288D1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor();

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Sequence + ID + Close button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${connection.orden}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'C.C: ${connection.acometidaId} ${connection.cuenta != null ? '\t(CI. ${connection.clienteId})' : ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      connection.abonado,
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  connection.estado,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: onClose,
                padding: EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                style: IconButton.styleFrom(
                  foregroundColor: cs.onErrorContainer.withValues(alpha: 1.0),
                  backgroundColor: cs.onErrorContainer.withValues(alpha: 0.12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Address and Side
          if (connection.direccion != null)
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 13,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${connection.direccion!} ${connection.ladoCalle != null ? '(${connection.ladoCalle})' : ''}',
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 8),

          // Readings metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MapMiniStat(
                label: 'Medidor',
                value: connection.numeroMedidor ?? 'S/N',
                icon: Icons.speed_outlined,
              ),
              _MapMiniStat(
                label: 'Lect. Anterior',
                value: connection.lecturaAnterior != null
                    ? '${connection.lecturaAnterior!.toStringAsFixed(1)} '
                    : '--',
              ),
              _MapMiniStat(
                label: 'Lect. Actual',
                value: connection.lecturaActual != null
                    ? '${connection.lecturaActual!.toStringAsFixed(1)} '
                    : 'Pendiente',
                highlight: connection.lecturaActual != null,
                color: statusColor,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Action Button
          Row(
            children: [
              // ===== BOTÓN 1: Tomar / Modificar Lectura (más ancho) =====
              Expanded(
                flex: 3, // ← ocupa más espacio
                child: SizedBox(
                  height: 38,
                  child: FilledButton.icon(
                    onPressed: connection.isCompleted ? null : onTakeReading,
                    style: FilledButton.styleFrom(
                      backgroundColor: connection.isCompleted
                          ? Colors.green.shade600
                          : const Color(0xFF0288D1),
                      disabledBackgroundColor: Colors.green.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(
                      connection.isCompleted
                          ? Icons.edit_rounded
                          : Icons.edit_note_rounded,
                      size: 15,
                    ),
                    label: Text(
                      connection.isCompleted
                          ? 'Modificar Lectura'
                          : 'Tomar Lectura',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // ===== BOTÓN 2: Anterior (más estrecho) =====
              Expanded(
                flex: 1, // ← más pequeño
                child: SizedBox(
                  height: 38,
                  child: FilledButton.icon(
                    onPressed: onPrevious,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF5E35B1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ), // reduce padding
                    ),
                    icon: const Icon(Icons.arrow_back_rounded, size: 15),
                    label: const Text(
                      'Ant.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // ===== BOTÓN 3: Siguiente (más estrecho) =====
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 38,
                  child: FilledButton.icon(
                    onPressed: onNext,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF5E35B1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                    label: const Text(
                      'Sig.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapMiniStat extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final Color? color;
  final IconData? icon; // ← nuevo (opcional)

  const _MapMiniStat({
    required this.label,
    required this.value,
    this.highlight = false,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final effectiveColor = highlight ? (color ?? cs.primary) : cs.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label + Icono (si existe)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 11,
                color: highlight ? effectiveColor : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 3),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 1),
        // Valor
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: effectiveColor,
          ),
        ),
      ],
    );
  }
}
