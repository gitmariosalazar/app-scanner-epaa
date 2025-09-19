import 'package:flutter/material.dart';

class EditTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final String? hintText;
  final int maxLines;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType; // 👈 nuevo parámetro

  const EditTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.leftIcon,
    this.rightIcon,
    this.hintText,
    this.maxLines = 1,
    this.validator,
    this.keyboardType, // 👈 también aquí
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 5),
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType, // 👈 aquí lo usamos
          decoration: InputDecoration(
            prefixIcon: leftIcon != null
                ? Icon(
                    leftIcon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  )
                : null,
            suffixIcon: rightIcon != null
                ? Icon(
                    rightIcon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          maxLines: maxLines,
          validator: validator,
        ),
      ],
    );
  }
}
