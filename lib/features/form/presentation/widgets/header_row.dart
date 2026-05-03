import 'package:flutter/material.dart';
import 'package:flutter_application/components/card/title_card.dart';
import 'package:flutter_application/utils/responsive_utils.dart';
import 'package:flutter_application/utils/screen_type_layout.dart';

// Brand color constants (unchanged across themes)
const _kGreen = Color(0xFF4CAF50);
const _kBlue = Color(0xFF0288D1);

class HeaderRow extends StatelessWidget {
  final TextEditingController connectionIdController;
  final TextEditingController averageConsumptionController;

  const HeaderRow({
    super.key,
    required this.connectionIdController,
    required this.averageConsumptionController,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ResponsiveRow(
      rowSpacing: ResponsiveUtils.mediumSpacing(context),
      children: [
        TitledCard(
          title: 'Conexión ID',
          elevation: ResponsiveUtils.cardElevation(context),
          bottomRightIcon: Icon(
            Icons.cable,
            color: _kGreen,
            size: ResponsiveUtils.iconSmall(context),
          ),
          titleStyle: ResponsiveUtils.titleSmall(context),
          children: [
            Text(
              connectionIdController.text.isEmpty
                  ? 'Sin ID de conexión'
                  : connectionIdController.text,
              style: ResponsiveUtils.titleMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        TitledCard(
          title: 'Consumo Prom.',
          elevation: ResponsiveUtils.cardElevation(context),
          bottomRightIcon: Icon(
            Icons.water_drop,
            color: _kBlue,
            size: ResponsiveUtils.iconSmall(context),
          ),
          titleStyle: ResponsiveUtils.titleSmall(context),
          children: [
            Text(
              connectionIdController.text.isEmpty
                  ? '0.0 m³'
                  : '${double.tryParse(averageConsumptionController.text)?.toStringAsFixed(2) ?? '0.00'} m³',
              style: ResponsiveUtils.titleMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }
}
