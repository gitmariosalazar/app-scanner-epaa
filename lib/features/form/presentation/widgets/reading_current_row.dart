// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:flutter_application/components/card/title_card.dart';
import 'package:flutter_application/features/reading/domain/entities/reading.dart';
import 'package:flutter_application/utils/date_utils.dart';
import 'package:flutter_application/utils/responsive_utils.dart';
import 'package:flutter_application/utils/screen_type_layout.dart';

// Brand color for success/secondary accent
const _kGreen = Color(0xFF4CAF50);

class ReadingCurrentRow extends StatelessWidget {
  final List<Reading> reading;

  const ReadingCurrentRow({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ResponsiveRow(
      rowSpacing: ResponsiveUtils.mediumSpacing(context),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LECTURA ANTERIOR
        TitledCard(
          title: 'Lectura Anterior',
          elevation: ResponsiveUtils.cardElevation(context),
          bottomRightIcon: Icon(
            Icons.history_outlined,
            color: _kGreen,
            size: ResponsiveUtils.iconSmall(context),
          ),
          titleStyle: ResponsiveUtils.titleSmall(context),
          backgroundColor: cs.secondaryContainer,
          children: [
            Text(
              reading[0].previousReading.toString().isEmpty
                  ? 'Sin lectura anterior'
                  : reading[0].previousReading.toString(),
              style: ResponsiveUtils.titleMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSecondaryContainer,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            ResponsiveUtils.vSpace(context, 0.015),
            Text(
              'Fecha: ${reading[1].previousReadingDate == null ? 'N/A' : formatFromIsoDate(reading[1].previousReadingDate.toString())}',
              style: ResponsiveUtils.bodySmall(
                context,
              ).copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),

        // LECTURA ACTUAL
        TitledCard(
          title: 'Lectura Actual',
          elevation: ResponsiveUtils.cardElevation(context),
          bottomRightIcon: Icon(
            Icons.speed_outlined,
            color: _kGreen,
            size: ResponsiveUtils.iconSmall(context),
          ),
          titleStyle: ResponsiveUtils.titleSmall(context).copyWith(
            color: _kGreen,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: cs.secondaryContainer,
          children: [
            Text(
              reading[0].currentReading == null
                  ? 'Sin lectura actual'
                  : reading[0].currentReading.toString(),
              style: ResponsiveUtils.titleMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: reading[0].currentReading == null
                    ? cs.onSurfaceVariant
                    : cs.onSecondaryContainer,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            ResponsiveUtils.vSpace(context, 0.015),
            Text(
              'Fecha: ${formatDate(reading[0].previousReadingDate ?? DateTime.now())}',
              style: ResponsiveUtils.bodySmall(
                context,
              ).copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}
