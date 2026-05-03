// lib/features/audit/presentation/pages/sector_browser_sheet.dart
//
// Presentation layer only — no domain/data imports beyond AuditSector entity.
// SRP: _SectorBrowserSheet  → grid of all 40 sectors
//       _SectorDetailSheet  → mini-dashboard for a single sector
// OCP: each widget is closed for modification but open via constructor params.
// DIP: receives [List<AuditSector>] from the parent — no direct cubit dependency.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application/features/audit/domain/entities/audit_sector.dart';

// ── Public entry-point ────────────────────────────────────────────────────────
/// Opens the sector browser bottom-sheet.
/// [sectors] may be empty (no audit data loaded yet) — the grid still shows
/// all 40 sector tiles; it just won't have progress data.
void showSectorBrowser({
  required BuildContext context,
  required List<AuditSector> sectors,
  required String displayMonth,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SectorBrowserSheet(
      sectors: sectors,
      displayMonth: displayMonth,
    ),
  );
}

// ── Sector name catalog (local — no extra network calls) ──────────────────────
const _kSectorNames = <int, String>{
  1: 'Atuntaqui Centro',
  2: 'Andrade Marín',
  3: 'Chaltura',
  4: 'Natabuela',
  5: 'Imbaya',
  6: 'San Roque',
  7: 'Rural Norte',
};

String _sectorName(int id) => _kSectorNames[id] ?? 'Sector $id';

// ── Color helpers ─────────────────────────────────────────────────────────────
Color _progressColor(double pct) {
  if (pct >= 100) return const Color(0xFF1EB980);
  if (pct >= 70) return const Color(0xFF1565C0);
  if (pct >= 40) return const Color(0xFFFF9800);
  return const Color(0xFFE53935);
}

// ── Sector Browser Sheet ──────────────────────────────────────────────────────
class _SectorBrowserSheet extends StatelessWidget {
  final List<AuditSector> sectors;
  final String displayMonth;

  const _SectorBrowserSheet({
    required this.sectors,
    required this.displayMonth,
  });

