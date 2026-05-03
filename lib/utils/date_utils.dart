/// returns date in dd-MM-yyyy format
String formatDate(DateTime date) {
  return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
}

/// returns time in HH:mm format
String formatTime(DateTime date) {
  return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
}

/// returns date and time in dd-MM-yyyy HH:mm format
String formatDateTime(DateTime date) {
  return "${formatDate(date)} ${formatTime(date)}";
}

/// converts ISO 8601 date string to dd-MM-yyyy format
String formatFromIsoDate(String isoDate, {String pattern = 'dd-MM-yyyy'}) {
  try {
    DateTime date = DateTime.parse(isoDate);
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  } catch (e) {
    return isoDate;
  }
}

/// Safely parses [raw] using multiple strategies and formats it as
/// "dd-MM-yyyy HH:mm". Returns the raw string (or '—') on failure.
///
/// Handles common API date formats:
///   • ISO 8601 with/without fractional seconds  (2026-05-02T12:00:00.123Z)
///   • Date-only strings                          (2026-05-02)
///   • Strings with space separator               (2026-05-02 12:00:00)
String safeFormatDateTime(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '—';

  // Strategy 1: direct parse (covers ISO 8601 and most variants)
  try {
    return formatDateTime(DateTime.parse(raw.trim()));
  } catch (_) {}

  // Strategy 2: replace space separator with 'T' (e.g. "2026-05-02 12:00:00")
  try {
    return formatDateTime(DateTime.parse(raw.trim().replaceFirst(' ', 'T')));
  } catch (_) {}

  // Strategy 3: date-only (yyyy-MM-dd)
  try {
    final parts = raw.trim().split('-');
    if (parts.length == 3) {
      final dt = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2].substring(0, 2)),
      );
      return formatDate(dt);
    }
  } catch (_) {}

  // Fallback: return raw value so the UI still shows something
  return raw;
}
