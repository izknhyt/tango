import 'package:hive/hive.dart';
import '../history_entry_model.dart';
import '../constants.dart';

/// Service layer for managing view history.
class HistoryService {
  final Box<HistoryEntry> _box;

  HistoryService([Box<HistoryEntry>? box])
      : _box = box ?? Hive.box<HistoryEntry>(historyBoxName);

  /// Add or update the view timestamp for the given [wordId].
  Future<void> addView(String wordId) async {
    final entry = HistoryEntry(wordId: wordId, timestamp: DateTime.now());
    await _box.put(wordId, entry);
    if (_box.length > 100) {
      final oldest = _box.toMap().entries.reduce((a, b) =>
          a.value.timestamp.isBefore(b.value.timestamp) ? a : b);
      await _box.delete(oldest.key);
    }
  }

  /// Retrieve all history entries sorted by newest first.
  List<HistoryEntry> all() {
    final entries = _box.values.toList();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }
}
