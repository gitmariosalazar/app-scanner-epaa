import 'package:flutter_application/features/location_enforcer/domain/entities/location_status.dart';

abstract class LocationEnforcerRepository {
  /// Checks current location permissions and service status.
  Future<LocationStatus> checkStatus();

  /// Prompts the user for location permissions.
  Future<LocationStatus> requestPermission();

  /// Opens the device settings for the user to manually enable location services or permissions.
  Future<void> openSettings();
}
