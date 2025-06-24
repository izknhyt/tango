// lib/flashcard_model.dart

import 'utils/json_extensions.dart';

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
  final DateTime? lastReviewed;
  final DateTime? nextDue;
  final int wrongCount;
  final int correctCount;

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
    this.lastReviewed,
    this.nextDue,
    this.wrongCount = 0,
    this.correctCount = 0,
  });

  Flashcard copyWith({
    DateTime? lastReviewed,
    DateTime? nextDue,
    int? wrongCount,
    int? correctCount,
  }) {
    return Flashcard(
      id: id,
      term: term,
      english: english,
      reading: reading,
      description: description,
      relatedIds: relatedIds,
      tags: tags,
      examExample: examExample,
      examPoint: examPoint,
      practicalTip: practicalTip,
      categoryLarge: categoryLarge,
      categoryMedium: categoryMedium,
      categorySmall: categorySmall,
      categoryItem: categoryItem,
      importance: importance,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      nextDue: nextDue ?? this.nextDue,
      wrongCount: wrongCount ?? this.wrongCount,
      correctCount: correctCount ?? this.correctCount,
    );
  }

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

    final relatedIds = _parseStringList(json.getFlexible('relatedIds'));
    final tags = _parseStringList(json.getFlexible('tags'));
    DateTime? _parseDate(dynamic v) {
      if (v is DateTime) return v;
      if (v is String) {
        return DateTime.tryParse(v);
      }
      return null;
    }

    return Flashcard(
      id: json.getFlexible('id') as String,
      term: json.getFlexible('term') as String,
      english: _parseNullableString(json.getFlexible('english')),
      reading: json.getFlexible('reading') as String,
      description: json.getFlexible('description') as String,
      relatedIds: relatedIds,
      tags: tags,
      examExample: _parseNullableString(json.getFlexible('examExample')),
      examPoint: _parseNullableString(json.getFlexible('examPoint')),
      practicalTip: _parseNullableString(json.getFlexible('practicalTip')),
      categoryLarge: json.getFlexible('categoryLarge') as String,
      categoryMedium: json.getFlexible('categoryMedium') as String,
      categorySmall: json.getFlexible('categorySmall') as String,
      categoryItem: json.getFlexible('categoryItem') as String,
      importance: _parseDouble(json.getFlexible('importance')),
      lastReviewed: _parseDate(json.getFlexible('lastReviewed')),
      nextDue: _parseDate(json.getFlexible('nextDue')),
      wrongCount: (json.getFlexible('wrongCount') as num?)?.toInt() ?? 0,
      correctCount: (json.getFlexible('correctCount') as num?)?.toInt() ?? 0,
    );
  }
}
