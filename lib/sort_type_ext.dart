import 'word_list_query.dart';

extension SortTypeExt on SortType {
  String get label {
    switch (this) {
      case SortType.id:
        return 'ID順';
      case SortType.importance:
        return '重要度順';
      case SortType.lastReviewed:
        return '最終閲覧順';
    }
  }
}
