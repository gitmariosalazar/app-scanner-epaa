// lib/features/form/presentation/pages/form_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_application/components/card/title_card.dart';
import 'package:flutter_application/components/divider/section_divider.dart';
import 'package:flutter_application/features/form/presentation/services/photo_reading_service.dart';
import 'package:flutter_application/features/form/presentation/widgets/action_button_exit_row.dart';
import 'package:flutter_application/features/form/presentation/widgets/action_buttons_row.dart';
import 'package:flutter_application/features/form/presentation/widgets/consumption_row.dart';
import 'package:flutter_application/features/form/presentation/widgets/date_period_card.dart';
import 'package:flutter_application/features/form/presentation/widgets/description_field.dart';
import 'package:flutter_application/features/form/presentation/widgets/header_row.dart';
import 'package:flutter_application/features/form/presentation/widgets/id_fields_row.dart';
import 'package:flutter_application/features/form/presentation/widgets/images_section.dart';
import 'package:flutter_application/features/form/presentation/widgets/owner_address_fields.dart';
import 'package:flutter_application/features/form/presentation/widgets/reading_current_row.dart';
import 'package:flutter_application/features/form/presentation/widgets/reading_fields_row.dart';
import 'package:flutter_application/features/properties/list/domain/usecases/get_connection_with_properties.dart';
import 'package:flutter_application/features/reading/domain/usecases/create_reading_usecase.dart';
import 'package:flutter_application/features/properties/form/update/data/models/dto/request/change_meter_request.dart';
import 'package:flutter_application/features/incidents/presentation/cubit/incident_cubit.dart';
import 'package:flutter_application/features/incidents/presentation/cubit/incident_state.dart';
import 'package:flutter_application/features/incidents/domain/entities/incident-category.model.dart';
import 'package:flutter_application/features/incidents/domain/dto/request/create_incident_request.dart';
import 'package:flutter_application/features/reading/data/model/create_reading_request.dart';
import 'package:flutter_application/features/reading/domain/entities/reading.dart';
import 'package:flutter_application/utils/consumption_utils.dart';
import 'package:flutter_application/utils/dialog_utils.dart';
import 'package:flutter_application/utils/responsive_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/form/presentation/blocs/readings/form_bloc.dart'
    as form_bloc;
import 'package:go_router/go_router.dart';
import 'package:flutter_application/components/button/epaa_extended_fab.dart';
import 'package:flutter_application/core/di/injection.dart' as di;

class AppColors {
  static const primary = Color(0xFF0288D1);
  static const secondary = Color(0xFF4CAF50);
  static const error = Color(0xFFE57373);
  static const background = Color(0xFFF5F7FA);
  static const cardBackground = Colors.white;
  static const cardSecondaryBackground = Color(0xFFE3F2FD);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
}

class FormScreen extends StatefulWidget {
  final List<Reading> reading;
  final String mode;

  const FormScreen({super.key, required this.reading, required this.mode});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final List<File> _attachedImages = [];
  final _connectionIdController = TextEditingController();
  final _connectionOwnerController = TextEditingController();
  final _readingIdController = TextEditingController();
  final _cardIdController = TextEditingController();
  final _currentReadingController = TextEditingController();
  final _previousReadingController = TextEditingController();
  final _sectorConnectionController = TextEditingController();
  final _addressConnectionController = TextEditingController();
  final _accountConnectionController = TextEditingController();
  final _cadastralKeyConnectionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _averageConsumptionController = TextEditingController();
  final _currentConsumptionController = TextEditingController();
  final _previousConsumptionController = TextEditingController();
  final _readingValueController = TextEditingController();
  final _previousReadingDate = TextEditingController();
  final _newCurrentReadingController = TextEditingController();
  final _meterNumberController = TextEditingController();
  final _monthReadingController = TextEditingController();
  final _startDatePeriodController = TextEditingController();
  final _endDatePeriodController = TextEditingController();
  final _now = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late ConsumptionVisuals _consumptionVisuals;
  String? _errorMessage;
  String? _successMessage;

  // Nuevos campos para actualización de medidor
  String? _condicionMedidor;
  String? _estadoFisico;
  final _nuevoMedidorController = TextEditingController();
  bool hasCurrentReading = false;
  String? connectionStateDescription;
  String? connectionStateName;
  bool? permitReading;
  int? connectionStateId;

  // Incidente de Ruta
  int? _selectedRouteIncidentId;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupListeners();
    _setupAnimations();

