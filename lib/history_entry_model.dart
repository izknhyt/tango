// lib/history_entry_model.dart
import 'package:hive/hive.dart';

part 'history_entry_model.g.dart'; // Hiveジェネレータが生成するファイル

@HiveType(typeId: 1) // typeIdは他とかぶらないようにする
class HistoryEntry extends HiveObject {
  @HiveField(0)
  final String wordId;

  @HiveField(1)
  final DateTime timestamp;

  HistoryEntry({required this.wordId, required this.timestamp});

  @override
  String toString() {
    return 'HistoryEntry(wordId: $wordId, timestamp: $timestamp)';
  }
}
