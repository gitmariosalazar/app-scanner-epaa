import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/components/loaders/professional_loader.dart';
import 'package:flutter_application/components/messages/custom_snack_bar.dart';
import 'package:flutter_application/features/observations/domain/entities/observation_entity.dart';
import 'package:flutter_application/features/observations/presentation/bloc/observation_bloc.dart';
import 'package:flutter_application/utils/date_utils.dart';
import 'package:flutter_application/utils/responsive_utils.dart';

// ── Adaptive Novelty Theme Engine ─────────────────────────────────────────────

class _NoveltyTheme {
  final Color primary;
  final Color background;
  final Color border;
  final Color onPrimary;
  final IconData icon;
  final String label;

  const _NoveltyTheme({
    required this.primary,
    required this.background,
    required this.border,
    required this.onPrimary,
    required this.icon,
    required this.label,
  });

  static _NoveltyTheme resolve(String rawType, bool isDark) {
    final type = rawType.trim().toUpperCase();

    if (type.contains('NORMAL')) {
      return _NoveltyTheme(
        primary: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
        background: isDark ? const Color(0xFF092916) : const Color(0xFFF0FDF4),
        border: isDark ? const Color(0xFF166534) : const Color(0xFFBBF7D0),
        onPrimary: isDark ? const Color(0xFF052010) : Colors.white,
        icon: Icons.check_circle_rounded,
        label: 'Normal',
      );
    } else if (type.contains('MUY BAJO')) {
      return _NoveltyTheme(
        primary: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
        background: isDark ? const Color(0xFF3B0D0D) : const Color(0xFFFEF2F2),
        border: isDark ? const Color(0xFF991B1B) : const Color(0xFFFECACA),
        onPrimary: isDark ? const Color(0xFF2B0505) : Colors.white,
        icon: Icons.arrow_downward_rounded,
        label: 'Consumo Muy Bajo',
      );
    } else if (type.contains('BAJO')) {
      return _NoveltyTheme(
        primary: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
        background: isDark ? const Color(0xFF331E02) : const Color(0xFFFFFBEB),
        border: isDark ? const Color(0xFF92400E) : const Color(0xFFFDE68A),
        onPrimary: isDark ? const Color(0xFF261400) : Colors.white,
        icon: Icons.trending_down_rounded,
        label: 'Consumo Bajo',
      );
    } else if (type.contains('EXCESIVO')) {
      return _NoveltyTheme(
        primary: isDark ? const Color(0xFFFF5252) : const Color(0xFFB71C1C),
        background: isDark ? const Color(0xFF400A0A) : const Color(0xFFFFF1F1),
        border: isDark ? const Color(0xFFB91C1C) : const Color(0xFFFFCDD2),
        onPrimary: Colors.white,
        icon: Icons.warning_rounded,
        label: 'Consumo Excesivo',
      );
    } else if (type.contains('ALTO')) {
      return _NoveltyTheme(
        primary: isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C),
        background: isDark ? const Color(0xFF381504) : const Color(0xFFFFF7ED),
        border: isDark ? const Color(0xFF9A3412) : const Color(0xFFFED7AA),
        onPrimary: isDark ? const Color(0xFF260D00) : Colors.white,
        icon: Icons.trending_up_rounded,
        label: 'Consumo Alto',
      );
    } else if (type.contains('INVÁLIDA') || type.contains('INVALIDA')) {
      return _NoveltyTheme(
        primary: isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
        background: isDark ? const Color(0xFF25103E) : const Color(0xFFF5F3FF),
        border: isDark ? const Color(0xFF5B21B6) : const Color(0xFFDDD6FE),
        onPrimary: isDark ? const Color(0xFF1E0A36) : Colors.white,
        icon: Icons.error_outline_rounded,
        label: 'Lectura Inválida',
      );
    } else if (type.contains('SIN LECTURA')) {
      return _NoveltyTheme(
        primary: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        background: isDark ? const Color(0xFF141F2E) : const Color(0xFFF8FAFC),
        border: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        onPrimary: isDark ? const Color(0xFF0F172A) : Colors.white,
        icon: Icons.block_rounded,
        label: 'Sin Lectura',
      );
    }

