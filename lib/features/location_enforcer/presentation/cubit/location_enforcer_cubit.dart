import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/location_enforcer/domain/entities/location_status.dart';
import 'package:flutter_application/features/location_enforcer/domain/usecases/check_location_status_usecase.dart';
import 'package:flutter_application/features/location_enforcer/domain/usecases/request_location_permission_usecase.dart';
import 'package:flutter_application/features/location_enforcer/domain/usecases/open_location_settings_usecase.dart';
import 'package:flutter_application/features/location_enforcer/presentation/cubit/location_enforcer_state.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class LocationEnforcerCubit extends Cubit<LocationEnforcerState> with WidgetsBindingObserver {
  final CheckLocationStatusUseCase _checkLocationStatusUseCase;
  final RequestLocationPermissionUseCase _requestLocationPermissionUseCase;
  final OpenLocationSettingsUseCase _openLocationSettingsUseCase;

  StreamSubscription<ServiceStatus>? _serviceStatusSubscription;
  Timer? _pollingTimer;

  LocationEnforcerCubit({
    required CheckLocationStatusUseCase checkLocationStatusUseCase,
    required RequestLocationPermissionUseCase requestLocationPermissionUseCase,
    required OpenLocationSettingsUseCase openLocationSettingsUseCase,
  })  : _checkLocationStatusUseCase = checkLocationStatusUseCase,
        _requestLocationPermissionUseCase = requestLocationPermissionUseCase,
        _openLocationSettingsUseCase = openLocationSettingsUseCase,
        super(const LocationEnforcerInitial()) {
    _initServiceStatusListener();
    // Revisa el estado inmediatamente al iniciar
    checkStatus();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkStatusSilently();
    }
  }

  void _initServiceStatusListener() {
    _serviceStatusSubscription = Geolocator.getServiceStatusStream().listen(
      (ServiceStatus status) {
        checkStatusSilently();
      },
    );
    
    // Polling de respaldo cada 3 segundos (silencioso)
    // Esto es necesario para dispositivos (como Xiaomi/MIUI) donde el stream
    // no se dispara al bajar la barra de notificaciones.
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      checkStatusSilently();
    });
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    _serviceStatusSubscription?.cancel();
    return super.close();
  }

  Future<void> checkStatusSilently() async {
    final status = await _checkLocationStatusUseCase();
    if (state.status != status) {
      emit(LocationEnforcerDetermined(status));
    }
  }

  Future<void> checkStatus() async {
    emit(const LocationEnforcerChecking());
    final status = await _checkLocationStatusUseCase();
    emit(LocationEnforcerDetermined(status));
  }

  Future<void> requestPermission() async {
    emit(const LocationEnforcerChecking());
    final status = await _requestLocationPermissionUseCase();
    emit(LocationEnforcerDetermined(status));
  }

  Future<void> openSettings() async {
    await _openLocationSettingsUseCase();
    // Re-check status after returning from settings might be handled 
    // by the UI layer (WidgetsBindingObserver) or we can wait a bit, 
    // but the observer is safer.
  }
}
