import 'review_service.dart';

extension ReviewModeExt on ReviewMode {
  String get label {
    switch (this) {
      case ReviewMode.newWords:
        return '新出語';
      case ReviewMode.random:
        return 'ランダム';
      case ReviewMode.wrongDescending:
        return '間違え順';
      case ReviewMode.tagFocus:
        return 'タグ集中';
      case ReviewMode.spacedRepetition:
        return '復習間隔順';
      case ReviewMode.mixed:
        return '総合優先度';
      case ReviewMode.tagOnly:
        return 'タグのみ';
      case ReviewMode.autoFilter:
        return '🌀 自動フィルターモード';
    }
  }
}