    // Cargar categorías de incidentes (novedades de ruta)
    context.read<IncidentCubit>().loadIncidentCategories();
  }

  void _initializeData() {
    final r = widget.reading;
    hasCurrentReading = r[0].hasCurrentReading!;
    _connectionIdController.text = r[0].cadastralKey!;
    _connectionOwnerController.text = r[0].clientName!;
    _readingIdController.text = r[0].readingId.toString();
    _cardIdController.text = r[0].cardId.toString();
    _currentReadingController.text = r[0].currentReading!.toString();
    _previousReadingController.text = r[0].previousReading.toString();
    _sectorConnectionController.text = r[0].sector.toString();
    _addressConnectionController.text = r[0].address.toString();
    _accountConnectionController.text = r[0].account.toString();
    _cadastralKeyConnectionController.text = r[0].cadastralKey.toString();
    _descriptionController.text = '';
    _averageConsumptionController.text = r[0].averageConsumption.toString();
    _readingValueController.text = r[0].readingValue.toString();
    _meterNumberController.text = r[0].meterNumber.toString();
    _nuevoMedidorController.text = r[0].meterNumber.toString();
    _previousReadingDate.text = r[0].previousReadingDate!.toString();
    _monthReadingController.text = r[0].monthReading.toString();
    _startDatePeriodController.text = r[0].startDatePeriod!.toIso8601String();
    _endDatePeriodController.text = r[0].endDatePeriod!.toIso8601String();
    connectionStateDescription = r[0].connectionStateDescription;
    connectionStateName = r[0].connectionStateName;
    permitReading = r[0].permitReading;
    connectionStateId = r[0].connectionStateId;
    _newCurrentReadingController.text = '';
    _currentConsumptionController.text = ConsumptionUtils.calculateConsumption(
      _newCurrentReadingController.text,
      _currentReadingController.text,
    );
    _previousConsumptionController.text = ConsumptionUtils.calculateConsumption(
      _currentReadingController.text,
      _previousReadingController.text,
    );
    _updateConsumptionVisuals();
  }

  void _setupListeners() {
    _newCurrentReadingController.addListener(_updateCurrentConsumption);
    _previousReadingController.addListener(_updateCurrentConsumption);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _updateCurrentConsumption() {
    final value = ConsumptionUtils.calculateConsumption(
      _newCurrentReadingController.text,
      _currentReadingController.text,
    );
    _currentConsumptionController.text = value;
    _updateConsumptionVisuals();
    if (mounted) setState(() {});
  }

  void _updateConsumptionVisuals() {
    _consumptionVisuals = ConsumptionUtils.setConsumptionVisuals(
      currentConsumption: double.tryParse(_currentConsumptionController.text),
      averageConsumption: double.tryParse(_averageConsumptionController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: const Text(
            'Detalle de La Acometida',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.12),
                Theme.of(context).colorScheme.surface,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: ResponsiveUtils.screenPadding(context).copyWith(
              top: ResponsiveUtils.scaleHeight(context, 0.035),
              bottom: ResponsiveUtils.scaleHeight(context, 0.1),
            ),
            child: BlocConsumer<form_bloc.FormBloc, form_bloc.FormState>(
              listener: (context, state) {
                if (!mounted) return;
                if (state is form_bloc.FormSuccess) {
                  _handleSuccess(context, state);
                } else if (state is form_bloc.ChangeMeterSuccess) {
                  DialogUtils.showResultDialog(
                    context,
                    '¡Medidor cambiado con éxito!',
                    Icons.check_circle,
                    Theme.of(context).colorScheme.secondary,
                  );
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) Navigator.of(context).pop(true);
                  });
                } else if (state is form_bloc.MeterConflictState) {
                  _showMeterConflictDialog(state);
                } else if (state is form_bloc.FormFailure) {
                  setState(() => _errorMessage = state.message);
                }
              },
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        HeaderRow(
                          connectionIdController: _connectionIdController,
                          averageConsumptionController:
                              _averageConsumptionController,
                        ),
                        ResponsiveUtils.vSpace(context, 0.03),
                        ConsumptionRow(
                          previousConsumptionController:
                              _previousConsumptionController,
                          currentConsumptionController:
                              _currentConsumptionController,
                          previousReadingDate: _previousReadingDate,
                          consumptionVisuals: _consumptionVisuals,
                          now: _now,
                        ),
                        ResponsiveUtils.vSpace(context, 0.03),
                        if (permitReading == true) ...[
                          if (hasCurrentReading == true) ...[
                            _buildMeterInspectionSection(context),
                            ResponsiveUtils.vSpace(context, 0.03),
                            _buildRouteIncidentSection(context),
                            ReadingFieldsRow(
                              currentReadingController:
                                  _currentReadingController,
                              newCurrentReadingController:
                                  _newCurrentReadingController,
                              monthReadingController: _monthReadingController,
                            ),
                            ResponsiveUtils.vSpace(context, 0.015),
                            DescriptionField(
                              descriptionController: _descriptionController,
                              mode: widget.mode,
                            ),
                            ResponsiveUtils.vSpace(context, 0.015),
                            ImagesSection(
                              attachedImages: _attachedImages,
                              mode: widget.mode,
                              onImageAdded: (file) {
                                if (mounted) {
                                  setState(() {
                                    _attachedImages.add(file);
                                    // Ya no limpiamos error por falta de imagen
                                  });
                                }
                              },
                              onImageRemoved: (index) {
                                if (mounted) {
                                  setState(
                                    () => _attachedImages.removeAt(index),
                                  );
                                }
                              },
                            ),
                            if (_errorMessage != null ||
                                _successMessage != null)
                              Padding(
                                padding: EdgeInsets.only(
                                  top: ResponsiveUtils.scaleHeight(
                                    context,
                                    0.01,
                                  ),
                                  left: ResponsiveUtils.scaleWidth(
                                    context,
                                    0.03,
                                  ),
                                  right: ResponsiveUtils.scaleWidth(
                                    context,
                                    0.03,
                                  ),
                                ),
                                child: Text(
                                  _errorMessage ?? _successMessage ?? "",
                                  style: ResponsiveUtils.bodySmall(context)
                                      .copyWith(
                                        color: _errorMessage != null
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.error
                                            : Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ResponsiveUtils.vSpace(context, 0.02),
                            ActionButtonsRow(
                              state: state,
                              onSavePressed: () =>
                                  _onSavePressed(context, state),
                              prefillData: {
                                "connectionId": _connectionIdController.text
                                    .trim(),
                                "clientId": _cardIdController.text.trim(),
                                "ownerName": _connectionOwnerController.text
                                    .trim(),
                                "address": _addressConnectionController.text
                                    .trim(),
                                "meterNumber": _meterNumberController.text
                                    .trim(),
                                "description":
                                    _descriptionController.text.isEmpty
                                    ? "Revisar medidor - lectura tomada manualmente"
                                    : _descriptionController.text.trim(),
                              },
                              animationController: _animationController,
                              scaleAnimation: _scaleAnimation,
                            ),
                          ] else ...[
                            TitledCard(
                              title: 'Lectura Ya Registrada',
                              elevation: ResponsiveUtils.cardElevation(context),
                              bottomRightIcon: Icon(
                                Icons.check_circle_outline,
                                color: Theme.of(context).colorScheme.primary,
                                size: ResponsiveUtils.iconSmall(context),
                              ),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              children: [
                                ReadingCurrentRow(reading: widget.reading),
                                ResponsiveUtils.vSpace(context, 0.03),
                                ActionButtonExitRow(
                                  prefillData: {
                                    "connectionId": _connectionIdController.text
                                        .trim(),
                                    "clientId": _cardIdController.text.trim(),
                                    "ownerName": _connectionOwnerController.text
                                        .trim(),
                                    "address": _addressConnectionController.text
                                        .trim(),
                                    "meterNumber": _meterNumberController.text
                                        .trim(),
                                    "description":
                                        _descriptionController.text.isEmpty
                                        ? "Revisar medidor - lectura tomada manualmente"
                                        : _descriptionController.text.trim(),
                                  },
                                  animationController: _animationController,
                                  scaleAnimation: _scaleAnimation,
                                ),
                              ],
                            ),
                          ],
                        ] else ...[
                          // ── Banner: Conexión bloqueada ──────────────────
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFB71C1C), Color(0xFFEF5350)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.30),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsiveUtils.scaleWidth(
                                context,
                                0.04,
                              ),
                              vertical: ResponsiveUtils.scaleHeight(
                                context,
                                0.018,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: Colors.white24,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.block_rounded,
                                    color: Colors.white,
                                    size: ResponsiveUtils.iconSmall(context),
                                  ),
                                ),
                                SizedBox(
                                  width: ResponsiveUtils.scaleWidth(
                                    context,
                                    0.03,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Conexión bloqueada para lectura',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Esta conexión no puede recibir nuevas lecturas en su estado actual.',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.85,
                                          ),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: ResponsiveUtils.scaleWidth(
                                    context,
                                    0.025,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.cancel_outlined,
                                        color: Colors.white,
                                        size: 11,
                                      ),
                                      const SizedBox(width: 5),
                                      const Text(
                                        'Lectura no\npermitida',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ResponsiveUtils.vSpace(context, 0.018),
                          // ── Tarjeta única: Estado + Info ──────────────────
                          Card(
                            elevation: ResponsiveUtils.cardElevation(context),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.error.withValues(alpha: 0.18),
                              ),
                            ),
                            color: Theme.of(context).colorScheme.errorContainer,
                            child: Padding(
                              padding: EdgeInsets.all(
                                ResponsiveUtils.scaleWidth(context, 0.045),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ─ Estado ────────────────────────────────────
                                  Text(
                                    'ESTADO ACTUAL DE LA CONEXIÓN',
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.4,
                                    ),
                                  ),
                                  SizedBox(
                                    height: ResponsiveUtils.scaleHeight(
                                      context,
                                      0.01,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.bookmark_outline,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          connectionStateName?.toUpperCase() ??
                                              'DESCONOCIDO',
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.error,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.6,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: ResponsiveUtils.scaleHeight(
                                      context,
                                      0.01,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.tertiaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.description_outlined,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            connectionStateDescription ??
                                                'Sin descripción disponible.',
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: ResponsiveUtils.scaleHeight(
                                      context,
                                      0.018,
                                    ),
                                  ),
                                  // ─ Divisor ─────────────────────────────────
                                  Divider(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                                    height: 1,
                                  ),
                                  SizedBox(
                                    height: ResponsiveUtils.scaleHeight(
                                      context,
                                      0.018,
                                    ),
                                  ),
                                  // ─ Fila 1: Cliente / Clave / Sector ─────────
                                  Row(
                                    children: [
                                      _connInfoCell(
                                        context,
                                        icon: Icons.person_outline,
                                        label: 'CLIENTE',
                                        value:
                                            widget.reading[0].clientName ?? '-',
                                      ),
                                      _connInfoDivider(),
                                      _connInfoCell(
                                        context,
                                        icon: Icons.vpn_key_outlined,
                                        label: 'CLAVE CATASTRAL',
                                        value:
                                            widget.reading[0].cadastralKey ??
                                            '-',
                                      ),
                                      _connInfoDivider(),
                                      _connInfoCell(
                                        context,
                                        icon: Icons.location_on_outlined,
                                        label: 'SECTOR',
                                        value:
                                            widget.reading[0].sector
                                                ?.toString() ??
                                            '-',
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: ResponsiveUtils.scaleHeight(
                                      context,
                                      0.012,
                                    ),
                                  ),
                                  Divider(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outlineVariant,
                                    height: 1,
                                  ),
                                  SizedBox(
                                    height: ResponsiveUtils.scaleHeight(
                                      context,
                                      0.012,
                                    ),
                                  ),
                                  // ─ Fila 2: Cuenta / Consumo / ID ───────────
                                  Row(
                                    children: [
                                      _connInfoCell(
                                        context,
                                        icon: Icons.tag,
                                        label: 'CUENTA',
                                        value:
                                            widget.reading[0].account
                                                ?.toString() ??
                                            '-',
                                      ),
                                      _connInfoDivider(),
                                      _connInfoCell(
                                        context,
                                        icon: Icons.bar_chart_rounded,
                                        label: 'CONSUMO PROMEDIO',
                                        value:
                                            '${(double.tryParse(widget.reading[0].averageConsumption ?? '0') ?? 0.0).toStringAsFixed(2)} m³',
                                      ),
                                      _connInfoDivider(),
                                      _connInfoCell(
                                        context,
                                        icon: Icons.badge_outlined,
                                        label: 'IDENTIFICACIÓN',
                                        value:
                                            widget.reading[0].cardId
                                                ?.toString() ??
                                            '-',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          ResponsiveUtils.vSpace(context, 0.02),
                          ActionButtonExitRow(
                            prefillData: {
                              "connectionId": _connectionIdController.text
                                  .trim(),
                              "clientId": _cardIdController.text.trim(),
                              "ownerName": _connectionOwnerController.text
                                  .trim(),
                              "address": _addressConnectionController.text
                                  .trim(),
                              "meterNumber": _meterNumberController.text.trim(),
                              "description": _descriptionController.text.isEmpty
                                  ? "Revisar medidor - lectura tomada manualmente"
                                  : _descriptionController.text.trim(),
                            },
                            animationController: _animationController,
                            scaleAnimation: _scaleAnimation,
                          ),
                        ],
                        ResponsiveUtils.vSpace(context, 0.03),
                        MinimalSectionDivider(
                          title: 'Información Adicional',
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.25),
                          children: [
                            ResponsiveUtils.vSpace(context, 0.015),
                            IdFieldsRow(
                              cardIdController: _cardIdController,
                              meterNumberController: _meterNumberController,
                            ),
                            ResponsiveUtils.vSpace(context, 0.03),
                            OwnerAddressFields(
                              connectionOwnerController:
                                  _connectionOwnerController,
                              addressConnectionController:
                                  _addressConnectionController,
                            ),
                            ResponsiveUtils.vSpace(context, 0.03),
                            DatePeriodCard(
                              startDatePeriodController:
                                  _startDatePeriodController,
                              endDatePeriodController: _endDatePeriodController,
                            ),
                          ],
                        ),
                        ResponsiveUtils.vSpace(context, 0.2),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        floatingActionButton: EpaaExtendedFab(
          enable: false,
          disabledTooltip: 'Conexión bloqueada — no disponible',
          icon: const Icon(Icons.edit_note_rounded),
          label: const Text(
            'Actualizar Coordenadas',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          onPressed: () async {
            final acometidaId = _connectionIdController.text.trim();

            if (acometidaId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ID de acometida no válido'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );

            try {
              final connection = await di.sl<GetConnectionWithProperties>()(
                acometidaId,
              );

              if (!mounted) return;
              Navigator.pop(this.context);

              this.context.push(
                '/update-form',
                extra: {'connection': connection, 'mode': 'manual'},
              );
            } catch (e) {
              if (!mounted) return;
              Navigator.pop(this.context);
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text('Error al cargar datos: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildRouteIncidentSection(BuildContext context) {
    return BlocBuilder<IncidentCubit, IncidentState>(
      builder: (context, state) {
        List<IncidentTypeModel> routeIncidents = [];
        if (state is IncidentCategoriesLoaded) {
          // Filtrar solo la categoría 8 (Incidentes de Ruta)
          final routeCategory = state.categories
              .where((c) => c.id == 8)
              .toList();
          if (routeCategory.isNotEmpty) {
            routeIncidents = routeCategory.first.incidentTypes;
          }
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Incidentes / Novedades de Ruta',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  validator: (value) => value == null ? 'Obligatorio' : null,
                  decoration: InputDecoration(
                    labelText: 'Seleccione Novedad *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  value:
                      routeIncidents.any(
                        (i) => i.typeCode == _selectedRouteIncidentId,
                      )
                      ? _selectedRouteIncidentId
                      : null,
                  items: routeIncidents.map((incident) {
                    return DropdownMenuItem<int>(
                      value: incident.typeCode,
                      child: Text(
                        incident.typeName,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRouteIncidentId = value;
                    });
                  },
                  icon: state is IncidentLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_drop_down),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMeterInspectionSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inspección del Medidor',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    validator: (value) => value == null ? 'Obligatorio' : null,
                    decoration: InputDecoration(
                      labelText: 'Condición del Medidor *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    value: _condicionMedidor,
                    items: const [
                      DropdownMenuItem(
                        value: 'NUEVO',
                        child: Text('NUEVO', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: 'ANTIGUO',
                        child: Text('ANTIGUO', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: 'NO_IDENTIFICADO',
                        child: Text(
                          'NO IDENTIFICADO',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (mounted) {
                        setState(() {
                          _condicionMedidor = val;
                          if (val == 'NO_IDENTIFICADO') {
                            _nuevoMedidorController.text = 'S/N';
                            _estadoFisico = 'NO_IDENTIFICADO';
                          } else {
                            if (_nuevoMedidorController.text == 'S/N') {
                              _nuevoMedidorController.clear();
                            }
                            if (_estadoFisico == 'NO_IDENTIFICADO') {
                              _estadoFisico = null;
                            }
                          }
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    validator: (value) => value == null ? 'Obligatorio' : null,
                    decoration: InputDecoration(
                      labelText: 'Estado Físico *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    value: _estadoFisico,
                    items: const [
                      DropdownMenuItem(
                        value: 'BUENO',
                        child: Text('BUENO', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: 'REGULAR',
                        child: Text('REGULAR', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: 'MALO',
                        child: Text('MALO', style: TextStyle(fontSize: 12)),
                      ),
                      DropdownMenuItem(
                        value: 'DESTRUIDO',
                        child: Text(
                          'DESTRUIDO',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'NO_IDENTIFICADO',
                        child: Text(
                          'NO IDENTIFICADO',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (mounted) {
                        setState(() {
                          _estadoFisico = val;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TitledCard(
              title: 'Número Registrado en Sistema',
              elevation: ResponsiveUtils.cardElevation(context),
              bottomRightIcon: Icon(
                Icons.water_drop,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.7),
                size: ResponsiveUtils.iconSmall(context),
              ),
              titleStyle: ResponsiveUtils.titleSmall(context),
              children: [
                Text(
                  _meterNumberController.text.isEmpty
                      ? 'S/N'
                      : '${_meterNumberController.text}',
                  style: ResponsiveUtils.titleMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            const SizedBox(height: 16),
            TextFormField(
              controller: _nuevoMedidorController,
              decoration: InputDecoration(
                labelText: 'Número de Medidor Físico *',
                hintText: 'Ej. 123456789 (o S/N)',
                prefixIcon: const Icon(
                  Icons.speed,
                ), // Icono de medidor/velocímetro
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Obligatorio. Ingrese el número o S/N';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers: blocked-connection info grid ────────────────────────────────

  Widget _connInfoCell(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 13,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _connInfoDivider() {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }

  void _handleSuccess(BuildContext context, form_bloc.FormSuccess state) async {
    DialogUtils.showResultDialog(
      context,
      '¡Formulario enviado con éxito!',
      Icons.check_circle,
      AppColors.secondary,
    );
    if (_attachedImages.isNotEmpty) {
      try {
        await submitPhotoReading(
          context: context,
          images: _attachedImages,
          readingId: state.data.readingId ?? 0,
          cadastralKey: state.data.cadastralKey ?? '',
          description: state.data.novelty ?? 'Sin descripción',
          mode: widget.mode,
        );
        if (mounted) {
          setState(() {
            _attachedImages.clear();
            _successMessage = 'Imágenes subidas con éxito.';
            _errorMessage = null;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _errorMessage = 'Error al subir imágenes: $e');
        }
      }
    }
  }

  void _showGpsSubmissionError(String message) {
    if (!mounted) return;

    setState(() => _errorMessage = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<bool> _ensureGpsEnabledForSubmission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showGpsSubmissionError('Activa el GPS para enviar la lectura.');
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _showGpsSubmissionError(
          'Debes conceder permiso de ubicación para enviar la lectura.',
        );
        return false;
      }

      if (permission == LocationPermission.deniedForever) {
        _showGpsSubmissionError(
          'El permiso de ubicación está bloqueado. Actívalo desde Ajustes.',
        );
        return false;
      }

      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      _showGpsSubmissionError(
        'No se pudo verificar el GPS. Actívalo e inténtalo de nuevo.',
      );
      return false;
    }
  }

  Future<void> _onSavePressed(
    BuildContext context,
    form_bloc.FormState state,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _errorMessage = null);

    ChangeMeterRequest? changeMeterReq;
    CreateIncidentRequest? incidentReq;
    CreateReadingRequest? readingReq;

    final validImages = _attachedImages
        .where((file) => file.existsSync())
        .toList();

    if (validImages.isEmpty) {
      setState(
        () => _errorMessage =
            'Debe adjuntar al menos una foto obligatoriamente para continuar.',
      );
      return;
    }

    final inputNumeroMedidor = _nuevoMedidorController.text.trim();
    final numeroSistema = _meterNumberController.text.trim();
    final currentDesc = _descriptionController.text.trim();

    // Evitar problemas de unicidad en la BD convirtiendo 'S/N' en 'CLAVECATASTRAL-S/N'
    final isSinNumero =
        inputNumeroMedidor.toUpperCase() == 'S/N' ||
        inputNumeroMedidor.toUpperCase() == 'S/N.';
    final numeroMedidorFinal = isSinNumero
        ? '${_cadastralKeyConnectionController.text}-S/N'
        : inputNumeroMedidor;

    if (inputNumeroMedidor.isNotEmpty) {
      String extraDesc = '';
      if (numeroMedidorFinal == numeroSistema ||
          inputNumeroMedidor == numeroSistema) {
        extraDesc =
            'Inspección: El número del medidor físico coincide exactamente con el registrado en el sistema ($numeroSistema). Anterior: ${_meterNumberController.text} Nuevo: ${_nuevoMedidorController.text} Lectura Anterior: ${_currentReadingController.text} Lectura Actual: ${_newCurrentReadingController.text}';
      } else if (isSinNumero) {
        extraDesc =
            'Inspección: El medidor físico no tiene número visible o es ilegible (S/N). Se registró como $numeroMedidorFinal. Anterior: ${_meterNumberController.text} Nuevo: ${_nuevoMedidorController.text} Lectura Anterior: ${_currentReadingController.text} Lectura Actual: ${_newCurrentReadingController.text}';
      } else {
        extraDesc =
            'Inspección: El número del medidor físico encontrado ($inputNumeroMedidor) es diferente al registrado en el sistema ($numeroSistema). Anterior: ${_meterNumberController.text} Nuevo: ${_nuevoMedidorController.text} Lectura Anterior: ${_currentReadingController.text} Lectura Actual: ${_newCurrentReadingController.text}';
      }

      _descriptionController.text = currentDesc.isEmpty
          ? extraDesc
          : '$currentDesc | $extraDesc';
    }

    if (inputNumeroMedidor.isNotEmpty &&
        numeroMedidorFinal != numeroSistema &&
        inputNumeroMedidor != numeroSistema) {
      final meterDetail = MeterChangeDetail(
        numeroMedidor: numeroMedidorFinal.isNotEmpty
            ? numeroMedidorFinal
            : null,
        claveCatastral: _cadastralKeyConnectionController.text,
        observaciones: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        medidorAnterior: OldMeterData(
          numeroMedidor: _meterNumberController.text,
          ultimaLectura: double.tryParse(_currentReadingController.text),
          fechaUltimaLectura: DateTime.now().toIso8601String(),
        ),
        medidorNuevo: NewMeterData(
          numeroMedidor: numeroMedidorFinal.isNotEmpty
              ? numeroMedidorFinal
              : null,
          lecturaAnterior: 0.0,
          lecturaActual: 0.0,
          fechaUltimaLectura: DateTime.now().toIso8601String(),
        ),
      );

      changeMeterReq = ChangeMeterRequest(
        connectionId: _connectionIdController.text,
        changeDetail: meterDetail,
        images: validImages,
        imageDescriptions: [],
      );
    }

    final enteredReadingStr = _newCurrentReadingController.text;
    final previousReadingStr = _currentReadingController.text;

    final isSameMeter =
        _nuevoMedidorController.text.trim() ==
        _meterNumberController.text.trim();

    if (enteredReadingStr.isNotEmpty && isSameMeter) {
      if (enteredReadingStr.isNotEmpty && previousReadingStr.isNotEmpty) {
        final enteredReading = double.tryParse(enteredReadingStr) ?? 0.0;
        final previousReading = double.tryParse(previousReadingStr) ?? 0.0;

        if (enteredReading < previousReading) {
          if (_descriptionController.text.trim().isEmpty ||
              _attachedImages.isEmpty) {
            setState(
              () => _errorMessage =
                  'La lectura ingresada es menor a la anterior. Debe ingresar una descripción o adjuntar al menos una foto obligatoriamente.',
            );
            return;
          }
          if (_descriptionController.text.trim().isEmpty) {
            setState(
              () => _errorMessage =
                  'La lectura ingresada es menor a la anterior. Debe ingresar una descripción obligatoriamente.',
            );
            return;
          }
          if (_attachedImages.isEmpty) {
            setState(
              () => _errorMessage =
                  'La lectura ingresada es menor a la anterior. Debe adjuntar al menos una foto obligatoriamente.',
            );
            return;
          }
        }
      }
    }

    final canSubmitWithGps = await _ensureGpsEnabledForSubmission();
    if (!canSubmitWithGps) return;

    LocationCapture? capture;
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      capture = LocationCapture(
        lat: position.latitude,
        lng: position.longitude,
      );
    } catch (e) {
      _showGpsSubmissionError(
        'No se pudo obtener la ubicación actual. Verifica el GPS e inténtalo de nuevo.',
      );
      return;
    }

    if (!mounted) return;

    if (_selectedRouteIncidentId != null) {
      incidentReq = CreateIncidentRequest(
        connectionId: _connectionIdController.text,
        incidentTypeId: _selectedRouteIncidentId!,
        reportDescription: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : 'Incidente reportado en ruta de lectura: Actualizacion del número de medidor: anterior: ${_meterNumberController.text}, nuevo: ${_nuevoMedidorController.text}. Lectura anterior: ${_currentReadingController.text}, Lectura actual: ${_newCurrentReadingController.text}',
        referenceAddress: _addressConnectionController.text,
        reportOrigin: 'LECTURISTA',
        priority: 'MEDIA',
        latitude: capture.lat,
        longitude: capture.lng,
        images: validImages,
        condicionMedidor: _condicionMedidor,
        estadoFisico: _estadoFisico,
      );
    }

    if (enteredReadingStr.isNotEmpty) {
      readingReq = CreateReadingRequest(
        novelty: _descriptionController.text,
        currentReading: double.parse(enteredReadingStr),
        previousReading: double.parse(
          previousReadingStr.isEmpty ? '0' : previousReadingStr,
        ),
        rentalIncomeCode: 0,
        incomeCode: 0,
        cadastralKey: _cadastralKeyConnectionController.text,
        sector: int.parse(
          _sectorConnectionController.text.isEmpty
              ? '0'
              : _sectorConnectionController.text,
        ),
        account: int.parse(
          _accountConnectionController.text.isEmpty
              ? '0'
              : _accountConnectionController.text,
        ),
        readingValue: double.parse('0'),
        connectionId: _connectionIdController.text,
        sewerRate: 0.0,
        averageConsumption:
            double.tryParse(_averageConsumptionController.text) ?? 0.0,
        previousMonthReading: _monthReadingController.text,
        readingLocation: capture,
      );
    }

    if (changeMeterReq == null && incidentReq == null && readingReq == null) {
      setState(
        () => _errorMessage =
            'Debe ingresar una lectura, un cambio de medidor o un incidente para guardar.',
      );
      return;
    }

    await DialogUtils.showConfirmationDialog(
      context,
      onConfirm: () async {
        if (!mounted) return false;
        final stillReadyForGps = await _ensureGpsEnabledForSubmission();
        if (!stillReadyForGps) return false;

        context.read<form_bloc.FormBloc>().add(
          form_bloc.SaveCompleteFormEvent(
            readingRequest: readingReq,
            changeMeterRequest: changeMeterReq,
            incidentRequest: incidentReq,
          ),
        );
        return true;
      },
      fields: [
        {'label': 'ID de Conexión', 'value': _connectionIdController.text},
        {'label': 'Propietario', 'value': _connectionOwnerController.text},
        {'label': 'Dirección', 'value': _addressConnectionController.text},
        {
          'label': 'Descripción',
          'value': _descriptionController.text.isEmpty
              ? 'Sin descripción'
              : _descriptionController.text,
        },
        {
          'label': 'Número de Imágenes Adjuntas',
          'value': _attachedImages.length.toString(),
        },
        {
          'label': 'Modo de Envío',
          'value': widget.mode == 'manual' ? 'Manual' : 'Escaneo',
        },
        {
          'label': 'Lectura Anterior',
          'value': _currentReadingController.text.isEmpty
              ? 'Sin lectura anterior'
              : _currentReadingController.text,
        },
        {
          'label': 'Lectura Actual',
          'value': _newCurrentReadingController.text.isEmpty
              ? 'Sin lectura actual'
              : double.parse(
                  _newCurrentReadingController.text,
                ).toStringAsFixed(2),
        },
        {
          'label': 'Consumo (m³)',
          'value': '${_currentConsumptionController.text} m³',
        },
      ],
    );
  }

  void _showMeterConflictDialog(form_bloc.MeterConflictState state) {
    final originalReq = state.originalEvent;
    final numeroMedidor =
        originalReq.changeMeterRequest?.changeDetail.numeroMedidor ??
        'Desconocido';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Medidor Duplicado / En Conflicto'),
          content: Text(
            'El medidor físico ($numeroMedidor) ya está registrado en otra acometida.\n\n'
            '¿Deseas guardar la lectura de todas formas y reportar automáticamente este incidente a la central para su revisión?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(
                  () => _errorMessage =
                      'Cambio de medidor cancelado por conflicto.',
                );
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                Navigator.of(context).pop();

                final readingLocation =
                    originalReq.readingRequest?.readingLocation;

                final autoIncidentReq = CreateIncidentRequest(
                  connectionId:
                      originalReq.changeMeterRequest?.connectionId ??
                      _connectionIdController.text,
                  incidentTypeId: 37, // Serie de Medidor No Coincide
                  reportDescription:
                      'Se encontró el medidor físico $numeroMedidor instalado en esta acometida, pero el sistema lo rechazó por conflicto. (Reporte Automático)',
                  referenceAddress:
                      _addressConnectionController.text.trim().isEmpty
                      ? 'S/N'
                      : _addressConnectionController.text,
                  reportOrigin: 'LECTURISTA',
                  priority: 'MEDIA',
                  latitude: readingLocation?.lat ?? 0.0,
                  longitude: readingLocation?.lng ?? 0.0,
                  images: originalReq.changeMeterRequest?.images ?? [],
                  condicionMedidor: _condicionMedidor,
                  estadoFisico: _estadoFisico,
                );

                this.context.read<form_bloc.FormBloc>().add(
                  form_bloc.SaveCompleteFormEvent(
                    readingRequest: originalReq.readingRequest,
                    changeMeterRequest: null, // Cancelamos el cambio de medidor
                    incidentRequest: autoIncidentReq, // Agregamos el incidente
                  ),
                );
              },
              child: const Text(
                'Reportar y Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _newCurrentReadingController.removeListener(_updateCurrentConsumption);
    _previousReadingController.removeListener(_updateCurrentConsumption);
    _accountConnectionController.dispose();
    _addressConnectionController.dispose();
    _cardIdController.dispose();
    _cadastralKeyConnectionController.dispose();
    _connectionIdController.dispose();
    _connectionOwnerController.dispose();
    _currentReadingController.dispose();
    _previousReadingController.dispose();
    _readingIdController.dispose();
    _sectorConnectionController.dispose();
    _descriptionController.dispose();
    _averageConsumptionController.dispose();
    _currentConsumptionController.dispose();
    _previousConsumptionController.dispose();
    _readingValueController.dispose();
    _previousReadingDate.dispose();
    _newCurrentReadingController.dispose();
    _nuevoMedidorController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
