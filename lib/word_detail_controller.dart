import 'package:flutter/foundation.dart';
import 'flashcard_model.dart';

/// Controller used to navigate backward and forward between viewed words in
/// [WordDetailContent].
class WordDetailController extends ChangeNotifier {
  bool Function()? _canGoBack;
  bool Function()? _canGoForward;
  VoidCallback? _goBack;
  VoidCallback? _goForward;
  Flashcard Function()? _currentFlashcard;

  void attach({
    required bool Function() canGoBack,
    required bool Function() canGoForward,
    required VoidCallback goBack,
    required VoidCallback goForward,
    required Flashcard Function() currentFlashcard,
  }) {
    _canGoBack = canGoBack;
    _canGoForward = canGoForward;
    _goBack = goBack;
    _goForward = goForward;
    _currentFlashcard = currentFlashcard;
    notifyListeners();
  }

  void detach() {
    _canGoBack = null;
    _canGoForward = null;
    _goBack = null;
    _goForward = null;
    _currentFlashcard = null;
    notifyListeners();
  }

  bool get canGoBack => _canGoBack?.call() ?? false;
  bool get canGoForward => _canGoForward?.call() ?? false;

  void back() {
    if (canGoBack) {
      _goBack?.call();
      notifyListeners();
    }
  }

  void forward() {
    if (canGoForward) {
      _goForward?.call();
      notifyListeners();
    }
  }

  Flashcard? get currentFlashcard => _currentFlashcard?.call();

  /// Call this when history state changes to update listeners.
  void update() => notifyListeners();
}
