import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/offline_reading.dart';
import 'package:flutter_application/features/reading-routes/domain/entities/route_connection_item.dart';
import 'package:geolocator/geolocator.dart';

class TakeRouteReadingDialog extends StatefulWidget {
  final RouteConnectionItem connection;
  final int assignmentId;
  final Function(OfflineReading reading) onSave;

  const TakeRouteReadingDialog({
    super.key,
    required this.connection,
    required this.assignmentId,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required RouteConnectionItem connection,
    required int assignmentId,
    required Function(OfflineReading reading) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TakeRouteReadingDialog(
        connection: connection,
        assignmentId: assignmentId,
        onSave: onSave,
      ),
    );
  }

  @override
  State<TakeRouteReadingDialog> createState() => _TakeRouteReadingDialogState();
}

class _TakeRouteReadingDialogState extends State<TakeRouteReadingDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _readingController;
  late final TextEditingController _observationsController;

  String _selectedNovelty = 'NORMAL';
  Position? _capturedPosition;
  bool _isLoadingGps = false;
  String? _gpsStatusMessage;

  final List<String> _noveltyOptions = [
    'NORMAL',
    'CONSUMO BAJO',
    'ALERTA CONSUMO ALTO',
    'ALERTA CONSUMO BAJO',
    'CONSUMO EXCESIVO',
    'LECTURA INVÁLIDA',
    'SIN LECTURA',
    'MEDIDOR EMPAÑADO',
    'MEDIDOR TRABADO / DAÑADO',
    'SIN ACCESO / PREDIO CERRADO',
    'PERRO BRAVO',
    'FUGA EN MEDIDOR',
  ];

  @override
  void initState() {
    super.initState();
    _readingController = TextEditingController(
      text: widget.connection.lecturaActual != null
          ? widget.connection.lecturaActual.toString()
          : '',
    );
    _observationsController = TextEditingController(
      text: widget.connection.observaciones ?? '',
    );
    if (widget.connection.novedadId != null &&
        _noveltyOptions.contains(widget.connection.novedadId)) {
      _selectedNovelty = widget.connection.novedadId!;
    }
    _captureGps();
  }

  @override
  void dispose() {
    _readingController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _captureGps() async {
    setState(() {
      _isLoadingGps = true;
      _gpsStatusMessage = 'Obteniendo GPS...';
    });

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      if (mounted) {
        setState(() {
          _capturedPosition = pos;
          _isLoadingGps = false;
          _gpsStatusMessage = 'GPS capturado (±${pos.accuracy.toStringAsFixed(1)}m)';
        });
      }
    } catch (_) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (mounted) {
          setState(() {
            _capturedPosition = last;
            _isLoadingGps = false;
            _gpsStatusMessage = last != null ? 'GPS de última posición' : 'GPS no disponible';
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoadingGps = false;
            _gpsStatusMessage = 'GPS no disponible';
          });
        }
      }
    }
  }

  double? get _currentEnteredValue => double.tryParse(_readingController.text.trim());

  double? get _calculatedConsumption {
    final cur = _currentEnteredValue;
    final prev = widget.connection.lecturaAnterior;
    if (cur != null && prev != null) {
      return cur - prev;
    }
    return null;
  }

  bool get _isReadingLowerThanPrevious {
    final cur = _currentEnteredValue;
    final prev = widget.connection.lecturaAnterior;
    return cur != null && prev != null && cur < prev;
  }

  bool get _isConsumptionExcessive {
    final cons = _calculatedConsumption;
    final avg = widget.connection.consumoPromedio;
    return cons != null && avg != null && avg > 0 && cons > (avg * 2.0);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final readingVal = _currentEnteredValue ?? 0.0;
    final novelty = _selectedNovelty == 'NORMAL' ? null : _selectedNovelty;
    final observations = _observationsController.text.trim();

    final reading = OfflineReading(
      idDetalleAvance: widget.connection.idDetalle,
      acometidaId: widget.connection.acometidaId,
      lecturaActual: readingVal,
      fechaHoraCaptura: DateTime.now(),
      latitudGps: _capturedPosition?.latitude ?? widget.connection.latitud,
      longitudGps: _capturedPosition?.longitude ?? widget.connection.longitud,
      novedadId: novelty,
      observaciones: observations.isNotEmpty ? observations : null,
      asignacionId: widget.assignmentId,
    );

    widget.onSave(reading);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? cs.surfaceContainer : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title and sequence badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '#${widget.connection.orden}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Acometida ${widget.connection.acometidaId}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          widget.connection.abonado,
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Reference values card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ReferencePill(
                      label: 'Medidor',
                      value: widget.connection.numeroMedidor ?? 'S/N',
                      icon: Icons.speed_rounded,
                    ),
                    _ReferencePill(
                      label: 'Lectura Anterior',
                      value: widget.connection.lecturaAnterior != null
                          ? '${widget.connection.lecturaAnterior!.toStringAsFixed(1)} m³'
                          : '--',
                      icon: Icons.history_rounded,
                    ),
                    _ReferencePill(
                      label: 'Consumo Promedio',
                      value: widget.connection.consumoPromedio != null
                          ? '${widget.connection.consumoPromedio!.toStringAsFixed(1)} m³'
                          : '--',
                      icon: Icons.water_drop_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Reading Input field
              Text(
                'Lectura Actual (m³)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _readingController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  hintText: '0.0',
                  suffixText: 'm³',
                  prefixIcon: const Icon(Icons.pin_rounded),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: cs.primary),
                  ),
                ),
                onChanged: (_) => setState(() {}),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    if (_selectedNovelty != 'SIN LECTURA' &&
                        _selectedNovelty != 'SIN ACCESO / PREDIO CERRADO' &&
                        _selectedNovelty != 'PERRO BRAVO') {
                      return 'Por favor ingresa la lectura o selecciona novedad';
                    }
                  }
                  return null;
                },
              ),

              // Calculated Consumption & Alerts
              if (_calculatedConsumption != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Consumo estimado del mes: ',
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                    Text(
                      '${_calculatedConsumption!.toStringAsFixed(1)} m³',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _isReadingLowerThanPrevious
                            ? Colors.red
                            : (_isConsumptionExcessive ? Colors.orange.shade800 : Colors.green.shade700),
                      ),
                    ),
                  ],
                ),
              ],

              // Warning Banner: Reading Lower than Previous
              if (_isReadingLowerThanPrevious) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_rounded, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '¡Alerta! La lectura actual es menor que la anterior. Verifique si el medidor se reinició o hubo error de tipeo.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Warning Banner: Excessive Consumption
              if (_isConsumptionExcessive) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Colors.orange.shade800, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Consumo superior al 200% del promedio histórico (${widget.connection.consumoPromedio} m³). Se sugiere registrar novedad si sospecha fuga.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Novelty Dropdown
              Text(
                'Novedad / Observación Técnica',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedNovelty,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.report_problem_outlined),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: _noveltyOptions.map((opt) {
                  return DropdownMenuItem(
                    value: opt,
                    child: Text(
                      opt,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: opt == 'NORMAL' ? FontWeight.normal : FontWeight.w700,
                        color: opt == 'NORMAL' ? null : Colors.orange.shade800,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedNovelty = val);
                },
              ),

              const SizedBox(height: 14),

              // Observations text field
              Text(
                'Observaciones Adicionales (Opcional)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _observationsController,
                maxLines: 2,
                style: const TextStyle(fontSize: 12.5),
                decoration: InputDecoration(
                  hintText: 'Detalles de acceso, estado del predio...',
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),

              const SizedBox(height: 14),

              // GPS Status Row
              Row(
                children: [
                  Icon(
                    _capturedPosition != null ? Icons.my_location_rounded : Icons.location_searching_rounded,
                    size: 16,
                    color: _capturedPosition != null ? Colors.green.shade600 : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _gpsStatusMessage ?? 'Buscando GPS...',
                      style: TextStyle(
                        fontSize: 11,
                        color: _capturedPosition != null ? Colors.green.shade700 : cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (_isLoadingGps)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    TextButton.icon(
                      onPressed: _captureGps,
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      icon: const Icon(Icons.refresh_rounded, size: 14),
                      label: const Text('Recapturar GPS', style: TextStyle(fontSize: 11)),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: cs.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.save_rounded, color: Colors.white),
                  label: const Text(
                    'Guardar Lectura',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReferencePill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ReferencePill({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
