// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:flutter_application/components/card/title_card.dart';
import 'package:flutter_application/features/reading/domain/entities/reading.dart';
import 'package:flutter_application/utils/date_utils.dart';
import 'package:flutter_application/utils/responsive_utils.dart';
import 'package:flutter_application/utils/screen_type_layout.dart';

class AppColors {
  static const primary = Color(0xFF0288D1);
  static const secondary = Color(0xFF4CAF50);
  static const cardSecondaryBackground = Color(0xFFE3F2FD);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
}

class ReadingCurrentRow extends StatelessWidget {
  final List<Reading> reading;

  const ReadingCurrentRow({super.key, required this.reading});

  @override
  Widget build(BuildContext context) {
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
            color: AppColors.secondary,
            size: ResponsiveUtils.iconSmall(context),
          ),
          titleStyle: ResponsiveUtils.titleSmall(context),
          backgroundColor: AppColors.cardSecondaryBackground,
          children: [
            Text(
              reading[0].previousReading.toString().isEmpty
                  ? 'Sin lectura anterior'
                  : reading[0].previousReading.toString(),
              style: ResponsiveUtils.titleMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            ResponsiveUtils.vSpace(context, 0.015),
            Text(
              'Fecha: ${reading[0].previousReadingDate == null ? 'N/A' : formatFromIsoDate(reading[0].previousReadingDate.toString())}',
              style: ResponsiveUtils.bodySmall(
                context,
              ).copyWith(color: AppColors.textSecondary),
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
            color: AppColors.secondary,
            size: ResponsiveUtils.iconSmall(context),
          ),
          titleStyle: ResponsiveUtils.titleSmall(
            context,
          ).copyWith(color: AppColors.secondary, fontWeight: FontWeight.w600),
          backgroundColor: AppColors.cardSecondaryBackground.withOpacity(0.95),
          children: [
            Text(
              reading[0].currentReading == null
                  ? 'Sin lectura actual'
                  : reading[0].currentReading.toString(),
              style: ResponsiveUtils.titleMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: reading[0].currentReading == null
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            ResponsiveUtils.vSpace(context, 0.015),
            Text(
              'Fecha: ${formatDate(reading[0].previousReadingDate ?? DateTime.now())}',
              style: ResponsiveUtils.bodySmall(
                context,
              ).copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}
