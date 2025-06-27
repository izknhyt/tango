import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart' as provider_pkg;
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

  final themeProvider = ThemeProvider();
  await themeProvider.loadAppPreferences();

  runApp(
    ProviderScope(
      child: provider_pkg.ChangeNotifierProvider(
        create: (_) => themeProvider,
        child: const MyApp(),
      ),
    ),
  );
}

ThemeData _buildTheme(Brightness brightness) {
  final base = ThemeData(brightness: brightness);
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0066CC),
    brightness: brightness,
  ).copyWith(
    primary: const Color(0xFF0066CC),
    secondary: const Color(0xFFFFA726),
    surfaceVariant: const Color(0xFFF5F7FA),
    error: const Color(0xFFD32F2F),
  );

  final textTheme = base.textTheme.apply(fontFamily: 'NotoSansJP').copyWith(
        displaySmall: const TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 22,
            fontWeight: FontWeight.w600),
        titleMedium: const TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 18,
            fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 16,
            fontWeight: FontWeight.w400),
        labelLarge: const TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 14,
            fontWeight: FontWeight.w500),
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    textTheme: textTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(scheme.primary),
        foregroundColor: MaterialStateProperty.all(scheme.onPrimary),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceVariant,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    iconTheme: const IconThemeData(size: 20),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = provider_pkg.Provider.of<ThemeProvider>(context);
    final scale = themeProvider.textScaleFactor;
    return MaterialApp(
      title: 'IT資格学習 単語帳',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: themeProvider.themeMode,
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
