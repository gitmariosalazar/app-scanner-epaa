import 'package:flutter/material.dart';
import 'package:flutter_application/components/card/title_card.dart';
import 'package:flutter_application/utils/consumption_utils.dart';
import 'package:flutter_application/utils/responsive_utils.dart';
import 'package:flutter_application/utils/screen_type_layout.dart';
import 'package:flutter_application/utils/date_utils.dart';



class ConsumptionRow extends StatelessWidget {
  final TextEditingController previousConsumptionController;
  final TextEditingController currentConsumptionController;
  final TextEditingController previousReadingDate;
  final ConsumptionVisuals consumptionVisuals;
  final DateTime now;

  const ConsumptionRow({
    super.key,
    required this.previousConsumptionController,
    required this.currentConsumptionController,
    required this.previousReadingDate,
    required this.consumptionVisuals,
    required this.now,
  });

  Widget _buildConsumptionCardContent(
    BuildContext context, {
    required bool isPrevious,
  }) {
    final cs = Theme.of(context).colorScheme;
    final controller = isPrevious
        ? previousConsumptionController
        : currentConsumptionController;
    final dateText = isPrevious
        ? (previousReadingDate.text.isEmpty
              ? 'N/A'
              : formatFromIsoDate(previousReadingDate.text))
        : formatDate(now);
    final bgColor = isPrevious
        ? cs.secondaryContainer
        : consumptionVisuals.backgroundColor;
    final textColor = isPrevious
        ? cs.onSecondaryContainer
        : consumptionVisuals.textColor;
    final dateTextColor = isPrevious
        ? cs.onSurfaceVariant
        : consumptionVisuals.textColor.withOpacity(0.8);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.cardBorderRadius(context),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: ResponsiveUtils.cardPadding(context),
          child: Text(
            controller.text.isEmpty ? '0.0 m³' : '${controller.text} m³',
            style: ResponsiveUtils.titleMedium(
              context,
            ).copyWith(fontWeight: FontWeight.bold, color: textColor),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ResponsiveUtils.vSpace(context, 0.015),
        Text(
          'Fecha: $dateText',
          style: ResponsiveUtils.bodySmall(
            context,
          ).copyWith(color: dateTextColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ResponsiveRow(
      rowSpacing: ResponsiveUtils.mediumSpacing(context),
      children: [
        TitledCard(
          title: 'Consumo Anterior',
          elevation: ResponsiveUtils.cardElevation(context),
          bottomRightIcon: Icon(
            Icons.history,
            color: cs.onSurfaceVariant,
            size: ResponsiveUtils.iconSmall(context),
          ),
          titleStyle: ResponsiveUtils.titleSmall(context),
          backgroundColor: cs.secondaryContainer,
          children: [_buildConsumptionCardContent(context, isPrevious: true)],
        ),
        TitledCard(
          title: 'Consumo Actual',
          elevation: ResponsiveUtils.cardElevation(context),
          bottomRightIcon: Icon(
            consumptionVisuals.icon,
            color: consumptionVisuals.textColor,
            size: ResponsiveUtils.iconSmall(context),
          ),
          backgroundColor: consumptionVisuals.backgroundColor,
          titleStyle: ResponsiveUtils.titleSmall(context),
          children: [_buildConsumptionCardContent(context, isPrevious: false)],
        ),
      ],
    );
  }
}
