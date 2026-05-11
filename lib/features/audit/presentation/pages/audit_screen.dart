// lib/features/audit/presentation/pages/audit_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/core/di/injection.dart' as di;
import 'package:flutter_application/features/audit/domain/entities/audit_sector.dart';
import 'package:flutter_application/features/audit/presentation/cubit/audit_cubit.dart';
import 'package:flutter_application/features/audit/presentation/cubit/audit_state.dart';
import 'package:flutter_application/features/audit/presentation/pages/sector_browser_sheet.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';

// ── Color tokens ─────────────────────────────────────────────────
class _C {
  // Brand colors — unchanged across themes
  static const accent = Color(0xFF1565C0);
  static const green = Color(0xFF2E7D32);
  static const greenBg = Color(0xFFE8F5E9);
  static const orange = Color(0xFFE65100);
  static const orangeBg = Color(0xFFFFF3E0);
  static const red = Color(0xFFC62828);
}

// Theme-aware helpers — replace the old static _C.bg / _C.primary / _C.grey
extension _AuditTheme on BuildContext {
  Color get _surface => Theme.of(this).colorScheme.surface;
  Color get _onSurface => Theme.of(this).colorScheme.onSurface;
  Color get _muted => Theme.of(this).colorScheme.onSurfaceVariant;
  Color get _cardBg => Theme.of(this).colorScheme.surfaceContainerHighest;
  Color get _cardBorder => Theme.of(this).colorScheme.outlineVariant;
  Color get _primaryColor => Theme.of(this).colorScheme.primary;
}

const _sectorNames = <int, String>{};

class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // BlocProvider.value: cubit is a singleton from DI, do NOT auto-close it
    return BlocProvider.value(
      value: di.sl<AuditCubit>(),
      child: const _AuditView(),
    );
  }
}

class _AuditView extends StatefulWidget {
  const _AuditView();

  @override
  State<_AuditView> createState() => _AuditViewState();
}

