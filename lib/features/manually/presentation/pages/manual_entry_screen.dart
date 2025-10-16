import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/features/manually/presentation/bloc/manually_bloc.dart';
import 'package:flutter_application/utils/responsive_utils.dart';

class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final TextEditingController _acometidaIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = context.isTablet;
    final sidePadding = isTablet ? 48.0 : 18.0;
    final cardRadius = context.largeBorderRadiusValue;
    final verticalSpace = isTablet ? 32.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ingresar Acometida ID',
          style: context.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<ManuallyBloc, ManuallyState>(
        listener: (context, state) {
          if (state is ManuallyLoaded) {
            context.push(
              '/form',
              extra: {'apiResponse': state.data, 'mode': 'manual'},
            );
          } else if (state is ManuallyFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ManuallyLoading;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.08),
                  theme.colorScheme.background,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: sidePadding,
                    vertical: verticalSpace,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sidePadding * 0.7,
                      vertical: verticalSpace * 1.1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.98),
                      borderRadius: BorderRadius.circular(cardRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.edit_document,
                            size: isTablet ? 56 : 36,
                            color: theme.colorScheme.primary,
                          ),
                          context.vSpace(0.012),
                          Text(
                            'Ingrese el ID de la Acometida',
                            style: context.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                              letterSpacing: 0.15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          context.vSpace(0.022),
                          TextFormField(
                            controller: _acometidaIdController,
                            enabled: !isLoading,
                            decoration: InputDecoration(
                              labelText: 'Acometida ID (ej: 5-256 o 12-256)',
                              labelStyle: context.bodyMedium.copyWith(
                                color: theme.colorScheme.primary.withOpacity(
                                  0.7,
                                ),
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: Icon(
                                Icons.edit,
                                color: theme.colorScheme.primary,
                                size: context.iconMedium,
                              ),
                              filled: true,
                              fillColor: theme.colorScheme.surface.withOpacity(
                                0.98,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  cardRadius * 0.7,
                                ),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  cardRadius * 0.7,
                                ),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.outline.withOpacity(
                                    0.32,
                                  ),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  cardRadius * 0.7,
                                ),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  cardRadius * 0.7,
                                ),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.error,
                                  width: 2,
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  cardRadius * 0.7,
                                ),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.error,
                                  width: 2,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: isTablet ? 18 : 12,
                                horizontal: 16,
                              ),
                            ),
                            style: context.bodyLarge.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: false,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[1-9][0-9-]*'),
                              ), // Allow 1-9 first, then digits or hyphen
                              _AcometidaIdInputFormatter(),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, ingrese un ID de acometida válido';
                              }
                              final regex = RegExp(
                                r'^([5-9]|[1-3][0-9]|40)-\d+$',
                              );
                              if (!regex.hasMatch(value)) {
                                return 'Formato inválido. Use 5-40 seguido de guion y números (ej., 5-256 o 12-256)';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) {
                              if (!isLoading &&
                                  (_formKey.currentState?.validate() ??
                                      false)) {
                                final acometidaId = _acometidaIdController.text
                                    .trim();
                                context.read<ManuallyBloc>().add(
                                  StartManuallyEvent(acometidaId),
                                );
                              }
                            },
                          ),
                          context.vSpace(0.04),
                          Row(
                            children: [
                              Expanded(
                                child: _MenuButton(
                                  color: theme.colorScheme.primary,
                                  icon: Icons.search,
                                  label: 'Consultar',
                                  isLoading: isLoading,
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            final acometidaId =
                                                _acometidaIdController.text
                                                    .trim();
                                            context.read<ManuallyBloc>().add(
                                              StartManuallyEvent(acometidaId),
                                            );
                                          }
                                        },
                                ),
                              ),
                              context.hSpace(0.04),
                              Expanded(
                                child: _MenuButton(
                                  color: Colors.redAccent,
                                  icon: Icons.cancel,
                                  label: 'Cancelar',
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          _acometidaIdController.clear();
                                          context.pop();
                                        },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _acometidaIdController.dispose();
    super.dispose();
  }
}

// Custom TextInputFormatter to enforce 5-40, auto-hyphen after 5-9 or 10-40, allow full editing, and prevent leading zero
class _AcometidaIdInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    final oldText = oldValue.text;

    // Allow empty input
    if (newText.isEmpty) {
      return newValue;
    }

    // Remove all non-digits and non-hyphen characters
    String cleaned = newText.replaceAll(RegExp(r'[^0-9-]'), '');

    // Prevent leading zero for the first part
    if (!cleaned.contains('-') && cleaned.startsWith('0')) {
      return oldValue;
    }

    // Prevent multiple hyphens
    if (cleaned.contains('-')) {
      final parts = cleaned.split('-');
      if (parts.length > 2) {
        return oldValue;
      }
      // Prevent leading zero before hyphen
      if (parts[0].startsWith('0')) {
        return oldValue;
      }
    }

    // Handle deletion
    if (newText.length < oldText.length) {
      return TextEditingValue(
        text: cleaned,
        selection: TextSelection.collapsed(offset: newValue.selection.end),
      );
    }

    // Handle input before the hyphen (5-40)
    if (!cleaned.contains('-')) {
      // Check for single digit (5-9)
      if (cleaned.length == 1) {
        final number = int.tryParse(cleaned);
        if (number != null && number >= 5 && number <= 9) {
          return TextEditingValue(
            text: '$cleaned-',
            selection: TextSelection.collapsed(
              offset: newValue.selection.end + 1,
            ),
          );
        }
      }
      // Check for two digits (10-40)
      if (cleaned.length >= 2) {
        final number = int.tryParse(cleaned.substring(0, 2));
        if (number != null && number >= 10 && number <= 40) {
          return TextEditingValue(
            text:
                '${cleaned.substring(0, 2)}-${cleaned.length > 2 ? cleaned.substring(2) : ''}',
            selection: TextSelection.collapsed(
              offset: newValue.selection.end + 1,
            ),
          );
        } else if (number != null && (number < 5 || number > 40)) {
          return oldValue;
        }
      }
    }

    final regex = RegExp(r'^[1-9]\d{0,1}-?\d*$');
    if (!regex.hasMatch(cleaned)) {
      return oldValue;
    }

    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: newValue.selection.end),
    );
  }
}

/// Attractive, responsive button with loading state and icon
class _MenuButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _MenuButton({
    required this.color,
    required this.icon,
    required this.label,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final radius = context.mediumBorderRadiusValue * 1.5;
    final isTablet = context.isTablet;
    final height = isTablet ? 60.0 : 50.0;
    final fontSize = isTablet ? 18.0 : 15.5;

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 4,
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 12,
            vertical: isTablet ? 14 : 10,
          ),
          minimumSize: Size(double.infinity, height),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: isTablet ? 26 : 20, color: Colors.white),
                  SizedBox(width: context.smallSpacing),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      letterSpacing: 0.3,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
