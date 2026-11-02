// lib/features/reading/domain/usecases/filter_pending_readings_usecase.dart
import 'package:flutter_application/features/reading/domain/entities/pending_reading_connection.dart';

/// Criterios de filtrado en memoria para acometidas pendientes.
class PendingFilterCriteria {
  final String searchTerm;
  final int? sector;

  const PendingFilterCriteria({
    this.searchTerm = '',
    this.sector,
  });

  bool get isEmpty => searchTerm.trim().isEmpty && sector == null;
}

/// Contrato de estrategia de filtrado (Open/Closed Principle).
abstract class IPendingFilterStrategy {
  bool isSatisfiedBy(PendingReadingConnection item, PendingFilterCriteria criteria);
}

/// Estrategia de búsqueda general: clave catastral, cliente, cédula/RUC, medidor o dirección.
class GeneralSearchStrategy implements IPendingFilterStrategy {
  @override
  bool isSatisfiedBy(PendingReadingConnection item, PendingFilterCriteria criteria) {
    if (criteria.searchTerm.trim().isEmpty) return true;
    final term = criteria.searchTerm.toLowerCase().trim();

    final cKey = item.cadastralKey.toLowerCase();
    final cName = item.clientName.toLowerCase();
    final cId = item.cardId.toLowerCase();
    final mNumber = item.meterNumber.toLowerCase();
    final addr = item.address.toLowerCase();

    return cKey.contains(term) ||
        cName.contains(term) ||
        cId.contains(term) ||
        mNumber.contains(term) ||
        addr.contains(term);
  }
}

/// Estrategia de filtrado por sector específico.
class SectorFilterStrategy implements IPendingFilterStrategy {
  @override
  bool isSatisfiedBy(PendingReadingConnection item, PendingFilterCriteria criteria) {
    if (criteria.sector == null) return true;
    return item.sector == criteria.sector;
  }
}

/// Caso de uso para filtrar la lista de acometidas pendientes según múltiples criterios.
class FilterPendingReadingsUseCase {
  final List<IPendingFilterStrategy> strategies;

  FilterPendingReadingsUseCase({List<IPendingFilterStrategy>? strategies})
      : strategies = strategies ??
            [
              GeneralSearchStrategy(),
              SectorFilterStrategy(),
            ];

  List<PendingReadingConnection> execute(
    List<PendingReadingConnection> items,
    PendingFilterCriteria criteria,
  ) {
    if (items.isEmpty) return [];
    if (criteria.isEmpty) return items;

    return items.where((item) {
      return strategies.every((strategy) => strategy.isSatisfiedBy(item, criteria));
    }).toList();
  }
}
