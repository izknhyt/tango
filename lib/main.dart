import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main_screen.dart';
import 'history_entry_model.dart';
import 'models/word.dart';
import 'models/learning_stat.dart';
import 'models/quiz_stat.dart';
import 'models/session_log.dart';
import 'models/review_queue.dart';
import 'models/flashcard_state.dart';
import 'constants.dart';
import 'services/word_repository.dart';
import 'services/learning_repository.dart';
import 'theme_provider.dart';
import 'theme/app_theme.dart';
import 'theme_mode_provider.dart';
import 'models/saved_theme_mode.dart';
import 'flashcard_repository.dart';
import 'flashcard_repository_provider.dart';

const _secureKeyName = 'hive_encryption_key';
const _secureStorage = FlutterSecureStorage();

Future<List<int>> _getEncryptionKey() async {
  try {
    final stored = await _secureStorage.read(key: _secureKeyName);
    if (stored != null) {
      return base64Url.decode(stored);
    }
    final key = Hive.generateSecureKey();
    await _secureStorage.write(
        key: _secureKeyName, value: base64UrlEncode(key));
    return key;
  } catch (e) {
    debugPrint('Secure storage unavailable: $e');
    return Hive.generateSecureKey();
  }
}

Future<Box<T>> _openBoxWithMigration<T>(
    String name, HiveAesCipher cipher) async {
  try {
    return await Hive.openBox<T>(name, encryptionCipher: cipher);
  } catch (_) {
    final box = await Hive.openBox<T>(name);
    final data = Map<dynamic, T>.from(box.toMap());
    await box.close();
    await box.deleteFromDisk();
    final newBox = await Hive.openBox<T>(name, encryptionCipher: cipher);
    await newBox.putAll(data);
    return newBox;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final List<TypeAdapter<dynamic>> adapters = [
    HistoryEntryAdapter(),
    WordAdapter(),
    LearningStatAdapter(),
    QuizStatAdapter(),
    SessionLogAdapter(),
    ReviewQueueAdapter(),
    SavedThemeModeAdapter(),
    FlashcardStateAdapter(),
  ];
  for (final adapter in adapters) {
    if (!Hive.isAdapterRegistered(adapter.typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  final key = await _getEncryptionKey();
  final cipher = HiveAesCipher(key);

  final openBoxTasks = [
    () => _openBoxWithMigration<Map>(favoritesBoxName, cipher),
    () => _openBoxWithMigration<HistoryEntry>(historyBoxName, cipher),
    () => _openBoxWithMigration<QuizStat>(quizStatsBoxName, cipher),
    () => _openBoxWithMigration<FlashcardState>(flashcardStateBoxName, cipher),
    () => _openBoxWithMigration<Word>(WordRepository.boxName, cipher),
    () => _openBoxWithMigration<LearningStat>(LearningRepository.boxName, cipher),
    () => _openBoxWithMigration<SessionLog>(sessionLogBoxName, cipher),
    () => _openBoxWithMigration<ReviewQueue>(reviewQueueBoxName, cipher),
    () => _openBoxWithMigration<SavedThemeMode>(settingsBoxName, cipher),
  ];
  for (final task in openBoxTasks) {
    await task();
  }

  final theme = ThemeProvider();
  await theme.loadAppPreferences();
  final flashcardRepo = await FlashcardRepository.open();

  runApp(
    ProviderScope(
      overrides: [
        themeProvider.overrideWith((ref) => theme),
        flashcardRepositoryProvider.overrideWith((ref) => flashcardRepo),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeProvider);
    final scale = themeNotifier.textScaleFactor;
    final mode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'IT資格学習 単語帳',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: mode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
          ),
          child: child!,
        );
      },
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
