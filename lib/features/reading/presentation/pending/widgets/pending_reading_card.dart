// lib/features/reading/presentation/pending/widgets/pending_reading_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_application/components/messages/app_alert.dart';
import 'package:flutter_application/features/reading/domain/entities/pending_reading_connection.dart';
import 'package:flutter_application/features/reading/domain/entities/pending_reading_history.dart';
import 'package:flutter_application/features/reading/domain/services/pending_location_service.dart';
import 'package:flutter_application/features/reading/presentation/pending/widgets/pending_connection_map_sheet.dart';
import 'package:intl/intl.dart';

class PendingReadingCard extends StatelessWidget {
  final PendingReadingConnection connection;
  final VoidCallback onTakeReading;
  final VoidCallback? onViewDetails;

  const PendingReadingCard({
    super.key,
    required this.connection,
    required this.onTakeReading,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fila superior: Clave catastral + Sector + Tarifa ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        size: 16,
                        color: cs.onPrimaryContainer,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        connection.cadastralKey,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: cs.onPrimaryContainer,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Sector chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Sector ${connection.sector}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey.shade800,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Tarifa chip
                if (connection.rateName.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      connection.rateName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cs.onSecondaryContainer,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Cliente y Cédula ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: cs.primary.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.person_rounded,
                    size: 20,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        connection.clientName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'CI/RUC: ${connection.cardId.isNotEmpty ? connection.cardId : '—'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Cuenta: ${connection.account}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Dirección ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    connection.address.isNotEmpty
                        ? connection.address
                        : 'Dirección no registrada',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Fila de Métricas: Medidor & Consumo Promedio ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Medidor
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.speed_rounded, size: 18, color: cs.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Medidor',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                connection.meterNumber.isNotEmpty
                                    ? connection.meterNumber
                                    : 'Sin medidor',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    height: 28,
                    width: 1,
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                  ),

                  // Consumo promedio
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.water_drop_outlined,
                            size: 18,
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Promedio',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '${connection.averageConsumption.toStringAsFixed(1)} m³',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Historial de Última Lectura (si existe) ──
            if (connection.lastReading != null) ...[
              const SizedBox(height: 10),
              _LastReadingSection(lastReading: connection.lastReading!),
            ],

            // ── Ubicaciones y Distancia (Acometida ↔ Última Lectura) ──
            _LocationsAndDistanceSection(
              connection: connection,
              onOpenMap: () {
                PendingConnectionMapSheet.show(
                  context,
                  connection: connection,
                  onTakeReading: onTakeReading,
                );
              },
            ),

            const SizedBox(height: 14),

            // ── Botones de Acción: Tomar Lectura y Cómo Llegar ──
            Builder(
              builder: (context) {
                const service = PendingLocationService();
                final hasLocation =
                    service.isValid(connection.locationConnection) ||
                    service.isValid(connection.lastReading?.locationReading);

                return Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: FilledButton.icon(
                          onPressed: onTakeReading,
                          icon: const Icon(
                            Icons.edit_calendar_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'Tomar Lectura',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: FilledButton.icon(
                          onPressed: hasLocation
                              ? () {
                                  PendingConnectionMapSheet.show(
                                    context,
                                    connection: connection,
                                    onTakeReading: onTakeReading,
                                  );
                                }
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Esta acometida no posee coordenadas GPS registradas.',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                          icon: Icon(
                            Icons.map_rounded,
                            size: 18,
                            color: hasLocation ? Colors.white : cs.outline,
                          ),
                          label: Text(
                            'Cómo Llegar',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: hasLocation ? Colors.white : cs.outline,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: hasLocation
                                ? const Color(0xFF00695C)
                                : cs.surfaceContainerHighest.withValues(
                                    alpha: 0.4,
                                  ),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LastReadingSection extends StatelessWidget {
  final PendingReadingHistory lastReading;

  const _LastReadingSection({required this.lastReading});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    String dateStr = '—';
    if (lastReading.readingDate != null) {
      dateStr = DateFormat('dd/MM/yyyy').format(lastReading.readingDate!);
    } else if (lastReading.readingMonth != null &&
        lastReading.readingYear != null) {
      dateStr = '${lastReading.readingMonth} ${lastReading.readingYear}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 14,
                color: Colors.amber.shade900,
              ),
              const SizedBox(width: 5),
              Text(
                'Última lectura: $dateStr',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.amber.shade900,
                ),
              ),
              const Spacer(),
              if (lastReading.consumption != null)
                Text(
                  '${lastReading.consumption!.toStringAsFixed(0)} m³',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.amber.shade900,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (lastReading.previousReading != null)
                Text(
                  'Ant: ${lastReading.previousReading!.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                ),
              if (lastReading.previousReading != null &&
                  lastReading.currentReading != null)
                Text(
                  '  ➔  ',
                  style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                ),
              if (lastReading.currentReading != null)
                Text(
                  'Act: ${lastReading.currentReading!.toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                ),
              if (lastReading.observation != null &&
                  lastReading.observation!.trim().isNotEmpty) ...[
                const Spacer(),
                Expanded(
                  child: Text(
                    lastReading.observation!,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontStyle: FontStyle.italic,
                      color: cs.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationsAndDistanceSection extends StatelessWidget {
  final PendingReadingConnection connection;
  final VoidCallback onOpenMap;

  const _LocationsAndDistanceSection({
    required this.connection,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    const service = PendingLocationService();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final locConn = connection.locationConnection;
    final locLast = connection.lastReading?.locationReading;

    final isConnValid = service.isValid(locConn);
    final isLastValid = service.isValid(locLast);

    final distanceMeters = service.calculateDistance(locConn, locLast);

    // Si ninguna tiene coordenadas registradas
    if (!isConnValid && !isLastValid) {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 14,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              'Sin coordenadas GPS registradas',
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila: Título de sección + acción ver en mapa
          Row(
            children: [
              Icon(Icons.map_outlined, size: 14, color: cs.primary),
              const SizedBox(width: 5),
              Text(
                'Geolocalización',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onOpenMap,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Ver en mapa',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: cs.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Coordenada Acometida
          if (isConnValid) ...[
            Row(
              children: [
                Icon(
                  Icons.water_drop_rounded,
                  size: 12,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  'Acometida: ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                Expanded(
                  child: Text(
                    service.formatCoordinates(locConn),
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          // Coordenada Última Lectura
          if (isLastValid) ...[
            const SizedBox(height: 3),
            Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 12,
                  color: Colors.deepOrange.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Últ. Lectura: ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                Expanded(
                  child: Text(
                    service.formatCoordinates(locLast),
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          // Distancia entre ambas ubicaciones (si existen ambas)
          if (distanceMeters != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: distanceMeters > 30
                    ? Colors.amber.withValues(alpha: 0.15)
                    : Colors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: distanceMeters > 30
                      ? Colors.amber.withValues(alpha: 0.4)
                      : Colors.green.withValues(alpha: 0.3),
                  width: 0.6,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    distanceMeters > 30
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline_rounded,
                    size: 13,
                    color: distanceMeters > 30
                        ? Colors.amber.shade900
                        : Colors.green.shade800,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Distancia entre puntos: ${service.formatDistance(distanceMeters)}',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: distanceMeters > 30
                            ? Colors.amber.shade900
                            : Colors.green.shade800,
                      ),
                    ),
                  ),
                  if (distanceMeters <= 30)
                    Text(
                      'Coincidente',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade800,
                      ),
                    )
                  else
                    Text(
                      'Divergencia',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber.shade900,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            AppAlert(
              message:
                  'Estas a ${connection.distanceMeters} metros de tu última ubicación',
              size: AlertSize.xs,
            ),
          ],
        ],
      ),
    );
  }
}
