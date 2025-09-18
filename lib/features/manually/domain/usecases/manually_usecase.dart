import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/manually/domain/repositories/manually_repository.dart';

class ManuallyUseCase {
  final ManuallyRepository repository;

  ManuallyUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    String connectionId,
  ) async {
    return await repository.fetchReading(connectionId);
  }
}
