// lib/features/reading/presentation/pending/pages/pending_readings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application/components/empty/EmptyData.dart';
import 'package:flutter_application/components/loaders/professional_loader.dart';
import 'package:flutter_application/core/di/injection.dart' as di;
import 'package:flutter_application/features/reading/domain/entities/pending_reading_connection.dart';
import 'package:flutter_application/features/reading/domain/usecases/get_reading_info.dart';
import 'package:flutter_application/features/reading/presentation/pending/cubit/pending_readings_cubit.dart';
import 'package:flutter_application/features/reading/presentation/pending/cubit/pending_readings_state.dart';
import 'package:flutter_application/features/reading/presentation/pending/widgets/pending_reading_card.dart';
import 'package:flutter_application/features/reading/presentation/pending/widgets/pending_readings_filter_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class PendingReadingsScreen extends StatefulWidget {
  final String? initialMonth;
  final int? initialSector;

  const PendingReadingsScreen({
    super.key,
    this.initialMonth,
    this.initialSector,
  });

  @override
  State<PendingReadingsScreen> createState() => _PendingReadingsScreenState();
}

class _PendingReadingsScreenState extends State<PendingReadingsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Despliega selector para elegir mes y año de consulta (YYYY-MM).
  Future<void> _selectMonth(BuildContext context, String currentMonth) async {
    final cubit = context.read<PendingReadingsCubit>();

    int currentYear;
    int currentMonthNum;
    try {
      final parts = currentMonth.split('-');
      currentYear = int.parse(parts[0]);
      currentMonthNum = int.parse(parts[1]);
    } catch (_) {
      final now = DateTime.now();
      currentYear = now.year;
      currentMonthNum = now.month;
    }

    int selectedYear = currentYear;
    int selectedMonthNum = currentMonthNum;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final now = DateTime.now();
            final years = [now.year - 1, now.year, now.year + 1];
            final monthNames = [
              'Enero',
              'Febrero',
              'Marzo',
              'Abril',
              'Mayo',
              'Junio',
              'Julio',
              'Agosto',
              'Septiembre',
              'Octubre',
              'Noviembre',
              'Diciembre',
            ];

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    color: Theme.of(dialogCtx).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Seleccionar Período',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selector de Año
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Año:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      DropdownButton<int>(
                        value: selectedYear,
                        items: years.map((y) {
                          return DropdownMenuItem(value: y, child: Text('$y'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => selectedYear = val);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Grid de Meses
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(12, (index) {
                      final mIndex = index + 1;
                      final isSelected = selectedMonthNum == mIndex;
                      return ChoiceChip(
                        label: Text(
                          monthNames[index].substring(0, 3),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Theme.of(dialogCtx).colorScheme.onSurface
                                : Theme.of(dialogCtx).colorScheme.primary,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: Theme.of(dialogCtx).colorScheme.primary,
                        onSelected: (_) {
                          setDialogState(() => selectedMonthNum = mIndex);
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(
                      dialogCtx,
                    ).colorScheme.errorContainer,
                    foregroundColor: Theme.of(
                      dialogCtx,
                    ).colorScheme.onErrorContainer,
                  ),
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final formatted =
                        '$selectedYear-${selectedMonthNum.toString().padLeft(2, '0')}';
                    Navigator.pop(dialogCtx, formatted);
                  },
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result != currentMonth) {
      await cubit.changeMonth(result);
    }
  }

  /// Acción directa para tomar la lectura de una acometida pendiente.
  Future<void> _handleTakeReading(
    BuildContext context,
    PendingReadingConnection item,
  ) async {
    final theme = Theme.of(context);

    // Muestra diálogo de carga mientras se consulta la info completa de la acometida
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
                SizedBox(width: 16),
                Text(
                  'Cargando acometida...',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final getReadingInfoUseCase = di.sl<GetReadingInfo>();
      final readings = await getReadingInfoUseCase(item.cadastralKey);

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Cierra loading dialog

      // Navegar a la pantalla de toma de lectura (/form)
      await context.push(
        '/form',
        extra: {'reading': readings, 'mode': 'manual'},
      );

      // Al volver, refrescar la lista para que las lecturas tomadas se actualicen
      if (context.mounted) {
        context.read<PendingReadingsCubit>().refresh();
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // Cierra loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al cargar información de la acometida: $e',
            style: const TextStyle(fontSize: 13),
          ),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Acometidas Pendientes',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refrescar',
            onPressed: () => context.read<PendingReadingsCubit>().refresh(),
          ),
        ],
      ),
      body: BlocConsumer<PendingReadingsCubit, PendingReadingsState>(
        listener: (context, state) {
          if (state is PendingReadingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: cs.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PendingReadingsLoading) {
            return const ProfessionalLoader(
              label: 'Consultando acometidas pendientes...',
              description: 'Obteniendo acometidas sin lectura para el período',
            );
          }

          if (state is PendingReadingsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 54,
                      color: cs.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No se pudo cargar las acometidas',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context
                          .read<PendingReadingsCubit>()
                          .loadPendingReadings(
                            month: state.selectedMonth,
                            sector: state.selectedSector,
                          ),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is PendingReadingsLoaded) {
            return Column(
              children: [
                // ── Barra de Filtros (Buscador + Mes + Sectores) ──
                PendingReadingsFilterBar(
                  searchController: _searchController,
                  selectedMonth: state.selectedMonth,
                  selectedSector: state.selectedSector,
                  availableSectors: state.availableSectors,
                  totalCount: state.totalCount,
                  onSearchChanged: (query) {
                    context.read<PendingReadingsCubit>().search(query);
                  },
                  onClearSearch: () {
                    _searchController.clear();
                    context.read<PendingReadingsCubit>().search('');
                  },
                  onSelectMonth: () =>
                      _selectMonth(context, state.selectedMonth),
                  onSelectSector: (sector) {
                    context.read<PendingReadingsCubit>().filterBySector(sector);
                  },
                ),

                const Divider(height: 1, thickness: 1),

                // ── Lista de Acometidas o Empty State ──
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () =>
                        context.read<PendingReadingsCubit>().refresh(),
                    child: state.filteredReadings.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: EmptyState(
                                  title: state.allReadings.isEmpty
                                      ? '¡No hay lecturas pendientes!'
                                      : 'No se encontraron resultados',
                                  description: state.allReadings.isEmpty
                                      ? 'Todas las acometidas del período ${state.selectedMonth} ${state.selectedSector != null ? 'en el Sector ${state.selectedSector}' : ''} ya cuentan con lectura registrada.'
                                      : 'Intenta ajustar los términos de búsqueda o cambiar el sector seleccionado.',
                                  icon: state.allReadings.isEmpty
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.search_off_rounded,
                                  iconColor: state.allReadings.isEmpty
                                      ? Colors.green
                                      : cs.outline,
                                  showButton: false,
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: state.filteredReadings.length,
                            itemBuilder: (context, index) {
                              final item = state.filteredReadings[index];
                              return PendingReadingCard(
                                key: ValueKey(item.cadastralKey),
                                connection: item,
                                onTakeReading: () =>
                                    _handleTakeReading(context, item),
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
}
