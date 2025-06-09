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
      id: json['id'] as String,
      term: json['term'] as String,
      english: _parseNullableString(json['english']),
      reading: json['reading'] as String,
      description: json['description'] as String,
      relatedTerms: (json['relatedTerms'] ?? json['related_terms']) != null
          ? List<String>.from(
              (json['relatedTerms'] ?? json['related_terms']) as List<dynamic>)
          : null,
      examExample:
          _parseNullableString(json['examExample'] ?? json['exam_example']),
      examPoint:
          _parseNullableString(json['examPoint'] ?? json['exam_point']),
      practicalTip:
          _parseNullableString(json['practicalTip'] ?? json['practical_tip']),
      categoryLarge:
          (json['categoryLarge'] ?? json['category_large']) as String,
      categoryMedium:
          (json['categoryMedium'] ?? json['category_medium']) as String,
      categorySmall:
          (json['categorySmall'] ?? json['category_small']) as String,
      categoryItem: (json['categoryItem'] ?? json['category_item']) as String,
      importance: _parseDouble(json['importance']),
    );
  }
}
