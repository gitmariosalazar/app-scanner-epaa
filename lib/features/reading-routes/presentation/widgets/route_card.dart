import 'package:flutter/material.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_assignment.dart';
import 'package:flutter_application/features/reading-routes/presentation/widgets/route_progress_bar.dart';
import 'package:intl/intl.dart';

class RouteCard extends StatelessWidget {
  final RouteAssignment route;
  final VoidCallback onTap;
  final VoidCallback onDownloadOffline;
  final VoidCallback? onOpenMap;
  final bool isDownloading;

  const RouteCard({
    super.key,
    required this.route,
    required this.onTap,
    required this.onDownloadOffline,
    this.onOpenMap,
    this.isDownloading = false,
  });

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETADA':
        return Colors.green.shade600;
      case 'EN_PROCESO':
        return Colors.blue.shade600;
      case 'PAUSADA':
        return Colors.amber.shade800;
      case 'REASIGNADA':
        return Colors.purple.shade600;
      case 'ASIGNADA':
      default:
        return const Color(0xFF0288D1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final statusColor = _getStatusColor(route.estado);
    final formattedDate = route.fechaProgramada != null
        ? DateFormat('dd/MM/yyyy').format(route.fechaProgramada!)
        : 'Sin fecha';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHighest : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Code badge + Sector + Status chip
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.alt_route_rounded,
                            size: 15,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            route.codigoRuta,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Sector ${route.sector}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        route.estado,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Route Name
                Text(
                  route.nombreRuta,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                // Info row: Periodo + Fecha programada
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Período: ${route.periodoMes}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Icon(
                      Icons.event_available_rounded,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress Bar
                RouteProgressBar(
                  total: route.totalPredios,
                  completed: route.prediosLeidos,
                  novelty: route.prediosConNovedad,
                  pending: route.prediosPendientes,
                  percentage: route.porcentajeAvance,
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),

                // Bottom actions: Offline status / Download + "Ver ruta" button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Offline download button/indicator
                    InkWell(
                      onTap: isDownloading ? null : onDownloadOffline,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isDownloading)
                              const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            else if (route.isDownloadedOffline)
                              Icon(
                                Icons.offline_pin_rounded,
                                size: 16,
                                color: Colors.green.shade600,
                              )
                            else
                              Icon(
                                Icons.cloud_download_outlined,
                                size: 16,
                                color: cs.primary,
                              ),
                            const SizedBox(width: 6),
                            Text(
                              route.isDownloadedOffline
                                  ? 'Guardada Offline'
                                  : 'Descargar Offline',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: route.isDownloadedOffline
                                    ? Colors.green.shade600
                                    : cs.primary,
                              ),
                            ),
                            if (route.pendingOfflineCount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade700,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${route.pendingOfflineCount} por subir',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Actions: Map shortcut button + "Abrir Ruta" indicator
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onOpenMap != null) ...[
                          IconButton(
                            icon: const Icon(Icons.map_rounded),
                            tooltip: 'Ver ruta en mapa interactivo',
                            color: cs.secondary,
                            iconSize: 20,
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            onPressed: onOpenMap,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          'Abrir Ruta',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: cs.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
