import 'package:equatable/equatable.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_connection_item.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_work_pack.dart';
import 'package:latlong2/latlong.dart';

abstract class RouteMapState extends Equatable {
  const RouteMapState();

  @override
  List<Object?> get props => [];
}

class RouteMapInitial extends RouteMapState {
  const RouteMapInitial();
}

class RouteMapLoaded extends RouteMapState {
  final RouteWorkPack pack;
  final List<RouteConnectionItem> mapItems;
  final RouteConnectionItem? selectedItem;
  final LatLng? userLocation;
  final String mapStyle; // 'calles', 'satelite', 'oscuro'
  final String statusFilter; // 'TODAS', 'PENDIENTES', 'LEIDAS', 'NOVEDADES'
  final bool showPolyline;
  final bool isTrackingUser;

  const RouteMapLoaded({
    required this.pack,
    required this.mapItems,
    this.selectedItem,
    this.userLocation,
    this.mapStyle = 'calles',
    this.statusFilter = 'TODAS',
    this.showPolyline = true,
    this.isTrackingUser = false,
  });

  RouteMapLoaded copyWith({
    RouteWorkPack? pack,
    List<RouteConnectionItem>? mapItems,
    RouteConnectionItem? selectedItem,
    bool clearSelectedItem = false,
    LatLng? userLocation,
    String? mapStyle,
    String? statusFilter,
    bool? showPolyline,
    bool? isTrackingUser,
  }) {
    return RouteMapLoaded(
      pack: pack ?? this.pack,
      mapItems: mapItems ?? this.mapItems,
      selectedItem: clearSelectedItem ? null : (selectedItem ?? this.selectedItem),
      userLocation: userLocation ?? this.userLocation,
      mapStyle: mapStyle ?? this.mapStyle,
      statusFilter: statusFilter ?? this.statusFilter,
      showPolyline: showPolyline ?? this.showPolyline,
      isTrackingUser: isTrackingUser ?? this.isTrackingUser,
    );
  }

  @override
  List<Object?> get props => [
    pack,
    mapItems,
    selectedItem,
    userLocation,
    mapStyle,
    statusFilter,
    showPolyline,
    isTrackingUser,
  ];
}
