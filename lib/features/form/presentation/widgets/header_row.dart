import 'package:flutter/material.dart';
import 'package:flutter_application/components/card/title_card.dart';
import 'package:flutter_application/utils/responsive_utils.dart';
import 'package:flutter_application/utils/screen_type_layout.dart';

class AppColors {
  static const primary = Color(0xFF0288D1);
  static const secondary = Color(0xFF4CAF50);
  static const cardBackground = Colors.white;
  static const textPrimary = Color(0xFF212121);
}

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
    return ResponsiveRow(
      rowSpacing: ResponsiveUtils.mediumSpacing(context),
      children: [
        TitledCard(
          title: 'Conexión ID',
          elevation: ResponsiveUtils.cardElevation(context),
          bottomRightIcon: Icon(
            Icons.cable,
            color: AppColors.secondary,
            size: ResponsiveUtils.iconSmall(context),
          ),
          titleStyle: ResponsiveUtils.titleSmall(context),
          backgroundColor: AppColors.cardBackground,
          children: [
            Text(
              connectionIdController.text.isEmpty
                  ? 'Sin ID de conexión'
                  : connectionIdController.text,
              style: ResponsiveUtils.titleMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
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
            color: AppColors.primary,
            size: ResponsiveUtils.iconSmall(context),
          ),
          titleStyle: ResponsiveUtils.titleSmall(context),
          backgroundColor: AppColors.cardBackground,
          children: [
            Text(
              connectionIdController.text.isEmpty
                  ? '0.0 m³'
                  : '${double.tryParse(averageConsumptionController.text)?.toStringAsFixed(2) ?? '0.00'} m³',
              style: ResponsiveUtils.titleMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
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