class _AuditViewState extends State<_AuditView> {
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    // Inicia el stream reactivo con el mes actual.
    // El cubit maneja el polling automático y el ciclo de vida de la app.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuditCubit>().startWatching(month: _selectedMonth);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context._surface,
      appBar: AppBar(
        title: const Text(
          'Avance de Lecturas',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        elevation: 0,
        actions: [
          // ── Sector Browser button ───────────────────────────────
          BlocBuilder<AuditCubit, AuditState>(
            builder: (context, state) {
              final sectors = _sectorsFrom(state);
              final month = _monthFrom(state) ?? _selectedMonth;
              final displayMonth = _formatMonthLabel(month);
              return IconButton(
                icon: const Icon(Icons.grid_view_rounded),
                tooltip: 'Explorar sectores',
                onPressed: () => showSectorBrowser(
                  context: context,
                  sectors: sectors,
                  displayMonth: displayMonth,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            tooltip: 'Cambiar período',
            onPressed: () => _pickMonth(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: () =>
                context.read<AuditCubit>().refresh(month: _selectedMonth),
          ),
        ],
      ),
      body: BlocConsumer<AuditCubit, AuditState>(
        listener: (context, state) {
          if (state is SectorClosed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sector ${state.result.sectorId} cerrado correctamente.',
                      ),
                    ),
                  ],
                ),
                backgroundColor: _C.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is SectorCloseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.error_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: _C.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuditLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _C.accent),
            );
          }
          if (state is AuditError) {
            return _ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<AuditCubit>().refresh(month: _selectedMonth),
            );
          }
          // All “loaded” states — preserve the list during sector operations
          List<AuditSector>? sectors;
          String? month;
          int? closingForSectorId;
          if (state is AuditLoaded) {
            sectors = state.sectors;
            month = state.month;
          } else if (state is SectorClosing) {
            sectors = state.sectors;
            month = state.month;
            closingForSectorId = state.sectorId;
          } else if (state is SectorClosed) {
            sectors = state.sectors;
            month = state.month;
          } else if (state is SectorCloseError) {
            sectors = state.sectors;
            month = state.month;
          }
          if (sectors != null && month != null) {
            return RefreshIndicator(
              color: _C.accent,
              onRefresh: () =>
                  context.read<AuditCubit>().refresh(month: _selectedMonth),
              child: _LoadedView(
                sectors: sectors!,
                month: month!,
                closingForSectorId: closingForSectorId,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _pickMonth(BuildContext context) async {
    final cubit = context.read<AuditCubit>();
    final now = DateTime.now();
    // Parse current selected year/month for the picker initial state
    final parts = _selectedMonth.split('-');
    final initialYear = int.tryParse(parts[0]) ?? now.year;
    final initialMonth = int.tryParse(parts[1]) ?? now.month;

    final picked = await showDialog<String>(
      context: context,
      builder: (_) => _MonthPickerDialog(
        initialYear: initialYear,
        initialMonth: initialMonth,
        maxYear: now.year,
        maxMonth: now.month,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _selectedMonth = picked);
      // Cambia el mes observado: cancela el stream anterior e inicia uno nuevo.
      cubit.startWatching(month: picked);
    }
  }

  // ── Helpers for the Sector Browser ──────────────────────────────────────────

  List<AuditSector> _sectorsFrom(AuditState state) {
    if (state is AuditLoaded) return state.sectors;
    if (state is SectorClosing) return state.sectors;
    if (state is SectorClosed) return state.sectors;
    if (state is SectorCloseError) return state.sectors;
    return const [];
  }

  String? _monthFrom(AuditState state) {
    if (state is AuditLoaded) return state.month;
    if (state is SectorClosing) return state.month;
    if (state is SectorClosed) return state.month;
    if (state is SectorCloseError) return state.month;
    return null;
  }

  String _formatMonthLabel(String month) => _formatMonth(month);
}

// ── Custom Month Picker Dialog ────────────────────────────────────────────────

class _MonthPickerDialog extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final int maxYear;
  final int maxMonth;

  const _MonthPickerDialog({
    required this.initialYear,
    required this.initialMonth,
    required this.maxYear,
    required this.maxMonth,
  });

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late int _year;
  late int _selectedMonth;

  static const _monthNames = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    _selectedMonth = widget.initialMonth;
  }

  bool _isDisabled(int month) {
    return _year > widget.maxYear ||
        (_year == widget.maxYear && month > widget.maxMonth);
  }

  void _confirm(int month) {
    if (_isDisabled(month)) return;
    final result =
        '${_year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Seleccionar período',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context._onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Year navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: _year > 2024
                      ? () => setState(() {
                          _year--;
                          if (_year != widget.initialYear) _selectedMonth = 0;
                        })
                      : null,
                  color: _C.accent,
                ),
                Text(
                  _year.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context._onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: _year < widget.maxYear
                      ? () => setState(() {
                          _year++;
                          if (_year != widget.initialYear) _selectedMonth = 0;
                        })
                      : null,
                  color: _C.accent,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Month grid
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.4,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(12, (i) {
                final month = i + 1;
                final isSelected = _selectedMonth == month;
                final disabled = _isDisabled(month);
                return GestureDetector(
                  onTap: disabled ? null : () => _confirm(month),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: disabled
                          ? Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest
                          : isSelected
                          ? _C.accent
                          : _C.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? _C.accent : Colors.transparent,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _monthNames[i],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: disabled
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : isSelected
                              ? Colors.white
                              : _C.accent,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared helpers ───────────────────────────────────────────────────────────

/// Formats a "yyyy-MM" or "yyyy-MM-dd" string to a capitalized Spanish month label.
/// Example: "2026-01" → "Enero 2026"
String _formatMonth(String m) {
  try {
    final normalized = m.length == 7 ? '$m-01' : m;
    final dt = DateTime.parse(normalized);
    final raw = DateFormat('MMMM yyyy', 'es_ES').format(dt);
    return raw[0].toUpperCase() + raw.substring(1);
  } catch (_) {
    return m;
  }
}

// ── Loaded view ────────────────────────────────────────────────────────────────

class _LoadedView extends StatelessWidget {
  final List<AuditSector> sectors;
  final String month;

  final int? closingForSectorId;

  const _LoadedView({
    required this.sectors,
    required this.month,
    this.closingForSectorId,
  });

  int get _completed => sectors.where((s) => s.isComplete).length;
  int get _totalExpected => sectors.fold(0, (a, s) => a + s.expectedTotal);
  int get _totalCompleted => sectors.fold(0, (a, s) => a + s.completedTotal);
  int get _totalPending => sectors.fold(0, (a, s) => a + s.pendingTotal);
  double get _globalProgress =>
      _totalExpected > 0 ? _totalCompleted / _totalExpected : 0.0;

  @override
  Widget build(BuildContext context) {
    final displayMonth = _formatMonth(month);

    return CustomScrollView(
      slivers: [
        // ── Summary header ─────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Período: $displayMonth',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: _globalProgress),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.outlineVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _progressColor(_globalProgress),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Avance global: ${(_globalProgress * 100).toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '$_totalCompleted / $_totalExpected lecturas',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // KPI row
                Row(
                  children: [
                    _KpiChip(
                      label: 'Sectores',
                      value: '$_completed/${sectors.length}',
                      chipColor: const Color(0xFF1EB980),
                      icon: Icons.location_city_rounded,
                    ),
                    const SizedBox(width: 8),
                    _KpiChip(
                      label: 'Completadas',
                      value: _totalCompleted.toString(),
                      chipColor: null, // uses colorScheme.primary
                      icon: Icons.check_circle_rounded,
                    ),
                    const SizedBox(width: 8),
                    _KpiChip(
                      label: 'Pendientes',
                      value: _totalPending.toString(),
                      chipColor: const Color(0xFFFF9800),
                      icon: Icons.pending_actions_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Section title ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Builder(
              builder: (context) => Text(
                'DETALLE POR SECTOR',
                style: TextStyle(
                  color: context._muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),

        // ── Sector cards ───────────────────────────────────────────
        if (sectors.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Builder(
                builder: (context) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_rounded, color: context._muted, size: 48),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Text(
                        'No hay datos de seguimiento de lecturas en el período seleccionado, por favor, registre sus lecturas o comuníquese con su administrador.',
                        style: TextStyle(
                          color: context._muted,
                          fontSize: 14,
                          fontFamily: 'OpenSans',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SectorAuditCard(
                    sector: sectors[i],
                    index: i,
                    month: month,
                    isClosing: closingForSectorId == sectors[i].sectorId,
                  ),
                ),
                childCount: sectors.length,
              ),
            ),
          ),
      ],
    );
  }

  Color _progressColor(double p) {
    if (p >= 0.9) return const Color(0xFF1EB980);
    if (p >= 0.6) return const Color(0xFF00BFFF);
    if (p >= 0.3) return const Color(0xFFFF9800);
    return const Color(0xFFFF5252);
  }
}

// ── Sector audit card ────────────────────────────────────────────────────────

class _SectorAuditCard extends StatelessWidget {
  final AuditSector sector;
  final String month;
  final bool isClosing;
  final int index;

  const _SectorAuditCard({
    required this.sector,
    required this.month,
    required this.index,
    this.isClosing = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = sector.progressPercentage / 100.0;
    final progressColor = sector.isComplete
        ? _C.green
        : progress >= 0.7
        ? _C.accent
        : progress >= 0.3
        ? _C.orange
        : _C.red;
    final sectorName =
        _sectorNames[sector.sectorId] ?? 'Sector ${sector.sectorId}';

    // Alternating row colors: even → subtle primary tint, odd → base surface
    final cs = Theme.of(context).colorScheme;
    final isEven = index % 2 == 0;
    final cardColor = isEven ? cs.primaryContainer : context._cardBg;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context._cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${sector.sectorId}',
                      style: TextStyle(
                        color: progressColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sectorName,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: context._onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatMonth(month),
                        style: TextStyle(fontSize: 11, color: context._muted),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(isComplete: sector.isComplete),
              ],
            ),
          ),

          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => LinearProgressIndicator(
                  value: v,
                  backgroundColor: context._cardBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 7,
                ),
              ),
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              children: [
                _StatItem(
                  label: 'Esperadas',
                  value: sector.expectedTotal.toString(),
                  color: context._muted,
                ),
                _StatItem(
                  label: 'Completadas',
                  value: sector.completedTotal.toString(),
                  color: _C.green,
                ),
                _StatItem(
                  label: 'Pendientes',
                  value: sector.pendingTotal.toString(),
                  color: _C.orange,
                ),
                _StatItem(
                  label: 'Avance',
                  value: '${sector.progressPercentage.toStringAsFixed(2)}%',
                  color: progressColor,
                  bold: true,
                ),
              ],
            ),
          ),

          // Observations (if any)
          if (sector.observations != null &&
              sector.observations!.isNotEmpty) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: context._muted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      sector.observations!,
                      style: TextStyle(
                        color: context._muted,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Close sector button (only when ≥ 90% and not yet closed) ────
          if (sector.progressPercentage >= 90.00 && !sector.isComplete)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: isClosing
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _C.green,
                          ),
                        ),
                      ),
                    )
                  : _CloseSectorButton(sector: sector, month: month),
            ),
        ],
      ),
    );
  }
}

