// lib/features/home/presentation/pages/welcome_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application/core/di/injection.dart' as di;
import 'package:flutter_application/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_application/features/auth/data/models/user_model.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Welcome / Home screen — SRP: only handles the welcome UI.
/// DIP: depends on [AuthLocalDataSource] abstraction, not a concrete class.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  UserModel? _user;
  DateTime _now = DateTime.now();
  late final Timer _clockTimer;

  @override
  void initState() {
    super.initState();
    _loadUser();
    // Refresh time every minute to keep greeting/clock up to date.
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  Future<void> _loadUser() async {
    try {
      final user = await di.sl<AuthLocalDataSource>().getUser();
      if (mounted) setState(() => _user = user);
    } catch (_) {}
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  String get _greeting {
    final h = _now.hour;
    if (h < 12) return '¡Buenos días';
    if (h < 18) return '¡Buenas tardes';
    return '¡Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hero header ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _HeroHeader(
              user: _user,
              greeting: _greeting,
              now: _now,
              isDark: isDark,
            ),
          ),

          // ── Quick-access section title ────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Acceso rápido',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Feature grid ──────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: _features(context),
            ),
          ),

          // ── System info card ──────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            sliver: SliverToBoxAdapter(child: _SystemInfoCard(isDark: isDark)),
          ),
        ],
      ),
    );
  }

  List<Widget> _features(BuildContext context) => [
    _FeatureCard(
      icon: Icons.qr_code_scanner_rounded,
      title: 'Escanear QR',
      subtitle: 'Captura lecturas\ncon la cámara',
      color: const Color(0xFF1565C0),
      onTap: () => context.push('/scan'),
    ),
    _FeatureCard(
      icon: Icons.edit_note_rounded,
      title: 'Ingreso Manual',
      subtitle: 'Busca por clave\ncatastral',
      color: const Color(0xFF6A1B9A),
      onTap: () => context.push('/manually-entry'),
    ),
    _FeatureCard(
      icon: Icons.dashboard_rounded,
      title: 'Dashboard',
      subtitle: 'Indicadores y\nmétricas clave',
      color: const Color(0xFF00695C),
      onTap: () => context.go('/home'),
    ),
    _FeatureCard(
      icon: Icons.fact_check_rounded,
      title: 'Auditoría',
      subtitle: 'Control de\navance mensual',
      color: const Color(0xFF1B5E20),
      onTap: () => context.go('/auditoria'),
    ),
    _FeatureCard(
      icon: Icons.report_problem_rounded,
      title: 'Observaciones',
      subtitle: 'Novedades y\nreportes de campo',
      color: const Color(0xFFE65100),
      onTap: () => context.push('/observations'),
    ),
    _FeatureCard(
      icon: Icons.person_rounded,
      title: 'Mi Perfil',
      subtitle: 'Cuenta y\nconfiguración',
      color: const Color(0xFF37474F),
      onTap: () => context.push('/profile'),
    ),
  ];
}

// ── Hero Header ───────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final UserModel? user;
  final String greeting;
  final DateTime now;
  final bool isDark;

  const _HeroHeader({
    required this.user,
    required this.greeting,
    required this.now,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors =
        isDark
            ? [const Color(0xFF0D2137), const Color(0xFF0A3D62)]
            : [const Color(0xFF1565C0), const Color(0xFF0288D1)];

    final dateStr = DateFormat('EEEE, d MMM yyyy', 'es_ES').format(now);
    final timeStr = DateFormat('HH:mm').format(now);
    final username = user?.username ?? '—';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: logo + date pill ──────────────────────────
              Row(
                children: [
                  // App logo
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EPAA-AA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'Sistema de Lecturas',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 11,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Date/time pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: Colors.white.withValues(alpha: 0.85),
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          timeStr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Greeting ───────────────────────────────────────────
              Row(
                children: [
                  Text(
                    '$greeting, ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '$username!',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Date label
              Text(
                dateStr,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 12,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 24),

              // ── Feature highlight pills ────────────────────────────
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _HighlightPill(icon: Icons.speed_rounded, text: 'Rápido'),
                  _HighlightPill(icon: Icons.security_rounded, text: 'Seguro'),
                  _HighlightPill(
                    icon: Icons.sync_rounded,
                    text: 'Tiempo real',
                  ),
                  _HighlightPill(
                    icon: Icons.offline_bolt_rounded,
                    text: 'Eficiente',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Highlight pill ────────────────────────────────────────────────────────────

class _HighlightPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HighlightPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feature card ──────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? cs.surfaceContainer : cs.surface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : color.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.08 : 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                  height: 1.3,
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

// ── System info card ──────────────────────────────────────────────────────────

class _SystemInfoCard extends StatelessWidget {
  final bool isDark;

  const _SystemInfoCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainer : cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.15),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                'Acerca del sistema',
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.business_rounded,
            label: 'Empresa',
            value: 'EPAA-AA',
          ),
          _InfoRow(
            icon: Icons.water_drop_rounded,
            label: 'Sistema',
            value: 'Gestión de Lecturas de Agua',
          ),
          _InfoRow(
            icon: Icons.smartphone_rounded,
            label: 'Módulo',
            value: 'Scanner EPAA-AA',
          ),
          _InfoRow(
            icon: Icons.verified_rounded,
            label: 'Versión',
            value: '1.0.0',
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_rounded,
                  color: cs.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Usa el escáner QR para capturar lecturas de forma rápida y precisa directamente desde el medidor.',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                      height: 1.5,
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

// ── Info row helper ───────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
