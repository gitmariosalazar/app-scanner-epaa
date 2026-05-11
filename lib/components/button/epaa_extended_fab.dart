import 'package:flutter/material.dart';

/// A [FloatingActionButton.extended] wrapper that supports an [enable] flag.
///
/// When [enable] is `false`:
/// - The button is desaturated (greyscale via [ColorFiltered])
/// - Opacity drops to 45%
/// - [onPressed] is set to `null` (fully inert)
/// - A tooltip is shown on long-press/hover
/// - Elevation is removed
///
/// Usage:
/// ```dart
/// EpaaExtendedFab(
///   enable: permitReading != false,
///   icon: const Icon(Icons.edit_note_rounded),
///   label: const Text('Actualizar Coordenadas'),
///   onPressed: () { ... },
/// )
/// ```
class EpaaExtendedFab extends StatelessWidget {
  final bool enable;
  final Widget icon;
  final Widget label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final String disabledTooltip;

  const EpaaExtendedFab({
    super.key,
    this.enable = true,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.disabledTooltip = 'No disponible',
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Opacity(
      opacity: enable ? 1.0 : 0.45,
      child: ColorFiltered(
        colorFilter: enable
            ? const ColorFilter.mode(Colors.transparent, BlendMode.color)
            : const ColorFilter.matrix(<double>[
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0,      0,      0,      1, 0,
              ]),
        child: Tooltip(
          message: enable ? '' : disabledTooltip,
          child: FloatingActionButton.extended(
            onPressed: enable ? onPressed : null,
            icon: icon,
            label: label,
            backgroundColor: backgroundColor ?? cs.primary,
            foregroundColor: foregroundColor ?? Colors.white,
            elevation: enable ? (elevation ?? 8.0) : 0.0,
            enableFeedback: enable,
          ),
        ),
      ),
    );
  }
}
