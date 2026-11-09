import 'package:flutter/material.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_assignment.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_connection_item.dart';
import 'package:flutter_application/features/reading-routes/presentation/cubit/route_detail_cubit.dart';
import 'package:flutter_application/features/reading-routes/presentation/cubit/route_detail_state.dart';
import 'package:flutter_application/features/reading-routes/presentation/widgets/route_connection_card.dart';
import 'package:flutter_application/features/reading-routes/presentation/widgets/route_progress_bar.dart';
import 'package:flutter_application/features/reading-routes/presentation/utils/route_reading_form_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RouteDetailScreen extends StatefulWidget {
  final RouteAssignment routeAssignment;

  const RouteDetailScreen({super.key, required this.routeAssignment});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<RouteDetailCubit>().loadRoutePack(
      widget.routeAssignment.idAsignacion,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.routeAssignment.codigoRuta,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              'Sector ${widget.routeAssignment.sector} • ${widget.routeAssignment.periodoMes}',
              style: TextStyle(fontSize: 11, color: cs.onInverseSurface),
            ),
          ],
        ),
        actions: [
          // Batch Sync Action Button
          BlocBuilder<RouteDetailCubit, RouteDetailState>(
            builder: (context, state) {
              if (state is RouteDetailLoaded) {
                final pendingCount = state.pendingSyncCount;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: state.isSyncing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                pendingCount > 0
                                    ? Icons.cloud_upload_rounded
                                    : Icons.cloud_done_rounded,
                                color: pendingCount > 0
                                    ? Colors.orange.shade700
                                    : Colors.green.shade600,
                              ),
                        tooltip: pendingCount > 0
                            ? 'Sincronizar $pendingCount lecturas pendientes'
                            : 'Lecturas al día',
                        onPressed: state.isSyncing
                            ? null
                            : () =>
                                  context.read<RouteDetailCubit>().syncBatch(),
                      ),
                      if (pendingCount > 0 && !state.isSyncing)
                        Positioned(
                          right: 6,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$pendingCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Interactive Map Button
          BlocBuilder<RouteDetailCubit, RouteDetailState>(
            builder: (context, state) {
              if (state is RouteDetailLoaded) {
                return IconButton(
                  icon: const Icon(Icons.map_rounded),
                  tooltip: 'Ver ruta en mapa interactivo',
                  onPressed: () {
                    context.push(
                      '/reading-routes/map',
                      extra: {
                        'pack': state.pack,
                        'assignment': widget.routeAssignment,
                      },
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Refresh / Redownload Route Button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar ruta del servidor',
            onPressed: () {
              context.read<RouteDetailCubit>().loadRoutePack(
                    widget.routeAssignment.idAsignacion,
                    forceDownload: true,
                  );
            },
          ),
        ],
      ),
      body: BlocConsumer<RouteDetailCubit, RouteDetailState>(
        listener: (context, state) {
          if (state is RouteDetailLoaded && state.syncMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.syncMessage!),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is RouteDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RouteDetailError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off_rounded, size: 48, color: cs.error),
                    const SizedBox(height: 12),
                    Text(
                      'No se pudo cargar el paquete de ruta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () {
                        context.read<RouteDetailCubit>().loadRoutePack(
                          widget.routeAssignment.idAsignacion,
                          forceDownload: true,
                        );
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar Descarga'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is RouteDetailLoaded) {
            final pack = state.pack;
            final acometidas = state.filteredAcometidas;
            final nextPending = pack.nextPendingInSequence;

            return Column(
              children: [
                // Header card with progress metrics
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: BoxDecoration(
                    color: isDark ? cs.surfaceContainer : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pack.nombreRuta,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RouteProgressBar(
                        total: pack.totalPredios,
                        completed: pack.prediosLeidos,
                        novelty: pack.prediosConNovedad,
                        pending: pack.prediosPendientes,
                        percentage: pack.porcentajeAvance,
                        height: 9,
                      ),
                    ],
                  ),
                ),

                // Quick Next in Sequence Banner
                if (nextPending != null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.directions_walk_rounded,
                          size: 20,
                          color: cs.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SIGUIENTE EN SECUENCIA (#${nextPending.orden})',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: cs.primary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                '${nextPending.acometidaId} • ${nextPending.abonado}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () => _openTakeReadingDialog(
                            context,
                            nextPending,
                            pack.idAsignacion,
                          ),
                          icon: const Icon(Icons.edit_note_rounded),
                          label: const Text('Leer'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Search & Filter controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                  child: Row(
                    children: [
                      // Search input
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Buscar predio, cuenta, abonado...',
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              size: 18,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear_rounded,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      context
                                          .read<RouteDetailCubit>()
                                          .searchAcometidas('');
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: cs.surfaceContainerHighest.withValues(
                              alpha: 0.35,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (val) => context
                              .read<RouteDetailCubit>()
                              .searchAcometidas(val),
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter chips row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _DetailFilterChip(
                          label: 'Todas',
                          count: pack.totalPredios,
                          isSelected: state.selectedFilter == 'TODAS',
                          onTap: () => context
                              .read<RouteDetailCubit>()
                              .filterAcometidas('TODAS'),
                        ),
                        const SizedBox(width: 6),
                        _DetailFilterChip(
                          label: 'Pendientes',
                          count: pack.prediosPendientes,
                          isSelected: state.selectedFilter == 'PENDIENTES',
                          onTap: () => context
                              .read<RouteDetailCubit>()
                              .filterAcometidas('PENDIENTES'),
                        ),
                        const SizedBox(width: 6),
                        _DetailFilterChip(
                          label: 'Leídas',
                          count: pack.prediosLeidos,
                          isSelected: state.selectedFilter == 'LEIDAS',
                          onTap: () => context
                              .read<RouteDetailCubit>()
                              .filterAcometidas('LEIDAS'),
                        ),
                        const SizedBox(width: 6),
                        _DetailFilterChip(
                          label: 'Novedades',
                          count: pack.prediosConNovedad,
                          isSelected: state.selectedFilter == 'NOVEDADES',
                          onTap: () => context
                              .read<RouteDetailCubit>()
                              .filterAcometidas('NOVEDADES'),
                        ),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 1),

                // Acometidas sequence list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await context.read<RouteDetailCubit>().loadRoutePack(
                            pack.idAsignacion,
                            forceDownload: true,
                          );
                    },
                    child: acometidas.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(
                                height: 200,
                                child: Center(
                                  child: Text(
                                    'No hay acometidas para el filtro seleccionado',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 4, bottom: 24),
                            itemCount: acometidas.length,
                            itemBuilder: (context, index) {
                              final item = acometidas[index];
                              final isNext =
                                  nextPending != null &&
                                  nextPending.idDetalle == item.idDetalle;

                              return RouteConnectionCard(
                                connection: item,
                                isNextInSequence: isNext,
                                onTakeReading: () => _openTakeReadingDialog(
                                  context,
                                  item,
                                  pack.idAsignacion,
                                ),
                                onLocateOnMap: () {
                                  context.push(
                                    '/reading-routes/map',
                                    extra: {
                                      'pack': pack,
                                      'assignment': widget.routeAssignment,
                                      'initialSelected': item,
                                    },
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _openTakeReadingDialog(
    BuildContext context,
    RouteConnectionItem item,
    int assignmentId,
  ) async {
    final saved = await RouteReadingFormLauncher.openForm(
      context,
      connection: item,
      assignmentId: assignmentId,
    );
    if (saved && context.mounted) {
      context.read<RouteDetailCubit>().loadRoutePack(assignmentId);
    }
  }
}

class _DetailFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _DetailFilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary
              : cs.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? cs.primary
                : cs.outlineVariant.withValues(alpha: 0.4),
          ),
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
