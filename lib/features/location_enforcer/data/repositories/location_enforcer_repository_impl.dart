import 'package:geolocator/geolocator.dart';
import 'package:flutter_application/features/location_enforcer/domain/entities/location_status.dart';
import 'package:flutter_application/features/location_enforcer/domain/repositories/location_enforcer_repository.dart';

class LocationEnforcerRepositoryImpl implements LocationEnforcerRepository {
  @override
  Future<LocationStatus> checkStatus() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationStatus.serviceDisabled;
    }

    final permission = await Geolocator.checkPermission();
    return _mapPermission(permission);
  }

  @override
  Future<LocationStatus> requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationStatus.serviceDisabled;
    }

    final permission = await Geolocator.requestPermission();
    return _mapPermission(permission);
  }

  @override
  Future<void> openSettings() async {
    // If service is disabled, we open location settings
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    } else {
      // If permission is denied forever, we open app settings
      await Geolocator.openAppSettings();
    }
  }

  LocationStatus _mapPermission(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationStatus.granted;
      case LocationPermission.denied:
        return LocationStatus.denied;
      case LocationPermission.deniedForever:
        return LocationStatus.deniedForever;
      case LocationPermission.unableToDetermine:
        return LocationStatus.unknown;
    }
  }
}
