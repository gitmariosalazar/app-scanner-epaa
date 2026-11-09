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
    if (reading.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final r0 = reading[0];
    final r1 = reading.length > 1 ? reading[1] : null;

    final String previousReadingValue =
        (r0.previousReading?.toString().trim().isNotEmpty ?? false)
            ? r0.previousReading.toString()
            : 'Sin lectura anterior';

    final String previousReadingDateStr = () {
      final date = r1?.previousReadingDate ?? r0.previousReadingDate;
      if (date == null) return 'N/A';
      return formatFromIsoDate(date.toString());
    }();

    final String currentReadingValue = r0.currentReading == null
        ? 'Sin lectura actual'
        : r0.currentReading.toString();

    final String currentReadingDateStr =
        formatDate(r0.previousReadingDate ?? DateTime.now());

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
              previousReadingValue,
              style: ResponsiveUtils.titleMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: cs.onSecondaryContainer,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            ResponsiveUtils.vSpace(context, 0.015),
            Text(
              'Fecha: $previousReadingDateStr',
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
          titleStyle: ResponsiveUtils.titleSmall(
            context,
          ).copyWith(color: _kGreen, fontWeight: FontWeight.w600),
          backgroundColor: cs.secondaryContainer,
          children: [
            Text(
              currentReadingValue,
              style: ResponsiveUtils.titleMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: r0.currentReading == null
                    ? cs.onSurfaceVariant
                    : cs.onSecondaryContainer,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            ResponsiveUtils.vSpace(context, 0.015),
            Text(
              'Fecha: $currentReadingDateStr',
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