// ── Close sector button ───────────────────────────────────────────────────────

class _CloseSectorButton extends StatelessWidget {
  final AuditSector sector;
  final String month;

  const _CloseSectorButton({required this.sector, required this.month});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: () => _openDialog(context),
        icon: const Icon(Icons.lock_rounded, size: 16),
        label: const Text(
          'Marcar como completado',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: _C.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          shadowColor: _C.green.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Future<void> _openDialog(BuildContext context) async {
    final cubit = context.read<AuditCubit>();
    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CloseSectorDialog(sector: sector, month: month),
    );
    if (result != null) {
      await cubit.closeSector(
        sectorId: sector.sectorId,
        month: month,
        supervisorId: result['supervisorId']!,
        observations: result['observations'],
      );
    }
  }
}

// ── Close sector confirmation dialog ─────────────────────────────────────────

class _CloseSectorDialog extends StatefulWidget {
  final AuditSector sector;
  final String month;

  const _CloseSectorDialog({required this.sector, required this.month});

  @override
  State<_CloseSectorDialog> createState() => _CloseSectorDialogState();
}

class _CloseSectorDialogState extends State<_CloseSectorDialog> {
  final _obsController = TextEditingController();
  String? _supervisorId;

  @override
  void initState() {
    super.initState();
    _loadSupervisor();
  }

