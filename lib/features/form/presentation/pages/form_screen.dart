// lib/features/form/presentation/pages/form_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
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
import 'package:flutter_application/features/reading/domain/entities/reading.dart';
import 'package:flutter_application/utils/consumption_utils.dart';
import 'package:flutter_application/utils/dialog_utils.dart';
import 'package:flutter_application/utils/responsive_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/form/presentation/blocs/readings/form_bloc.dart'
    as form_bloc;
import 'package:go_router/go_router.dart';
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
  bool hasCurrentReading = false;
  String? connectionStateDescription;
  String? connectionStateName;
  bool? permitReading;
  int? connectionStateId;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _setupListeners();
    _setupAnimations();
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
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Detalle de La Acometida',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, AppColors.background],
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
                                            ? AppColors.error
                                            : AppColors.secondary,
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
                                color: AppColors.primary,
                                size: ResponsiveUtils.iconSmall(context),
                              ),
                              backgroundColor: const Color.fromARGB(
                                255,
                                255,
                                255,
                                255,
                              ),
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
                                color: AppColors.error.withValues(alpha: 0.18),
                              ),
                            ),
                            color: const Color(0xFFFFF3E0),
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
                                      color: AppColors.textSecondary,
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
                                      const Icon(
                                        Icons.bookmark_outline,
                                        color: AppColors.error,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          connectionStateName?.toUpperCase() ??
                                              'DESCONOCIDO',
                                          style: const TextStyle(
                                            color: AppColors.error,
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
                                      color: const Color(0xFFFFE0B2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.description_outlined,
                                          color: AppColors.textSecondary,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            connectionStateDescription ??
                                                'Sin descripción disponible.',
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
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
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.15,
                                    ),
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
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.10,
                                    ),
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
                          color: AppColors.primary.withValues(alpha: 0.8),
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            // Obtener el ID de acometida del campo de texto
            final acometidaId = _connectionIdController.text.trim();

            if (acometidaId.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("ID de acometida no válido"),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            // Mostrar loading
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );

            try {
              // Llamada directa al UseCase
              final connection = await di.sl<GetConnectionWithProperties>()(
                acometidaId,
              );

              if (!mounted) return;
              Navigator.pop(this.context); // cerrar loading

              // Navegar a la pantalla de actualización
              this.context.push(
                '/update-form',
                extra: {'connection': connection, 'mode': 'manual'},
              );
            } catch (e) {
              if (!mounted) return;
              Navigator.pop(this.context); // cerrar loading
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text("Error al cargar datos: $e"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          label: const Text(
            "Actualizar Coordenadas",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          enableFeedback: false,
          icon: const Icon(Icons.edit_note_rounded),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 8.0,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
              Icon(icon, color: AppColors.textSecondary, size: 13),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
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
            style: const TextStyle(
              color: AppColors.textPrimary,
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
      color: AppColors.textSecondary.withValues(alpha: 0.15),
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
          readingId: state.data['readingId'],
          cadastralKey: state.data['cadastralKey'],
          description: state.data['novelty'] ?? 'Sin descripción',
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

  Future<void> _onSavePressed(
    BuildContext context,
    form_bloc.FormState state,
  ) async {
    if (!_formKey.currentState!.validate()) return;

    // SE ELIMINÓ LA RESTRICCIÓN: imágenes ya no son obligatorias en modo manual
    // SE ELIMINÓ LA RESTRICCIÓN: descripción (observaciones) ya no es obligatoria

    setState(() => _errorMessage = null);

    await DialogUtils.showConfirmationDialog(
      context,
      onConfirm: () {
        if (!mounted) return;
        context.read<form_bloc.FormBloc>().add(
          form_bloc.InsertReadingEvent(
            novelty: _descriptionController.text,
            currentReading: double.parse(_newCurrentReadingController.text),
            previousReading: double.parse(
              _currentReadingController.text.isEmpty
                  ? '0'
                  : _currentReadingController.text,
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
          ),
        );
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
    _animationController.dispose();
    super.dispose();
  }
}
