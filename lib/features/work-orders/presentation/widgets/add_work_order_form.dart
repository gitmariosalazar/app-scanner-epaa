// lib/features/work_orders/presentation/dialogs/add_work_order_responsive_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_application/features/work-orders/data/models/create_work_order_request.dart';
import 'package:flutter_application/features/work-orders/domain/repositories/work_order_repository.dart';
import 'package:flutter_application/features/work-orders/presentation/blocs/create_work_order/create_work_order_bloc.dart';
import 'package:flutter_application/features/work-orders/presentation/blocs/create_work_order/create_work_order_event.dart';
import 'package:flutter_application/features/work-orders/presentation/blocs/create_work_order/create_work_order_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/components/divider/section_divider.dart';
import 'package:flutter_application/components/text/text_field.dart';
import 'package:flutter_application/utils/responsive_utils.dart';
import 'package:flutter_application/utils/screen_type_layout.dart';

class AddWorkOrderResponsiveDialog extends StatefulWidget {
  final CreateWorkOrderBloc bloc;
  final Map<String, dynamic>? prefillData;

  const AddWorkOrderResponsiveDialog({
    super.key,
    required this.bloc,
    this.prefillData,
  });

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
  final _ownerNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _meterNumberController = TextEditingController();

  int? _workOrderTypeId = 2;
  int? _priorityId = 1;
  int? _workOrderStatusId = 1;
  final int _createdUserId = 1;

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
  void initState() {
    super.initState();
    _loadPrefillData();
  }

  void _loadPrefillData() {
    final data = widget.prefillData ?? {};

    _connectionIdController.text = data["connectionId"]?.toString() ?? "";
    _clientIdController.text = data["clientId"]?.toString() ?? "";
    _ownerNameController.text = data["ownerName"]?.toString() ?? "";
    _addressController.text = data["address"]?.toString() ?? "";
    _meterNumberController.text = data["meterNumber"]?.toString() ?? "";

    final desc = data["description"]?.toString();
    _descriptionController.text = desc?.isNotEmpty == true
        ? desc!
        : "Revisar medidor de agua y estado de la conexión...";

    if (_descriptionController.text.length > 20) {
      _priorityId = 3; // Alta
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _connectionIdController.dispose();
    _clientIdController.dispose();
    _ownerNameController.dispose();
    _addressController.dispose();
    _meterNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final maxWidth = isTablet ? 600.0 : context.width * 0.92;

    return BlocProvider.value(
      value: widget.bloc,
      child: BlocConsumer<CreateWorkOrderBloc, CreateWorkOrderState>(
        listener: (context, state) {
          if (state is CreateWorkOrderSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Orden #${state.entity.workOrderId} creada con éxito",
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
              ),
            );
            Navigator.of(context).pop(true); // ← SOLO ESTO CAMBIA
          } else if (state is CreateWorkOrderFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CreateWorkOrderLoading;

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                context.mediumBorderRadiusValue,
              ),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth, minWidth: 300),
              padding: EdgeInsets.all(context.largeSpacing),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(
                  context.mediumBorderRadiusValue,
                ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "O. Trabajo: ${_connectionIdController.text}",
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

                      MinimalSectionDivider(
                        title: 'Información de la Conexión',
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                        isExpanded: false,
                        children: [
                          ResponsiveUtils.vSpace(context, 0.015),
                          _buildIdFieldsRow(),
                          ResponsiveUtils.vSpace(context, 0.03),
                          _buildOwnerAddressFields(),
                          ResponsiveUtils.vSpace(context, 0.03),
                        ],
                      ),
                      context.vSpace(0.04),

                      // Descripción
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          labelText: "Descripción para la orden *",
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
                        validator: (v) =>
                            v == null ? "Selecciona un tipo" : null,
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
                        validator: (v) =>
                            v == null ? "Selecciona prioridad" : null,
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
                        onChanged: (v) =>
                            setState(() => _workOrderStatusId = v),
                        validator: (v) =>
                            v == null ? "Selecciona estado" : null,
                      ),
                      context.vSpace(0.04),

                      // BOTONES
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
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
                          ),
                          context.hSpace(0.04),
                          ElevatedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      final request = CreateWorkOrderRequest(
                                        description: _descriptionController.text
                                            .trim(),
                                        workOrderTypeId: _workOrderTypeId!,
                                        priorityId: _priorityId!,
                                        workOrderStatusId: _workOrderStatusId!,
                                        connectionId: _connectionIdController
                                            .text
                                            .trim(),
                                        clientId: _clientIdController.text
                                            .trim(),
                                        createdUserId: _createdUserId
                                            .toString(),
                                      );

                                      context.read<CreateWorkOrderBloc>().add(
                                        CreateWorkOrderSubmitted(
                                          CreateWorkOrderParams(request),
                                        ),
                                      );
                                    }
                                  },
                            icon: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    Icons.add_task,
                                    size: context.iconMedium,
                                  ),
                            label: Text(
                              isLoading ? "Creando..." : "Crear Orden",
                              style: context.buttonText,
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.largeSpacing,
                                vertical: context.buttonHeight * 0.01,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  context.buttonBorderRadiusValue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIdFieldsRow() {
    return ResponsiveRow(
      rowSpacing: ResponsiveUtils.mediumSpacing(context),
      children: [
        CustomTextField(
          controller: _clientIdController,
          label: 'Cédula de Ciudadanía',
          leftIcon: Icons.pin,
          isReadOnly: true,
        ),
        CustomTextField(
          controller: _meterNumberController,
          label: 'Número de Medidor',
          leftIcon: Icons.water_damage_outlined,
          isReadOnly: true,
        ),
      ],
    );
  }

  Widget _buildOwnerAddressFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: _ownerNameController,
          label: 'Propietario de la Conexión',
          leftIcon: Icons.person_outline,
          isReadOnly: true,
        ),
        ResponsiveUtils.vSpace(context, 0.03),
        CustomTextField(
          controller: _addressController,
          label: 'Dirección de la Conexión',
          leftIcon: Icons.location_on_outlined,
          isReadOnly: true,
        ),
        ResponsiveUtils.vSpace(context, 0.03),
        CustomTextField(
          controller: _connectionIdController,
          label: 'Clave Catastral',
          leftIcon: Icons.cable,
        ),
      ],
    );
  }
}
