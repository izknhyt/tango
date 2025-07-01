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
import 'constants.dart';
import 'services/word_repository.dart';
import 'services/learning_repository.dart';
import 'theme_provider.dart';
import 'theme/app_theme.dart';
import 'theme_mode_provider.dart';
import 'models/saved_theme_mode.dart';

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

  if (!Hive.isAdapterRegistered(HistoryEntryAdapter().typeId)) {
    Hive.registerAdapter(HistoryEntryAdapter());
  }
  if (!Hive.isAdapterRegistered(WordAdapter().typeId)) {
    Hive.registerAdapter(WordAdapter());
  }
  if (!Hive.isAdapterRegistered(LearningStatAdapter().typeId)) {
    Hive.registerAdapter(LearningStatAdapter());
  }
  if (!Hive.isAdapterRegistered(QuizStatAdapter().typeId)) {
    Hive.registerAdapter(QuizStatAdapter());
  }
  if (!Hive.isAdapterRegistered(SessionLogAdapter().typeId)) {
    Hive.registerAdapter(SessionLogAdapter());
  }
  if (!Hive.isAdapterRegistered(ReviewQueueAdapter().typeId)) {
    Hive.registerAdapter(ReviewQueueAdapter());
  }
  if (!Hive.isAdapterRegistered(SavedThemeModeAdapter().typeId)) {
    Hive.registerAdapter(SavedThemeModeAdapter());
  }

  final key = await _getEncryptionKey();
  final cipher = HiveAesCipher(key);

  await _openBoxWithMigration<Map>(favoritesBoxName, cipher);
  await _openBoxWithMigration<HistoryEntry>(historyBoxName, cipher);
  await _openBoxWithMigration<QuizStat>(quizStatsBoxName, cipher);
  await _openBoxWithMigration<Map>(flashcardStateBoxName, cipher);
  await _openBoxWithMigration<Word>(WordRepository.boxName, cipher);
  await _openBoxWithMigration<LearningStat>(LearningRepository.boxName, cipher);
  await _openBoxWithMigration<SessionLog>(sessionLogBoxName, cipher);
  await _openBoxWithMigration<ReviewQueue>(reviewQueueBoxName, cipher);
  await _openBoxWithMigration<SavedThemeMode>(settingsBoxName, cipher);

  final theme = ThemeProvider();
  await theme.loadAppPreferences();

  runApp(
    ProviderScope(
      overrides: [themeProvider.overrideWithValue(theme)],
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
