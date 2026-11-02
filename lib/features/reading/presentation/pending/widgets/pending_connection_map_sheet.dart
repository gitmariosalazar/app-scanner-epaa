// lib/features/reading/presentation/pending/widgets/pending_connection_map_sheet.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:flutter_application/features/reading/domain/entities/pending_connection_location.dart';
import 'package:flutter_application/features/reading/domain/entities/pending_reading_connection.dart';
import 'package:flutter_application/features/reading/domain/services/pending_location_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

enum MapTargetDestination { connection, lastReading }

class PendingConnectionMapSheet extends StatefulWidget {
  final PendingReadingConnection connection;
  final VoidCallback onTakeReading;

  const PendingConnectionMapSheet({
    super.key,
    required this.connection,
    required this.onTakeReading,
  });

  /// Abre la vista de mapa como un BottomSheet interactivo sin salir de la app
  /// y sin perder la tarjeta de la acometida.
  static Future<void> show(
    BuildContext context, {
    required PendingReadingConnection connection,
    required VoidCallback onTakeReading,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PendingConnectionMapSheet(
        connection: connection,
        onTakeReading: onTakeReading,
      ),
    );
  }

  @override
  State<PendingConnectionMapSheet> createState() =>
      _PendingConnectionMapSheetState();
}

class _PendingConnectionMapSheetState extends State<PendingConnectionMapSheet>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  final PendingLocationService _locationService = const PendingLocationService();

  MapTargetDestination _selectedDestination = MapTargetDestination.connection;
  Position? _currentPosition;
  bool _isLoadingGps = true;
  String _mapStyle = 'calles'; // 'calles', 'satelite', 'oscuro'
  StreamSubscription<Position>? _positionStream;

  PendingConnectionLocation? get _connectionLoc =>
      widget.connection.locationConnection;

  PendingConnectionLocation? get _lastReadingLoc =>
      widget.connection.lastReading?.locationReading;

  PendingConnectionLocation? get _activeTargetLoc {
    if (_selectedDestination == MapTargetDestination.lastReading &&
        _locationService.isValid(_lastReadingLoc)) {
      return _lastReadingLoc;
    }
    if (_locationService.isValid(_connectionLoc)) {
      return _connectionLoc;
    }
    return _lastReadingLoc;
  }

  @override
  void initState() {
    super.initState();
    if (!_locationService.isValid(_connectionLoc) &&
        _locationService.isValid(_lastReadingLoc)) {
      _selectedDestination = MapTargetDestination.lastReading;
    }
    _initGps();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initGps() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 6),
        ),
      );
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingGps = false;
        });
      }
    } catch (_) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (mounted) {
          setState(() {
            _currentPosition = last;
            _isLoadingGps = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() => _isLoadingGps = false);
        }
      }
    }

    // Escuchar actualizaciones de ubicación mientras la hoja esté abierta
    try {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen((pos) {
        if (mounted) {
          setState(() => _currentPosition = pos);
        }
      });
    } catch (_) {}
  }

  String _getTileUrl(bool isDark) {
    final mapConfig = Environment.mapConfig;

    switch (mapConfig.provider) {
      case 'mapbox':
        String styleId = isDark ? 'dark-v11' : 'streets-v12';
        if (_mapStyle == 'satelite') styleId = 'satellite-streets-v12';
        if (_mapStyle == 'oscuro') styleId = 'dark-v11';
        if (_mapStyle == 'calles') styleId = 'streets-v12';
        return 'https://api.mapbox.com/styles/v1/mapbox/$styleId/tiles/{z}/{x}/{y}?access_token=${mapConfig.mapboxApiKey}';
      case 'stadia':
        if (_mapStyle == 'satelite') {
          return 'https://tiles.stadiamaps.com/tiles/alidade_satellite/{z}/{x}/{y}.jpg?api_key=${mapConfig.stadiaApiKey}';
        }
        return isDark
            ? 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}.png?api_key=${mapConfig.stadiaApiKey}'
            : 'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}.png?api_key=${mapConfig.stadiaApiKey}';
      default:
        if (_mapStyle == 'satelite') {
          return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
        }
        return isDark
            ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
            : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  void _centerOnUser() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        16.0,
      );
    }
  }

  void _centerOnTarget() {
    final target = _activeTargetLoc;
    if (target != null) {
      _mapController.move(LatLng(target.lat, target.lng), 16.5);
    }
  }

  void _fitBothPoints() {
    final target = _activeTargetLoc;
    if (target == null) return;

    if (_currentPosition != null) {
      final bounds = LatLngBounds(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        LatLng(target.lat, target.lng),
      );
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 70),
        ),
      );
    } else {
      _centerOnTarget();
    }
  }

  Future<void> _openExternalNavigation() async {
    final target = _activeTargetLoc;
    if (target == null) return;

    final lat = target.lat;
    final lng = target.lng;
    final label = Uri.encodeComponent(
      'Acometida ${widget.connection.cadastralKey}',
    );

    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=$label',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final target = _activeTargetLoc;
    final initialCenter = target != null
        ? LatLng(target.lat, target.lng)
        : const LatLng(0.3344, -78.2144);

    // Calcular distancia en vivo desde GPS actual al destino
    double? distanceToTarget;
    if (_currentPosition != null && target != null) {
      distanceToTarget = _locationService.calculateDistance(
        PendingConnectionLocation(
          lat: _currentPosition!.latitude,
          lng: _currentPosition!.longitude,
        ),
        target,
      );
    }

    // Calcular distancia entre Acometida y Última Lectura (si existen ambas)
    double? distanceBetweenAcometidaAndLast;
    if (_locationService.isValid(_connectionLoc) &&
        _locationService.isValid(_lastReadingLoc)) {
      distanceBetweenAcometidaAndLast = _locationService.calculateDistance(
        _connectionLoc,
        _lastReadingLoc,
      );
    }

    // Puntos de la ruta
    final routePoints = <LatLng>[];
    if (_currentPosition != null && target != null) {
      routePoints.add(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      );
      routePoints.add(LatLng(target.lat, target.lng));
    }

    // Línea de referencia entre Acometida y Última Lectura
    final referencePoints = <LatLng>[];
    if (_locationService.isValid(_connectionLoc) &&
        _locationService.isValid(_lastReadingLoc)) {
      referencePoints.add(LatLng(_connectionLoc!.lat, _connectionLoc!.lng));
      referencePoints.add(LatLng(_lastReadingLoc!.lat, _lastReadingLoc!.lng));
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Stack(
          children: [
            // ── Mapa Base (FlutterMap) ──
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: 15.5,
                maxZoom: 18.5,
                minZoom: 4.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: _getTileUrl(isDark),
                  userAgentPackageName: 'com.epaa.scanner',
                  subdomains: const ['a', 'b', 'c', 'd'],
                ),

                // Línea de referencia entre Acometida y Última Lectura
                if (referencePoints.length == 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: referencePoints,
                        color: Colors.amber.shade700.withValues(alpha: 0.6),
                        strokeWidth: 2.5,
                        strokeCap: StrokeCap.round,
                        pattern: StrokePattern.dashed(segments: const [6, 4]),
                      ),
                    ],
                  ),

                // Línea de ruta directa desde el GPS del lector
                if (routePoints.length == 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        color: cs.primary.withValues(alpha: 0.85),
                        strokeWidth: 4.0,
                        strokeCap: StrokeCap.round,
                      ),
                    ],
                  ),

                // Marcadores en el mapa
                MarkerLayer(
                  markers: [
                    // Marcador de Acometida
                    if (_locationService.isValid(_connectionLoc))
                      Marker(
                        point: LatLng(_connectionLoc!.lat, _connectionLoc!.lng),
                        width: 70,
                        height: 70,
                        child: _LocationMarker(
                          label: 'Acometida',
                          icon: Icons.water_drop_rounded,
                          color: Colors.blue.shade700,
                          isSelected: _selectedDestination ==
                              MapTargetDestination.connection,
                          onTap: () {
                            setState(() {
                              _selectedDestination =
                                  MapTargetDestination.connection;
                            });
                            _centerOnTarget();
                          },
                        ),
                      ),

                    // Marcador de Última Lectura
                    if (_locationService.isValid(_lastReadingLoc))
                      Marker(
                        point: LatLng(
                          _lastReadingLoc!.lat,
                          _lastReadingLoc!.lng,
                        ),
                        width: 70,
                        height: 70,
                        child: _LocationMarker(
                          label: 'Últ. Lectura',
                          icon: Icons.history_rounded,
                          color: Colors.deepOrange.shade600,
                          isSelected: _selectedDestination ==
                              MapTargetDestination.lastReading,
                          onTap: () {
                            setState(() {
                              _selectedDestination =
                                  MapTargetDestination.lastReading;
                            });
                            _centerOnTarget();
                          },
                        ),
                      ),

                    // Marcador del Usuario / Lector
                    if (_currentPosition != null)
                      Marker(
                        point: LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        ),
                        width: 50,
                        height: 50,
                        child: const _UserLiveLocationMarker(),
                      ),
                  ],
                ),
              ],
            ),

            // ── Barra Superior Flotante: Título, Selector de Destino y Cerrar ──
            Positioned(
              top: 12,
              left: 14,
              right: 14,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surface.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.navigation_rounded,
                            color: cs.onPrimaryContainer,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Ruta a Acometida ${widget.connection.cadastralKey}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.connection.clientName,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: cs.onSurfaceVariant,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (_isLoadingGps) ...[
                                    const SizedBox(width: 6),
                                    const SizedBox(
                                      width: 10,
                                      height: 10,
                                      child: CircularProgressIndicator(strokeWidth: 1.5),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'GPS...',
                                      style: TextStyle(fontSize: 10, color: cs.primary),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Botón cerrar
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Cerrar mapa',
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),

                  // Selector de destino (si existen ambas coordenadas)
                  if (_locationService.isValid(_connectionLoc) &&
                      _locationService.isValid(_lastReadingLoc)) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: cs.surface.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _DestinationTabButton(
                              label: 'Acometida',
                              icon: Icons.water_drop_rounded,
                              color: Colors.blue.shade700,
                              isSelected: _selectedDestination ==
                                  MapTargetDestination.connection,
                              onTap: () {
                                setState(() {
                                  _selectedDestination =
                                      MapTargetDestination.connection;
                                });
                                _centerOnTarget();
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _DestinationTabButton(
                              label: 'Última Lectura',
                              icon: Icons.history_rounded,
                              color: Colors.deepOrange.shade600,
                              isSelected: _selectedDestination ==
                                  MapTargetDestination.lastReading,
                              onTap: () {
                                setState(() {
                                  _selectedDestination =
                                      MapTargetDestination.lastReading;
                                });
                                _centerOnTarget();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Controles Flotantes a la Derecha (Capas, Centrar, Zoom) ──
            Positioned(
              right: 14,
              bottom: 235,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FloatingMapButton(
                    icon: Icons.layers_rounded,
                    tooltip: 'Cambiar capa',
                    onTap: _toggleMapStyle,
                  ),
                  const SizedBox(height: 8),
                  _FloatingMapButton(
                    icon: Icons.alt_route_rounded,
                    tooltip: 'Ajustar ruta completa',
                    onTap: _fitBothPoints,
                  ),
                  const SizedBox(height: 8),
                  _FloatingMapButton(
                    icon: Icons.my_location_rounded,
                    tooltip: 'Mi ubicación',
                    color: _currentPosition != null ? cs.primary : null,
                    onTap: _centerOnUser,
                  ),
                  const SizedBox(height: 8),
                  _FloatingMapButton(
                    icon: Icons.place_rounded,
                    tooltip: 'Centrar en acometida',
                    color: Colors.red.shade600,
                    onTap: _centerOnTarget,
                  ),
                  const SizedBox(height: 8),
                  _FloatingMapButton(
                    icon: Icons.add,
                    tooltip: 'Acercar',
                    onTap: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  _FloatingMapButton(
                    icon: Icons.remove,
                    tooltip: 'Alejar',
                    onTap: () {
                      _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Tarjeta Inferior de la Acometida ("Sin perder de vista la card") ──
            Positioned(
              left: 14,
              right: 14,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fila 1: Clave, Sector y Distancia estimada en vivo
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.connection.cadastralKey,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: cs.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Sector ${widget.connection.sector}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey.shade800,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (distanceToTarget != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.directions_walk_rounded,
                                  size: 14,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _locationService.formatDistance(distanceToTarget),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Fila 2: Nombre de cliente y medidor
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.connection.clientName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                widget.connection.address,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: cs.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (widget.connection.meterNumber.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Med: ${widget.connection.meterNumber}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Fila 3: Indicador de divergencia entre lecturas si existe
                    if (distanceBetweenAcometidaAndLast != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: distanceBetweenAcometidaAndLast > 50
                              ? Colors.amber.withValues(alpha: 0.15)
                              : Colors.blue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.compare_arrows_rounded,
                              size: 14,
                              color: distanceBetweenAcometidaAndLast > 50
                                  ? Colors.amber.shade900
                                  : cs.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Distancia acometida ↔ última lectura: ${_locationService.formatDistance(distanceBetweenAcometidaAndLast)}',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: distanceBetweenAcometidaAndLast > 50
                                      ? Colors.amber.shade900
                                      : cs.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Fila 4: Botones de acción ("Tomar Lectura" y "GPS Externo")
                    Row(
                      children: [
                        // Tomar Lectura (botón principal)
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 42,
                            child: FilledButton.icon(
                              onPressed: () {
                                Navigator.of(context).pop();
                                widget.onTakeReading();
                              },
                              icon: const Icon(
                                Icons.edit_calendar_rounded,
                                size: 18,
                              ),
                              label: const Text(
                                'Tomar Lectura',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: cs.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // GPS Externo (Google Maps / Waze)
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 42,
                            child: OutlinedButton.icon(
                              onPressed: _openExternalNavigation,
                              icon: const Icon(
                                Icons.open_in_new_rounded,
                                size: 16,
                              ),
                              label: const Text(
                                'GPS Ext.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleMapStyle() {
    setState(() {
      if (_mapStyle == 'calles') {
        _mapStyle = 'satelite';
      } else if (_mapStyle == 'satelite') {
        _mapStyle = 'oscuro';
      } else {
        _mapStyle = 'calles';
      }
    });
  }
}

class _DestinationTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _DestinationTabButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingMapButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  const _FloatingMapButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.95),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: color ?? cs.onSurface),
        tooltip: tooltip,
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _LocationMarker extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _LocationMarker({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: EdgeInsets.all(isSelected ? 6 : 4),
            decoration: BoxDecoration(
              color: isSelected ? color : color.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: isSelected ? 3 : 1,
                ),
              ],
            ),
            child: Icon(icon, size: isSelected ? 18 : 14, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _UserLiveLocationMarker extends StatelessWidget {
  const _UserLiveLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
