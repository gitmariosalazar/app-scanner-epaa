import 'dart:async';
import 'package:flutter_application/features/reading-routes/domain/entities/route_connection_item.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_work_pack.dart';
import 'package:flutter_application/features/reading-routes/presentation/cubit/route_map_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class RouteMapCubit extends Cubit<RouteMapState> {
  StreamSubscription<Position>? _positionSubscription;

  RouteMapCubit() : super(const RouteMapInitial());

  void init(RouteWorkPack pack, {RouteConnectionItem? initialSelected}) {
    final validItems = pack.acometidas.where((a) => a.hasCoordinates).toList();
    emit(
      RouteMapLoaded(
        pack: pack,
        mapItems: validItems,
        selectedItem: initialSelected ?? pack.nextPendingInSequence,
        statusFilter: 'TODAS',
      ),
    );
    _startLocationUpdates();
  }

  void updatePack(RouteWorkPack updatedPack) {
    if (state is! RouteMapLoaded) return;
    final s = state as RouteMapLoaded;

    final List<RouteConnectionItem> validItems =
        updatedPack.acometidas.where((a) => a.hasCoordinates).toList();
    final filtered = _applyFilter(validItems, s.statusFilter);

    // Si el elemento seleccionado se actualizó, mantener referencia actualizada
    RouteConnectionItem? updatedSelected = s.selectedItem;
    if (s.selectedItem != null) {
      for (final a in updatedPack.acometidas) {
        if (a.idDetalle == s.selectedItem!.idDetalle) {
          updatedSelected = a;
          break;
        }
      }
    }

    emit(
      s.copyWith(
        pack: updatedPack,
        mapItems: filtered,
        selectedItem: updatedSelected,
      ),
    );
  }

  void selectMarker(RouteConnectionItem? item) {
    if (state is! RouteMapLoaded) return;
    final s = state as RouteMapLoaded;
    emit(s.copyWith(selectedItem: item, clearSelectedItem: item == null));
  }

  void setFilter(String filter) {
    if (state is! RouteMapLoaded) return;
    final s = state as RouteMapLoaded;

    final allValid = s.pack.acometidas.where((a) => a.hasCoordinates).toList();
    final filtered = _applyFilter(allValid, filter);

    emit(s.copyWith(statusFilter: filter, mapItems: filtered));
  }

  void setMapStyle(String style) {
    if (state is! RouteMapLoaded) return;
    final s = state as RouteMapLoaded;
    emit(s.copyWith(mapStyle: style));
  }

  void togglePolyline() {
    if (state is! RouteMapLoaded) return;
    final s = state as RouteMapLoaded;
    emit(s.copyWith(showPolyline: !s.showPolyline));
  }

  void updateUserLocation(LatLng location) {
    if (state is! RouteMapLoaded) return;
    final s = state as RouteMapLoaded;
    emit(s.copyWith(userLocation: location));
  }

  Future<void> _startLocationUpdates() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      updateUserLocation(LatLng(pos.latitude, pos.longitude));
    } catch (_) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) {
          updateUserLocation(LatLng(last.latitude, last.longitude));
        }
      } catch (_) {}
    }

    try {
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen((pos) {
        updateUserLocation(LatLng(pos.latitude, pos.longitude));
      });
    } catch (_) {}
  }

  List<RouteConnectionItem> _applyFilter(
    List<RouteConnectionItem> items,
    String filter,
  ) {
    switch (filter) {
      case 'PENDIENTES':
        return items.where((a) => a.estado == 'PENDIENTE' || a.estado == 'SALTADA').toList();
      case 'LEIDAS':
        return items.where((a) => a.estado == 'LEIDA').toList();
      case 'NOVEDADES':
        return items.where((a) => a.estado == 'NOVEDAD').toList();
      default:
        return items;
    }
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}
