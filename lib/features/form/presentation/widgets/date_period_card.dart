import 'package:flutter/material.dart';
import 'package:flutter_application/utils/date_utils.dart';
import 'package:flutter_application/utils/responsive_utils.dart';

class AppColors {
  static const primary = Color(0xFF0288D1);
  static const cardSecondaryBackground = Color(0xFFE3F2FD);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
}

class DatePeriodCard extends StatelessWidget {
  final TextEditingController startDatePeriodController;
  final TextEditingController endDatePeriodController;

  const DatePeriodCard({
    super.key,
    required this.startDatePeriodController,
    required this.endDatePeriodController,
  });

  Widget _buildDateBubble(
    BuildContext context,
    String date,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            date,
            style: ResponsiveUtils.titleSmall(context).copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: ResponsiveUtils.bodySmall(
            context,
          ).copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String startDate = formatFromIsoDate(startDatePeriodController.text);
    final String endDate = formatFromIsoDate(endDatePeriodController.text);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSecondaryBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Periodo de Lectura',
            style: ResponsiveUtils.titleMedium(context).copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateBubble(
                context,
                startDate,
                'Inicio',
                Colors.greenAccent,
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.greenAccent,
                            AppColors.primary,
                            Colors.orangeAccent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Periodo Activo',
                      style: ResponsiveUtils.bodySmall(
                        context,
                      ).copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              _buildDateBubble(context, endDate, 'Fin', Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }
}
