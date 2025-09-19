import 'package:flutter/material.dart';
import 'package:flutter_application/components/card/title_card.dart';
import 'package:flutter_application/components/text/edit_text_field.dart';
import 'package:flutter_application/components/text/read_only_field.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application/core/di/injection.dart' as di;
import 'package:flutter_application/features/form/presentation/bloc/form_bloc.dart'
    as form_bloc;

class FormScreen extends StatefulWidget {
  final Map<String, dynamic> apiResponse;

  const FormScreen({super.key, required this.apiResponse});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Details Connection
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

  // Animation controller for button scale effect
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Seleccionar el objeto con el readingId más alto
    final List<dynamic> dataList = widget.apiResponse['data'] ?? [];
    Map<String, dynamic> data = dataList.isNotEmpty
        ? dataList.first as Map<String, dynamic>
        : {};

    // Mostrar advertencia si no hay datos
    if (dataList.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'No se encontraron datos en la respuesta de la API.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }

    // Initialize controllers with API response data or fallback values
    _connectionIdController.text = data['cadastralKey']?.toString() ?? '';
    _connectionOwnerController.text =
        '${data['firstNames']?.toString() ?? ''} ${data['lastNames']?.toString() ?? ''}';
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

    // Initialize animation controller and scale animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => di.sl<form_bloc.FormBloc>(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: const Text(
            'Detalles de la Conexión',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Container(
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
            child: BlocConsumer<form_bloc.FormBloc, form_bloc.FormState>(
              listener: (context, state) {
                if (state is form_bloc.FormSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('¡Formulario enviado con éxito!'),
                      backgroundColor: Colors.green.shade600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 3),
                      elevation: 4,
                    ),
                  );
                } else if (state is form_bloc.FormFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: theme.colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 3),
                      elevation: 4,
                    ),
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
                        Row(
                          children: [
                            Expanded(
                              child: TitledCard(
                                title: 'Conexión Activa',
                                elevation: 4,
                                bottomRightIcon: const Icon(
                                  Icons.cable,
                                  color: Colors.green,
                                  size: 28,
                                ),
                                child: Text(
                                  _connectionIdController.text.isEmpty
                                      ? 'Sin ID de conexión'
                                      : _connectionIdController.text,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TitledCard(
                                title: 'Consumo Promedio',
                                elevation: 4,
                                bottomRightIcon: const Icon(
                                  Icons.water_drop,
                                  color: Colors.blueAccent,
                                  size: 28,
                                ),
                                child: Text(
                                  _connectionIdController.text.isEmpty
                                      ? '0.0 m³'
                                      : '${double.tryParse(_averageConsumptionController.text)?.toStringAsFixed(2) ?? '0.00'} m³',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ReadOnlyField(
                                controller: _cardIdController,
                                label: 'Cédula de Ciudadanía',
                                leftIcon: Icons.pin,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ReadOnlyField(
                                controller: _readingIdController,
                                label: 'ID de Lectura',
                                leftIcon: Icons.water_damage_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ReadOnlyField(
                          controller: _connectionOwnerController,
                          label: 'Propietario de la Conexión',
                          leftIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        ReadOnlyField(
                          controller: _addressConnectionController,
                          label: 'Dirección de la Conexión',
                          leftIcon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ReadOnlyField(
                                controller: _previousReadingController,
                                label: 'Lectura Anterior',
                                leftIcon: Icons.history_outlined,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: EditTextField(
                                controller: _currentReadingController,
                                label: 'Lectura Actual',
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
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        EditTextField(
                          controller: _descriptionController,
                          label: 'Descripción o Novedades',
                          leftIcon: Icons.description,
                          maxLines: 4,
                          hintText: 'Describe cualquier novedad aquí...',
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTapDown: (_) {
                                  if (state is! form_bloc.FormLoading) {
                                    _animationController.forward();
                                  }
                                },
                                onTapUp: (_) => _animationController.reverse(),
                                onTapCancel: () =>
                                    _animationController.reverse(),
                                child: AnimatedBuilder(
                                  animation: _scaleAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _scaleAnimation.value,
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.colorScheme.primary,
                                          theme.colorScheme.primaryContainer,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: state is form_bloc.FormLoading
                                          ? null
                                          : () {
                                              if (_formKey.currentState
                                                      ?.validate() ??
                                                  false) {
                                                showDialog<bool>(
                                                  context: context,
                                                  builder: (BuildContext dialogContext) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                        'Confirmar Guardado',
                                                      ),
                                                      content: const Text(
                                                        '¿Está seguro de que desea guardar la información?',
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                dialogContext,
                                                              ).pop(false),
                                                          child: const Text(
                                                            'Cancelar',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                dialogContext,
                                                              ).pop(true),
                                                          child: const Text(
                                                            'Guardar',
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ).then((confirmed) {
                                                  if (confirmed == true) {
                                                    context.read<form_bloc.FormBloc>().add(
                                                      form_bloc.SubmitFormEvent(
                                                        readingId: int.parse(
                                                          _readingIdController
                                                                  .text
                                                                  .isEmpty
                                                              ? '0'
                                                              : _readingIdController
                                                                    .text,
                                                        ),
                                                        novelty:
                                                            _descriptionController
                                                                .text,
                                                        currentReading:
                                                            double.parse(
                                                              _currentReadingController
                                                                  .text,
                                                            ),
                                                        previousReading: double.parse(
                                                          _previousReadingController
                                                                  .text
                                                                  .isEmpty
                                                              ? '0'
                                                              : _previousReadingController
                                                                    .text,
                                                        ),
                                                        rentalIncomeCode: 1500,
                                                        incomeCode: 1256,
                                                        cadastralKey:
                                                            _cadastralKeyConnectionController
                                                                .text,
                                                        sector: int.parse(
                                                          _sectorConnectionController
                                                                  .text
                                                                  .isEmpty
                                                              ? '0'
                                                              : _sectorConnectionController
                                                                    .text,
                                                        ),
                                                        account: int.parse(
                                                          _accountConnectionController
                                                                  .text
                                                                  .isEmpty
                                                              ? '0'
                                                              : _accountConnectionController
                                                                    .text,
                                                        ),
                                                        connectionId:
                                                            _connectionIdController
                                                                .text,
                                                        averageConsumption:
                                                            24.2,
                                                      ),
                                                    );
                                                  }
                                                });
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        backgroundColor: Colors.blueAccent,
                                        foregroundColor: Colors.white,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          side: const BorderSide(
                                            color: Colors.white24,
                                            width: 1.5,
                                          ),
                                        ),
                                        elevation: 0,
                                        minimumSize: const Size(
                                          double.infinity,
                                          56,
                                        ),
                                      ),
                                      child: state is form_bloc.FormLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.save,
                                                  size: 22,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Guardar',
                                                  style: theme
                                                      .textTheme
                                                      .labelLarge
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.white,
                                                        letterSpacing: 0.5,
                                                      ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTapDown: (_) {
                                  if (state is! form_bloc.FormLoading) {
                                    _animationController.forward();
                                  }
                                },
                                onTapUp: (_) => _animationController.reverse(),
                                onTapCancel: () =>
                                    _animationController.reverse(),
                                child: AnimatedBuilder(
                                  animation: _scaleAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _scaleAnimation.value,
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          theme.colorScheme.error,
                                          theme.colorScheme.errorContainer,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.colorScheme.error
                                              .withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: state is form_bloc.FormLoading
                                          ? null
                                          : () {
                                              Navigator.of(context).pop();
                                            },
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          side: const BorderSide(
                                            color: Colors.white24,
                                            width: 1.5,
                                          ),
                                        ),
                                        elevation: 0,
                                        minimumSize: const Size(
                                          double.infinity,
                                          56,
                                        ),
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
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
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
    _animationController.dispose();
    super.dispose();
  }
}
