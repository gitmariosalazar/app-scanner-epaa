import 'package:flutter/material.dart';
import 'package:flutter_application/utils/responsive_utils.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onPressed;
  final bool circular;
  final Color? color;

  const ActionButton({
    super.key,
    required this.icon,
    this.label,
    required this.onPressed,
    this.circular = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? Theme.of(context).colorScheme.primary;
    final iconSize = ResponsiveUtils.iconMedium(context);
    final borderRadius = circular
        ? iconSize // Hace que sea un círculo perfecto
        : ResponsiveUtils.buttonBorderRadius(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: circular
          ? RawMaterialButton(
              onPressed: onPressed,
              elevation: ResponsiveUtils.cardElevation(context),
              fillColor: buttonColor,
              shape: const CircleBorder(),
              constraints: BoxConstraints.tightFor(
                width: iconSize * 2,
                height: iconSize * 2,
              ),
              child: Icon(icon, size: iconSize, color: Colors.white),
            )
          : ElevatedButton.icon(
              icon: Icon(icon, size: iconSize),
              label: Text(
                label ?? '',
                style: ResponsiveUtils.buttonText(context),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.mediumSpacing(context),
                  vertical: ResponsiveUtils.smallSpacing(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                elevation: ResponsiveUtils.cardElevation(context),
                shadowColor: buttonColor.withOpacity(0.3),
              ),
              onPressed: onPressed,
            ),
    );
  }
}
