import 'package:flutter/material.dart';

class ReadOnlyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? leftIcon;
  final IconData? rightIcon;

  const ReadOnlyField({
    Key? key,
    required this.controller,
    required this.label,
    this.leftIcon,
    this.rightIcon,
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
        TextField(
          controller: controller,
          readOnly: true,
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
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
