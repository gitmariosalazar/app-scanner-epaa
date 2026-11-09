import 'package:flutter/material.dart';
import 'package:flutter_application/features/reading-routes/presentation/cubit/user_routes_cubit.dart';
import 'package:flutter_application/features/reading-routes/presentation/cubit/user_routes_state.dart';
import 'package:flutter_application/features/reading-routes/presentation/widgets/route_card.dart';
import 'package:flutter_application/features/reading-routes/presentation/widgets/route_kpi_header.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/components/date/date_picker.dart';

class UserRoutesScreen extends StatefulWidget {
  const UserRoutesScreen({super.key});

  @override
  State<UserRoutesScreen> createState() => _UserRoutesScreenState();
}

enum RouteFilterType { period, date }

class _UserRoutesScreenState extends State<UserRoutesScreen> {
  final TextEditingController _searchController = TextEditingController();
  RouteFilterType? _filterType;
  String? _filterValue; // "2026-03" o "2026-03-15"

  Future<void> _reloadRoutes({bool forceRefresh = true}) async {
    final periodoMes = _filterType == RouteFilterType.period
        ? _filterValue
        : (_filterValue != null && _filterValue!.length >= 7
              ? _filterValue!.substring(0, 7)
              : null);
    final fecha = _filterType == RouteFilterType.date ? _filterValue : null;

    await context.read<UserRoutesCubit>().loadRoutes(
      periodoMes: periodoMes,
      fecha: fecha,
      forceRefresh: forceRefresh,
    );
  }

  DateTime _initialDateFor(RouteFilterType type) {
    final now = DateTime.now();
    if (_filterType == type && _filterValue != null) {
      if (type == RouteFilterType.period) {
        final parts = _filterValue!.split('-');
        return DateTime(
          int.tryParse(parts[0]) ?? now.year,
          parts.length > 1 ? (int.tryParse(parts[1]) ?? now.month) : now.month,
        );
      } else {
        return DateTime.tryParse(_filterValue!) ?? now;
      }
    }
    return now;
  }

  void _onPeriodSelected(String period) {
    setState(() {
      _filterType = RouteFilterType.period;
      _filterValue = period;
    });
    _reloadRoutes(forceRefresh: true);
  }

  void _onDateSelected(String date) {
    setState(() {
      _filterType = RouteFilterType.date;
      _filterValue = date;
    });
    _reloadRoutes(forceRefresh: true);
  }

  void _clearFilter() {
    setState(() {
      _filterType = null;
      _filterValue = null;
    });
    context.read<UserRoutesCubit>().loadRoutes(forceRefresh: true);
  }

