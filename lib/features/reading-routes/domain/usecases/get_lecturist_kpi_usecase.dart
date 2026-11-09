import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/lecturist_daily_kpi.dart';
import 'package:flutter_application/features/reading-routes/domain/repositories/reading_routes_repository.dart';

class GetLecturistKpiUseCase {
  final ReadingRoutesRepository repository;

  GetLecturistKpiUseCase(this.repository);

  Future<Either<Failure, LecturistDailyKpi>> call({String? fecha}) {
    return repository.getDailyKpi(fecha: fecha);
  }
}
