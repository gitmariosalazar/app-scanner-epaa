import 'package:equatable/equatable.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_connection_item.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_work_pack.dart';

abstract class RouteDetailState extends Equatable {
  const RouteDetailState();

  @override
  List<Object?> get props => [];
}

class RouteDetailInitial extends RouteDetailState {
  const RouteDetailInitial();
}

class RouteDetailLoading extends RouteDetailState {
  const RouteDetailLoading();
}

class RouteDetailLoaded extends RouteDetailState {
  final RouteWorkPack pack;
  final List<RouteConnectionItem> filteredAcometidas;
  final String selectedFilter; // 'TODAS', 'PENDIENTES', 'LEIDAS', 'NOVEDADES'
  final String searchQuery;
  final bool isSyncing;
  final String? syncMessage;
  final RouteConnectionItem? activeConnection;
  final bool isOnline;

  const RouteDetailLoaded({
    required this.pack,
    required this.filteredAcometidas,
    this.selectedFilter = 'TODAS',
    this.searchQuery = '',
    this.isSyncing = false,
    this.syncMessage,
    this.activeConnection,
    this.isOnline = true,
  });

  int get pendingSyncCount => pack.pendingOfflineReadingsCount;

  RouteDetailLoaded copyWith({
    RouteWorkPack? pack,
    List<RouteConnectionItem>? filteredAcometidas,
    String? selectedFilter,
    String? searchQuery,
    bool? isSyncing,
    String? syncMessage,
    bool clearSyncMessage = false,
    RouteConnectionItem? activeConnection,
    bool clearActiveConnection = false,
    bool? isOnline,
  }) {
    return RouteDetailLoaded(
      pack: pack ?? this.pack,
      filteredAcometidas: filteredAcometidas ?? this.filteredAcometidas,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isSyncing: isSyncing ?? this.isSyncing,
      syncMessage: clearSyncMessage ? null : (syncMessage ?? this.syncMessage),
      activeConnection: clearActiveConnection
          ? null
          : (activeConnection ?? this.activeConnection),
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  List<Object?> get props => [
    pack,
    filteredAcometidas,
    selectedFilter,
    searchQuery,
    isSyncing,
    syncMessage,
    activeConnection,
    isOnline,
  ];
}

class RouteDetailError extends RouteDetailState {
  final String message;

  const RouteDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
