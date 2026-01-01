// lib/features/properties/form/update/presentation/screens/update_connection_form_screen.dart
import 'package:flutter_application/components/common/custom_overlay_snack_bar.dart';
import 'package:flutter_application/features/properties/form/presentation/screen/map_picker_screen.dart';
import 'package:flutter_application/features/properties/form/update/domain/repositories/company_repository.dart';
import 'package:flutter_application/features/properties/form/update/domain/repositories/connection_repository.dart';
import 'package:flutter_application/features/properties/form/update/domain/repositories/customer_repository.dart';
import 'package:flutter_application/utils/convert_coordinates.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application/core/theme/app_colors.dart';
import 'package:flutter_application/components/button/widget_button.dart';
import 'package:flutter_application/components/common/custom_text_field.dart';
import 'package:flutter_application/components/common/form_card.dart';
import 'package:flutter_application/utils/date_utils.dart';
import 'package:flutter_application/utils/responsive_utils.dart';
import 'package:flutter_application/utils/validators.dart';
import 'package:flutter_application/features/properties/list/domain/entities/connection.dart';
import 'package:flutter_application/features/properties/form/update/domain/usecases/update_company.dart';
import 'package:flutter_application/features/properties/form/update/domain/usecases/update_connection.dart';
import 'package:flutter_application/features/properties/form/update/domain/usecases/update_customer.dart';
import 'package:flutter_application/features/properties/form/presentation/widgets/client/company_form.dart';
import 'package:flutter_application/features/properties/form/presentation/widgets/client/natural_person_form.dart';
import 'package:flutter_application/features/properties/form/presentation/widgets/connection/gps_section.dart';
import 'package:flutter_application/core/di/injection.dart' as di;

class UpdateConnectionFormScreen extends StatefulWidget {
  final ConnectionEntity connection;
  final String mode;

  const UpdateConnectionFormScreen({
    super.key,
    required this.connection,
    this.mode = 'manual',
  });

  @override
  State<UpdateConnectionFormScreen> createState() =>
      _UpdateConnectionFormScreenState();
}

