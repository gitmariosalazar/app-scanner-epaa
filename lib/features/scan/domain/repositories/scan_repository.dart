// lib/features/scan/domain/repositories/scan_repository.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';

abstract class ScanRepository {
  Future<Either<Failure, String>> scanQR();
}
