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
import 'services/box_initializer.dart';

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

class _InitData {
  final ThemeProvider theme;
  final FlashcardRepository repo;

  _InitData({required this.theme, required this.repo});
}

Future<_InitData> _initialize() async {
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

  await openAllBoxes(cipher);

  final theme = ThemeProvider();
  await theme.loadAppPreferences();
  final repo = await FlashcardRepository.open();
  return _InitData(theme: theme, repo: repo);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _Bootstrapper());
}

class _Bootstrapper extends StatefulWidget {
  const _Bootstrapper();

  @override
  State<_Bootstrapper> createState() => _BootstrapperState();
}

class _BootstrapperState extends State<_Bootstrapper> {
  late final Future<_InitData> _future = _initialize();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_InitData>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final data = snapshot.data!;
        return ProviderScope(
          overrides: [
            themeProvider.overrideWith((ref) => data.theme),
            flashcardRepositoryProvider.overrideWith((ref) => data.repo),
          ],
          child: const MyApp(),
        );
      },
    );
  }
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
