import 'package:dartz/dartz.dart';
import 'package:flutter_application/core/error/failure.dart';
import 'package:flutter_application/core/usecases/usecase.dart';
import 'package:flutter_application/features/incidents/domain/entities/incident-category.model.dart';
import 'package:flutter_application/features/incidents/domain/repositories/incident_repository.dart';

class FindIncidentCategoriesUseCase implements UseCase<List<IncidentCategoryModel>, NoParams> {
  final IncidentRepository repository;

  FindIncidentCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<IncidentCategoryModel>>> call(NoParams params) {
    return repository.findIncidentCategories();
  }
}