  Future<void> _showFilterMenu() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtrar Rutas',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Selecciona el criterio de consulta:',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Opción A: Por Mes (Período)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: const Text(
                  'Por Mes (Período)',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Muestra todas las rutas programadas en el mes (ej. 2026-03)',
                ),
                onTap: () => Navigator.pop(modalCtx, 'period'),
              ),
              const Divider(height: 8),

              // Opción B: Por Fecha (Día específico)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.today_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                title: const Text(
                  'Por Fecha (Día específico)',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Filtra rutas y el KPI de rendimiento de esa jornada (ej. 2026-03-15)',
                ),
                onTap: () => Navigator.pop(modalCtx, 'date'),
              ),

              // Opción C: Limpiar filtro si hay uno activo
              if (_filterValue != null) ...[
                const Divider(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.clear_all_rounded,
                      color: Colors.red,
                    ),
                  ),
                  title: const Text(
                    'Restablecer Filtro',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text(
                    'Ver todas las rutas asignadas sin filtro',
                  ),
                  onTap: () => Navigator.pop(modalCtx, 'clear'),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (!mounted || choice == null) return;

    if (choice == 'clear') {
      _clearFilter();
    } else if (choice == 'period') {
      final initial = _initialDateFor(RouteFilterType.period);
      ProfessionalDatePicker.show(
        context: context,
        mode: ProfessionalDatePickerMode.monthYear,
        initialDate: initial,
        firstDate: DateTime(2024, 1),
        lastDate: DateTime(DateTime.now().year + 1, 12),
        onFormattedSelected: _onPeriodSelected,
      );
    } else if (choice == 'date') {
      final initial = _initialDateFor(RouteFilterType.date);
      ProfessionalDatePicker.show(
        context: context,
        mode: ProfessionalDatePickerMode.fullDate,
        initialDate: initial,
        firstDate: DateTime(2024, 1, 1),
        lastDate: DateTime(DateTime.now().year + 1, 12, 31),
        onFormattedSelected: _onDateSelected,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<UserRoutesCubit>().loadRoutes();
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Rutas de Lectura',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _filterValue != null,
              child: const Icon(Icons.calendar_month_rounded),
            ),
            tooltip: 'Filtrar por período o fecha',
            onPressed: _showFilterMenu,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar rutas',
            onPressed: () => _reloadRoutes(forceRefresh: true),
          ),
        ],
      ),
      body: BlocConsumer<UserRoutesCubit, UserRoutesState>(
        listener: (context, state) {
          if (state is UserRoutesLoaded && state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.successMessage!),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UserRoutesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UserRoutesError) {
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
                      'No se pudieron cargar las rutas',
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
                      onPressed: () => _reloadRoutes(forceRefresh: true),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is UserRoutesLoaded) {
            final allRoutes = state.allRoutes;
            final filteredRoutes = state.filteredRoutes;
            final kpi = state.kpi;
            final isOnline = state.isOnline;

            return RefreshIndicator(
              onRefresh: () => _reloadRoutes(forceRefresh: true),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  // KPI Header
                  RouteKpiHeader(kpi: kpi, isOnline: isOnline),

                  if (_filterValue != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          InputChip(
                            avatar: Icon(
                              _filterType == RouteFilterType.period
                                  ? Icons.calendar_month_rounded
                                  : Icons.today_rounded,
                              size: 16,
                            ),
                            backgroundColor: cs.surface,
                            label: Text(
                              _filterType == RouteFilterType.period
                                  ? 'Período: $_filterValue'
                                  : 'Fecha: $_filterValue',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            onDeleted: _clearFilter,
                            deleteIcon: const Icon(
                              Icons.close_rounded,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),

                  // Search input field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por código, nombre o sector...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                context.read<UserRoutesCubit>().search('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: cs.surfaceContainerHighest.withValues(
                        alpha: 0.35,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (val) =>
                        context.read<UserRoutesCubit>().search(val),
                  ),

                  const SizedBox(height: 14),

                  // Filter Chips row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Todas',
                          count: allRoutes.length,
                          isSelected: state.selectedFilter == 'TODAS',
                          onTap: () => context
                              .read<UserRoutesCubit>()
                              .filterByStatus('TODAS'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Pendientes / En Curso',
                          count: allRoutes
                              .where((r) => r.estado != 'COMPLETADA')
                              .length,
                          isSelected: state.selectedFilter == 'PENDIENTES',
                          onTap: () => context
                              .read<UserRoutesCubit>()
                              .filterByStatus('PENDIENTES'),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: 'Completadas',
                          count: allRoutes
                              .where(
                                (r) =>
                                    r.estado == 'COMPLETADA' ||
                                    r.porcentajeAvance >= 100,
                              )
                              .length,
                          isSelected: state.selectedFilter == 'COMPLETADAS',
                          onTap: () => context
                              .read<UserRoutesCubit>()
                              .filterByStatus('COMPLETADAS'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Route list title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rutas Asignadas (${filteredRoutes.length})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                        ),
                      ),
                      if (!isOnline)
                        Row(
                          children: [
                            Icon(
                              Icons.offline_pin_rounded,
                              size: 14,
                              color: Colors.orange.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Modo Offline Activo',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Empty state
                  if (filteredRoutes.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 20,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.route_outlined,
                            size: 56,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            allRoutes.isEmpty
                                ? 'No tienes rutas de lectura asignadas para este ciclo'
                                : 'No se encontraron rutas con el filtro seleccionado',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            allRoutes.isEmpty
                                ? 'Comunícate con tu supervisor de campo para asignación de cuadrilla.'
                                : 'Prueba cambiando el criterio de búsqueda.',
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                  // Route cards
                  ...filteredRoutes.map((route) {
                    final isDownloading =
                        state.downloadingAssignmentId == route.idAsignacion;
                    return RouteCard(
                      route: route,
                      isDownloading: isDownloading,
                      onTap: () {
                        context.push('/reading-routes/detail', extra: route);
                      },
                      onDownloadOffline: () {
                        context.read<UserRoutesCubit>().downloadRoutePack(
                          route.idAsignacion,
                        );
                      },
                      onOpenMap: () {
                        context.push(
                          '/reading-routes/map',
                          extra: {'assignment': route},
                        );
                      },
                    );
                  }),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary
              : cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? cs.primary
                : cs.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : cs.onSurface,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
