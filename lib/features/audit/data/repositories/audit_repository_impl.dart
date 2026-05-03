// lib/features/audit/data/repositories/audit_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/exception.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/audit/data/datasources/audit_remote_datasource.dart';
import 'package:flutter_application/features/audit/domain/entities/audit_sector.dart';
import 'package:flutter_application/features/audit/domain/entities/close_audit_sector_result.dart';
import 'package:flutter_application/features/audit/domain/repositories/audit_repository.dart';

class AuditRepositoryImpl implements AuditRepository {
  final AuditRemoteDataSource remoteDataSource;

  AuditRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AuditSector>>> getAuditByMonth(
    String month,
  ) async {
    try {
      final dtos = await remoteDataSource.getAuditByMonth(month);

      // Map DTOs → domain entities (DRY: single mapping location)
      final entities = dtos.map((dto) {
        return AuditSector(
          auditId: dto.auditId,
          readingMonth: _parseDate(dto.readingMonth),
          sectorId: dto.sectorId,
          expectedTotal: dto.expectedTotal,
          completedTotal: dto.completedTotal,
          pendingTotal: dto.pendingTotal,
          progressPercentage: dto.progressPercentage,
          isComplete: dto.isComplete,
          closureDate:
              dto.closureDate != null ? _parseDate(dto.closureDate!) : null,
          supervisorId: dto.supervisorId,
          observations: dto.observations,
          createdAt: _parseDate(dto.createdAt),
          updatedAt: _parseDate(dto.updatedAt),
        );
      }).toList();

      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Error al cargar auditoría: $e'));
    }
  }

  @override
  Future<Either<Failure, CloseAuditSectorResult>> closeSector({
    required int sectorId,
    required String month,
    required String supervisorId,
    String? observations,
  }) async {
    try {
      final dto = await remoteDataSource.closeSector(
        sectorId: sectorId,
        month: month,
        supervisorId: supervisorId,
        observations: observations,
      );

      return Right(
        CloseAuditSectorResult(
          auditId: dto.auditId,
          sectorId: dto.sectorId,
          readingMonth: dto.readingMonth,
          isComplete: dto.isComplete,
          closureDate:
              dto.closureDate != null ? _parseDate(dto.closureDate!) : null,
          supervisorId: dto.supervisorId,
          observations: dto.observations,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error al cerrar sector de auditoría: $e'),
      );
    }
  }

  DateTime _parseDate(String raw) {
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return DateTime.now();
    }
  }
}
