import 'package:flutter/material.dart';
import 'package:flutter_application/components/text/text_field.dart';
import 'package:flutter_application/utils/responsive_utils.dart';
import 'package:flutter_application/utils/screen_type_layout.dart';

class ReadingFieldsRow extends StatelessWidget {
  final TextEditingController currentReadingController;
  final TextEditingController newCurrentReadingController;
  final TextEditingController monthReadingController;

  const ReadingFieldsRow({
    super.key,
    required this.currentReadingController,
    required this.newCurrentReadingController,
    required this.monthReadingController,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveRow(
      rowSpacing: ResponsiveUtils.mediumSpacing(context),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: currentReadingController,
          label: 'Lectura Anterior ${monthReadingController.text}',
          leftIcon: Icons.history_outlined,
          isReadOnly: true,
        ),
        CustomTextField(
          controller: newCurrentReadingController,
          label: 'Lectura Actual (Obligatorio)',
          leftIcon: Icons.speed_outlined,
          hintText: '0.00',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, ingrese la lectura actual';
            }
            final number = double.tryParse(value);
            if (number == null || number < 0) {
              return 'Ingrese un número positivo válido';
            }
            return null;
          },
        ),
      ],
    );
  }
}