    return _NoveltyTheme(
      primary: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
      background: isDark ? const Color(0xFF08273D) : const Color(0xFFF0F9FF),
      border: isDark ? const Color(0xFF0369A1) : const Color(0xFFBAE6FD),
      onPrimary: isDark ? const Color(0xFF021726) : Colors.white,
      icon: Icons.info_outline_rounded,
      label: rawType.isEmpty ? 'Observación' : rawType,
    );
  }
}

// ── Main Page ─────────────────────────────────────────────────────────────────

class ObservationPage extends StatefulWidget {
  final String? connectionId;
  const ObservationPage({super.key, required this.connectionId});

  @override
  State<ObservationPage> createState() => _ObservationPageState();
}

class _ObservationPageState extends State<ObservationPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'TODOS';
  String? _activeConnectionFilter;

  @override
  void initState() {
    super.initState();
    if (widget.connectionId != null && widget.connectionId!.trim().isNotEmpty) {
      _activeConnectionFilter = widget.connectionId!.trim();
    }
    _searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<ObservationBloc>();
      if (bloc.state is ObservationInitial) {
        _reloadObservations();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  void _reloadObservations() {
    final bloc = context.read<ObservationBloc>();
    if (_activeConnectionFilter != null && _activeConnectionFilter!.isNotEmpty) {
      bloc.add(FindObservationsByCadastralKeyEvent(_activeConnectionFilter!));
    } else {
      bloc.add(FindAllObservationsEvent());
    }
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = 'TODOS';
      _activeConnectionFilter = null;
    });
    context.read<ObservationBloc>().add(FindAllObservationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: _buildAppBar(context, cs, isDark),
      body: SafeArea(
        child: BlocBuilder<ObservationBloc, ObservationState>(
          builder: (context, state) {
            if (state is ObservationLoading) {
              return const ProfessionalLoader(
                label: 'Cargando observaciones...',
                description: 'Consultando novedades y registros de consumo.',
              );
            }

            if (state is ObservationError) {
              return _buildErrorState(context, state.message, cs, isDark);
            }

            List<ObservationEntity> allObservations = [];
            if (state is FindAllObservationLoaded) {
              allObservations = state.observation;
            } else if (state is GetObservationByCadastralKeyListLoaded) {
              allObservations = state.observations;
            }

            if (state is ObservationInitial && allObservations.isEmpty) {
              return _buildEmptyState(
                context,
                title: 'No hay datos cargados',
                subtitle: 'Presione el botón para consultar las observaciones registradas.',
                actionLabel: 'Cargar observaciones',
                onAction: _reloadObservations,
                cs: cs,
                isDark: isDark,
              );
            }

            // Apply filters
            final filteredObservations = _filterObservations(allObservations);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: RefreshIndicator(
                  color: cs.primary,
                  backgroundColor: isDark ? cs.surfaceContainerHighest : Colors.white,
                  onRefresh: () async => _reloadObservations(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      // Overview summary metrics
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            context.mediumSpacing,
                            context.mediumSpacing,
                            context.mediumSpacing,
                            context.smallSpacing,
                          ),
                          child: _buildMetricsBanner(
                            context,
                            allObservations: allObservations,
                            filteredCount: filteredObservations.length,
                            cs: cs,
                            isDark: isDark,
                          ),
                        ),
                      ),

                      // Search bar & category chips
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.mediumSpacing,
                            vertical: context.smallSpacing,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSearchBar(context, cs, isDark),
                              context.vSpace(0.012),
                              _buildFilterChips(context, allObservations, cs, isDark),
                              if (_activeConnectionFilter != null) ...[
                                context.vSpace(0.01),
                                _buildActiveConnectionBanner(cs, isDark),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // List items or empty state
                      if (filteredObservations.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildEmptyState(
                            context,
                            title: 'Sin observaciones coincidentes',
                            subtitle: _searchQuery.isNotEmpty || _selectedCategory != 'TODOS'
                                ? 'No se encontraron resultados para los filtros aplicados. Intente ajustar o restablecer la búsqueda.'
                                : 'No existen observaciones registradas para este periodo.',
                            actionLabel: 'Restablecer filtros',
                            onAction: _clearAllFilters,
                            cs: cs,
                            isDark: isDark,
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            context.mediumSpacing,
                            context.smallSpacing,
                            context.mediumSpacing,
                            context.largeSpacing * 2,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final obs = filteredObservations[index];
                                return _buildObservationCard(
                                  context,
                                  obs: obs,
                                  cs: cs,
                                  isDark: isDark,
                                );
                              },
                              childCount: filteredObservations.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── AppBar ───────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context, ColorScheme cs, bool isDark) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      backgroundColor: isDark ? cs.surfaceContainerHighest : cs.primary,
      foregroundColor: isDark ? cs.onSurface : cs.onPrimary,
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              tooltip: 'Regresar',
              onPressed: () => Navigator.of(context).maybePop(),
            )
          : null,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (isDark ? cs.primary : Colors.white).withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: isDark ? cs.primary : cs.onPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Observaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? cs.onSurface : cs.onPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Actualizar observaciones',
          onPressed: _reloadObservations,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Metrics Summary Banner ───────────────────────────────────────────────────

  Widget _buildMetricsBanner(
    BuildContext context, {
    required List<ObservationEntity> allObservations,
    required int filteredCount,
    required ColorScheme cs,
    required bool isDark,
  }) {
    final total = allObservations.length;
    final normalCount = allObservations.where((e) {
      return e.noveltyTypeName.trim().toUpperCase().contains('NORMAL');
    }).length;
    final criticalCount = allObservations.where((e) {
      final name = e.noveltyTypeName.trim().toUpperCase();
      return name.contains('EXCESIVO') ||
          name.contains('MUY BAJO') ||
          name.contains('INVÁLIDA') ||
          name.contains('INVALIDA');
    }).length;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? cs.outlineVariant.withValues(alpha: 0.6) : cs.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  title: 'Total',
                  value: '$total',
                  icon: Icons.list_alt_rounded,
                  accentColor: cs.primary,
                  isDark: isDark,
                ),
              ),
              Container(width: 1, height: 36, color: cs.outlineVariant),
              Expanded(
                child: _buildMetricTile(
                  context,
                  title: 'Normales',
                  value: '$normalCount',
                  icon: Icons.check_circle_outline_rounded,
                  accentColor: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A),
                  isDark: isDark,
                ),
              ),
              Container(width: 1, height: 36, color: cs.outlineVariant),
              Expanded(
                child: _buildMetricTile(
                  context,
                  title: 'Críticos',
                  value: '$criticalCount',
                  icon: Icons.warning_amber_rounded,
                  accentColor: isDark ? const Color(0xFFFF5252) : const Color(0xFFDC2626),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          if (_searchQuery.isNotEmpty || _selectedCategory != 'TODOS') ...[
            const SizedBox(height: 10),
            Divider(height: 1, thickness: 0.8, color: cs.outlineVariant),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.filter_list_rounded, size: 14, color: cs.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Mostrando $filteredCount de $total observaciones filtradas',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _clearAllFilters,
                  child: Text(
                    'Limpiar filtros',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    required bool isDark,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: accentColor),
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: accentColor,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }

  // ── Search & Filter Controls ─────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context, ColorScheme cs, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? cs.outlineVariant.withValues(alpha: 0.6) : cs.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          color: cs.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar por título, abonado, acometida o dirección...',
          hintStyle: TextStyle(
            color: cs.onSurfaceVariant.withValues(alpha: 0.8),
            fontSize: 13,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: cs.primary, size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, color: cs.onSurfaceVariant, size: 20),
                  tooltip: 'Borrar búsqueda',
                  onPressed: () => _searchController.clear(),
                )
              : null,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    List<ObservationEntity> allObservations,
    ColorScheme cs,
    bool isDark,
  ) {
    final categories = <String, (String label, IconData icon)>{
      'TODOS': ('Todos', Icons.apps_rounded),
      'NORMAL': ('Normal', Icons.check_circle_rounded),
      'ALTO': ('Consumo Alto', Icons.trending_up_rounded),
      'BAJO': ('Consumo Bajo', Icons.trending_down_rounded),
      'EXCESIVO': ('Excesivo', Icons.warning_rounded),
      'INVÁLIDA': ('Inválida / Sin lect.', Icons.error_outline_rounded),
    };

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: categories.entries.map((entry) {
          final key = entry.key;
          final (label, icon) = entry.value;
          final isSelected = _selectedCategory == key;

          int count = 0;
          if (key == 'TODOS') {
            count = allObservations.length;
          } else if (key == 'INVÁLIDA') {
            count = allObservations.where((e) {
              final n = e.noveltyTypeName.toUpperCase();
              return n.contains('INVÁLIDA') || n.contains('INVALIDA') || n.contains('SIN LECTURA');
            }).length;
          } else {
            count = allObservations.where((e) {
              return e.noveltyTypeName.toUpperCase().contains(key);
            }).length;
          }

          final chipColor = isSelected
              ? cs.primary
              : (isDark ? cs.surfaceContainerHighest : Colors.white);
          final textColor = isSelected
              ? (isDark ? cs.onPrimary : Colors.white)
              : cs.onSurface;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    _selectedCategory = key;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? cs.primary
                          : (isDark ? cs.outlineVariant : cs.outlineVariant.withValues(alpha: 0.8)),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: textColor),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? Colors.black26 : Colors.white24)
                              : cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActiveConnectionBanner(ColorScheme cs, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: isDark ? 0.3 : 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.secondary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.link_rounded, size: 16, color: cs.secondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Filtrando por acometida: #$_activeConnectionFilter',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSecondaryContainer,
              ),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                _activeConnectionFilter = null;
              });
              context.read<ObservationBloc>().add(FindAllObservationsEvent());
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Text(
                    'Ver todas',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: cs.secondary,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(Icons.close_rounded, size: 14, color: cs.secondary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter Logic ─────────────────────────────────────────────────────────────

  List<ObservationEntity> _filterObservations(List<ObservationEntity> all) {
    return all.where((obs) {
      // 1. Connection ID filter
      if (_activeConnectionFilter != null && _activeConnectionFilter!.isNotEmpty) {
        if (!obs.connectionId.toLowerCase().contains(_activeConnectionFilter!.toLowerCase())) {
          return false;
        }
      }

      // 2. Category filter
      if (_selectedCategory != 'TODOS') {
        final type = obs.noveltyTypeName.toUpperCase();
        if (_selectedCategory == 'INVÁLIDA') {
          final isInvalid = type.contains('INVÁLIDA') ||
              type.contains('INVALIDA') ||
              type.contains('SIN LECTURA');
          if (!isInvalid) return false;
        } else if (!type.contains(_selectedCategory)) {
          return false;
        }
      }

      // 3. Search query filter
      if (_searchQuery.isNotEmpty) {
        final matchTitle = obs.observationTitle.toLowerCase().contains(_searchQuery);
        final matchDetail = obs.observationDetail.toLowerCase().contains(_searchQuery);
        final matchClient = obs.clientName.toLowerCase().contains(_searchQuery);
        final matchAddress = obs.address.toLowerCase().contains(_searchQuery);
        final matchConn = obs.connectionId.toLowerCase().contains(_searchQuery);
        final matchType = obs.noveltyTypeName.toLowerCase().contains(_searchQuery);

        if (!matchTitle &&
            !matchDetail &&
            !matchClient &&
            !matchAddress &&
            !matchConn &&
            !matchType) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  // ── Observation Card ─────────────────────────────────────────────────────────

  Widget _buildObservationCard(
    BuildContext context, {
    required ObservationEntity obs,
    required ColorScheme cs,
    required bool isDark,
  }) {
    final noveltyTheme = _NoveltyTheme.resolve(obs.noveltyTypeName, isDark);
    final cidText = obs.connectionId.isNotEmpty ? obs.connectionId : 'Sin ID';
    final delta = obs.currentReading - obs.previousReading;
    final deltaFormatted = delta >= 0 ? '+${delta.toStringAsFixed(1)}' : delta.toStringAsFixed(1);

    final effectiveDate = obs.registrationDate.trim().isNotEmpty
        ? obs.registrationDate.trim()
        : obs.readingDate.trim();
    final effectiveClient = obs.clientName.trim().isNotEmpty
        ? obs.clientName.trim()
        : (obs.clientId.trim().isNotEmpty
            ? 'Abonado: ${obs.clientId.trim()}'
            : 'Abonado (Cta: ${obs.account})');

    return Padding(
      padding: EdgeInsets.only(bottom: context.mediumSpacing),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? cs.surfaceContainerHighest : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? noveltyTheme.primary.withValues(alpha: 0.3)
                : cs.outlineVariant,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : noveltyTheme.primary.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showObservationDetailSheet(context, obs, noveltyTheme, isDark),
              splashColor: noveltyTheme.primary.withValues(alpha: 0.1),
              highlightColor: noveltyTheme.primary.withValues(alpha: 0.05),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left semantic indicator
                    Container(
                      width: 5,
                      decoration: BoxDecoration(
                        color: noveltyTheme.primary,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(16),
                        ),
                      ),
                    ),

                    // Main card content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Type chip & Connection ID
                            Row(
                              children: [
                                // Novelty pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: noveltyTheme.background,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: noveltyTheme.border,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        noveltyTheme.icon,
                                        size: 13,
                                        color: noveltyTheme.primary,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        noveltyTheme.label,
                                        style: TextStyle(
                                          color: noveltyTheme.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                // Connection ID pill with copy action
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: obs.connectionId));
                                    CustomSnackBar.show(
                                      context: context,
                                      message: 'Acometida $cidText copiada',
                                      type: SnackBarType.info,
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? cs.surfaceContainerHighest.withValues(alpha: 0.6)
                                          : cs.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: cs.outlineVariant.withValues(alpha: 0.8),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.water_drop_rounded,
                                          size: 12,
                                          color: cs.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'C.C: $cidText',
                                          style: TextStyle(
                                            color: cs.onSurface,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Observation Title
                            Text(
                              obs.observationTitle.isNotEmpty
                                  ? obs.observationTitle
                                  : 'Observación de Lectura',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 6),

                            // Observation detail text
                            Text(
                              obs.observationDetail,
                              style: TextStyle(
                                fontSize: 13,
                                color: cs.onSurfaceVariant,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 12),

                            // Client & Location strip
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.25)
                                    : cs.surfaceContainerHighest.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.person_outline_rounded,
                                        size: 14,
                                        color: cs.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '$effectiveClient (Cta: ${obs.account})',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: cs.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        'Sec: ${obs.sector}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (obs.address.trim().isNotEmpty) ...[
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: cs.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            obs.address.trim(),
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              color: cs.onSurfaceVariant,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  // Readings comparison row
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.speed_rounded,
                                        size: 14,
                                        color: noveltyTheme.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Ant: ${obs.previousReading.toStringAsFixed(1)} m³',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: cs.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 12,
                                        color: cs.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Act: ${obs.currentReading.toStringAsFixed(1)} m³',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: cs.onSurface,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: noveltyTheme.primary.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Δ $deltaFormatted m³',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: noveltyTheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Footer: Date and 'Ver detalle' prompt
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 13,
                                  color: cs.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  safeFormatDateTime(effectiveDate),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Text(
                                      'Ver detalle',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: noveltyTheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 16,
                                      color: noveltyTheme.primary,
                                    ),
                                  ],
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
            ),
          ),
        ),
      ),
    );
  }

  // ── Detail Bottom Sheet ──────────────────────────────────────────────────────

  void _showObservationDetailSheet(
    BuildContext context,
    ObservationEntity obs,
    _NoveltyTheme theme,
    bool isDark,
  ) {
    final cs = Theme.of(context).colorScheme;
    final cidText = obs.connectionId.isNotEmpty ? obs.connectionId : 'Sin ID';
    final delta = obs.currentReading - obs.previousReading;
    final deltaFormatted = delta >= 0 ? '+${delta.toStringAsFixed(1)}' : delta.toStringAsFixed(1);
    final effectiveDate = obs.registrationDate.trim().isNotEmpty
        ? obs.registrationDate.trim()
        : obs.readingDate.trim();
    final effectiveClient = obs.clientName.trim().isNotEmpty
        ? obs.clientName.trim()
        : (obs.clientId.trim().isNotEmpty
            ? 'Abonado: ${obs.clientId.trim()}'
            : 'Abonado (Cta: ${obs.account})');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D1B2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header card with avatar & badges
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.background,
                              shape: BoxShape.circle,
                              border: Border.all(color: theme.border, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primary.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Icon(theme.icon, size: 28, color: theme.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.background,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: theme.border),
                                      ),
                                      child: Text(
                                        theme.label,
                                        style: TextStyle(
                                          color: theme.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded),
                                      onPressed: () => Navigator.pop(ctx),
                                      tooltip: 'Cerrar',
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  obs.observationTitle.isNotEmpty
                                      ? obs.observationTitle
                                      : 'Observación de Lectura',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: cs.onSurface,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 13,
                                      color: cs.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      safeFormatDateTime(effectiveDate),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: cs.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Section 1: Meter readings & Consumption metrics
                      _buildSectionHeader('Lecturas y Consumo', Icons.speed_rounded, cs),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildMetricBox(
                              label: 'Lectura Anterior',
                              value: '${obs.previousReading.toStringAsFixed(1)} m³',
                              color: cs.primary,
                              cs: cs,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricBox(
                              label: 'Lectura Actual',
                              value: '${obs.currentReading.toStringAsFixed(1)} m³',
                              color: cs.primary,
                              cs: cs,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMetricBox(
                              label: 'Variación',
                              value: '$deltaFormatted m³',
                              color: theme.primary,
                              cs: cs,
                              isDark: isDark,
                              highlight: true,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Section 2: Client & Account information
                      _buildSectionHeader('Datos del Abonado', Icons.person_rounded, cs),
                      const SizedBox(height: 8),
                      _buildInfoContainer(
                        isDark: isDark,
                        cs: cs,
                        children: [
                          _buildDetailRow('Nombre del Cliente', effectiveClient, cs),
                          _buildDetailRow('Cédula / Identificación', obs.clientId, cs),
                          _buildDetailRow('Número de Cuenta', obs.account.toString(), cs),
                          _buildDetailRow('Sector', obs.sector.toString(), cs),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Section 3: Location & Connection ID
                      _buildSectionHeader('Ubicación y Acometida', Icons.location_on_rounded, cs),
                      const SizedBox(height: 8),
                      _buildInfoContainer(
                        isDark: isDark,
                        cs: cs,
                        children: [
                          _buildDetailRow('Dirección', obs.address, cs),
                          _buildDetailRow(
                            'ID de Acometida',
                            cidText,
                            cs,
                            trailing: InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: obs.connectionId));
                                CustomSnackBar.show(
                                  context: ctx,
                                  message: 'ID de acometida copiado',
                                  type: SnackBarType.info,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.copy_rounded, size: 12, color: cs.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Copiar',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: cs.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _buildDetailRow('Mes de Facturación', obs.readingMonth, cs),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Section 4: Observation Details & Novelty Type
                      _buildSectionHeader('Detalles de la Novedad', Icons.description_rounded, cs),
                      const SizedBox(height: 8),
                      _buildInfoContainer(
                        isDark: isDark,
                        cs: cs,
                        children: [
                          _buildDetailRow('Tipo de Novedad', obs.noveltyTypeName, cs),
                          _buildDetailRow(
                            'Descripción del Tipo',
                            obs.noveltyTypeDescription.isNotEmpty
                                ? obs.noveltyTypeDescription
                                : 'Sin descripción técnica adicional.',
                            cs,
                          ),
                          _buildDetailRow(
                            'Detalle Registrado',
                            obs.observationDetail.isNotEmpty
                                ? obs.observationDetail
                                : 'Sin detalle registrado.',
                            cs,
                          ),
                          if (obs.observations.isNotEmpty &&
                              obs.observations != obs.observationDetail)
                            _buildDetailRow('Observación Adicional', obs.observations, cs),
                        ],
                      ),

                      // Section 5: Recommended Action Callout (if available)
                      if (obs.actionRecommended != null &&
                          obs.actionRecommended!.trim().isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.border, width: 1.2),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.handyman_rounded, color: theme.primary, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Acción Recomendada',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: theme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      obs.actionRecommended!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: cs.onSurface,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                final text = '📋 Reporte de Observación\n'
                                    '• Título: ${obs.observationTitle}\n'
                                    '• Novedad: ${obs.noveltyTypeName}\n'
                                    '• Acometida: $cidText\n'
                                    '• Cliente: $effectiveClient (${obs.clientId})\n'
                                    '• Dirección: ${obs.address}\n'
                                    '• Lectura: ${obs.previousReading} m³ ➔ ${obs.currentReading} m³ (Var: $deltaFormatted m³)\n'
                                    '• Detalle: ${obs.observationDetail}\n'
                                    '• Fecha: ${safeFormatDateTime(effectiveDate)}';
                                Clipboard.setData(ClipboardData(text: text));
                                CustomSnackBar.show(
                                  context: ctx,
                                  message: 'Reporte copiado al portapapeles',
                                  type: SnackBarType.success,
                                );
                              },
                              icon: const Icon(Icons.copy_rounded, size: 16),
                              label: const Text('Copiar reporte'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: cs.primary,
                                side: BorderSide(color: cs.primary),
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => Navigator.pop(ctx),
                              icon: const Icon(Icons.check_rounded, size: 18),
                              label: const Text('Entendido'),
                              style: FilledButton.styleFrom(
                                backgroundColor: cs.primary,
                                foregroundColor: isDark ? cs.onPrimary : Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ColorScheme cs) {
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricBox({
    required String label,
    required String value,
    required Color color,
    required ColorScheme cs,
    required bool isDark,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: highlight
            ? color.withValues(alpha: isDark ? 0.2 : 0.08)
            : (isDark ? cs.surfaceContainerHighest : cs.surfaceContainerHigh),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight ? color.withValues(alpha: 0.5) : cs.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: highlight ? color : cs.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContainer({
    required bool isDark,
    required ColorScheme cs,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainerHighest : cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String? value,
    ColorScheme cs, {
    Widget? trailing,
  }) {
    final displayValue = (value == null || value.trim().isEmpty) ? '—' : value.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayValue,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: cs.onSurface,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
    );
  }

  // ── Empty & Error States ─────────────────────────────────────────────────────

  Widget _buildEmptyState(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
    required ColorScheme cs,
    required bool isDark,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 52,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(actionLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: isDark ? cs.onPrimary : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String message,
    ColorScheme cs,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: cs.error.withValues(alpha: isDark ? 0.15 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 52,
                color: cs.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No se pudieron cargar las observaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _reloadObservations,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: isDark ? cs.onPrimary : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
