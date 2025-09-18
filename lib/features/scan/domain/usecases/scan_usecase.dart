// lib/features/scan/domain/usecases/scan_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/core/usecases/usecase.dart';
import 'package:flutter_application/features/scan/domain/repositories/scan_repository.dart';

class ScanUseCase implements UseCase<String, NoParams> {
  final ScanRepository repository;

  ScanUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) {
    return repository.scanQR();
  }
}
