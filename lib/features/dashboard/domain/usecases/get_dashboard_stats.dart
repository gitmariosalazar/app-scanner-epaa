// lib/features/dashboard/domain/usecases/get_dashboard_stats.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/core/usecases/usecase.dart';
import 'package:flutter_application/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:flutter_application/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardStats extends UseCase<DashboardStats, NoParams> {
  final DashboardRepository repository;

  GetDashboardStats(this.repository);

  @override
  Future<Either<Failure, DashboardStats>> call(NoParams params) {
    return repository.getDashboardStats();
  }
}