class _UpdateConnectionFormScreenState extends State<UpdateConnectionFormScreen>
    with TickerProviderStateMixin {
  // Form Keys (solo 2 pasos)
  final _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>()];

  // Controllers & State
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  int _currentStep = 0;
  bool _isNaturalPerson = true;
  bool _isCompany = false;
  bool _isSubmitting = false;
  bool _isDatePickerActive = false;
  bool _isGettingLocation = false;
  bool _hasLoadedGeolocation = false;

  GoogleMapController? _mapController;

  // Cliente Natural
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _identificationCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final List<TextEditingController> _emailsNatural = [];
  final List<TextEditingController> _phonesNatural = [];

  int _sexId = 1;
  int _civilStatus = 1;
  int _professionId = 1;
  String _originCountry = 'ECU';
  String _identificationType = 'CED';
  String _parishId = '100150';
  bool _deceased = false;

  // Empresa
  final _companyNameCtrl = TextEditingController();
  final _socialReasonCtrl = TextEditingController();
  final _rucCtrl = TextEditingController();
  final _companyAddressCtrl = TextEditingController();
  final List<TextEditingController> _emailsCompany = [];
  final List<TextEditingController> _phonesCompany = [];

  String _companyParishId = '1';
  String _companyCountry = 'ECU';
  String _identificationTypeCompany = 'RUC';

  // Acometida
  final _cadastralKeyCtrl = TextEditingController();
  final _meterNumberCtrl = TextEditingController();
  final _contractNumberCtrl = TextEditingController();
  final _connectionAddressCtrl = TextEditingController();
  final _installationDateCtrl = TextEditingController();
  final _peopleNumberCtrl = TextEditingController();
  final _referenceCtrl = TextEditingController();
  final _latitudeCtrl = TextEditingController();
  final _longitudeCtrl = TextEditingController();
  final _sectorCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _zoneCtrl = TextEditingController();
  Map<String, double> _coordinatesCtrl = <String, double>{};

  // Valores normalizados
  String? _rateName;
  String? _zoneName;

  bool _sewerage = true;
  bool _status = true;

  // GPS
  final _countryCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _cantonCtrl = TextEditingController();
  final _addressFullCtrl = TextEditingController();
  final _accuracyCtrl = TextEditingController();
  final _precisionCtrl = TextEditingController();
  final _geolocationDateCtrl = TextEditingController();
  final _geometricZoneCtrl = TextEditingController();

  // Listas válidas
  static const _validRates = [
    'RESIDENCIAL',
    'COMERCIAL',
    'INDUSTRIAL',
    'BENEFICENCIA',
  ];
  static const _validZones = [
    'ZONA 1',
    'ZONA 2',
    'ZONA 3',
    'ZONA 4',
    'ZONA NO ASIGNADA',
  ];

  // Estado de errores por paso
  List<String?> _stepErrors = [null, null];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadInitialData();
    _pageController.addListener(() {
      setState(() {
        _currentStep = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _mapController?.dispose();

    final controllers = [
      _firstNameCtrl,
      _lastNameCtrl,
      _identificationCtrl,
      _dobCtrl,
      _addressCtrl,
      ..._emailsNatural,
      ..._phonesNatural,
      _companyNameCtrl,
      _socialReasonCtrl,
      _rucCtrl,
      _companyAddressCtrl,
      ..._emailsCompany,
      ..._phonesCompany,
      _cadastralKeyCtrl,
      _meterNumberCtrl,
      _contractNumberCtrl,
      _connectionAddressCtrl,
      _installationDateCtrl,
      _peopleNumberCtrl,
      _referenceCtrl,
      _latitudeCtrl,
      _longitudeCtrl,
      _sectorCtrl,
      _accountCtrl,
      _zoneCtrl,
      _countryCtrl,
      _provinceCtrl,
      _cantonCtrl,
      _addressFullCtrl,
      _accuracyCtrl,
      _precisionCtrl,
      _geolocationDateCtrl,
      _geometricZoneCtrl,
    ];
    for (var c in controllers) c.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final conn = widget.connection;

    _isNaturalPerson = conn.person != null;
    _isCompany = conn.company != null;

    if (_isNaturalPerson && conn.person != null) {
      final p = conn.person!;
      _firstNameCtrl.text = p.firstName ?? '';
      _lastNameCtrl.text = p.lastName ?? '';
      _identificationCtrl.text = conn.clientId;
      _dobCtrl.text = p.birthDate ?? '';
      _addressCtrl.text = p.address ?? '';
      _sexId = p.genderId ?? 1;
      _civilStatus = p.civilStatus;
      _professionId = p.professionId;
      _originCountry = p.country ?? 'ECU';
      _parishId = p.parishId ?? '100150';
      _deceased = p.isDeceased ?? false;

      _emailsNatural.clear();
      _phonesNatural.clear();
      for (var e in p.emails) {
        if (e?.email != null) {
          _emailsNatural.add(TextEditingController(text: e!.email));
        }
      }
      for (var p in p.phones) {
        if (p?.numero != null) {
          _phonesNatural.add(TextEditingController(text: p!.numero));
        }
      }
      if (_emailsNatural.isEmpty) _emailsNatural.add(TextEditingController());
      if (_phonesNatural.isEmpty) _phonesNatural.add(TextEditingController());
    }

    if (_isCompany && conn.company != null) {
      final c = conn.company!;
      _companyNameCtrl.text = c.businessName ?? '';
      _socialReasonCtrl.text = c.commercialName ?? '';
      _rucCtrl.text = c.ruc;
      _companyAddressCtrl.text = c.address ?? '';
      _companyParishId = c.parishId ?? '1';
      _companyCountry = c.country ?? 'ECU';

      _emailsCompany.clear();
      _phonesCompany.clear();
      for (var e in c.emails) {
        if (e?.email != null) {
          _emailsCompany.add(TextEditingController(text: e!.email));
        }
      }
      for (var p in c.phones) {
        if (p?.numero != null) {
          _phonesCompany.add(TextEditingController(text: p!.numero));
        }
      }
      if (_emailsCompany.isEmpty) _emailsCompany.add(TextEditingController());
      if (_phonesCompany.isEmpty) _phonesCompany.add(TextEditingController());
    }

    _cadastralKeyCtrl.text = conn.connectionCadastralKey;
    _meterNumberCtrl.text = conn.connectionMeterNumber ?? '';
    _contractNumberCtrl.text = conn.connectionContractNumber ?? '';
    _connectionAddressCtrl.text = conn.connectionAddress;
    _installationDateCtrl.text = formatFromIsoDate(
      conn.connectionInstallationDate ?? '',
    );
    _geolocationDateCtrl.text =
        conn.connectionGeolocationDate?.toIso8601String() ?? '';

    _peopleNumberCtrl.text = conn.connectionPeopleNumber?.toString() ?? '4';
    _referenceCtrl.text = conn.connectionReference ?? '';
    _sectorCtrl.text = conn.connectionSector.toString();
    _accountCtrl.text = conn.connectionAccount.toString();
    _zoneCtrl.text = conn.connectionZone?.toString() ?? '';
    _sewerage = conn.connectionSewerage ?? true;
    _status = conn.connectionStatus ?? true;
    _coordinatesCtrl = extractCoordinates(conn.connectionCoordinates ?? '');
    _latitudeCtrl.text = _coordinatesCtrl['latitude']?.toString() ?? '';
    _longitudeCtrl.text = _coordinatesCtrl['longitude']?.toString() ?? '';

    _rateName =
        _normalizeValue(conn.connectionRateName, _validRates) ?? 'COMERCIAL';
    _zoneName = _normalizeValue(conn.zoneName, _validZones) ?? 'ZONA 1';

    if (conn.connectionCoordinates?.isNotEmpty == true) {
      _latitudeCtrl.text = _coordinatesCtrl['latitude']?.toString() ?? '';
      _longitudeCtrl.text = _coordinatesCtrl['longitude']?.toString() ?? '';
    } else {
      _latitudeCtrl.text = '0.32069990';
      _longitudeCtrl.text = '-78.10616480';
    }

    _accuracyCtrl.text = conn.connectionAltitude?.toStringAsFixed(1) ?? '0.0';
    _precisionCtrl.text =
        conn.connectionPrecision?.toStringAsFixed(2) ?? '0.99';
    _geolocationDateCtrl.text =
        conn.connectionGeolocationDate?.toIso8601String() ??
        DateTime.now().toIso8601String();
    _geometricZoneCtrl.text = conn.connectionGeometricZone ?? '';
  }

  String? _normalizeValue(String? value, List<String> validList) {
    if (value == null) return null;
    final normalized = value.trim().toUpperCase();
    return validList.contains(normalized) ? normalized : null;
  }

  Future<void> _selectDate(TextEditingController controller) async {
    if (_isDatePickerActive) return;
    _isDatePickerActive = true;
    try {
      final initial = controller.text.isNotEmpty
          ? DateTime.tryParse(controller.text) ?? DateTime.now()
          : DateTime.now();
      final date = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        ),
      );
      if (date != null && mounted) {
        final formatted =
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
        setState(() => controller.text = formatted);
      }
    } finally {
      _isDatePickerActive = false;
    }
  }

  Future<void> _getCurrentLocationAndAddress() async {
    if (_isGettingLocation) return;
    setState(() => _isGettingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _showErrorSnackBar('Servicio de ubicación desactivado.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _showErrorSnackBar('Permiso denegado.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return _showErrorSnackBar('Permiso denegado permanentemente.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final accuracy = position.accuracy;
      final precision = accuracy <= 5
          ? 0.99
          : accuracy <= 10
          ? 0.95
          : accuracy <= 20
          ? 0.90
          : accuracy <= 50
          ? 0.80
          : 0.50;

      setState(() {
        _latitudeCtrl.text = position.latitude.toStringAsFixed(8);
        _longitudeCtrl.text = position.longitude.toStringAsFixed(8);
        _accuracyCtrl.text = accuracy.toStringAsFixed(1);
        _precisionCtrl.text = precision.toStringAsFixed(2);
        _geolocationDateCtrl.text = DateTime.now().toIso8601String();
      });

      await _reverseGeocode(position.latitude, position.longitude);
      _showSnackBar(
        'Ubicación obtenida con precisión ${precision.toStringAsFixed(2)}',
      );
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
      );
    } catch (e) {
      _showErrorSnackBar('Error al obtener ubicación: $e');
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _countryCtrl.text = place.country ?? 'Ecuador';
          _provinceCtrl.text = place.administrativeArea ?? '';
          _cantonCtrl.text =
              place.subAdministrativeArea ?? place.locality ?? '';
          _addressFullCtrl.text = [
            place.street,
            place.subLocality,
            place.locality,
            place.subAdministrativeArea,
            place.administrativeArea,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error al obtener dirección.');
    }
  }

  void _openMap() async {
    final lat = double.tryParse(_latitudeCtrl.text) ?? 0.32069990;
    final lng = double.tryParse(_longitudeCtrl.text) ?? -78.10616480;

    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initialLat: lat,
          initialLng: lng,
          onLocationPicked: (newLat, newLng) {
            Navigator.pop(context, {'lat': newLat, 'lng': newLng});
          },
        ),
      ),
    );

    if (result != null && mounted) {
      final newLat = result['lat'] as double;
      final newLng = result['lng'] as double;

      setState(() {
        _latitudeCtrl.text = newLat.toStringAsFixed(8);
        _longitudeCtrl.text = newLng.toStringAsFixed(8);
        _precisionCtrl.text = '0.99';
        _geolocationDateCtrl.text = DateTime.now().toIso8601String();
      });

      await _reverseGeocode(newLat, newLng);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message, {VoidCallback? onRetry}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Reintentar',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            context.hSpace(0.01),
            Text(
              '¡Datos actualizados correctamente!',
              style: context.bodyMedium.copyWith(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.pop();
    });
  }

  void _nextStep() {
    final formState = _formKeys[_currentStep].currentState;
    if (formState != null && formState.validate()) {
      if (_currentStep < 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _confirmSubmit();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor completa los campos requeridos del paso actual',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  Future<void> _confirmSubmit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirmar Guardado', style: context.titleMedium),
        content: Text(
          '¿Desea guardar todos los cambios?',
          style: context.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isSubmitting = true;
      _stepErrors = [null, null];
    });

    final client = http.Client();

    try {
      // === PASO 1: CLIENTE ===
      if (_isNaturalPerson) {
        await di.sl<UpdateCustomerUseCase>()(
          customerId: _identificationCtrl.text,
          params: UpdateCustomerParams(
            firstName: _firstNameCtrl.text,
            lastName: _lastNameCtrl.text,
            emails: _emailsNatural
                .map((e) => e.text.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
            phoneNumbers: _phonesNatural
                .map((e) => e.text.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
            dateOfBirth: _dobCtrl.text,
            sexId: _sexId,
            civilStatus: _civilStatus,
            address: _addressCtrl.text,
            professionId: _professionId,
            originCountry: _originCountry,
            identificationType: _identificationType,
            parishId: _parishId,
            deceased: _deceased,
          ),
        );
      } else if (_isCompany) {
        await di.sl<UpdateCompanyUseCase>()(
          companyRuc: _rucCtrl.text,
          params: UpdateCompanyParams(
            companyName: _companyNameCtrl.text,
            socialReason: _socialReasonCtrl.text,
            companyAddress: _companyAddressCtrl.text,
            companyParishId: _companyParishId,
            companyCountry: _companyCountry,
            companyEmails: _emailsCompany
                .map((e) => e.text.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
            companyPhones: _phonesCompany
                .map((e) => e.text.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
            identificationType: _identificationTypeCompany,
          ),
        );
      }

      // === PASO 2: ACOMETIDA ===
      if (_cadastralKeyCtrl.text.trim().isNotEmpty) {
        final lat = double.tryParse(_latitudeCtrl.text) ?? 0.0;
        final lng = double.tryParse(_longitudeCtrl.text) ?? 0.0;
        final alt = double.tryParse(_accuracyCtrl.text) ?? 0.0;
        final prec = double.tryParse(_precisionCtrl.text) ?? 0.0;

        await di.sl<UpdateConnectionUseCase>()(
          connectionId: widget.connection.connectionId,
          params: UpdateConnectionParams(
            clientId: _isNaturalPerson
                ? _identificationCtrl.text
                : _rucCtrl.text,
            connectionRateId: _getRateId(_rateName),
            connectionRateName: _rateName!,
            connectionMeterNumber: _meterNumberCtrl.text,
            connectionContractNumber: _contractNumberCtrl.text,
            connectionSewerage: _sewerage,
            connectionStatus: _status,
            connectionAddress: _connectionAddressCtrl.text,
            connectionInstallationDate: _installationDateCtrl.text.isNotEmpty
                ? _installationDateCtrl.text
                : DateTime.now().toIso8601String(),
            connectionPeopleNumber: int.tryParse(_peopleNumberCtrl.text) ?? 1,
            connectionZone: int.tryParse(_zoneCtrl.text) ?? 1,
            longitude: lng,
            latitude: lat,
            connectionReference: _referenceCtrl.text,
            connectionAltitude: alt,
            connectionPrecision: prec,
            connectionGeolocationDate: _geolocationDateCtrl.text.isNotEmpty
                ? _geolocationDateCtrl.text
                : DateTime.now().toIso8601String(),
            zoneId: _getZoneId(_zoneName),
          ),
        );
      }

      // === ÉXITO FINAL ===
      _showSuccess();
    } catch (e) {
      String stepName = _isNaturalPerson || _isCompany
          ? 'cliente'
          : 'acometida';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar $stepName: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      client.close();
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  int _getRateId(String? rate) => rate == 'BENEFICENCIA'
      ? 1
      : rate == 'RESIDENCIAL'
      ? 2
      : rate == 'INDUSTRIAL'
      ? 3
      : 6;

  int _getZoneId(String? zone) => zone == 'ZONA 1'
      ? 1
      : zone == 'ZONA 2'
      ? 2
      : zone == 'ZONA 3'
      ? 3
      : zone == 'ZONA 4'
      ? 4
      : 0;

  @override
  Widget build(BuildContext context) {
    final currentPage = _pageController.hasClients
        ? _pageController.page ?? 0.0
        : 0.0;
    final currentStep = currentPage.round();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: context.iconMedium),
          onPressed: _prevStep,
        ),
        title: Text(
          'Editar ${widget.connection.connectionId}',
          style: context.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.close,
                size: context.iconMedium,
                color: AppColors.surface,
              ),
            ),
            onPressed: () {
              context.pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCustomStepper(currentStep),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildClientStep(), _buildConnectionStep()],
            ),
          ),
          _buildBottomBar(currentStep),
        ],
      ),
    );
  }

  Widget _buildCustomStepper(int currentStep) {
    return Container(
      color: AppColors.shadow.withOpacity(0.8),
      padding: EdgeInsets.symmetric(vertical: context.smallSpacing * 1.2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(width: 35),
          _buildStepIcon(0, Icons.person, currentStep),
          _buildStepConnector(1, currentStep),
          _buildStepIcon(1, Icons.water_drop, currentStep),
          const SizedBox(width: 35),
        ],
      ),
    );
  }

  Widget _buildStepIcon(int index, IconData baseIcon, int currentStep) {
    final isActive = currentStep == index;
    final isCompleted = currentStep > index;
    final hasError = _stepErrors[index] != null;

    IconData icon;
    Color bg;
    Color color = Colors.white;

    if (hasError) {
      icon = Icons.error;
      bg = AppColors.error;
    } else if (isCompleted) {
      icon = Icons.check;
      bg = AppColors.secondary;
    } else if (isActive) {
      icon = baseIcon;
      bg = AppColors.accent;
    } else {
      icon = baseIcon;
      bg = AppColors.primary.withOpacity(0.3);
      color = Colors.white70;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bg,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: bg.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Icon(icon, color: color, size: context.iconMedium),
    );
  }

  Widget _buildStepConnector(int nextIndex, int currentStep) {
    final isCompleted = currentStep > nextIndex - 1;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 3,
        margin: EdgeInsets.symmetric(horizontal: context.smallSpacing),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.white : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildClientStep() => SingleChildScrollView(
    padding: context.screenPadding,
    child: Form(
      key: _formKeys[0],
      child: Column(
        children: [
          _buildSummaryCard(),
          context.vSpace(0.0),
          FormCard(
            title: 'Tipo de Cliente',
            child: Center(
              child: SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text(
                      'Persona Natural',
                      style: TextStyle(
                        color: _isNaturalPerson
                            ? Colors.white
                            : AppColors.textPrimary.withOpacity(0.6),
                      ),
                    ),
                    icon: Icon(
                      Icons.verified_user,
                      color: _isNaturalPerson
                          ? Colors.white
                          : AppColors.textPrimary.withOpacity(0.6),
                    ),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text(
                      'Empresa',
                      style: TextStyle(
                        color: _isCompany
                            ? Colors.white
                            : AppColors.textPrimary.withOpacity(0.6),
                      ),
                    ),
                    icon: Icon(
                      Icons.business,
                      color: _isCompany
                          ? Colors.white
                          : AppColors.textPrimary.withOpacity(0.6),
                    ),
                  ),
                ],
                selected: {_isNaturalPerson},
                onSelectionChanged: (v) {
                  setState(() {
                    _isNaturalPerson = v.first;
                    _isCompany = !v.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (s) => s.contains(WidgetState.selected)
                        ? AppColors.primary
                        : AppColors.surface.withOpacity(0.6),
                  ),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        context.mediumBorderRadiusValue,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          context.vSpace(0.0),
          if (_isNaturalPerson)
            NaturalPersonForm(
              firstNameCtrl: _firstNameCtrl,
              lastNameCtrl: _lastNameCtrl,
              identificationCtrl: _identificationCtrl,
              dobCtrl: _dobCtrl,
              addressCtrl: _addressCtrl,
              emails: _emailsNatural,
              phones: _phonesNatural,
              onSelectDate: () => _selectDate(_dobCtrl),
            )
          else if (_isCompany)
            CompanyForm(
              companyNameCtrl: _companyNameCtrl,
              socialReasonCtrl: _socialReasonCtrl,
              rucCtrl: _rucCtrl,
              companyAddressCtrl: _companyAddressCtrl,
              emails: _emailsCompany,
              phones: _phonesCompany,
            ),
        ],
      ),
    ),
  );

  Widget _buildSummaryCard() {
    final clientName = widget.connection.person != null
        ? '${widget.connection.person!.firstName} ${widget.connection.person!.lastName}'
        : widget.connection.company?.businessName ?? 'Sin nombre';
    return FormCard(
      title: 'Información General',
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(
              _isCompany ? Icons.business : Icons.person,
              color: AppColors.primary,
              size: context.iconMedium,
            ),
          ),
          context.hSpace(0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.connection.connectionId,
                  style: context.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  clientName,
                  style: context.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.connection.connectionAddress,
                  style: context.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStep() => SingleChildScrollView(
    padding: context.screenPadding,
    child: Form(
      key: _formKeys[1],
      child: Column(
        children: [
          FormCard(
            title: 'Datos de la Acometida',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _cadastralKeyCtrl,
                        label: 'Clave Catastral',
                        icon: Icons.vpn_key,
                      ),
                    ),
                    context.hSpace(0.025),
                    Expanded(
                      child: CustomTextField(
                        controller: _meterNumberCtrl,
                        label: 'Número de Medidor',
                        icon: Icons.water_drop,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _installationDateCtrl,
                        label: 'Fecha de Instalación',
                        icon: Icons.calendar_today,
                        readOnly: true,
                        onTap: () => _selectDate(_installationDateCtrl),
                      ),
                    ),
                    context.hSpace(0.025),
                    Expanded(
                      child: CustomTextField(
                        controller: _peopleNumberCtrl,
                        label: 'Número de Personas',
                        icon: Icons.group,
                        keyboardType: TextInputType.number,
                        validator: numberValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _validRates.contains(_rateName)
                            ? _rateName
                            : null,
                        hint: const Text('Tarifa'),
                        decoration: _dropdownDecoration('Tarifa'),
                        items: _validRates
                            .map(
                              (r) => DropdownMenuItem(
                                value: r,
                                child: Text(
                                  r,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _rateName = v),
                      ),
                    ),
                    context.hSpace(0.02),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _validZones.contains(_zoneName)
                            ? _zoneName
                            : null,
                        hint: const Text('Zona'),
                        decoration: _dropdownDecoration('Zona'),
                        items: _validZones
                            .map(
                              (r) => DropdownMenuItem(
                                value: r,
                                child: Text(
                                  r,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _zoneName = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _connectionAddressCtrl,
                  label: 'Dirección',
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _referenceCtrl,
                  label: 'Referencia',
                  icon: Icons.pin_drop,
                  isRequired: false,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildSwitchCard(
                      'Alcantarillado',
                      _sewerage,
                      (v) => setState(() => _sewerage = v),
                    ),
                    _buildSwitchCard(
                      'Estado Activo',
                      _status,
                      (v) => setState(() => _status = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GpsSection(
            latitudeCtrl: _latitudeCtrl,
            longitudeCtrl: _longitudeCtrl,
            accuracyCtrl: _accuracyCtrl,
            countryCtrl: _countryCtrl,
            provinceCtrl: _provinceCtrl,
            cantonCtrl: _cantonCtrl,
            addressFullCtrl: _addressFullCtrl,
            precisionCtrl: _precisionCtrl,
            geolocationDateCtrl: _geolocationDateCtrl,
            onGetLocation: _getCurrentLocationAndAddress,
            onOpenMap: _openMap,
            isGettingLocation: _isGettingLocation,
            animationController: _animationController,
            scaleAnimation: _scaleAnimation,
          ),
        ],
      ),
    ),
  );

  InputDecoration _dropdownDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      fontSize: 12,
      color: Colors.grey,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: AppColors.surface.withOpacity(0.3),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    isDense: true,
  );

  Widget _buildBottomBar(int currentStep) => Container(
    padding: context.screenPadding,
    decoration: BoxDecoration(
      color: AppColors.card,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 12,
          offset: const Offset(0, -3),
        ),
      ],
    ),
    child: Row(
      children: [
        if (currentStep > 0)
          Expanded(
            child: ActionButton(
              label: 'Anterior',
              icon: Icons.arrow_back,
              color: AppColors.textSecondary.withOpacity(0.8),
              onPressed: _prevStep,
            ),
          ),
        if (currentStep > 0) context.hSpace(0.02),
        Expanded(
          child: ActionButton(
            label: currentStep == 1 ? 'Finalizar' : 'Siguiente',
            icon: currentStep == 1 ? Icons.check : Icons.arrow_forward,
            color: AppColors.secondary,
            onPressed: _nextStep,
            loading: _isSubmitting,
          ),
        ),
      ],
    ),
  );

  Widget _buildSwitchCard(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) => Expanded(
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: context.smallSpacing * 0.5),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.4),
        borderRadius: BorderRadius.circular(context.smallBorderRadiusValue),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: context.bodyMedium.copyWith(fontWeight: FontWeight.w500),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        contentPadding: EdgeInsets.symmetric(horizontal: context.smallSpacing),
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.smallBorderRadiusValue),
        ),
      ),
    ),
  );
}
