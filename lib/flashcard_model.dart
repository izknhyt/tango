// lib/flashcard_model.dart

class Flashcard {
  final String id;
  final String term;
  final String? english; // "ー" や "nan" の場合は null として扱う
  final String reading;
  final String description;
  final List<String>? relatedTerms;
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
    this.relatedTerms,
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
    // JSONの "nan" や "ー" を null に変換するヘルパー関数
    String? _parseNullableString(dynamic value) {
      if (value is String && (value.toLowerCase() == 'nan' || value == 'ー')) {
        return null;
      }
      return value as String?;
    }

    // 複数のキー候補から値を取得するヘルパー
    dynamic _valueForKeys(List<String> keys) {
      for (final key in keys) {
        if (json.containsKey(key)) {
          return json[key];
        }
      }
      return null;
    }

    // relatedTerms フィールドは配列またはカンマ区切りの文字列を許容する
    List<String>? _parseRelatedTerms() {
      final val = _valueForKeys(['relatedTerms', 'related_terms']);
      if (val == null) return null;
      if (val is List) {
        return List<String>.from(val);
      }
      if (val is String && val.trim().isNotEmpty) {
        return val.split(',').map((e) => e.trim()).toList();
      }
      return null;
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

    return Flashcard(
      id: _valueForKeys(['id', 'ID']) as String,
      term: _valueForKeys(['term']) as String,
      english: _parseNullableString(_valueForKeys(['english'])),
      reading: _valueForKeys(['reading']) as String,
      description: _valueForKeys(['description']) as String,
      relatedTerms: _parseRelatedTerms(),
      examExample:
          _parseNullableString(_valueForKeys(['examExample', 'exam_example'])),
      examPoint:
          _parseNullableString(_valueForKeys(['examPoint', 'exam_point'])),
      practicalTip:
          _parseNullableString(_valueForKeys(['practicalTip', 'practical_tip'])),
      categoryLarge:
          _valueForKeys(['categoryLarge', 'category_large']) as String,
      categoryMedium:
          _valueForKeys(['categoryMedium', 'category_medium']) as String,
      categorySmall:
          _valueForKeys(['categorySmall', 'category_small']) as String,
      categoryItem:
          _valueForKeys(['categoryItem', 'category_item']) as String,
      importance:
          _parseDouble(_valueForKeys(['importance'])),
    );
  }
}
