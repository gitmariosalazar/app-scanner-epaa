import 'package:flutter/material.dart';
import 'package:flutter_application/utils/date_utils.dart';
import 'package:flutter_application/utils/responsive_utils.dart';

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
    Color accentColor,
  ) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.15),
            border: Border.all(color: accentColor, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            date,
            style: ResponsiveUtils.titleSmall(context).copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: ResponsiveUtils.bodySmall(
            context,
          ).copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final String startDate = formatFromIsoDate(startDatePeriodController.text);
    final String endDate = formatFromIsoDate(endDatePeriodController.text);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
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
              color: cs.onSecondaryContainer,
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
                            cs.primary,
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
                      ).copyWith(color: cs.onSurfaceVariant),
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
