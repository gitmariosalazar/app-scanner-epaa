// lib/features/dashboard/presentation/cubit/dashboard_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/core/usecases/usecase.dart';
import 'package:flutter_application/features/dashboard/domain/usecases/get_dashboard_stats.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetDashboardStats _getDashboardStats;

  DashboardCubit(this._getDashboardStats) : super(DashboardInitial());

  Future<void> loadStats() async {
    if (isClosed) return;
    emit(DashboardLoading());
    final result = await _getDashboardStats(NoParams());
    if (isClosed) return;
    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (stats) => emit(DashboardLoaded(stats)),
    );
  }

  Future<void> refresh() => loadStats();
}
