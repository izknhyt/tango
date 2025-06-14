// lib/main.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Hive Flutterをインポート
import 'package:provider/provider.dart'; // Providerをインポート
import 'main_screen.dart'; // MainScreenウィジェット
import 'history_entry_model.dart'; // HistoryEntryモデル (Hiveアダプタ登録のため)
import 'theme_provider.dart'; // ThemeProvider (テーマと文字サイズ管理のため)

Future<void> main() async {
  // Flutterエンジンとウィジェットツリーのバインディングを初期化
  WidgetsFlutterBinding.ensureInitialized();

  // Hiveの初期化
  await Hive.initFlutter();

  // Hiveアダプタの登録
  if (!Hive.isAdapterRegistered(HistoryEntryAdapter().typeId)) {
    Hive.registerAdapter(HistoryEntryAdapter());
  }

  // 使用するHiveのBoxを開く
  await Hive.openBox<Map>('favorites_box_v2');
  await Hive.openBox<HistoryEntry>('history_box_v2');
  await Hive.openBox<Map>('quiz_stats_box_v1');

  // ThemeProviderのインスタンスを作成 (runAppの前に初期化処理が走るように)
  final themeProvider = ThemeProvider();
  // ThemeProviderのコンストラクタで _loadThemePreference() と _loadFontSizePreference() が呼ばれます

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider, // アプリ全体でThemeProviderを共有
      child: const MyApp(key: ValueKey("MyApp")),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ProviderからThemeProviderのインスタンスを取得してテーマモードと文字サイズを監視
    final themeProvider = Provider.of<ThemeProvider>(context);
    final double currentTextScaleFactor =
        themeProvider.textScaleFactor; // 現在の文字サイズスケールファクター

    // --- ライトテーマの定義 ---
    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF007ACC),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5DC),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF007ACC),
        foregroundColor: Colors.white,
        elevation: 1.0,
      ),
      textTheme: TextTheme(
        // Removed const
        displayLarge:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        displayMedium:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        displaySmall:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        headlineMedium:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        headlineSmall:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        titleLarge:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        titleMedium:
            const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
        titleSmall:
            const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
        bodyLarge: const TextStyle(color: Colors.black87, height: 1.5),
        bodyMedium: const TextStyle(color: Colors.black87, height: 1.4),
        // Colors.grey is const, so this TextStyle can be const.
        bodySmall: const TextStyle(color: Colors.grey, height: 1.3),
        labelLarge:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        // Colors.grey is const, so this TextStyle can be const.
        labelSmall: const TextStyle(color: Colors.grey),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: const Color(0xFF007ACC),
        unselectedItemColor: Colors.grey[
            700], // Not const, so parent cannot be const if this part matters
        backgroundColor: Colors.white,
        elevation: 4.0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007ACC),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        titleTextStyle: TextStyle(
            // Removed const
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color:
                Colors.black87.withOpacity(0.9)), // .withOpacity() is not const
        subtitleTextStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey[700]), // Colors.grey[700] is not const
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    // --- ダークテーマの定義 ---
    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF007ACC),
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900], // Not const
        foregroundColor: Colors.white,
        elevation: 1.0,
      ),
      textTheme: TextTheme(
        // Removed const
        displayLarge:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        displayMedium:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        displaySmall:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineMedium:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineSmall:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        titleLarge:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        titleMedium:
            const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
        titleSmall:
            const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
        bodyLarge: const TextStyle(color: Colors.white70, height: 1.5),
        bodyMedium: const TextStyle(color: Colors.white70, height: 1.4),
        // Problematic line: Colors.grey[400] is not const
        bodySmall:
            TextStyle(color: Colors.grey[400], height: 1.3), // Removed const
        labelLarge:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        // Problematic line: Colors.grey[400] is not const
        labelSmall: TextStyle(color: Colors.grey[400]), // Removed const
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: Colors.lightBlueAccent[100], // Not const
        unselectedItemColor: Colors.grey[500], // Not const
        backgroundColor: Colors.grey[850], // Not const
        elevation: 4.0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700], // Not const
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        // Colors.white.withOpacity(0.9) is not const
        titleTextStyle: TextStyle(
            // Removed const
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9)),
        // Colors.grey[400] is not const
        subtitleTextStyle:
            TextStyle(fontSize: 14, color: Colors.grey[400]), // Removed const
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    return MaterialApp(
      title: 'IT資格学習 単語帳',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(currentTextScaleFactor),
          ),
          child: child!,
        );
      },
      initialRoute: '/',
      routes: {
        '/': (context) => const MainScreen(key: ValueKey("MainScreen")),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
