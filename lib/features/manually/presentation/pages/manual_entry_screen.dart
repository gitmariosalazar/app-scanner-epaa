import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/features/manually/presentation/bloc/manually_bloc.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ingresar Acometida ID',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<ManuallyBloc, ManuallyState>(
        listener: (context, state) {
          if (state is ManuallyLoaded) {
            context.push('/form', extra: state.data);
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
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.background,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 24.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Ingrese el ID de la Acometida',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _acometidaIdController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: 'Acometida ID',
                        prefixIcon: Icon(
                          Icons.edit,
                          color: theme.colorScheme.primary,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.error,
                            width: 2,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.error,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, ingrese un ID de acometida válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      final acometidaId = _acometidaIdController
                                          .text
                                          .trim();
                                      context.read<ManuallyBloc>().add(
                                        StartManuallyEvent(acometidaId),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(
                                  color: Colors.white24,
                                  width: 1.5,
                                ),
                              ),
                              elevation: 4,
                              minimumSize: const Size(double.infinity, 56),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.search,
                                        size: 22,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Consultar',
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () {
                                    _acometidaIdController.clear();
                                    context.pop();
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(
                                  color: Colors.white24,
                                  width: 1.5,
                                ),
                              ),
                              elevation: 4,
                              minimumSize: const Size(double.infinity, 56),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.cancel,
                                  size: 22,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Cancelar',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
