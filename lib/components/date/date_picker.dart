import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ProfessionalDatePickerMode {
  yearOnly, // Solo año
  monthYear, // Mes + Año
  fullDate, // Día + Mes + Año
}

class ProfessionalDatePicker extends StatefulWidget {
  final ProfessionalDatePickerMode mode;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? label;
  final String? hint;
  final ValueChanged<DateTime>? onDateSelected;
  final ValueChanged<String>? onFormattedSelected; // útil si quieres "2025-03" o "2025"
  final bool showClearButton;
  final InputDecoration? decoration;
  final TextStyle? textStyle;
  final IconData? prefixIcon;

  const ProfessionalDatePicker({
    super.key,
    this.mode = ProfessionalDatePickerMode.monthYear,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.label,
    this.hint,
    this.onDateSelected,
    this.onFormattedSelected,
    this.showClearButton = false,
    this.decoration,
    this.textStyle,
    this.prefixIcon,
  });

  /// Abre directamente el diálogo de selección de fecha según el [mode].
  /// Retorna el [DateTime] seleccionado o null si fue cancelado.
  static Future<DateTime?> show({
    required BuildContext context,
    ProfessionalDatePickerMode mode = ProfessionalDatePickerMode.monthYear,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    ValueChanged<DateTime>? onDateSelected,
    ValueChanged<String>? onFormattedSelected,
  }) async {
    final now = DateTime.now();
    final effectiveInitial = initialDate ?? DateTime(now.year, now.month);
    final effectiveFirst = firstDate ?? DateTime(2000);
    final effectiveLast = lastDate ?? DateTime(now.year, now.month, now.day);

    DateTime? picked;

    switch (mode) {
      case ProfessionalDatePickerMode.yearOnly:
        picked = await showDialog<DateTime>(
          context: context,
          builder: (dialogContext) {
            int selectedYear = effectiveInitial.year;
            return AlertDialog(
              title: const Text('Seleccionar año'),
              content: SizedBox(
                width: 300,
                height: 300,
                child: YearPicker(
                  firstDate: effectiveFirst,
                  lastDate: effectiveLast,
                  selectedDate: DateTime(selectedYear),
                  onChanged: (date) {
                    selectedYear = date.year;
                    Navigator.of(dialogContext).pop(DateTime(selectedYear));
                  },
                ),
              ),
            );
          },
        );
        break;

      case ProfessionalDatePickerMode.monthYear:
        picked = await showDialog<DateTime>(
          context: context,
          builder: (dialogContext) {
            return _MonthYearPickerDialog(
              initialDate: effectiveInitial,
              firstDate: effectiveFirst,
              lastDate: effectiveLast,
            );
          },
        );
        break;

      case ProfessionalDatePickerMode.fullDate:
        DateTime initialFull = effectiveInitial;
        if (initialFull.isBefore(effectiveFirst)) initialFull = effectiveFirst;
        if (initialFull.isAfter(effectiveLast)) initialFull = effectiveLast;

        picked = await showDatePicker(
          context: context,
          initialDate: initialFull,
          firstDate: effectiveFirst,
          lastDate: effectiveLast,
          builder: (builderContext, child) {
            return Theme(
              data: Theme.of(builderContext).copyWith(
                colorScheme: Theme.of(builderContext).colorScheme.copyWith(
                  primary: Theme.of(builderContext).colorScheme.primary,
                ),
              ),
              child: child!,
            );
          },
        );
        break;
    }

    if (picked != null) {
      onDateSelected?.call(picked);
      onFormattedSelected?.call(formatValue(picked, mode));
    }

    return picked;
  }

  static String formatValue(DateTime date, ProfessionalDatePickerMode mode) {
    switch (mode) {
      case ProfessionalDatePickerMode.yearOnly:
        return DateFormat('yyyy').format(date);
      case ProfessionalDatePickerMode.monthYear:
        return DateFormat('yyyy-MM').format(date);
      case ProfessionalDatePickerMode.fullDate:
        return DateFormat('yyyy-MM-dd').format(date);
    }
  }

  static String formatDisplayText(DateTime date, ProfessionalDatePickerMode mode) {
    switch (mode) {
      case ProfessionalDatePickerMode.yearOnly:
        return DateFormat('yyyy').format(date);
      case ProfessionalDatePickerMode.monthYear:
        return DateFormat('MMMM yyyy', 'es').format(date);
      case ProfessionalDatePickerMode.fullDate:
        return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  @override
  State<ProfessionalDatePicker> createState() => _ProfessionalDatePickerState();
}

class _ProfessionalDatePickerState extends State<ProfessionalDatePicker> {
  late DateTime _selectedDate;
  late DateTime _firstDate;
  late DateTime _lastDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = widget.initialDate ?? DateTime(now.year, now.month);
    _firstDate = widget.firstDate ?? DateTime(2000);
    _lastDate = widget.lastDate ?? DateTime(now.year, now.month, now.day);
  }

  @override
  void didUpdateWidget(covariant ProfessionalDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate != null && widget.initialDate != oldWidget.initialDate) {
      _selectedDate = widget.initialDate!;
    }
  }

  String get _displayText =>
      ProfessionalDatePicker.formatDisplayText(_selectedDate, widget.mode);

  String get _formattedValue =>
      ProfessionalDatePicker.formatValue(_selectedDate, widget.mode);

  Future<void> _pick() async {
    final picked = await ProfessionalDatePicker.show(
      context: context,
      mode: widget.mode,
      initialDate: _selectedDate,
      firstDate: _firstDate,
      lastDate: _lastDate,
    );

    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
      widget.onDateSelected?.call(picked);
      widget.onFormattedSelected?.call(_formattedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: _pick,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: (widget.decoration ??
                InputDecoration(
                  labelText: widget.label,
                  hintText: widget.hint ?? 'Seleccionar',
                  prefixIcon: Icon(
                    widget.prefixIcon ?? Icons.calendar_month_rounded,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ))
            .copyWith(
              suffixIcon: widget.showClearButton
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        final now = DateTime.now();
                        setState(() {
                          _selectedDate = now;
                        });
                        widget.onDateSelected?.call(_selectedDate);
                        widget.onFormattedSelected?.call(_formattedValue);
                      },
                    )
                  : const Icon(Icons.arrow_drop_down_rounded),
            ),
        child: Text(
          _displayText,
          style: widget.textStyle ?? theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}

/// Dialog interno profesional para Mes + Año
class _MonthYearPickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _MonthYearPickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  late int _selectedYear;
  late int _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final months = List.generate(12, (i) => i + 1);

    return AlertDialog(
      title: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _selectedYear > widget.firstDate.year
                ? () => setState(() => _selectedYear--)
                : null,
          ),
          Expanded(
            child: Text(
              '$_selectedYear',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _selectedYear < widget.lastDate.year
                ? () => setState(() => _selectedYear++)
                : null,
          ),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final month = months[index];
            final isSelected =
                month == _selectedMonth &&
                _selectedYear == widget.initialDate.year;
            final isDisabled =
                (_selectedYear == widget.firstDate.year &&
                    month < widget.firstDate.month) ||
                (_selectedYear == widget.lastDate.year &&
                    month > widget.lastDate.month);

            return Material(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: isDisabled
                    ? null
                    : () {
                        setState(() => _selectedMonth = month);
                        Navigator.of(
                          context,
                        ).pop(DateTime(_selectedYear, month));
                      },
                child: Center(
                  child: Text(
                    DateFormat('MMM', 'es').format(DateTime(2020, month)),
                    style: TextStyle(
                      color: isDisabled
                          ? theme.disabledColor
                          : isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
