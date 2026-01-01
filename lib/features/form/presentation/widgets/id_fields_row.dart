import 'package:flutter/material.dart';
import 'package:flutter_application/components/text/text_field.dart';
import 'package:flutter_application/utils/responsive_utils.dart';
import 'package:flutter_application/utils/screen_type_layout.dart';

class IdFieldsRow extends StatelessWidget {
  final TextEditingController cardIdController;
  final TextEditingController meterNumberController;

  const IdFieldsRow({
    super.key,
    required this.cardIdController,
    required this.meterNumberController,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveRow(
      rowSpacing: ResponsiveUtils.mediumSpacing(context),
      children: [
        CustomTextField(
          controller: cardIdController,
          label: 'Cédula de Ciudadanía',
          leftIcon: Icons.pin,
          textStyle: ResponsiveUtils.bodyMedium(
            context,
          ).copyWith(color: const Color(0xFF212121)),
          isReadOnly: true,
        ),
        CustomTextField(
          controller: meterNumberController,
          label: 'Número de Medidor',
          leftIcon: Icons.water_damage_outlined,
          textStyle: ResponsiveUtils.bodyMedium(
            context,
          ).copyWith(color: const Color(0xFF212121)),
          isReadOnly: true,
        ),
      ],
    );
  }
}
