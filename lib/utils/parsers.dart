String? parseNullableString(dynamic value) {
  if (value is String && (value.toLowerCase() == 'nan' || value == 'ー')) {
    return null;
  }
  return value as String?;
}

double parseDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    final doubleValue = double.tryParse(value);
    if (doubleValue != null) {
      return doubleValue;
    }
  }
  return 0.0;
}

List<String>? parseStringList(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty ||
        trimmed.toLowerCase() == 'nan' ||
        trimmed == 'ー') {
      return null;
    }
    return trimmed.split(',').map((e) => e.trim()).toList();
  }
  return null;
}

DateTime? parseDate(dynamic v) {
  if (v is DateTime) return v;
  if (v is String) {
    return DateTime.tryParse(v);
  }
  return null;
}
