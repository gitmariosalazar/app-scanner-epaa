import 'package:flutter/material.dart';
import 'package:flutter_application/features/form/presentation/pages/form_screen.dart';
import 'package:flutter_application/utils/responsive_utils.dart';

Future<Map<String, dynamic>?> showAddWorkOrderDialog(
  BuildContext context,
) async {
  return await showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const AddWorkOrderResponsiveDialog(),
  );
}

class AddWorkOrderResponsiveDialog extends StatefulWidget {
  const AddWorkOrderResponsiveDialog({super.key});

  @override
  State<AddWorkOrderResponsiveDialog> createState() =>
      _AddWorkOrderResponsiveDialogState();
}

class _AddWorkOrderResponsiveDialogState
    extends State<AddWorkOrderResponsiveDialog> {
  final _formKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();
  final _connectionIdController = TextEditingController();
  final _clientIdController = TextEditingController();

  int? _workOrderTypeId = 2;
  int? _priorityId = 1;
  int? _workOrderStatusId = 3;
  final int _createdUserId = 1;

  late AnimationController _animationController;

  // Opciones de los dropdowns
  final List<Map<String, dynamic>> _workOrderTypes = [
    {"id": 1, "name": "Mantenimiento preventivo"},
    {"id": 2, "name": "Reparación"},
    {"id": 3, "name": "Instalación"},
    {"id": 4, "name": "Inspección"},
  ];

  final List<Map<String, dynamic>> _priorities = [
    {"id": 1, "name": "Baja", "color": Colors.green},
    {"id": 2, "name": "Media", "color": Colors.orange},
    {"id": 3, "name": "Alta", "color": Colors.red},
    {"id": 4, "name": "Crítica", "color": Colors.deepPurple},
  ];

  final List<Map<String, dynamic>> _statuses = [
    {"id": 1, "name": "Pendiente"},
    {"id": 2, "name": "En progreso"},
    {"id": 3, "name": "Completada"},
    {"id": 4, "name": "Cancelada"},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _connectionIdController.dispose();
    _clientIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final maxWidth = isTablet ? 600.0 : context.width * 0.92;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.mediumBorderRadiusValue),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth, minWidth: 300),
        padding: EdgeInsets.all(context.largeSpacing),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(context.mediumBorderRadiusValue),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 25),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título + Cerrar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Generar Orden de Trabajo",
                      style: context.titleLarge.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: context.iconMedium),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                context.vSpace(0.04),

                // Descripción
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    labelText: "Descripción *",
                    hintText: "Describe el trabajo a realizar...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        context.smallBorderRadiusValue,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.description_outlined),
                    contentPadding: EdgeInsets.all(context.mediumSpacing),
                  ),
                  style: context.bodyLarge,
                  validator: (v) =>
                      v?.trim().isEmpty ?? true ? "Requerido" : null,
                ),
                context.vSpace(0.04),

                // Tipo de orden
                DropdownButtonFormField<int>(
                  value: _workOrderTypeId,
                  decoration: InputDecoration(
                    labelText: "Tipo de orden *",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        context.smallBorderRadiusValue,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.build_outlined),
                    contentPadding: EdgeInsets.all(context.mediumSpacing),
                  ),
                  style: context.bodyLarge,
                  items: _workOrderTypes
                      .map(
                        (e) => DropdownMenuItem(
                          value: e["id"] as int,
                          child: Text(e["name"] as String),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _workOrderTypeId = v),
                  validator: (v) => v == null ? "Selecciona un tipo" : null,
                ),
                context.vSpace(0.04),

                // Prioridad
                DropdownButtonFormField<int>(
                  value: _priorityId,
                  decoration: InputDecoration(
                    labelText: "Prioridad *",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        context.smallBorderRadiusValue,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.flag_outlined),
                    contentPadding: EdgeInsets.all(context.mediumSpacing),
                  ),
                  style: context.bodyLarge,
                  items: _priorities
                      .map(
                        (p) => DropdownMenuItem(
                          value: p["id"] as int,
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 14,
                                color: p["color"] as Color,
                              ),
                              SizedBox(width: context.smallSpacing),
                              Text(p["name"] as String),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _priorityId = v),
                  validator: (v) => v == null ? "Selecciona prioridad" : null,
                ),
                context.vSpace(0.04),

                // Estado
                DropdownButtonFormField<int>(
                  value: _workOrderStatusId,
                  decoration: InputDecoration(
                    labelText: "Estado inicial *",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        context.smallBorderRadiusValue,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.sync_outlined),
                    contentPadding: EdgeInsets.all(context.mediumSpacing),
                  ),
                  style: context.bodyLarge,
                  items: _statuses
                      .map(
                        (e) => DropdownMenuItem(
                          value: e["id"] as int,
                          child: Text(e["name"] as String),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _workOrderStatusId = v),
                  validator: (v) => v == null ? "Selecciona estado" : null,
                  enableFeedback: false,
                ),
                context.vSpace(0.04),

                // Connection ID
                TextFormField(
                  controller: _connectionIdController,
                  decoration: InputDecoration(
                    labelText: "Connection ID",
                    hintText: "Ej: 23-42",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        context.smallBorderRadiusValue,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.link_outlined),
                    contentPadding: EdgeInsets.all(context.mediumSpacing),
                  ),
                  style: context.bodyLarge,
                ),
                context.vSpace(0.04),

                // Client ID
                TextFormField(
                  controller: _clientIdController,
                  decoration: InputDecoration(
                    labelText: "Client ID",
                    hintText: "Ej: 1000202729",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        context.smallBorderRadiusValue,
                      ),
                    ),
                    prefixIcon: const Icon(Icons.person_outline),
                    contentPadding: EdgeInsets.all(context.mediumSpacing),
                  ),
                  style: context.bodyLarge,
                ),
                context.vSpace(0.08),

                // Botones
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Botton Cancelar
                    OutlinedButton.icon(
                      icon: Icon(
                        Icons.cancel_outlined,
                        size: context.iconMedium,
                      ),
                      label: Text("Cancelar", style: context.buttonText),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.largeSpacing,
                          vertical: context.buttonHeight * 0.1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            context.buttonBorderRadiusValue,
                          ),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    context.hSpace(0.04),
                    ElevatedButton.icon(
                      icon: Icon(Icons.add_task, size: context.iconMedium),
                      label: Text("Crear Orden", style: context.buttonText),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.largeSpacing,
                          vertical: context.buttonHeight * 0.8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            context.buttonBorderRadiusValue,
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final data = {
                            "description": _descriptionController.text.trim(),
                            "workOrderTypeId": _workOrderTypeId,
                            "priorityId": _priorityId,
                            "workOrderStatusId": _workOrderStatusId,
                            "connectionId":
                                _connectionIdController.text.trim().isEmpty
                                ? null
                                : _connectionIdController.text.trim(),
                            "clientId": _clientIdController.text.trim().isEmpty
                                ? null
                                : _clientIdController.text.trim(),
                            "createdUserId": _createdUserId,
                          };

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Orden de trabajo creada"),
                            ),
                          );

                          Navigator.of(context).pop(data);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