  AuditSector? _auditFor(int id) {
    try {
      return sectors.firstWhere((s) => s.sectorId == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? cs.surfaceContainerHigh : cs.surface;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Drag handle ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // ── Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.grid_view_rounded,
                      color: cs.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explorar Sectores',
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          displayMonth,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            // ── Legend ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  _LegendDot(color: const Color(0xFF1EB980), label: '100%'),
                  const SizedBox(width: 12),
                  _LegendDot(color: const Color(0xFF1565C0), label: '≥70%'),
                  const SizedBox(width: 12),
                  _LegendDot(color: const Color(0xFFFF9800), label: '≥40%'),
                  const SizedBox(width: 12),
                  _LegendDot(color: const Color(0xFFE53935), label: '<40%'),
                  const Spacer(),
                  Text(
                    '40 sectores',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ── Grid ─────────────────────────────────────────────────
            Expanded(
              child: GridView.builder(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemCount: 40,
                itemBuilder: (_, i) {
                  final sectorId = i + 1;
                  final audit = _auditFor(sectorId);
                  return _SectorTile(
                    sectorId: sectorId,
                    audit: audit,
                    onTap: () => _openDetail(context, sectorId, audit),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, int sectorId, AuditSector? audit) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SectorDetailSheet(
        sectorId: sectorId,
        audit: audit,
        displayMonth: displayMonth,
      ),
    );
  }
}

// ── Legend dot helper ─────────────────────────────────────────────────────────
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Sector Tile ───────────────────────────────────────────────────────────────
class _SectorTile extends StatelessWidget {
  final int sectorId;
  final AuditSector? audit;
  final VoidCallback onTap;

  const _SectorTile({
    required this.sectorId,
    required this.audit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = audit?.progressPercentage ?? 0.0;
    final color = audit != null ? _progressColor(pct) : cs.outlineVariant;
    final isComplete = audit?.isComplete ?? false;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isDark
              ? color.withValues(alpha: 0.18)
              : color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.5 : 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sector number badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Center(
                child: isComplete
                    ? Icon(Icons.check_rounded, color: color, size: 18)
                    : Text(
                        '$sectorId',
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 5),
            // Progress %
            Text(
              audit != null ? '${pct.toStringAsFixed(0)}%' : '—',
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sector Detail Sheet ───────────────────────────────────────────────────────
class _SectorDetailSheet extends StatelessWidget {
  final int sectorId;
  final AuditSector? audit;
  final String displayMonth;

  const _SectorDetailSheet({
    required this.sectorId,
    required this.audit,
    required this.displayMonth,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return DateFormat('dd MMM yyyy HH:mm', 'es_ES').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = _sectorName(sectorId);

    final pct = audit?.progressPercentage ?? 0.0;
    final color = audit != null ? _progressColor(pct) : cs.outlineVariant;

    // Gradient based on progress color + theme
    final gradientStart = isDark
        ? color.withValues(alpha: 0.7)
        : color;
    final gradientEnd = isDark
        ? color.withValues(alpha: 0.45)
        : color.withValues(alpha: 0.75);

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: isDark ? cs.surfaceContainerHigh : cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          controller: controller,
          child: Column(
            children: [
              // ── Drag handle ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 0),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // ── Hero gradient header ───────────────────────────────
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [gradientStart, gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: sector badge + status
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '$sectorId',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                displayMonth,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StatusPill(
                          isComplete: audit?.isComplete ?? false,
                          hasData: audit != null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Progress bar
                    if (audit != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Avance general',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${pct.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: pct / 100),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, __) => LinearProgressIndicator(
                            value: v.clamp(0.0, 1.0),
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.25),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                    ] else
                      Text(
                        'Sin datos de auditoría para este período',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (audit != null) ...[
                // ── KPI cards ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _DetailKpi(
                        icon: Icons.assignment_outlined,
                        label: 'Esperadas',
                        value: '${audit!.expectedTotal}',
                        color: cs.primary,
                      ),
                      const SizedBox(width: 10),
                      _DetailKpi(
                        icon: Icons.check_circle_outline_rounded,
                        label: 'Completadas',
                        value: '${audit!.completedTotal}',
                        color: const Color(0xFF1EB980),
                      ),
                      const SizedBox(width: 10),
                      _DetailKpi(
                        icon: Icons.pending_outlined,
                        label: 'Pendientes',
                        value: '${audit!.pendingTotal}',
                        color: const Color(0xFFFF9800),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── Info section ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? cs.surfaceContainerHighest
                          : cs.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.numbers_rounded,
                          label: 'ID Auditoría',
                          value: '${audit!.auditId}',
                          color: cs.primary,
                        ),
                        _InfoRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'Período',
                          value: DateFormat('MMMM yyyy', 'es_ES')
                              .format(audit!.readingMonth),
                          color: cs.primary,
                        ),
                        _InfoRow(
                          icon: Icons.play_circle_outline_rounded,
                          label: 'Inicio de ciclo',
                          value: _formatDate(audit!.createdAt),
                          color: cs.primary,
                        ),
                        _InfoRow(
                          icon: Icons.lock_clock_rounded,
                          label: 'Fecha de cierre',
                          value: _formatDate(audit!.closureDate),
                          color: audit!.closureDate != null
                              ? const Color(0xFF1EB980)
                              : cs.onSurfaceVariant,
                        ),
                        _InfoRow(
                          icon: Icons.person_outline_rounded,
                          label: 'Supervisor',
                          value: audit!.supervisorId ?? 'No asignado',
                          color: cs.primary,
                          isLast: audit!.observations == null,
                        ),
                        if (audit!.observations != null &&
                            audit!.observations!.isNotEmpty)
                          _InfoRow(
                            icon: Icons.notes_rounded,
                            label: 'Observaciones',
                            value: audit!.observations!,
                            color: const Color(0xFFFF9800),
                            isLast: true,
                          ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // ── No data placeholder ────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 32,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.inbox_rounded,
                          size: 40,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Sin auditoría registrada',
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Este sector no tiene datos de auditoría\npara el período seleccionado.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Status pill ───────────────────────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  final bool isComplete;
  final bool hasData;
  const _StatusPill({required this.isComplete, required this.hasData});

  @override
  Widget build(BuildContext context) {
    if (!hasData) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Sin datos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isComplete
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 5),
          Text(
            isComplete ? 'Cerrado' : 'En curso',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail KPI card ───────────────────────────────────────────────────────────
class _DetailKpi extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailKpi({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.6)),
      ],
    );
  }
}
