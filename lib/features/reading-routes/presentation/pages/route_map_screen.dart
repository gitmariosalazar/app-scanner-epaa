import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_application/config/environments/environment.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_assignment.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_connection_item.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_work_pack.dart';
import 'package:flutter_application/features/reading-routes/presentation/cubit/route_detail_cubit.dart';
import 'package:flutter_application/features/reading-routes/presentation/cubit/route_detail_state.dart';
import 'package:flutter_application/features/reading-routes/presentation/cubit/route_map_cubit.dart';
import 'package:flutter_application/features/reading-routes/presentation/cubit/route_map_state.dart';
import 'package:flutter_application/features/reading-routes/presentation/widgets/route_map_bottom_sheet.dart';
import 'package:flutter_application/features/reading-routes/presentation/widgets/route_map_legend.dart';
import 'package:flutter_application/features/reading-routes/presentation/utils/route_reading_form_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RouteMapScreen extends StatefulWidget {
  final RouteWorkPack? pack;
  final RouteAssignment routeAssignment;
  final RouteConnectionItem? initialSelected;

  const RouteMapScreen({
    super.key,
    this.pack,
    required this.routeAssignment,
    this.initialSelected,
  });

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    if (widget.pack != null) {
      context.read<RouteMapCubit>().init(
        widget.pack!,
        initialSelected: widget.initialSelected,
      );
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  String _getTileUrl(String mapStyle, bool isDark) {
    final mapConfig = Environment.mapConfig;

    switch (mapConfig.provider) {
      case 'mapbox':
        String styleId = isDark ? 'dark-v11' : 'streets-v12';
        if (mapStyle == 'satelite') styleId = 'satellite-streets-v12';
        if (mapStyle == 'oscuro') styleId = 'dark-v11';
        if (mapStyle == 'calles') styleId = 'streets-v12';
        return 'https://api.mapbox.com/styles/v1/mapbox/$styleId/tiles/{z}/{x}/{y}?access_token=${mapConfig.mapboxApiKey}';

      case 'carto':
        String style = isDark ? 'dark_all' : 'rastertiles/voyager';
        if (mapStyle == 'oscuro') style = 'dark_all';
        if (mapStyle == 'calles') style = 'rastertiles/voyager';
        if (mapStyle == 'satelite') {
          return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
        }
        return 'https://cartodb-basemaps-a.global.ssl.fastly.net/$style/{z}/{x}/{y}.png';

      default:
        if (mapStyle == 'satelite') {
          return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
        }
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  Color _getMarkerColor(RouteConnectionItem item, bool isSelected) {
    switch (item.estado) {
      case 'LEIDA':
        // Verde – completada / leída
        return isSelected
            ? const Color(0xFF2E7D32) // Verde más oscuro
            : const Color(0xFF43A047); // Verde medio

      case 'NOVEDAD':
        // Ámbar / Naranja – tiene novedad
        return isSelected
            ? const Color(0xFFE65100) // Naranja oscuro
            : const Color(0xFFFB8C00); // Naranja brillante

      case 'SALTADA':
      case 'OMITIDA':
        // Morado – saltada / omitida
        return isSelected
            ? const Color(0xFF6A1B9A) // Morado oscuro
            : const Color(0xFF8E24AA); // Morado medio

      case 'PENDIENTE':
      default:
        // Azul – pendiente
        return isSelected
            ? const Color(0xFF1565C0) // Azul más oscuro
            : const Color(0xFF1E88E5); // Azul principal
    }
  }

  LatLng _calculateInitialCenter(List<RouteConnectionItem> items) {
    if (widget.initialSelected != null &&
        widget.initialSelected!.hasCoordinates) {
      return LatLng(
        widget.initialSelected!.latitud!,
        widget.initialSelected!.longitud!,
      );
    }
    for (final it in items) {
      if (it.hasCoordinates) {
        return LatLng(it.latitud!, it.longitud!);
      }
    }
    // Default Antonio Ante center
    return const LatLng(0.331589, -78.221085);
  }

  void _fitRouteBounds(List<RouteConnectionItem> items) {
    final validPoints = items
        .where((a) => a.hasCoordinates)
        .map((a) => LatLng(a.latitud!, a.longitud!))
        .toList();

    if (validPoints.isEmpty) return;

    if (validPoints.length == 1) {
      _mapController.move(validPoints.first, 16.5);
      return;
    }

    try {
      final bounds = LatLngBounds.fromPoints(validPoints);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
      );
    } catch (_) {}
  }

  void _centerOnUser(LatLng? userLocation) {
    if (userLocation != null) {
      _mapController.move(userLocation, 17.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Obteniendo ubicación GPS...'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _centerOnNextPending(RouteWorkPack pack) {
    final next = pack.nextPendingInSequence;
    if (next != null && next.hasCoordinates) {
      final target = LatLng(next.latitud!, next.longitud!);
      _mapController.move(target, 17.5);
      context.read<RouteMapCubit>().selectMarker(next);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No hay predios pendientes con coordenadas disponibles.',
          ),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mapa • ${widget.routeAssignment.codigoRuta}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            Text(
              widget.pack?.nombreRuta ?? widget.routeAssignment.nombreRuta,
              style: TextStyle(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          // Fit Bounds Action
          IconButton(
            icon: const Icon(Icons.zoom_out_map_rounded),
            tooltip: 'Ajustar mapa a toda la ruta',
            onPressed: () {
              final state = context.read<RouteMapCubit>().state;
              if (state is RouteMapLoaded) {
                _fitRouteBounds(state.mapItems);
              }
            },
          ),
        ],
      ),
      body: BlocListener<RouteDetailCubit, RouteDetailState>(
        listener: (context, detailState) {
          if (detailState is RouteDetailLoaded) {
            final mapState = context.read<RouteMapCubit>().state;
            if (mapState is! RouteMapLoaded) {
              context.read<RouteMapCubit>().init(
                detailState.pack,
                initialSelected: widget.initialSelected,
              );
            }
          }
        },
        child: BlocBuilder<RouteMapCubit, RouteMapState>(
          builder: (context, state) {
            if (state is! RouteMapLoaded) {
              return BlocBuilder<RouteDetailCubit, RouteDetailState>(
                builder: (context, detailState) {
                  if (detailState is RouteDetailError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: cs.error,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No se pudo cargar la ruta',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              detailState.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 18),
                            FilledButton.icon(
                              onPressed: () => context
                                  .read<RouteDetailCubit>()
                                  .loadRoutePack(
                                    widget.routeAssignment.idAsignacion,
                                  ),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              );
            }

            final pack = state.pack;
            final items = state.mapItems;
            final selected = state.selectedItem;
            final userPos = state.userLocation;
            final mapStyle = state.mapStyle;
            final showPolyline = state.showPolyline;

            // Points in sequence for walking path polyline
            final polylinePoints = pack.acometidas
                .where((a) => a.hasCoordinates)
                .map((a) => LatLng(a.latitud!, a.longitud!))
                .toList();

            final initialCenter = _calculateInitialCenter(items);

            return Stack(
              children: [
                // 1. FlutterMap Layer
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: initialCenter,
                    initialZoom: 16.5,
                    minZoom: 11.0,
                    maxZoom: 19.0,
                    onTap: (_, _) {
                      context.read<RouteMapCubit>().selectMarker(null);
                    },
                  ),
                  children: [
                    // Tile Layer
                    TileLayer(
                      urlTemplate: _getTileUrl(mapStyle, isDark),
                      userAgentPackageName: 'com.epaa.app.scanner',
                      maxZoom: 19,
                    ),

                    // Walking route polyline
                    if (showPolyline && polylinePoints.length > 1)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: polylinePoints,
                            strokeWidth: 3.5,
                            color: const Color(
                              0xFF0288D1,
                            ).withValues(alpha: 0.8),
                          ),
                        ],
                      ),

                    // Markers Layer
                    MarkerLayer(
                      markers: [
                        // Acometida markers
                        ...items.map((item) {
                          final isSelected =
                              selected != null &&
                              selected.idDetalle == item.idDetalle;
                          final color = _getMarkerColor(item, isSelected);

                          return Marker(
                            point: LatLng(item.latitud!, item.longitud!),
                            width: isSelected ? 44 : 36,
                            height: isSelected ? 48 : 40,
                            alignment: Alignment.topCenter,
                            child: GestureDetector(
                              onTap: () {
                                context.read<RouteMapCubit>().selectMarker(
                                  item,
                                );
                                _mapController.move(
                                  LatLng(item.latitud!, item.longitud!),
                                  math.max(_mapController.camera.zoom, 17.0),
                                );
                              },
                              child: _RouteAcometidaMarker(
                                order: item.orden,
                                color: color,
                                isSelected: isSelected,
                                status: item.estado,
                              ),
                            ),
                          );
                        }),

                        // Live User Position Marker
                        if (userPos != null)
                          Marker(
                            point: userPos,
                            width: 32,
                            height: 32,
                            child: const _LiveUserGpsMarker(),
                          ),
                      ],
                    ),
                  ],
                ),

                // 2. Top Filter Chips Bar
                Positioned(
                  top: 10,
                  left: 12,
                  right: 12,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _MapFilterChip(
                          label: 'Todas',
                          count: pack.acometidas
                              .where((a) => a.hasCoordinates)
                              .length,
                          isSelected: state.statusFilter == 'TODAS',
                          onTap: () =>
                              context.read<RouteMapCubit>().setFilter('TODAS'),
                        ),
                        const SizedBox(width: 6),
                        _MapFilterChip(
                          label: 'Pendientes',
                          count: pack.acometidas
                              .where(
                                (a) =>
                                    a.hasCoordinates &&
                                    (a.estado == 'PENDIENTE' ||
                                        a.estado == 'SALTADA'),
                              )
                              .length,
                          isSelected: state.statusFilter == 'PENDIENTES',
                          onTap: () => context.read<RouteMapCubit>().setFilter(
                            'PENDIENTES',
                          ),
                        ),
                        const SizedBox(width: 6),
                        _MapFilterChip(
                          label: 'Leídas',
                          count: pack.acometidas
                              .where(
                                (a) => a.hasCoordinates && a.estado == 'LEIDA',
                              )
                              .length,
                          isSelected: state.statusFilter == 'LEIDAS',
                          onTap: () =>
                              context.read<RouteMapCubit>().setFilter('LEIDAS'),
                        ),
                        const SizedBox(width: 6),
                        _MapFilterChip(
                          label: 'Novedades',
                          count: pack.acometidas
                              .where(
                                (a) =>
                                    a.hasCoordinates && a.estado == 'NOVEDAD',
                              )
                              .length,
                          isSelected: state.statusFilter == 'NOVEDADES',
                          onTap: () => context.read<RouteMapCubit>().setFilter(
                            'NOVEDADES',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 3. Floating Map Controls (Right Side)
                Positioned(
                  right: 14,
                  top: 70,
                  child: Column(
                    children: [
                      // Center on User GPS
                      _MapFloatingButton(
                        icon: Icons.my_location_rounded,
                        tooltip: 'Mi ubicación GPS',
                        color: userPos != null ? cs.primary : null,
                        onTap: () => _centerOnUser(userPos),
                      ),
                      const SizedBox(height: 8),

                      // Center on Next Pending
                      _MapFloatingButton(
                        icon: Icons.directions_walk_rounded,
                        tooltip: 'Siguiente predio pendiente',
                        color: Colors.green.shade600,
                        onTap: () => _centerOnNextPending(pack),
                      ),
                      const SizedBox(height: 8),

                      // Toggle Map Style
                      _MapFloatingButton(
                        icon: mapStyle == 'satelite'
                            ? Icons.satellite_alt_rounded
                            : (mapStyle == 'oscuro'
                                  ? Icons.dark_mode_rounded
                                  : Icons.map_rounded),
                        tooltip: 'Cambiar capa de mapa',
                        onTap: () {
                          final nextStyle = mapStyle == 'calles'
                              ? 'satelite'
                              : (mapStyle == 'satelite' ? 'oscuro' : 'calles');
                          context.read<RouteMapCubit>().setMapStyle(nextStyle);
                        },
                      ),
                      const SizedBox(height: 8),

                      // Toggle Walking Polyline
                      _MapFloatingButton(
                        icon: Icons.timeline_rounded,
                        tooltip: 'Alternar línea de recorrido',
                        color: showPolyline
                            ? const Color(0xFF0288D1)
                            : Colors.grey,
                        onTap: () =>
                            context.read<RouteMapCubit>().togglePolyline(),
                      ),
                    ],
                  ),
                ),

                // 4. Floating Legend (Left Bottom)
                const Positioned(left: 14, bottom: 24, child: RouteMapLegend()),

                // 5. Selected Marker Bottom Sheet
                if (selected != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: RouteMapBottomSheet(
                      connection: selected,
                      onClose: () =>
                          context.read<RouteMapCubit>().selectMarker(null),
                      onTakeReading: () async {
                        final detailCubit = context.read<RouteDetailCubit>();
                        final mapCubit = context.read<RouteMapCubit>();
                        final saved = await RouteReadingFormLauncher.openForm(
                          context,
                          connection: selected,
                          assignmentId: pack.idAsignacion,
                        );
                        if (saved && mounted) {
                          await detailCubit.loadRoutePack(pack.idAsignacion);
                          final detailState = detailCubit.state;
                          if (detailState is RouteDetailLoaded) {
                            mapCubit.updatePack(detailState.pack);
                          }
                        }
                      },
                      onPrevious: () {
                        final state = context.read<RouteMapCubit>().state;
                        if (state is RouteMapLoaded) {
                          // Buscar la acometida con orden inmediatamente anterior
                          final prev =
                              state.mapItems
                                  .where((m) => m.orden < selected.orden)
                                  .toList()
                                ..sort((a, b) => b.orden.compareTo(a.orden));

                          final prevItem = prev.firstOrNull;

                          if (prevItem != null && prevItem.hasCoordinates) {
                            context.read<RouteMapCubit>().selectMarker(
                              prevItem,
                            );
                            _mapController.move(
                              LatLng(prevItem.latitud!, prevItem.longitud!),
                              17.5,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Ya no hay más acometidas anteriores en esta ruta.',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      onNext: () {
                        final state = context.read<RouteMapCubit>().state;
                        if (state is RouteMapLoaded) {
                          // Buscar la acometida con orden inmediatamente superior
                          final next =
                              state.mapItems
                                  .where((m) => m.orden > selected.orden)
                                  .toList()
                                ..sort((a, b) => a.orden.compareTo(b.orden));

                          final nextItem = next.firstOrNull;

                          if (nextItem != null && nextItem.hasCoordinates) {
                            context.read<RouteMapCubit>().selectMarker(
                              nextItem,
                            );
                            _mapController.move(
                              LatLng(nextItem.latitud!, nextItem.longitud!),
                              17.5,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Ya no hay más acometidas posteriores en esta ruta.',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RouteAcometidaMarker extends StatelessWidget {
  final int order;
  final Color color;
  final bool isSelected;
  final String status;

  const _RouteAcometidaMarker({
    required this.order,
    required this.color,
    required this.isSelected,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Order sequence badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: isSelected ? Colors.amberAccent : Colors.white,
              width: isSelected ? 2.0 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            '#$order',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 2),

        // Pin icon/circle
        Container(
          width: isSelected ? 24 : 18,
          height: isSelected ? 24 : 18,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.amberAccent : Colors.white,
              width: isSelected ? 2.5 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isSelected ? 0.6 : 0.4),
                blurRadius: isSelected ? 8 : 4,
                spreadRadius: isSelected ? 2 : 0,
              ),
            ],
          ),
          child: Icon(
            status == 'LEIDA'
                ? Icons.check
                : (status == 'NOVEDAD'
                      ? Icons.priority_high
                      : Icons.location_on),
            size: isSelected ? 13 : 10,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _LiveUserGpsMarker extends StatelessWidget {
  const _LiveUserGpsMarker();

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
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _MapFilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary
              : (isDark ? cs.surfaceContainer : Colors.white).withValues(
                  alpha: 0.95,
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? cs.primary
                : Colors.black.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : cs.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($count)',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white70 : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapFloatingButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  const _MapFloatingButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: (isDark ? cs.surfaceContainer : Colors.white).withValues(
          alpha: 0.95,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
