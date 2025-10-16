import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application/components/card/title_card.dart';
import 'package:flutter_application/components/divider/section_divider.dart';
import 'package:flutter_application/components/text/edit_text_field.dart';
import 'package:flutter_application/components/text/read_only_field.dart';
import 'package:flutter_application/utils/consumption_utils.dart';
import 'package:flutter_application/utils/date_utils.dart';
import 'package:flutter_application/utils/dialog_utils.dart';
import 'package:flutter_application/utils/responsive_utils.dart';
import 'package:flutter_application/utils/screen_type_layout.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/features/form/presentation/bloc/form_bloc.dart'
    as form_bloc;
import 'package:image_picker/image_picker.dart';

// Define a consistent color palette
class AppColors {
  static const primary = Color(0xFF0288D1); // Bright blue for primary elements
  static const secondary = Color(0xFF4CAF50); // Green for secondary elements
  static const error = Color(0xFFE57373); // Red for errors
  static const background = Color(0xFFF5F7FA); // Light neutral background
  static const cardBackground = Colors.white; // White for cards
  static const cardSecondaryBackground = Color(
    0xFFE3F2FD,
  ); // Light blue for secondary cards
  static const textPrimary = Color(0xFF212121); // Dark text for primary content
  static const textSecondary = Color(
    0xFF757575,
  ); // Lighter text for secondary content
}

class FormScreen extends StatefulWidget {
  final Map<String, dynamic> apiResponse;
  final String mode; // 'scan' or 'manual'

  const FormScreen({super.key, required this.apiResponse, required this.mode});

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
  final _now = DateTime.now();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late ConsumptionVisuals _consumptionVisuals;

  @override
  void initState() {
    super.initState();
    // Procesar apiResponse (unchanged)
    List<dynamic> dataList = [];
    Map<String, dynamic> data = {};

    if (widget.apiResponse.containsKey('apiResponse') &&
        widget.apiResponse['apiResponse'] is Map<String, dynamic> &&
        widget.apiResponse['apiResponse'].containsKey('data') &&
        widget.apiResponse['apiResponse']['data'] is List) {
      dataList = widget.apiResponse['apiResponse']['data'] as List<dynamic>;
    } else if (widget.apiResponse.containsKey('data') &&
        widget.apiResponse['data'] is List) {
      dataList = widget.apiResponse['data'] as List<dynamic>;
    } else {
      data = widget.apiResponse;
    }

    if (dataList.isNotEmpty) {
      data = dataList.first as Map<String, dynamic>;
    }

    if (data.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se encontraron datos válidos en la respuesta de la API.',
              style: ResponsiveUtils.bodyMedium(
                context,
              ).copyWith(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.buttonBorderRadius(context),
              ),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }

    debugPrint('Datos procesados en FormScreen: $data, modo: ${widget.mode}');

    _connectionIdController.text = data['cadastralKey']?.toString() ?? '';
    _connectionOwnerController.text = data['clientName']?.toString() ?? '';
    _readingIdController.text = data['readingId']?.toString() ?? '';
    _cardIdController.text = data['cardId']?.toString() ?? '';
    _currentReadingController.text = data['currentReading']?.toString() ?? '';
    _previousReadingController.text = data['previousReading']?.toString() ?? '';
    _sectorConnectionController.text = data['sector']?.toString() ?? '';
    _addressConnectionController.text = data['address']?.toString() ?? '';
    _accountConnectionController.text = data['account']?.toString() ?? '';
    _cadastralKeyConnectionController.text =
        data['cadastralKey']?.toString() ?? '';
    _descriptionController.text = '';
    _averageConsumptionController.text =
        data['averageConsumption']?.toString() ?? '';
    _readingValueController.text = data['readingValue']?.toString() ?? '';
    _previousReadingDate.text = data['previousReadingDate']?.toString() ?? '';
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

    _newCurrentReadingController.addListener(_updateCurrentConsumption);
    _previousReadingController.addListener(_updateCurrentConsumption);

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
    setState(() {});
  }

