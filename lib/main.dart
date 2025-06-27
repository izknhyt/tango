import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart' as provider_pkg;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
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
import 'analytics_provider.dart';

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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
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
  await _openBoxWithMigration(settingsBoxName, cipher);

  final themeProvider = ThemeProvider();
  await themeProvider.loadAppPreferences();

  runZonedGuarded(() {
    runApp(
      ProviderScope(
        child: provider_pkg.ChangeNotifierProvider(
          create: (_) => themeProvider,
          child: const MyApp(),
        ),
      ),
    );
  }, FirebaseCrashlytics.instance.recordError);
}


class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(analyticsProvider.notifier);
      if (!notifier.hasValue) {
        final result = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Analytics'),
            content:
                const Text('匿名の利用状況データを送信してもよいですか？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('いいえ'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('はい'),
              ),
            ],
          ),
        );
        await notifier.setEnabled(result ?? false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = provider_pkg.Provider.of<ThemeProvider>(context);
    final scale = themeProvider.textScaleFactor;
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