  Future<void> _loadSupervisor() async {
    try {
      final user = await di.sl<AuthLocalDataSource>().getUser();
      if (mounted) setState(() => _supervisorId = user?.id ?? 'supervisor');
    } catch (_) {
      if (mounted) setState(() => _supervisorId = 'supervisor');
    }
  }

  @override
  void dispose() {
    _obsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = widget.sector.progressPercentage;
    final sectorName =
        _sectorNames[widget.sector.sectorId] ??
        'Sector ${widget.sector.sectorId}';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Gradient header ──────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Marcar como completado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  sectorName,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // ── Body ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress summary card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _C.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.green.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: _C.green,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${progress.toStringAsFixed(2)}% de avance registrado',
                            style: const TextStyle(
                              color: _C.green,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${widget.sector.completedTotal} / ${widget.sector.expectedTotal} lecturas',
                            style: TextStyle(
                              color: _C.green.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Esta acción cierra el período de lectura para este sector. '
                  'Una vez cerrado por el supervisor, el sistema no podrá reabrirlo automáticamente.',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Observaciones (opcional)',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _obsController,
                  maxLines: 3,
                  maxLength: 300,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Ej: Lecturas completadas satisfactoriamente...',
                    hintStyle: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                    counterStyle: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Actions ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.cancel_rounded, size: 18),
                    label: const Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.error,
                      side: BorderSide(color: cs.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _supervisorId == null
                        ? null
                        : () => Navigator.pop(context, {
                            'supervisorId': _supervisorId!,
                            'observations': _obsController.text,
                          }),
                    icon: _supervisorId == null
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: const Text(
                      'Confirmar',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: _C.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small widgets ─────────────────────────────────────────────────────────────

class _KpiChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  /// Solid background color for the chip.
  /// Pass null to use colorScheme.primary (for "Completadas").
  final Color? chipColor;

  const _KpiChip({
    required this.label,
    required this.value,
    required this.icon,
    this.chipColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = chipColor ?? cs.primary;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: bg.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 16),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isComplete;
  const _StatusBadge({required this.isComplete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isComplete ? _C.greenBg : _C.orangeBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete
                ? Icons.check_circle_rounded
                : Icons.hourglass_top_rounded,
            size: 12,
            color: isComplete ? _C.green : _C.orange,
          ),
          const SizedBox(width: 4),
          Text(
            isComplete ? 'Completo' : 'En progreso',
            style: TextStyle(
              color: isComplete ? _C.green : _C.orange,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool bold;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: bold ? 14 : 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          Text(label, style: TextStyle(color: context._muted, fontSize: 9)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, color: context._muted, size: 56),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: context._muted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
