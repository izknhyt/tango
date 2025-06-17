// lib/flashcard_model.dart

class Flashcard {
  final String id;
  final String term;
  final String? english; // "ー" や "nan" の場合は null として扱う
  final String reading;
  final String description;
  final List<String>? relatedIds;
  final List<String>? tags;
  final String? examExample;
  final String? examPoint;
  final String? practicalTip;
  final String categoryLarge;
  final String categoryMedium;
  final String categorySmall;
  final String categoryItem;
  final double importance; // JSONでは数値だが、念のためnumで受けてdoubleに変換

  Flashcard({
    required this.id,
    required this.term,
    this.english,
    required this.reading,
    required this.description,
    this.relatedIds,
    this.tags,
    this.examExample,
    this.examPoint,
    this.practicalTip,
    required this.categoryLarge,
    required this.categoryMedium,
    required this.categorySmall,
    required this.categoryItem,
    required this.importance,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    // CamelCase キーと snake_case キーのどちらでも取得できるようにする
    dynamic _get(String camelCaseKey) {
      if (json.containsKey(camelCaseKey)) return json[camelCaseKey];
      final snakeCaseKey = camelCaseKey
          .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'),
              (m) => '${m[1]}_${m[2]}')
          .toLowerCase();
      return json[snakeCaseKey];
    }

    // JSONの "nan" や "ー" を null に変換するヘルパー関数
    String? _parseNullableString(dynamic value) {
      if (value is String && (value.toLowerCase() == 'nan' || value == 'ー')) {
        return null;
      }
      return value as String?;
    }

    // importance が 文字列 "nan" の場合や数値でない場合のフォールバック
    double _parseDouble(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        final doubleValue = double.tryParse(value);
        if (doubleValue != null) {
          return doubleValue;
        }
      }
      return 0.0; // デフォルト値またはエラー処理に適した値
    }

    List<String>? _parseStringList(dynamic value) {
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

    final relatedIds = _parseStringList(_get('relatedIds'));
    final tags = _parseStringList(_get('tags'));

    return Flashcard(
      id: _get('id') as String,
      term: _get('term') as String,
      english: _parseNullableString(_get('english')),
      reading: _get('reading') as String,
      description: _get('description') as String,
      relatedIds: relatedIds,
      tags: tags,
      examExample: _parseNullableString(_get('examExample')),
      examPoint: _parseNullableString(_get('examPoint')),
      practicalTip: _parseNullableString(_get('practicalTip')),
      categoryLarge: _get('categoryLarge') as String,
      categoryMedium: _get('categoryMedium') as String,
      categorySmall: _get('categorySmall') as String,
      categoryItem: _get('categoryItem') as String,
      importance: _parseDouble(_get('importance')),
    );
  }
}
