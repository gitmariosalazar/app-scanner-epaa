import 'package:flutter/material.dart';
import 'package:flutter_application/components/text/text_field.dart';
import 'package:flutter_application/utils/responsive_utils.dart';

class OwnerAddressFields extends StatelessWidget {
  final TextEditingController connectionOwnerController;
  final TextEditingController addressConnectionController;

  const OwnerAddressFields({
    super.key,
    required this.connectionOwnerController,
    required this.addressConnectionController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: connectionOwnerController,
          label: 'Propietario de la Conexión',
          leftIcon: Icons.person_outline,
          textStyle: ResponsiveUtils.bodyMedium(
            context,
          ).copyWith(color: const Color(0xFF212121)),
          isReadOnly: true,
        ),
        ResponsiveUtils.vSpace(context, 0.03),
        CustomTextField(
          controller: addressConnectionController,
          label: 'Dirección de la Conexión',
          leftIcon: Icons.location_on_outlined,
          textStyle: ResponsiveUtils.bodyMedium(
            context,
          ).copyWith(color: const Color(0xFF212121)),
          isReadOnly: true,
        ),
      ],
    );
  }
}
