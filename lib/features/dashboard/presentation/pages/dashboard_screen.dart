// lib/features/dashboard/presentation/pages/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/core/di/injection.dart' as di;
import 'package:flutter_application/features/auth/presentation/cubit/login_cubit.dart';
import 'package:flutter_application/features/auth/presentation/cubit/login_state.dart';
import 'package:flutter_application/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:flutter_application/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:flutter_application/features/dashboard/presentation/cubit/dashboard_state.dart';

// ── Semantic status colors (brand constants, same in light & dark) ─────────
const _kGreen = Color(0xFF1EB980);
const _kOrange = Color(0xFFFF9800);
const _kRed = Color(0xFFFF5252);
const _kPurple = Colors.deepPurpleAccent;

class _C {
  // Brand colors — unchanged across themes
  static const accent = Color(0xFF1565C0);
  static const green = Color(0xFF2E7D32);
  static const greenBg = Color(0xFFE8F5E9);
  static const orange = Color(0xFFE65100);
  static const orangeBg = Color(0xFFFFF3E0);
  static const red = Color(0xFFC62828);
}

// ── Convenience extension ──────────────────────────────────────────────────
extension _T on BuildContext {
  ColorScheme get _cs => Theme.of(this).colorScheme;
  Color get _muted => Theme.of(this).colorScheme.onSurfaceVariant;
}


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: di.sl<DashboardCubit>()..loadStats(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final cs = context._cs;
    final user = context.select<LoginCubit, LoginState>((c) => c.state);
    final userName = user is LoginSuccess ? user.user.firstName : 'Lecturista';

    return Scaffold(
      backgroundColor: cs.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cs.surface, cs.surfaceContainerLow],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              final cs2 = context._cs;
              return RefreshIndicator(
                color: cs2.primary,
                backgroundColor: cs2.surfaceContainerHigh,
                onRefresh: () => context.read<DashboardCubit>().refresh(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildHeader(context, cs2, userName),
                    ),
                    if (state is DashboardLoading)
                      SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(color: cs2.primary),
                        ),
                      )
                    else if (state is DashboardError)
                      SliverFillRemaining(
                        child: _ErrorView(message: state.message),
                      )
                    else if (state is DashboardLoaded) ...[
                      SliverToBoxAdapter(
                        child: _buildKpiGrid(context, cs2, state.stats),
                      ),
                      SliverToBoxAdapter(
                        child: _buildProgressSection(context, cs2, state.stats),
                      ),
                      SliverToBoxAdapter(
                        child: _buildQuickActions(context, cs2),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context, ColorScheme cs, String userName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(DateTime.now().hour),
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 13,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userName,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: _kGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'EPAA-AA · Antonio Ante',
                        style: TextStyle(
                          color: cs.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _AvatarButton(),
        ],
      ),
    );
  }

  String _greeting(int hour) {
    if (hour < 12) return 'Buenos días 🌅';
    if (hour < 18) return 'Buenas tardes ☀️';
    return 'Buenas noches 🌙';
  }

  // ── KPI Grid ─────────────────────────────────────────────────────────────

  Widget _buildKpiGrid(BuildContext context, ColorScheme cs, DashboardStats s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('RESUMEN DEL PERÍODO'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  icon: Icons.water_drop_rounded,
                  iconColor: cs.primary,
                  title: 'Realizadas',
                  value: s.totalCompleted.toString(),
                  subtitle: 'lecturas totales',
                  trendLabel: '+${s.readingsToday} hoy',
                  trendUp: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KpiCard(
                  icon: Icons.assignment_rounded,
                  iconColor: _kOrange,
                  title: 'Meta',
                  value: s.totalAssigned.toString(),
                  subtitle: 'asignadas período',
                  trendLabel: '${s.remaining} restantes',
                  trendUp: null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  icon: Icons.location_city_rounded,
                  iconColor: _kGreen,
                  title: 'Sectores',
                  value: '${s.sectorsCompleted}/${s.sectorsTotal}',
                  subtitle: 'completados',
                  trendLabel: s.sectorsCompleted == s.sectorsTotal
                      ? '¡Completo!'
                      : '${s.sectorsTotal - s.sectorsCompleted} pendientes',
                  trendUp: s.sectorsCompleted == s.sectorsTotal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _KpiCard(
                  icon: Icons.trending_up_rounded,
                  iconColor: _progressColor(cs, s.overallProgress),
                  title: 'Avance',
                  value: '${s.completionPercent.toStringAsFixed(1)}%',
                  subtitle: 'del total',
                  trendLabel: _progressLabel(s.overallProgress),
                  trendUp: s.overallProgress >= 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _progressColor(ColorScheme cs, double p) {
    if (p >= 0.9) return _kGreen;
    if (p >= 0.6) return cs.primary;
    if (p >= 0.3) return _kOrange;
    return _kRed;
  }

  String _progressLabel(double p) {
    if (p >= 0.9) return 'Excelente ✓';
    if (p >= 0.7) return 'En buen ritmo';
    if (p >= 0.5) return 'A la mitad';
    return 'Requiere atención';
  }

  // ── Progress Section ──────────────────────────────────────────────────────

  Widget _buildProgressSection(
    BuildContext context,
    ColorScheme cs,
    DashboardStats s,
  ) {
    final progress = s.overallProgress; // already a 0.0–1.0 ratio

    final progressColor = progress >= 1.0
        ? _C.green
        : progress >= 0.7
        ? _C.accent
        : progress >= 0.3
        ? _C.orange
        : _C.red;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _SectionLabel('AVANCE POR SECTOR'),
              Text(
                'Actualizado ${_timeAgo(s.lastUpdated)}',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...s.sectorProgress.asMap().entries.map(
            (e) => _SectorProgressCard(sector: e.value, index: e.key),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    return 'hace ${diff.inHours}h';
  }

  // ── Quick Actions ─────────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionLabel('ACCIONES RÁPIDAS'),
          const SizedBox(height: 12),
          Row(
            children: [
              _QuickAction(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Escanear QR',
                color: cs.primary,
                onTap: () => context.push('/scan'),
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: Icons.edit_note_rounded,
                label: 'Manual',
                color: _kPurple,
                onTap: () => context.push('/manually-entry'),
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: Icons.note_alt_rounded,
                label: 'Observ.',
                color: _kOrange,
                onTap: () => context.push('/observations'),
              ),
              const SizedBox(width: 10),
              _QuickAction(
                icon: Icons.work_rounded,
                label: 'Órdenes',
                color: _kGreen,
                onTap: () => context.push('/add-work-order'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Sub-Widgets ───────────────────────────────────────────────────────────────

class _AvatarButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = context._cs;
    return GestureDetector(
      onTap: () => context.push('/profile'),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: cs.primary, width: 2),
        ),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: cs.primaryContainer,
          child: Icon(Icons.person_rounded, color: cs.primary, size: 24),
        ),
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: context._cs.onSurfaceVariant,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final String trendLabel;
  final bool? trendUp;

  const _KpiCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.trendLabel,
    this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context._cs;
    final trendColor = trendUp == null
        ? cs.onSurfaceVariant
        : (trendUp! ? _kGreen : _kOrange);
    final trendIcon = trendUp == null
        ? Icons.remove
        : (trendUp!
              ? Icons.arrow_upward_rounded
              : Icons.arrow_downward_rounded);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
              Icon(trendIcon, color: trendColor, size: 14),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            trendLabel,
            style: TextStyle(
              color: trendColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectorProgressCard extends StatelessWidget {
  final SectorProgress sector;
  final int index;
  const _SectorProgressCard({required this.sector, required this.index});

  @override
  Widget build(BuildContext context) {
    final cs = context._cs;
    final pct = sector.percentage; // 0.0–1.0
    final color = sector.isComplete
        ? _kGreen
        : pct >= 0.7
        ? cs.primary
        : pct >= 0.4
        ? _kOrange
        : _kRed;
    final pending = sector.assigned - sector.completed;

    // Alternating row colors: even → primaryContainer (visible), odd → base surface
    final isEven = index % 2 == 0;
    final cardColor = isEven
        ? cs.primaryContainer
        : cs.surfaceContainerHigh;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      child: Column(
        children: [
          // ── Header row: dot, name, count, % ────────────────────────
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  sector.sectorName,
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${sector.completed}/${sector.assigned}',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 44,
                child: Text(
                  '${(pct * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Progress bar ────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                backgroundColor: cs.outlineVariant,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ),

          // ── Stats row ──────────────────────────────────────────
          const SizedBox(height: 10),
          Row(
            children: [
              _StatItem(
                label: 'Esperadas',
                value: sector.assigned.toString(),
                color: context._muted,
              ),
              _StatItem(
                label: 'Completadas',
                value: sector.completed.toString(),
                color: _kGreen,
              ),
              _StatItem(
                label: 'Pendientes',
                value: pending.toString(),
                color: _kOrange,
              ),
              _StatItem(
                label: 'Avance',
                value: '${(pct * 100).toStringAsFixed(1)}%',
                color: color,
                bold: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = context._cs;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, color: cs.onSurfaceVariant, size: 56),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              onPressed: () => context.read<DashboardCubit>().refresh(),
            ),
          ],
        ),
      ),
    );
  }
}
