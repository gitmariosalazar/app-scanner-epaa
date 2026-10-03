import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application/features/form/presentation/widgets/images_section.dart';
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
  final _meterNumberController = TextEditingController();
  final List<File> _photosFacade = [];
  final List<File> _photosMeter = [];
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final request = UpdateConnectionBasicRequest(
        connectionId: widget.connection.connectionId,
        meterNumber: _meterNumberController.text.trim().isNotEmpty
            ? _meterNumberController.text.trim()
            : null,
        photosFacade: _photosFacade,
        photosMeter: _photosMeter,
        photosFacadeDescriptions: _photosFacade.map((_) => "Fachada").toList(),
        photosMeterDescriptions: _photosMeter.map((_) => "Medidor").toList(),
      );

      final useCase = di.sl<UpdateConnectionBasicUseCase>();
      await useCase(request);

      if (!mounted) return;
      Navigator.pop(context, true); // Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Acometida actualizada correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Actualizar Acometida',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ConnectionInfoCard(connection: widget.connection),
            const SizedBox(height: 24),
            TextField(
              controller: _meterNumberController,
              decoration: InputDecoration(
                labelText: 'Nuevo Número de Medidor (Opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: const Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Fotos de la Fachada (Max 10)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            ImagesSection(
              attachedImages: _photosFacade,
              mode: 'facade',
              onImageAdded: (file) {
                if (_photosFacade.length < 10) {
                  setState(() => _photosFacade.add(file));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Máximo 10 fotos permitidas')),
                  );
                }
              },
              onImageRemoved: (index) {
                setState(() => _photosFacade.removeAt(index));
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Fotos del Medidor (Max 10)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            ImagesSection(
              attachedImages: _photosMeter,
              mode: 'meter',
              onImageAdded: (file) {
                if (_photosMeter.length < 10) {
                  setState(() => _photosMeter.add(file));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Máximo 10 fotos permitidas')),
                  );
                }
              },
              onImageRemoved: (index) {
                setState(() => _photosMeter.removeAt(index));
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                      ),
                    )
                  : const Text(
                      'Guardar Cambios',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
