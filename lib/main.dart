import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'main_screen.dart';
import 'history_entry_model.dart';
import 'theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(HistoryEntryAdapter().typeId)) {
    Hive.registerAdapter(HistoryEntryAdapter());
  }

  await Hive.openBox<Map>('favorites_box_v2');
  await Hive.openBox<HistoryEntry>('history_box_v2');
  await Hive.openBox<Map>('quiz_stats_box_v1');

  final themeProvider = ThemeProvider();

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeProvider,
      child: const MyApp(),
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

  final textTheme = GoogleFonts.notoSansJpTextTheme(base.textTheme).copyWith(
    displaySmall:
        GoogleFonts.notoSansJp(fontSize: 22, fontWeight: FontWeight.w600),
    titleMedium:
        GoogleFonts.notoSansJp(fontSize: 18, fontWeight: FontWeight.w600),
    bodyLarge:
        GoogleFonts.notoSansJp(fontSize: 16, fontWeight: FontWeight.w400),
    labelLarge:
        GoogleFonts.notoSansJp(fontSize: 14, fontWeight: FontWeight.w500),
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
    cardTheme: CardTheme(
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
    final provider = Provider.of<ThemeProvider>(context);
    final scale = provider.textScaleFactor;
    return MaterialApp(
      title: 'IT資格学習 単語帳',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: provider.themeMode,
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
