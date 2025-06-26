extension JsonKeyLookup on Map<String, dynamic> {
  dynamic getFlexible(String camelCaseKey) {
    if (containsKey(camelCaseKey)) return this[camelCaseKey];
    final snakeCaseKey = camelCaseKey
        .replaceAllMapped(
            RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
        .toLowerCase();
    return this[snakeCaseKey];
  }
}
