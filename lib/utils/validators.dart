// lib/core/utils/validators.dart
String? emailValidator(String? value) {
  // Si está vacío o solo espacios → permitido (NO requerido)
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  // Si tiene contenido, debe cumplir con formato de email
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value.trim())) {
    return 'Email inválido';
  }

  return null;
}

String? phoneValidator(String? value) {
  // Si está vacío o solo espacios → permitido (NO requerido)
  if (value == null || value.trim().isEmpty) {
    return 'Teléfono requerido';
  }

  // Si tiene contenido, debe cumplir con formato de teléfono
  if (value.trim().length < 7) {
    return 'Teléfono inválido (mín 7 dígitos)';
  }

  return null;
}

String? numberValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Número requerido';
  }
  if (double.tryParse(value.trim()) == null) {
    return 'Número inválido';
  }
  return null;
}

String? requiredValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Campo requerido';
  }
  return null;
}

// Valida que el formato sea yyyy-mm y no sea una fecha en el futuro
String? monthReadingValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Campo requerido';
  }

  final trimmedValue = value.trim();

  // Validar formato estricto: 4 dígitos, guión, 2 dígitos (ej. 2026-01)
  if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(trimmedValue)) {
    return 'Formato inválido (usa AAAA-MM)';
  }

  try {
    final parts = trimmedValue.split('-');
    int year = int.parse(parts[0]);
    int month = int.parse(parts[1]);

    if (month < 1 || month > 12) {
      return 'Mes inválido';
    }

    final now = DateTime.now();
    int nowYear = now.year;
    int nowMonth = now.month;

    if (year > nowYear) {
      return 'Año inválido';
    }

    // Si es el año actual, el mes no puede ser mayor al mes actual
    if (year == nowYear && month > nowMonth) {
      return 'Mes no puede ser futuro';
    }

    // NOTA: Si necesitas que sea EXCLUSIVAMENTE el mes actual, usa esto en su lugar:
    // if (year != nowYear || month != nowMonth) {
    //   return 'Debe ser el mes actual';
    // }
  } catch (e) {
    return 'Formato inválido';
  }

  return null;
}

// Retorna mes: 2026-09 then 2026-10
String nextReadingMonthValidator(String previousMonth) {
  final parts = previousMonth.split('-');
  int year = int.parse(parts[0]);
  int month = int.parse(parts[1]);

  if (month == 12) {
    month = 1;
    year++;
  } else {
    month++;
  }

  return '$year-${month.toString().padLeft(2, '0')}';
}
