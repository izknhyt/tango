import 'word_list_query.dart';

extension SortTypeExt on SortType {
  String get label {
    switch (this) {
      case SortType.syllabus:
        return 'シラバス順';
      case SortType.importance:
        return '重要度順';
      case SortType.wrong:
        return '間違え順';
      case SortType.unviewed:
        return '未読優先';
      case SortType.interval:
        return '学習間隔順';
      case SortType.ai:
        return 'AIおすすめ';
    }
  }
}
