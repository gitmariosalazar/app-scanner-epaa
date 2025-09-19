import 'package:flutter/material.dart';

class TitledCard extends StatelessWidget {
  final String title;
  final Widget child;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final Widget? bottomRightIcon;

  const TitledCard({
    Key? key,
    required this.title,
    required this.child,
    this.elevation = 6,
    this.padding = const EdgeInsets.all(20.0),
    this.bottomRightIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: padding,
        child: Stack(
          children: [
            // Contenido principal
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                child,
              ],
            ),

            // Ícono flotante en la esquina inferior derecha
            if (bottomRightIcon != null)
              Positioned(bottom: 0, right: 0, child: bottomRightIcon!),
          ],
        ),
      ),
    );
  }
}
