import 'package:flutter/material.dart';
import 'package:flutter_application/utils/date_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/observations/domain/entities/observation_entity.dart';
import 'package:flutter_application/features/observations/presentation/bloc/observation_bloc.dart';
import 'package:flutter_application/utils/responsive_utils.dart';

// ── Semantic novelty colors (status indicators – intentionally fixed) ────────
const _kGreen   = Color(0xFF2E7D32);
const _kAmberLo = Color(0xFFF9A825);
const _kAmberHi = Color(0xFFE65100);
const _kRedLo   = Color(0xFFD32F2F);
const _kRedHi   = Color(0xFFB71C1C);
const _kPurple  = Color(0xFF6A1B9A);
const _kGrey    = Color(0xFF546E7A);

class ObservationPage extends StatelessWidget {
  final String? connectionId;
  const ObservationPage({super.key, required this.connectionId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications, color: cs.onPrimary, size: 24),
            const SizedBox(width: 10),
            Text(
              'Observaciones',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: 2,
      ),
      body: BlocBuilder<ObservationBloc, ObservationState>(
        builder: (context, state) {
          if (state is ObservationLoading) {
            return Center(child: CircularProgressIndicator(color: cs.primary));
          } else if (state is ObservationError) {
            return _buildError(context, state.message);
          } else if (state is FindAllObservationLoaded) {
            final observations = state.observation;
            if (observations.isEmpty) return _buildEmpty(context);
            return AnimatedList(
              key: const ValueKey('observation_list'),
              initialItemCount: observations.length,
              padding: EdgeInsets.all(context.mediumSpacing),
              itemBuilder: (context, index, animation) {
                final obs = observations[index];
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation.drive(Tween(begin: 0.95, end: 1.0)),
                    child: _buildObservationCard(context, obs),
                  ),
                );
              },
            );
          }
          return Center(
            child: _buildActionButton(
              context,
              label: 'Cargar observaciones',
              icon: Icons.refresh,
              onPressed: () => context.read<ObservationBloc>().add(FindAllObservationsEvent()),
            ),
          );
        },
      ),
    );
  }

  // ── Empty & Error states ─────────────────────────────────────────────────

  Widget _buildEmpty(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, color: cs.onSurfaceVariant, size: context.iconLarge * 1.2),
          context.vSpace(0.02),
          Text(
            'No hay observaciones disponibles',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          context.vSpace(0.025),
          _buildActionButton(
            context,
            label: 'Reintentar',
            icon: Icons.refresh,
            onPressed: () => context.read<ObservationBloc>().add(FindAllObservationsEvent()),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: cs.error, size: context.iconLarge * 1.2),
          context.vSpace(0.02),
          Text(
            '❌ Error: $message',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: cs.error,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          context.vSpace(0.025),
          _buildActionButton(
            context,
            label: 'Reintentar',
            icon: Icons.refresh,
            onPressed: () => context.read<ObservationBloc>().add(FindAllObservationsEvent()),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: cs.onPrimary, size: context.iconMedium),
      label: Text(
        label,
        style: TextStyle(
          color: cs.onPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        padding: EdgeInsets.symmetric(
          horizontal: context.largeSpacing * 1.2,
          vertical: context.mediumSpacing * 1.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.mediumBorderRadiusValue),
        ),
        elevation: 2,
      ),
    );
  }

  // ── Observation Card ─────────────────────────────────────────────────────

  Widget _buildObservationCard(BuildContext context, ObservationEntity obs) {
    final cs  = Theme.of(context).colorScheme;
    final type  = obs.noveltyTypeName.toUpperCase();
    final color = _colorForNovelty(type);
    final icon  = _iconForNovelty(type);
    final cidText = obs.connectionId.isNotEmpty ? obs.connectionId : 'Sin ID';

    return Padding(
      padding: EdgeInsets.only(bottom: context.mediumSpacing),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(context.largeBorderRadiusValue),
        color: cs.surfaceContainerHigh,
        child: InkWell(
          borderRadius: BorderRadius.circular(context.largeBorderRadiusValue),
          onTap: () => _showDetailsDialog(context, obs, color, icon),
          child: Padding(
            padding: EdgeInsets.all(context.mediumSpacing * 1.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row ──────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        obs.observationTitle,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: context.smallSpacing * 0.5,
                        horizontal: context.mediumSpacing,
                      ),
                      decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        borderRadius: BorderRadius.circular(context.smallBorderRadiusValue),
                      ),
                      child: Text(
                        'C.C: $cidText',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                context.vSpace(0.01),
                // ── Content row ─────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: context.iconMedium,
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Icon(icon, color: color, size: context.iconMedium * 0.85),
                    ),
                    SizedBox(width: context.mediumSpacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            obs.observationDetail,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface,
                            ),
                          ),
                          context.vSpace(0.01),
                          // ── Date + type chips ──────────────────
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: context.smallSpacing * 0.6,
                                  horizontal: context.mediumSpacing,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(context.smallBorderRadiusValue),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_rounded,
                                      color: cs.onSurfaceVariant,
                                      size: context.iconExtraSmall,
                                    ),
                                    context.hSpace(0.005),
                                    Text(
                                      safeFormatDateTime(obs.registrationDate),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: context.smallSpacing * 0.6,
                                  horizontal: context.mediumSpacing,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(context.smallBorderRadiusValue),
                                  border: Border.all(color: color.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  type,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.visibility_rounded, color: color, size: context.iconSmall),
                      tooltip: 'Ver detalles',
                      onPressed: () => _showDetailsDialog(context, obs, color, icon),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Details Dialog ───────────────────────────────────────────────────────

  void _showDetailsDialog(
    BuildContext context,
    ObservationEntity obs,
    Color color,
    IconData icon,
  ) {
    final cidText = obs.connectionId.isNotEmpty ? obs.connectionId : 'Sin ID de conexión';
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return Dialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: context.mediumSpacing,
            vertical: context.largeSpacing,
          ),
          backgroundColor: cs.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.largeBorderRadiusValue),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.largeBorderRadiusValue),
              gradient: LinearGradient(
                colors: [cs.surfaceContainerHigh, color.withValues(alpha: 0.05)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(context.mediumSpacing * 1.2),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title row ──────────────────────────────────
                    Row(
                      children: [
                        CircleAvatar(
                          radius: context.iconMedium,
                          backgroundColor: color.withValues(alpha: 0.15),
                          child: Icon(icon, color: color, size: context.iconMedium * 0.85),
                        ),
                        SizedBox(width: context.mediumSpacing),
                        Expanded(
                          child: Text(
                            obs.observationTitle,
                            style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    context.vSpace(0.01),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: context.smallSpacing * 0.5,
                          horizontal: context.mediumSpacing,
                        ),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer,
                          borderRadius: BorderRadius.circular(context.smallBorderRadiusValue),
                        ),
                        child: Text(
                          'C.C: $cidText',
                          style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                            color: cs.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Divider(height: context.mediumSpacing * 2, thickness: 1, color: cs.outlineVariant),
                    _infoRow(ctx, '📝 Detalle', obs.observationDetail),
                    _infoRow(ctx, '📅 Fecha', safeFormatDateTime(obs.registrationDate)),
                    _infoRow(ctx, '📍 Dirección', obs.address),
                    _infoRow(ctx, '👤 Cliente', '${obs.clientName} (${obs.clientId})'),
                    _infoRow(ctx, '🔢 Lectura anterior', obs.previousReading.toString()),
                    _infoRow(ctx, '🔢 Lectura actual', obs.currentReading.toString()),
                    _infoRow(ctx, '⚙️ Tipo de novedad', obs.noveltyTypeName),
                    _infoRow(ctx, '📋 Descripción', obs.noveltyTypeDescription),
                    if (obs.actionRecommended != null)
                      _infoRow(ctx, '🛠️ Acción recomendada', obs.actionRecommended),
                    context.vSpace(0.025),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text('Cerrar', style: TextStyle(fontWeight: FontWeight.w700)),
                        style: FilledButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: context.mediumSpacing * 1.5,
                            vertical: context.mediumSpacing,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.mediumBorderRadiusValue),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Info row (dialog) ────────────────────────────────────────────────────

  Widget _infoRow(BuildContext context, String label, String? value) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.mediumSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          Expanded(
            child: Text(
              value ?? '—',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Novelty helpers ──────────────────────────────────────────────────────

  Color _colorForNovelty(String type) {
    switch (type) {
      case 'NORMAL':             return _kGreen;
      case 'CONSUMO BAJO':       return _kAmberLo;
      case 'CONSUMO ALTO':       return _kAmberHi;
      case 'CONSUMO MUY BAJO':   return _kRedLo;
      case 'CONSUMO EXCESIVO':   return _kRedHi;
      case 'LECTURA INVÁLIDA':   return _kPurple;
      case 'SIN LECTURA':        return _kGrey;
      default:                   return _kGrey;
    }
  }

  IconData _iconForNovelty(String type) {
    switch (type) {
      case 'NORMAL':             return Icons.check_circle_rounded;
      case 'CONSUMO BAJO':       return Icons.trending_down_rounded;
      case 'CONSUMO ALTO':       return Icons.trending_up_rounded;
      case 'CONSUMO MUY BAJO':   return Icons.arrow_downward_rounded;
      case 'CONSUMO EXCESIVO':   return Icons.arrow_upward_rounded;
      case 'LECTURA INVÁLIDA':   return Icons.error_rounded;
      case 'SIN LECTURA':        return Icons.block_rounded;
      default:                   return Icons.help_rounded;
    }
  }
}