  void _updateConsumptionVisuals() {
    _consumptionVisuals = ConsumptionUtils.setConsumptionVisuals(
      currentConsumption: double.tryParse(_currentConsumptionController.text),
      averageConsumption: double.tryParse(_averageConsumptionController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background, // Updated background color
      appBar: AppBar(
        title: Text(
          'Detalle de La Acometida',
          style: ResponsiveUtils.titleMedium(
            context,
          ).copyWith(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: ResponsiveUtils.cardElevation(context),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.05), // Softer gradient
              AppColors.background,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: ResponsiveUtils.screenPadding(context).copyWith(
            top: ResponsiveUtils.scaleHeight(
              context,
              0.035,
            ), // Increased top padding
            bottom: ResponsiveUtils.scaleHeight(
              context,
              0.025,
            ), // Increased bottom padding
          ),
          child: BlocConsumer<form_bloc.FormBloc, form_bloc.FormState>(
            listener: (context, state) {
              if (state is form_bloc.FormSuccess) {
                DialogUtils.showResultDialog(
                  context,
                  '¡Formulario enviado con éxito!',
                  Icons.check_circle,
                  AppColors.secondary,
                );
              } else if (state is form_bloc.FormFailure) {
                DialogUtils.showResultDialog(
                  context,
                  state.message,
                  Icons.error_outline,
                  AppColors.error,
                );
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeaderRow(theme),
                      ResponsiveUtils.vSpace(
                        context,
                        0.03,
                      ), // Increased spacing
                      _buildConsumptionRow(theme, state),
                      ResponsiveUtils.vSpace(
                        context,
                        0.03,
                      ), // Increased spacing
                      _buildReadingFieldsRow(),
                      ResponsiveUtils.vSpace(
                        context,
                        0.015,
                      ), // Adjusted spacing
                      _buildDescriptionField(theme),
                      ResponsiveUtils.vSpace(context, 0),
                      ResponsiveUtils.vSpace(context, 0.015),
                      _buildImagesSection(context),
                      ResponsiveUtils.vSpace(
                        context,
                        0.02,
                      ), // Increased spacing
                      _buildActionButtonsRow(theme, state),
                      ResponsiveUtils.vSpace(
                        context,
                        0.03,
                      ), // Increased spacing
                      MinimalSectionDivider(
                        title: 'Información Adicional',
                        color: AppColors.primary.withOpacity(0.8),

                        children: [
                          ResponsiveUtils.vSpace(
                            context,
                            0.015,
                          ), // Adjusted spacing
                          _buildIdFieldsRow(),
                          ResponsiveUtils.vSpace(
                            context,
                            0.03,
                          ), // Increased spacing
                          _buildOwnerAddressFields(),
                          ResponsiveUtils.vSpace(
                            context,
                            0.03,
                          ), // Increased spacing
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImagesSection(BuildContext context) {
    final theme = Theme.of(context);
    final double imageSize = ResponsiveUtils.isTablet(context)
        ? 110 - 20
        : 75 - 20;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cargar Imágenes',
          style: ResponsiveUtils.bodyLarge(
            context,
          ).copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        ResponsiveUtils.vSpace(context, 0.01),
        SizedBox(
          height: imageSize,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _attachedImages.length + 1,
            separatorBuilder: (_, __) =>
                SizedBox(width: ResponsiveUtils.smallSpacing(context)),
            itemBuilder: (context, index) {
              if (index == _attachedImages.length) {
                // Botón de agregar imagen
                return _buildAddImageButton(context, imageSize);
              } else {
                final file = _attachedImages[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        file,
                        width: ResponsiveUtils.isTablet(context)
                            ? 110 - 20
                            : 75 - 20,
                        height: ResponsiveUtils.isTablet(context)
                            ? 110 - 20
                            : 75 - 20,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _attachedImages.removeAt(index);
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton(BuildContext context, double size) {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final XFile? pickedImage = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
        if (pickedImage != null) {
          setState(() {
            _attachedImages.add(File(pickedImage.path));
          });
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.cardSecondaryBackground.withOpacity(0.75),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.45),
            width: 2,
          ),
        ),
        child: Icon(
          Icons.add_a_photo_rounded,
          size: size * 0.48,
          color: AppColors.primary.withOpacity(0.82),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(ThemeData theme) {
    return ResponsiveRow(
      rowSpacing: ResponsiveUtils.mediumSpacing(context),
      children: [
        TitledCard(
          title: 'Conexión ID',
          elevation: ResponsiveUtils.cardElevation(context),
          bottomRightIcon: Icon(
            Icons.cable,
            color: AppColors.secondary, // Updated icon color
            size: ResponsiveUtils.iconSmall(context),
          ),
          titleStyle: ResponsiveUtils.titleSmall(context),
          backgroundColor: AppColors.cardBackground, // Updated card background
          children: [
            Text(
              _connectionIdController.text.isEmpty
                  ? 'Sin ID de conexión'
                  : _connectionIdController.text,
              style: ResponsiveUtils.titleMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary, // Updated text color
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        TitledCard(
          title: 'Consumo Prom.',
          elevation: ResponsiveUtils.cardElevation(context),
          bottomRightIcon: Icon(
            Icons.water_drop,
            color: AppColors.primary, // Updated icon color
            size: ResponsiveUtils.iconSmall(context),
          ),
          titleStyle: ResponsiveUtils.titleSmall(context),
          backgroundColor: AppColors.cardBackground, // Updated card background
          children: [
            Text(
              _connectionIdController.text.isEmpty
                  ? '0.0 m³'
                  : '${double.tryParse(_averageConsumptionController.text)?.toStringAsFixed(2) ?? '0.00'} m³',
              style: ResponsiveUtils.titleMedium(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary, // Updated text color
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConsumptionRow(ThemeData theme, form_bloc.FormState state) {
    return ResponsiveRow(
      rowSpacing: ResponsiveUtils.mediumSpacing(context),
      children: [
        TitledCard(
          title: 'Consumo Anterior',
          elevation: ResponsiveUtils.cardElevation(context),
          bottomRightIcon: Icon(
            Icons.history,
            color: AppColors.textSecondary, // Updated icon color
            size: ResponsiveUtils.iconSmall(context),
          ),
          titleStyle: ResponsiveUtils.titleSmall(context),
          backgroundColor:
              AppColors.cardSecondaryBackground, // Updated card background
          children: [_buildConsumptionCardContent(theme, isPrevious: true)],
        ),
        TitledCard(
          title: 'Consumo Actual',
          elevation: ResponsiveUtils.cardElevation(context),
          bottomRightIcon: Icon(
            _consumptionVisuals.icon,
            color: _consumptionVisuals.textColor,
            size: ResponsiveUtils.iconSmall(context),
          ),
          backgroundColor: _consumptionVisuals.backgroundColor,
          titleStyle: ResponsiveUtils.titleSmall(context),
          children: [_buildConsumptionCardContent(theme, isPrevious: false)],
        ),
      ],
    );
  }

  Widget _buildConsumptionCardContent(
    ThemeData theme, {
    required bool isPrevious,
    TextStyle? textStyle,
  }) {
    final style = textStyle ?? ResponsiveUtils.titleMedium(context);
    final controller = isPrevious
        ? _previousConsumptionController
        : _currentConsumptionController;
    final dateText = isPrevious
        ? (_previousReadingDate.text.isEmpty
              ? 'N/A'
              : formatFromIsoDate(_previousReadingDate.text))
        : formatDate(_now);
    final bgColor = isPrevious
        ? AppColors.cardSecondaryBackground
        : _consumptionVisuals.backgroundColor;
    final textColor = isPrevious
        ? AppColors.textPrimary
        : _consumptionVisuals.textColor;
    final dateTextColor = isPrevious
        ? AppColors.textSecondary
        : _consumptionVisuals.textColor.withOpacity(0.8);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(
              ResponsiveUtils.cardBorderRadius(context),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: ResponsiveUtils.cardPadding(context),
          child: Text(
            controller.text.isEmpty ? '0.0 m³' : '${controller.text} m³',
            style: style.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ResponsiveUtils.vSpace(context, 0.015), // Adjusted spacing
        Text(
          'Fecha: $dateText',
          style: ResponsiveUtils.bodySmall(
            context,
          ).copyWith(color: dateTextColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildIdFieldsRow() {
    return ResponsiveRow(
      rowSpacing: ResponsiveUtils.mediumSpacing(context),
      children: [
        ReadOnlyField(
          controller: _cardIdController,
          label: 'Cédula de Ciudadanía',
          leftIcon: Icons.pin,
          textStyle: ResponsiveUtils.bodyMedium(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        ReadOnlyField(
          controller: _readingIdController,
          label: 'ID de Lectura',
          leftIcon: Icons.water_damage_outlined,
          textStyle: ResponsiveUtils.bodyMedium(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildOwnerAddressFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReadOnlyField(
          controller: _connectionOwnerController,
          label: 'Propietario de la Conexión',
          leftIcon: Icons.person_outline,
          textStyle: ResponsiveUtils.bodyMedium(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        ResponsiveUtils.vSpace(context, 0.03), // Increased spacing
        ReadOnlyField(
          controller: _addressConnectionController,
          label: 'Dirección de la Conexión',
          leftIcon: Icons.location_on_outlined,
          textStyle: ResponsiveUtils.bodyMedium(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildReadingFieldsRow() {
    return ResponsiveRow(
      rowSpacing: ResponsiveUtils.mediumSpacing(context),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReadOnlyField(
          controller: _currentReadingController,
          label: 'Lectura Anterior',
          leftIcon: Icons.history_outlined,
          textStyle: ResponsiveUtils.bodyLarge(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
        EditTextField(
          controller: _newCurrentReadingController,
          label: 'Lectura Actual (Obligatorio)',
          leftIcon: Icons.speed_outlined,
          hintText: '0.00',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, ingrese la lectura actual';
            }
            final number = double.tryParse(value);
            if (number == null || number < 0) {
              return 'Ingrese un número positivo válido';
            }
            return null;
          },
          textStyle: ResponsiveUtils.bodyLarge(
            context,
          ).copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(ThemeData theme) {
    return EditTextField(
      controller: _descriptionController,
      label:
          'Descripción o Novedades${widget.mode == 'manual' ? ' (Requerido)' : ' (Opcional)'}',
      leftIcon: Icons.description,
      maxLines: ResponsiveUtils.isTablet(context) ? 5 : 3,
      hintText: widget.mode == 'manual'
          ? 'Ingrese una descripción detallada...'
          : 'Ingrese una descripción o novedad...',
      textStyle: ResponsiveUtils.bodyMedium(
        context,
      ).copyWith(color: AppColors.textPrimary),
      validator: widget.mode == 'manual'
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingrese una descripción';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildActionButtonsRow(ThemeData theme, form_bloc.FormState state) {
    return ResponsiveRow(
      forceRow: true,
      rowSpacing: ResponsiveUtils.largeSpacing(context), // Increased spacing
      children: [
        ResponsiveButton(
          onPressed: state is form_bloc.FormLoading
              ? null
              : () => _onSavePressed(context, state),
          icon: Icons.save,
          label: 'Guardar',
          color: AppColors.secondary, // Updated button color
          loading: state is form_bloc.FormLoading,
          height: ResponsiveUtils.buttonSmall(
            context,
          ), // Slightly larger button
          animationController: _animationController,
          scaleAnimation: _scaleAnimation,
        ),
        ResponsiveButton(
          onPressed: state is form_bloc.FormLoading
              ? null
              : () => Navigator.of(context).pop(),
          icon: Icons.cancel,
          label: 'Cancelar',
          color: AppColors.error, // Updated button color
          loading: false,
          height: ResponsiveUtils.buttonSmall(
            context,
          ), // Slightly larger button
          animationController: _animationController,
          scaleAnimation: _scaleAnimation,
        ),
      ],
    );
  }

  void _onSavePressed(BuildContext context, form_bloc.FormState state) {
    debugPrint('Modo en _onSavePressed: ${widget.mode}');
    if (_formKey.currentState?.validate() ?? false) {
      DialogUtils.showConfirmationDialog(
        context,
        onConfirm: () {
          debugPrint('Ejecutando onConfirm con context: $context');
          context.read<form_bloc.FormBloc>().add(
            form_bloc.InsertReadingEvent(
              novelty: _descriptionController.text,
              currentReading: double.parse(_newCurrentReadingController.text),
              previousReading: double.parse(
                _currentReadingController.text.isEmpty
                    ? '0'
                    : _currentReadingController.text,
              ),
              rentalIncomeCode: 1500,
              incomeCode: 1256,
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
              readingValue: double.parse(
                _readingValueController.text.isNotEmpty
                    ? _readingValueController.text
                    : '0',
              ),
              connectionId: _connectionIdController.text,
              sewerRate: 0.0,
              averageConsumption:
                  double.tryParse(_averageConsumptionController.text) ?? 0.0,
            ),
          );
        },
        fields: [
          {'label': 'ID de Conexión', 'value': _connectionIdController.text},
          {'label': 'Propietario', 'value': _connectionOwnerController.text},
          {'label': 'Dirección', 'value': _addressConnectionController.text},
          {
            'label': 'Lectura Actual',
            'value': _newCurrentReadingController.text,
          },
          {
            'label': 'Descripción',
            'value': _descriptionController.text.isEmpty
                ? 'Sin descripción'
                : _descriptionController.text,
          },
        ],
      );
    }
  }

  @override
  void dispose() {
    _accountConnectionController.dispose();
    _addressConnectionController.dispose();
    _cardIdController.dispose();
    _cadastralKeyConnectionController.dispose();
    _connectionIdController.dispose();
    _connectionOwnerController.dispose();
    _currentReadingController.removeListener(_updateCurrentConsumption);
    _previousReadingController.removeListener(_updateCurrentConsumption);
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

class ResponsiveButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color color;
  final bool loading;
  final double height;
  final AnimationController animationController;
  final Animation<double> scaleAnimation;

  const ResponsiveButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
    this.loading = false,
    required this.height,
    required this.animationController,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!loading) {
          animationController.forward();
        }
      },
      onTapUp: (_) => animationController.reverse(),
      onTapCancel: () => animationController.reverse(),
      child: AnimatedBuilder(
        animation: scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: scaleAnimation.value,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)], // Smoother gradient
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(
                  ResponsiveUtils.buttonBorderRadius(context),
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3), // Subtle border
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2), // Softer shadow
                    blurRadius: ResponsiveUtils.isSmallDevice(context) ? 8 : 12,
                    offset: Offset(
                      0,
                      ResponsiveUtils.isSmallDevice(context) ? 3 : 5,
                    ),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.buttonBorderRadius(context),
                    ),
                  ),
                  elevation: 0,
                  padding: ResponsiveUtils.cardPadding(context).copyWith(
                    left: ResponsiveUtils.scaleWidth(
                      context,
                      0.04,
                    ), // Consistent padding
                    right: ResponsiveUtils.scaleWidth(context, 0.04),
                  ),
                  minimumSize: Size(double.infinity, height),
                ),
                child: loading
                    ? SizedBox(
                        width: ResponsiveUtils.iconMedium(context),
                        height: ResponsiveUtils.iconMedium(context),
                        child: CircularProgressIndicator(
                          strokeWidth: 3, // Thicker stroke for visibility
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: ResponsiveUtils.iconSmall(context),
                            color: Colors.white,
                          ),
                          ResponsiveUtils.hSpace(
                            context,
                            0.03,
                          ), // Increased spacing
                          Text(
                            label,
                            style: ResponsiveUtils.buttonText(context).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
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
}
