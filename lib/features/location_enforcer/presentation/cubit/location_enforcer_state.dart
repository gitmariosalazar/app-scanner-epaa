import 'package:flutter_application/features/location_enforcer/domain/entities/location_status.dart';

abstract class LocationEnforcerState {
  final LocationStatus status;

  const LocationEnforcerState(this.status);
}

class LocationEnforcerInitial extends LocationEnforcerState {
  const LocationEnforcerInitial() : super(LocationStatus.unknown);
}

class LocationEnforcerChecking extends LocationEnforcerState {
  const LocationEnforcerChecking() : super(LocationStatus.unknown);
}

class LocationEnforcerDetermined extends LocationEnforcerState {
  const LocationEnforcerDetermined(super.status);
}
