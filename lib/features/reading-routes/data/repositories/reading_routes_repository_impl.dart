import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/core/network/network_info.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_application/features/reading-routes/data/datasources/reading_routes_local_datasource.dart';
import 'package:flutter_application/features/reading-routes/data/datasources/reading_routes_remote_datasource.dart';
import 'package:flutter_application/features/reading-routes/data/models/lecturist_daily_kpi_model.dart';
import 'package:flutter_application/features/reading-routes/data/models/route_assignment_model.dart';
import 'package:flutter_application/features/reading-routes/data/models/sync_mobile_reading_model.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/lecturist_daily_kpi.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/offline_reading.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_assignment.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_work_pack.dart';
import 'package:flutter_application/features/reading-routes/domain/repositories/reading_routes_repository.dart';

class ReadingRoutesRepositoryImpl implements ReadingRoutesRepository {
  final ReadingRoutesRemoteDataSource remoteDataSource;
  final ReadingRoutesLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final AuthLocalDataSource authLocalDataSource;

  ReadingRoutesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.authLocalDataSource,
  });

  Future<String> _getCurrentUserId() async {
    try {
      final authResponse = await authLocalDataSource.getAuthResponse();
      return authResponse?.user.id ?? 'default_user';
    } catch (_) {
      return 'default_user';
    }
  }

  @override
  Future<Either<Failure, List<RouteAssignment>>> getUserAssignments({
    String? periodoMes,
    String? fecha,
    bool forceRefresh = false,
  }) async {
    final userId = await _getCurrentUserId();
    final cacheKey = '${userId}_${periodoMes ?? 'all'}_${fecha ?? 'all'}';

    final isConnected = await networkInfo.isConnected;

    if (isConnected && forceRefresh) {
      try {
        final remoteItems = await remoteDataSource.getMyAssignedRoutes(
          periodoMes: periodoMes,
          fecha: fecha,
        );

        final enrichedList = <RouteAssignmentModel>[];
        for (final item in remoteItems) {
          final isDownloaded = await localDataSource.isRoutePackDownloaded(
            item.idAsignacion,
          );
          final pendingCount = await localDataSource.getPendingOfflineCount(
            item.idAsignacion,
          );
          enrichedList.add(
            RouteAssignmentModel(
              idAsignacion: item.idAsignacion,
              rutaId: item.rutaId,
              codigoRuta: item.codigoRuta,
              nombreRuta: item.nombreRuta,
              sector: item.sector,
              usuarioId: item.usuarioId,
              nombreLecturista: item.nombreLecturista,
              empleadoId: item.empleadoId,
              periodoMes: item.periodoMes,
              fechaProgramada: item.fechaProgramada,
              fechaInicio: item.fechaInicio,
              fechaCierre: item.fechaCierre,
              estado: item.estado,
              totalPredios: item.totalPredios,
              prediosLeidos: item.prediosLeidos,
              prediosConNovedad: item.prediosConNovedad,
              prediosPendientes: item.prediosPendientes,
              porcentajeAvance: item.porcentajeAvance,
              isDownloadedOffline: isDownloaded,
              pendingOfflineCount: pendingCount,
            ),
          );
        }

        await localDataSource.cacheAssignments(cacheKey, enrichedList);
        return Right(enrichedList);
      } catch (e) {
        // Fallback to local
      }
    }

    // Try local cache first if offline or on error
    final cached = await localDataSource.getCachedAssignments(cacheKey);
    if (cached != null && cached.isNotEmpty && !forceRefresh) {
      final updatedCached = <RouteAssignment>[];
      for (final a in cached) {
        final isDownloaded = await localDataSource.isRoutePackDownloaded(
          a.idAsignacion,
        );
        final pendingCount = await localDataSource.getPendingOfflineCount(
          a.idAsignacion,
        );
        updatedCached.add(
          a.copyWith(
            isDownloadedOffline: isDownloaded,
            pendingOfflineCount: pendingCount,
          ),
        );
      }
      return Right(updatedCached);
    }

    // If online and nothing in cache or refresh needed
    if (isConnected) {
      try {
        final remoteItems = await remoteDataSource.getMyAssignedRoutes(
          periodoMes: periodoMes,
          fecha: fecha,
        );

        final enrichedList = <RouteAssignmentModel>[];
        for (final item in remoteItems) {
          final isDownloaded = await localDataSource.isRoutePackDownloaded(
            item.idAsignacion,
          );
          final pendingCount = await localDataSource.getPendingOfflineCount(
            item.idAsignacion,
          );
          enrichedList.add(
            RouteAssignmentModel(
              idAsignacion: item.idAsignacion,
              rutaId: item.rutaId,
              codigoRuta: item.codigoRuta,
              nombreRuta: item.nombreRuta,
              sector: item.sector,
              usuarioId: item.usuarioId,
              nombreLecturista: item.nombreLecturista,
              empleadoId: item.empleadoId,
              periodoMes: item.periodoMes,
              fechaProgramada: item.fechaProgramada,
              fechaInicio: item.fechaInicio,
              fechaCierre: item.fechaCierre,
              estado: item.estado,
              totalPredios: item.totalPredios,
              prediosLeidos: item.prediosLeidos,
              prediosConNovedad: item.prediosConNovedad,
              prediosPendientes: item.prediosPendientes,
              porcentajeAvance: item.porcentajeAvance,
              isDownloadedOffline: isDownloaded,
              pendingOfflineCount: pendingCount,
            ),
          );
        }

        await localDataSource.cacheAssignments(cacheKey, enrichedList);
        return Right(enrichedList);
      } catch (e) {
        return Left(ServerFailure(message: e.toString()));
      }
    }

    if (cached != null) {
      return Right(cached);
    }

    return Left(
      NetworkFailure(
        message:
            'Sin conexión a internet y no hay rutas guardadas en memoria local.',
      ),
    );
  }

  @override
  Future<Either<Failure, RouteWorkPack>> getRouteWorkPack(
    int assignmentId, {
    bool forceDownload = false,
  }) async {
    // Si no se fuerza la descarga, revisamos si ya está en caché local
    if (!forceDownload) {
      final cached = await localDataSource.getCachedRoutePack(assignmentId);
      if (cached != null) {
        return Right(cached);
      }
    }

    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      try {
        final remotePack = await remoteDataSource.getMobileWorkPack(
          assignmentId,
        );
        await localDataSource.cacheRoutePack(assignmentId, remotePack);

        // Recuperar para integrar cualquier lectura en cola local previa
        final mergedPack = await localDataSource.getCachedRoutePack(
          assignmentId,
        );
        return Right(mergedPack ?? remotePack);
      } catch (e) {
        // En caso de fallo remoto, ver si tenemos copia local
        final cached = await localDataSource.getCachedRoutePack(assignmentId);
        if (cached != null) return Right(cached);
        return Left(ServerFailure(message: e.toString()));
      }
    }

    // Modo offline
    final cached = await localDataSource.getCachedRoutePack(assignmentId);
    if (cached != null) {
      return Right(cached);
    }

    return Left(
      NetworkFailure(
        message:
            'Ruta no descargada. Debes conectarte a internet al menos una vez para descargar el paquete de trabajo.',
      ),
    );
  }

  @override
  Future<Either<Failure, RouteWorkPack>> saveOfflineReading(
    OfflineReading reading,
  ) async {
    try {
      await localDataSource.enqueueOfflineReading(reading);
      final updatedPack = await localDataSource.getCachedRoutePack(
        reading.asignacionId,
      );
      if (updatedPack != null) {
        return Right(updatedPack);
      }
      return Left(
        CacheFailure(
          message: 'No se encontró el paquete local para actualizar',
        ),
      );
    } catch (e) {
      return Left(CacheFailure(message: 'Error al guardar lectura local: $e'));
    }
  }

  @override
  Future<Either<Failure, SyncBatchResult>> syncPendingBatch(
    int assignmentId,
  ) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return Left(
        NetworkFailure(
          message:
              'No hay conexión a internet para sincronizar las lecturas pendientes.',
        ),
      );
    }

    try {
      final pendingReadings = await localDataSource.getOfflineReadings(
        assignmentId,
      );
      if (pendingReadings.isEmpty) {
        return const Right(
          SyncBatchResult(
            success: true,
            totalSincronizados: 0,
            totalExitosos: 0,
            totalFallidos: 0,
          ),
        );
      }

      final request = SyncMobileReadingsBatchRequestModel(
        asignacionId: assignmentId,
        lecturas: pendingReadings
            .map((r) => SyncMobileReadingItemModel.fromEntity(r))
            .toList(),
      );

      final result = await remoteDataSource.syncReadingsBatch(request);

      if (result.success || result.totalExitosos > 0) {
        final syncedIds = pendingReadings
            .take(result.totalExitosos)
            .map((r) => r.idDetalleAvance)
            .toList();

        await localDataSource.removeOfflineReadings(assignmentId, syncedIds);

        // Refrescar el paquete desde el backend para garantizar consistencia absoluta
        try {
          final refreshedPack = await remoteDataSource.getMobileWorkPack(
            assignmentId,
          );
          await localDataSource.cacheRoutePack(assignmentId, refreshedPack);
        } catch (_) {}
      }

      return Right(result);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Fallo al sincronizar lote de lecturas: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, LecturistDailyKpi>> getDailyKpi({
    String? fecha,
  }) async {
    final today = fecha ?? DateTime.now().toIso8601String().split('T')[0];
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final kpi = await remoteDataSource.getMyDailyKpi(fecha: today);
        await localDataSource.cacheDailyKpi(today, kpi);
        return Right(kpi);
      } catch (_) {}
    }

    final cached = await localDataSource.getCachedDailyKpi(today);
    if (cached != null) {
      return Right(cached);
    }

    return Right(LecturistDailyKpiModel.empty('', today));
  }

  @override
  Future<int> getPendingSyncCount(int assignmentId) {
    return localDataSource.getPendingOfflineCount(assignmentId);
  }

  @override
  Future<bool> isRouteDownloaded(int assignmentId) {
    return localDataSource.isRoutePackDownloaded(assignmentId);
  }
}
