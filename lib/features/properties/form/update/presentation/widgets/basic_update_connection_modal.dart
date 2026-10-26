import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application/components/widgets/images_section.dart';
import 'package:flutter_application/features/properties/form/update/data/models/dto/request/update_connection_basic_request.dart';
import 'package:flutter_application/features/properties/form/update/domain/usecases/update_connection_basic_usecase.dart';
import 'package:flutter_application/core/di/injection.dart' as di;
import 'package:flutter_application/features/properties/search/domain/entities/connection.dart';
import 'package:flutter_application/components/widgets/connection_info_card.dart';

class BasicUpdateConnectionModal extends StatefulWidget {
  final ConnectionWithPropertiesEntity connection;

  const BasicUpdateConnectionModal({super.key, required this.connection});

  @override
  State<BasicUpdateConnectionModal> createState() =>
      _BasicUpdateConnectionModalState();
}

class _BasicUpdateConnectionModalState
    extends State<BasicUpdateConnectionModal> {
  final _formKey = GlobalKey<FormState>();
  final _meterNumberController = TextEditingController();
  final List<File> _photosFacade = [];
  final List<File> _photosMeter = [];
  bool _isLoading = false;
  bool _triedSubmit =
      false; // shows validation messages only after first attempt

  bool get _isFormValid {
    final hasMeter = _meterNumberController.text.trim().isNotEmpty;
    final hasFacade = _photosFacade.isNotEmpty;
    final hasMeterPhotos = _photosMeter.isNotEmpty;
    return hasMeter && hasFacade && hasMeterPhotos;
  }

  Future<void> _submit() async {
    setState(() => _triedSubmit = true);

    if (!_formKey.currentState!.validate() || !_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Completa todos los campos obligatorios',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final request = UpdateConnectionBasicRequest(
        connectionId: widget.connection.connectionId,
        meterNumber: _meterNumberController.text.trim(),
        photosFacade: _photosFacade,
        photosMeter: _photosMeter,
        photosFacadeDescriptions: _photosFacade.map((_) => "Fachada").toList(),
        photosMeterDescriptions: _photosMeter.map((_) => "Medidor").toList(),
      );

      final useCase = di.sl<UpdateConnectionBasicUseCase>();
      await useCase(request);

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Acometida actualizada correctamente',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _meterNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 12,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Actualizar Acometida',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Todos los campos son obligatorios',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.55),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Connection info card
              ConnectionInfoCard(connection: widget.connection),
              const SizedBox(height: 28),

              // ── Meter number ──────────────────────────────────────────────
              _SectionHeader(
                icon: Icons.numbers_rounded,
                title: 'Número de Medidor',
                isRequired: true,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _meterNumberController,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'Ej: 12345678',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.4,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.8,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: colorScheme.error),
                  ),
                  prefixIcon: Icon(
                    Icons.speed_rounded,
                    color: colorScheme.primary.withValues(alpha: 0.8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El número de medidor es obligatorio';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 28),

              // ── Facade photos ─────────────────────────────────────────────
              _SectionHeader(
                icon: Icons.home_work_rounded,
                title: 'Fotos de la Fachada',
                subtitle: 'Máximo 10 • Mínimo 1',
                isRequired: true,
              ),
              const SizedBox(height: 10),
              _PhotoCard(
                child: ImagesSection(
                  attachedImages: _photosFacade,
                  mode: 'facade',
                  allowGallery: true,
                  onImageAdded: (file) {
                    if (_photosFacade.length < 10) {
                      setState(() => _photosFacade.add(file));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Máximo 10 fotos permitidas'),
                        ),
                      );
                    }
                  },
                  onImageRemoved: (index) {
                    setState(() => _photosFacade.removeAt(index));
                  },
                ),
              ),
              if (_triedSubmit && _photosFacade.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    'Debes agregar al menos 1 foto de la fachada',
                    style: TextStyle(color: colorScheme.error, fontSize: 13),
                  ),
                ),
              const SizedBox(height: 28),

              // ── Meter photos ──────────────────────────────────────────────
              _SectionHeader(
                icon: Icons.electric_meter_rounded,
                title: 'Fotos del Medidor',
                subtitle: 'Máximo 10 • Mínimo 1',
                isRequired: true,
              ),
              const SizedBox(height: 10),
              _PhotoCard(
                child: ImagesSection(
                  attachedImages: _photosMeter,
                  mode: 'meter',
                  allowGallery: true,
                  onImageAdded: (file) {
                    if (_photosMeter.length < 10) {
                      setState(() => _photosMeter.add(file));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Máximo 10 fotos permitidas'),
                        ),
                      );
                    }
                  },
                  onImageRemoved: (index) {
                    setState(() => _photosMeter.removeAt(index));
                  },
                ),
              ),
              if (_triedSubmit && _photosMeter.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    'Debes agregar al menos 1 foto del medidor',
                    style: TextStyle(color: colorScheme.error, fontSize: 13),
                  ),
                ),
              const SizedBox(height: 36),

              // ── Submit button ─────────────────────────────────────────────

              // ... (todo el código anterior se mantiene igual hasta el botón de submit)

              // ── Botones ─────────────────────────────────────────────────
              Row(
                children: [
                  // Cancelar
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        foregroundColor: colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Guardar
                  Expanded(
                    flex: 1,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFormValid
                              ? colorScheme.primary
                              : colorScheme.primary.withValues(alpha: 0.45),
                          foregroundColor: colorScheme.onPrimary,
                          elevation: _isFormValid ? 2 : 0,
                          shadowColor: colorScheme.primary.withValues(
                            alpha: 0.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Guardar',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isRequired;

  const _SectionHeader({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (isRequired) ...[
                    const SizedBox(width: 6),
                    Text(
                      '*',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ],
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final Widget child;

  const _PhotoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.12)),
      ),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}
