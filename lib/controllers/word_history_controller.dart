import 'package:flutter/foundation.dart';

import '../flashcard_model.dart';
import '../services/history_service.dart';

class _ViewState {
  final List<Flashcard> list;
  final int index;
  const _ViewState(this.list, this.index);
}

/// Controller to track viewed flashcards and navigate history.
class WordHistoryController extends ChangeNotifier {
  final HistoryService _historyService;
  final List<_ViewState> _history = [];
  int _historyIndex = -1;
  bool _suppressPush = false;

  WordHistoryController([HistoryService? service])
      : _historyService = service ?? HistoryService();

  void initialize(List<Flashcard> list, int index) {
    _history
      ..clear()
      ..add(_ViewState(list, index));
    _historyIndex = 0;
    _addEntry();
    notifyListeners();
  }

  bool get canGoBack => _historyIndex > 0;
  bool get canGoForward =>
      _historyIndex >= 0 && _historyIndex < _history.length - 1;

  List<Flashcard> get currentList => _history[_historyIndex].list;
  int get currentIndex => _history[_historyIndex].index;
  Flashcard get currentFlashcard => currentList[currentIndex];

  void setPage(int index) {
    _history[_historyIndex] = _ViewState(currentList, index);
    _addEntry();
    _push();
  }

  void openGroup(List<Flashcard> list, int index) {
    _jumpTo(_ViewState(list, index), addToHistory: true);
  }

  void back() {
    if (canGoBack) {
      _historyIndex--;
      _jumpTo(_history[_historyIndex]);
    }
  }

  void forward() {
    if (canGoForward) {
      _historyIndex++;
      _jumpTo(_history[_historyIndex]);
    }
  }

  void _push() {
    if (_suppressPush) {
      _suppressPush = false;
      return;
    }
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(_ViewState(currentList, currentIndex));
    _historyIndex = _history.length - 1;
    notifyListeners();
  }

  void _jumpTo(_ViewState view, {bool addToHistory = false}) {
    _suppressPush = true;
    _history[_historyIndex] = view;
    if (addToHistory) {
      if (_historyIndex < _history.length - 1) {
        _history.removeRange(_historyIndex + 1, _history.length);
      }
      _history.add(_ViewState(view.list, view.index));
      _historyIndex = _history.length - 1;
    }
    _addEntry();
    notifyListeners();
  }

  Future<void> _addEntry() async {
    await _historyService.addView(currentFlashcard.id);
  }
}
