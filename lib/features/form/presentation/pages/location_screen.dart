import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'dart:async';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  bool _isTracking = false;
  bool _isLoading = true;
  // Flag: set to true before dispose() to block all async map operations
  bool _disposed = false;

  Position? _currentPosition;
  String _currentAddress = 'Cargando ubicación...';
  StreamSubscription<Position>? _positionStreamSubscription;
  GeoPoint? _geoPoint;
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController(
      initMapWithUserPosition: const UserTrackingOption(
        enableTracking: true,
        unFollowUser: false,
      ),
    );
    _checkPermissions();
  }

  // ── Guard: prevents any map call after dispose ─────────────────────────────
  bool get _canUseMap => !_disposed && mounted;

  @override
  void dispose() {
    _disposed = true;
    // 1. Cancel stream first — stops any new position events
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    // 2. Dispose map controller safely — plugin has a known timer bug in 1.4.x
    try {
      _mapController.dispose();
    } catch (e) {
      if (kDebugMode) debugPrint('OSM MapController dispose error (known bug): $e');
    }
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Los servicios de ubicación no están habilitados.');
        await _setFallbackLocation();
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Permiso de ubicación denegado.');
          await _setFallbackLocation();
          if (mounted) setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showError(
          'Permiso de ubicación denegado permanentemente. Abre configuración.',
        );
        await Geolocator.openAppSettings();
        await _setFallbackLocation();
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      await _getInitialPosition();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error checking permissions: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      _showError('Error al verificar permisos: $e');
      await _setFallbackLocation();
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _setFallbackLocation() async {
    if (!_canUseMap) return;
    try {
      _geoPoint = GeoPoint(latitude: -0.3385, longitude: -78.1757); // Antonio Ante
      await _mapController.goToLocation(_geoPoint!);
      if (mounted) {
        setState(
          () => _currentAddress = 'Otavalo, Imbabura, Ecuador (fallback)',
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error setting fallback location: $e');
    }
  }

  Future<void> _getInitialPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!_canUseMap) return;
      setState(() {
        _currentPosition = position;
        _geoPoint = GeoPoint(
          latitude: position.latitude,
          longitude: position.longitude,
        );
        _isLoading = false;
      });
      if (!_canUseMap) return;
      await _mapController.goToLocation(_geoPoint!);
      await _updateAddress(position);
      if (!_canUseMap) return;
      await _updateMarker(position);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error getting initial position: $e');
        debugPrintStack(stackTrace: stackTrace);
      }
      _showError('Error al obtener ubicación inicial: $e');
      await _setFallbackLocation();
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateAddress(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty && mounted) {
        final place = placemarks.first;
        final fullAddress =
            '${place.street ?? ''}, ${place.subLocality ?? ''}, '
            '${place.locality ?? ''}, ${place.administrativeArea ?? ''}, '
            '${place.country ?? ''}';
        setState(
          () => _currentAddress = fullAddress.trim().isEmpty
              ? 'Dirección no disponible'
              : fullAddress.trim(),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting address: $e');
    }
  }

  Future<void> _updateMarker(Position position) async {
    if (!_canUseMap) return;
    try {
      if (_geoPoint != null) {
        await _mapController.removeMarkers([_geoPoint!]);
      }
      if (!_canUseMap) return;
      _geoPoint = GeoPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      await _mapController.addMarker(
        _geoPoint!,
        markerIcon: const MarkerIcon(
          icon: Icon(Icons.location_pin, color: Colors.red, size: 48),
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error updating marker: $e');
    }
  }

  void _startTracking() {
    if (!_canUseMap) return;
    setState(() => _isTracking = true);

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    ).listen(
      (Position position) async {
        if (!_canUseMap) return;
        setState(() {
          _currentPosition = position;
          _geoPoint = GeoPoint(
            latitude: position.latitude,
            longitude: position.longitude,
          );
        });
        if (!_canUseMap) return;
        await _mapController.goToLocation(_geoPoint!);
        await _updateAddress(position);
        if (!_canUseMap) return;
        await _updateMarker(position);
        if (kDebugMode) {
          debugPrint(
            '📍 ${position.latitude}, ${position.longitude} => $_currentAddress',
          );
        }
      },
      onError: (e) {
        if (kDebugMode) debugPrint('Error in position stream: $e');
        if (mounted) {
          _showError('Error en el seguimiento de ubicación: $e');
          setState(() => _isTracking = false);
        }
      },
    );
  }

  void _stopTracking() {
    if (!mounted) return;
    setState(() => _isTracking = false);
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación en Tiempo Real'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: OSMFlutter(
                  controller: _mapController,
                  osmOption: OSMOption(
                    zoomOption: const ZoomOption(
                      initZoom: 17,
                      minZoomLevel: 3,
                      maxZoomLevel: 19,
                      stepZoom: 1.0,
                    ),
                    userLocationMarker: UserLocationMaker(
                      personMarker: const MarkerIcon(
                        icon: Icon(
                          Icons.person_pin_circle,
                          color: Colors.red,
                          size: 48,
                        ),
                      ),
                      directionArrowMarker: const MarkerIcon(
                        icon: Icon(
                          Icons.navigation,
                          color: Colors.blue,
                          size: 36,
                        ),
                      ),
                    ),
                    roadConfiguration: const RoadOption(roadColor: Colors.blue),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _currentAddress,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_currentPosition != null)
                      Text(
                        'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)} | '
                        'Lon: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: Icon(_isTracking ? Icons.stop : Icons.location_on),
                      label: Text(
                        _isTracking
                            ? 'Detener Seguimiento'
                            : 'Iniciar Seguimiento',
                      ),
                      onPressed: _isTracking ? _stopTracking : _startTracking,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
