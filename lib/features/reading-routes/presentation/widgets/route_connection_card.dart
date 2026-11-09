import 'package:flutter/material.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_connection_item.dart';

class RouteConnectionCard extends StatelessWidget {
  final RouteConnectionItem connection;
  final bool isNextInSequence;
  final VoidCallback onTakeReading;
  final VoidCallback? onLocateOnMap;

  const RouteConnectionCard({
    super.key,
    required this.connection,
    this.isNextInSequence = false,
    required this.onTakeReading,
    this.onLocateOnMap,
  });

  Color _getStatusColor() {
    switch (connection.estado) {
      case 'LEIDA':
        return Colors.green.shade600;
      case 'NOVEDAD':
        return Colors.orange.shade700;
      case 'SALTADA':
      case 'OMITIDA':
        return Colors.amber.shade800;
      case 'PENDIENTE':
      default:
        return isNextInSequence
            ? const Color(0xFF0288D1)
            : Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon() {
    switch (connection.estado) {
      case 'LEIDA':
        return Icons.check_circle_rounded;
      case 'NOVEDAD':
        return Icons.warning_amber_rounded;
      case 'SALTADA':
      case 'OMITIDA':
        return Icons.skip_next_rounded;
      case 'PENDIENTE':
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHighest : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isNextInSequence
              ? cs.primary
              : (isDark
                    ? Colors.white10
                    : Colors.black.withValues(alpha: 0.06)),
          width: isNextInSequence ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isNextInSequence
                ? cs.primary.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: isNextInSequence ? 10 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Siguiente en Secuencia" Banner
          if (isNextInSequence && connection.estado == 'PENDIENTE')
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.directions_walk_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'SIGUIENTE EN SECUENCIA DE LECTURA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Sequence Number + Status Badge + Map Locate Button
                Row(
                  children: [
                    // Sequence Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
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

                    // Clave Catastral & Cuenta
                    Expanded(
                      child: Text(
                        '${connection.acometidaId} ${connection.cuenta != null ? '(Cta. ${connection.cuenta})' : ''}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 12, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            connection.estado,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Offline pending sync chip
                    if (connection.isOfflinePending) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.save_rounded,
                              size: 11,
                              color: Colors.white,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'Local',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                // Subscriber Name
                Row(
                  children: [
                    // ===== Nombre (izquierda) =====
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 16,
                            color: Colors.blueGrey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              connection.abonado,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ===== ID (derecha) =====
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.badge_rounded,
                          size: 15,
                          color: Colors.blueGrey.shade500,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          connection.clienteId.trim().isNotEmpty &&
                                  connection.clienteId != 'null'
                              ? connection.clienteId
                              : 'Sin ID',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueGrey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Address & Street side
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
                        '${connection.direccion ?? 'Sin dirección catastral'} ${connection.ladoCalle != null ? '• Lado: ${connection.ladoCalle}' : ''}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: cs.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Meter number & Access instructions
                if (connection.numeroMedidor != null ||
                    connection.instruccionAcceso != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (connection.numeroMedidor != null) ...[
                        Icon(
                          Icons.speed_rounded,
                          size: 13,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Medidor: ${connection.numeroMedidor}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      if (connection.instruccionAcceso != null &&
                          connection.instruccionAcceso!.isNotEmpty) ...[
                        Icon(
                          Icons.info_outline_rounded,
                          size: 13,
                          color: Colors.amber.shade800,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            connection.instruccionAcceso!,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.amber.shade800,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],

                const SizedBox(height: 10),

                // Readings block
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ReadingValueBox(
                        label: 'Lectura Anterior',
                        value: connection.lecturaAnterior != null
                            ? '${connection.lecturaAnterior!.toStringAsFixed(1)} m³'
                            : '--',
                      ),
                      _ReadingValueBox(
                        label: 'Promedio',
                        value: connection.consumoPromedio != null
                            ? '${connection.consumoPromedio!.toStringAsFixed(1)} m³'
                            : '--',
                      ),
                      _ReadingValueBox(
                        label: 'Lectura Actual',
                        value: connection.lecturaActual != null
                            ? '${connection.lecturaActual!.toStringAsFixed(1)} m³'
                            : 'Pendiente',
                        isHighlighted: connection.lecturaActual != null,
                        highlightColor: statusColor,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Action buttons row
                Row(
                  children: [
                    // Locate on map button
                    if (connection.hasCoordinates && onLocateOnMap != null)
                      OutlinedButton.icon(
                        onPressed: onLocateOnMap,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.map_rounded, size: 15),
                        label: const Text(
                          'Mapa',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),

                    const Spacer(),

                    // Primary Action: "Tomar Lectura" or "Modificar"
                    Tooltip(
                      message: connection.isCompleted ? 'Próximamente...' : '',
                      child: FilledButton.icon(
                        onPressed: connection.isCompleted
                            ? null
                            : onTakeReading,
                        style: FilledButton.styleFrom(
                          backgroundColor: connection.isCompleted
                              ? cs.secondary
                              : (isNextInSequence
                                    ? cs.primary
                                    : const Color(0xFF0288D1)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: Icon(
                          connection.isCompleted
                              ? Icons.edit_rounded
                              : Icons.edit_note,
                          size: 15,
                          color: Colors.white,
                        ),

                        label: Text(
                          connection.isCompleted
                              ? 'Modificar'
                              : 'Tomar Lectura',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingValueBox extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;
  final Color? highlightColor;

  const _ReadingValueBox({
    required this.label,
    required this.value,
    this.isHighlighted = false,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 9.5, color: Colors.grey)),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isHighlighted
                ? (highlightColor ?? Colors.green.shade700)
                : null,
          ),
        ),
      ],
    );
  }
}
