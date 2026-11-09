import 'package:equatable/equatable.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/lecturist_daily_kpi.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_assignment.dart';

abstract class UserRoutesState extends Equatable {
  const UserRoutesState();

  @override
  List<Object?> get props => [];
}

class UserRoutesInitial extends UserRoutesState {
  const UserRoutesInitial();
}

class UserRoutesLoading extends UserRoutesState {
  const UserRoutesLoading();
}

class UserRoutesLoaded extends UserRoutesState {
  final List<RouteAssignment> allRoutes;
  final List<RouteAssignment> filteredRoutes;
  final LecturistDailyKpi kpi;
  final String selectedFilter; // 'TODAS', 'PENDIENTES', 'COMPLETADAS'
  final String searchQuery;
  final bool isOnline;
  final int? downloadingAssignmentId;
  final String? successMessage;

  const UserRoutesLoaded({
    required this.allRoutes,
    required this.filteredRoutes,
    required this.kpi,
    this.selectedFilter = 'TODAS',
    this.searchQuery = '',
    this.isOnline = true,
    this.downloadingAssignmentId,
    this.successMessage,
  });

  UserRoutesLoaded copyWith({
    List<RouteAssignment>? allRoutes,
    List<RouteAssignment>? filteredRoutes,
    LecturistDailyKpi? kpi,
    String? selectedFilter,
    String? searchQuery,
    bool? isOnline,
    int? downloadingAssignmentId,
    bool clearDownloading = false,
    String? successMessage,
    bool clearSuccess = false,
  }) {
    return UserRoutesLoaded(
      allRoutes: allRoutes ?? this.allRoutes,
      filteredRoutes: filteredRoutes ?? this.filteredRoutes,
      kpi: kpi ?? this.kpi,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isOnline: isOnline ?? this.isOnline,
      downloadingAssignmentId: clearDownloading
          ? null
          : (downloadingAssignmentId ?? this.downloadingAssignmentId),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    allRoutes,
    filteredRoutes,
    kpi,
    selectedFilter,
    searchQuery,
    isOnline,
    downloadingAssignmentId,
    successMessage,
  ];
}

class UserRoutesError extends UserRoutesState {
  final String message;

  const UserRoutesError(this.message);

  @override
  List<Object?> get props => [message];
}
