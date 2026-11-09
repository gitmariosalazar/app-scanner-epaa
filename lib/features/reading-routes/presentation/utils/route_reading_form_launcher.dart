import 'package:flutter/material.dart';
import 'package:flutter_application/core/di/injection.dart' as di;
import 'package:flutter_application/core/network/network_info.dart';
import 'package:flutter_application/features/reading/domain/entities/reading.dart';
import 'package:flutter_application/features/reading/domain/usecases/get_reading_info.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_connection_item.dart';
import 'package:go_router/go_router.dart';

/// Utilidad que desacopla la navegación y adaptación de datos entre
/// el módulo de rutas de lectura y el formulario estándar de toma de lectura (`FormScreen`).
///
/// Cumple con los principios de Responsabilidad Única (SRP) y Arquitectura Limpia,
/// permitiendo abrir exactamente el formulario `FormScreen` preservando la pila de navegación.
class RouteReadingFormLauncher {
  /// Abre `FormScreen` adaptando la acometida seleccionada a la entidad `Reading`.
  /// Si está conectado, intenta obtener datos frescos de la acometida; si está offline
  /// o falla la red, sintetiza una entidad `Reading` a partir de los datos en caché de la ruta.
  ///
  /// Retorna `true` si la lectura fue guardada con éxito (online u offline),
  /// o `false`/`null` si fue cancelada o el usuario regresó sin guardar.
  static Future<bool> openForm(
    BuildContext context, {
    required RouteConnectionItem connection,
    required int assignmentId,
  }) async {
    Reading reading;
    bool isConnected = false;

    try {
      isConnected = await di.sl<NetworkInfo>().isConnected;
    } catch (_) {
      isConnected = false;
    }

    if (isConnected) {
      try {
        final getReadingInfo = di.sl<GetReadingInfo>();
        final list = await getReadingInfo(connection.acometidaId)
            .timeout(const Duration(seconds: 4));
        if (list.isNotEmpty) {
          reading = list.first;
        } else {
          reading = _buildFallbackReading(connection);
        }
      } catch (_) {
        reading = _buildFallbackReading(connection);
      }
    } else {
      reading = _buildFallbackReading(connection);
    }

    if (!context.mounted) return false;

    final result = await context.push<bool>(
      '/form',
      extra: {
        'reading': [reading],
        'mode': 'route',
        'routeItem': connection,
        'assignmentId': assignmentId,
      },
    );

    return result == true;
  }

  /// Construye una entidad `Reading` completa y consistente a partir de la información
  /// almacenada localmente en la acometida de la ruta.
  static Reading _buildFallbackReading(RouteConnectionItem connection) {
    final now = DateTime.now();
    final prevDate = now.subtract(const Duration(days: 30));

    // Formatear lecturas anteriores
    final prevStr = connection.lecturaAnterior != null
        ? connection.lecturaAnterior!.toStringAsFixed(
            connection.lecturaAnterior! % 1 == 0 ? 0 : 2,
          )
        : '0';

    final avgStr = connection.consumoPromedio != null
        ? connection.consumoPromedio!.toStringAsFixed(
            connection.consumoPromedio! % 1 == 0 ? 0 : 2,
          )
        : '0';

    final monthStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    return Reading(
      readingId: connection.idDetalle,
      previousReadingDate: prevDate,
      readingTime: now,
      cadastralKey: connection.acometidaId,
      cardId: connection.clienteId.trim().isNotEmpty
          ? connection.clienteId
          : (connection.cuenta ?? connection.acometidaId),
      clientName: connection.abonado,
      address: connection.direccion ??
          (connection.referencia ?? 'Sin dirección especificada'),
      // En FormScreen: currentReading = valor del ciclo anterior
      // previousReading = valor de dos ciclos atrás
      previousReading: '0',
      currentReading: prevStr,
      sector: int.tryParse(connection.ladoCalle ?? '1') ?? 1,
      account: int.tryParse(connection.cuenta ?? '0') ?? 0,
      readingValue: '0',
      averageConsumption: avgStr,
      meterNumber: connection.numeroMedidor ?? '',
      hasCurrentReading: true,
      permitReading: true,
      connectionStateId: 1,
      connectionStateName: 'ACTIVO',
      connectionStateDescription: 'Conexión activa para toma de lectura',
      monthReading: monthStr,
      startDatePeriod: prevDate,
      endDatePeriod: now,
      connectionLocation: connection.hasCoordinates
          ? ConnectionLocation(
              lat: connection.latitud,
              lng: connection.longitud,
            )
          : null,
    );
  }
}
