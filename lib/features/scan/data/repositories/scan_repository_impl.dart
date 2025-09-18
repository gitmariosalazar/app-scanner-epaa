// lib/features/scan/data/repositories/scan_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/scan/data/datasources/scan_datasource.dart';
import 'package:flutter_application/features/scan/domain/repositories/scan_repository.dart';

class ScanRepositoryImpl implements ScanRepository {
  final ScanDataSource dataSource;

  ScanRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, String>> scanQR() async {
    try {
      final result = await dataSource.scanQR();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
