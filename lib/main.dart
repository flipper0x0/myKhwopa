import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:firebase_core/firebase_core.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'tabs/articles_tab.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase App
  await Firebase.initializeApp();

  tz.initializeTimeZones();
  await NotificationService().initialize();

  await Hive.initFlutter();

  Hive.registerAdapter(NoticeAdapter());
  Hive.registerAdapter(NewsAdapter());
  Hive.registerAdapter(NewsletterAdapter());
  Hive.registerAdapter(EventAdapter());

  await Hive.openBox('settings');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>();
  }
}

class _MyAppState extends State<MyApp> {
  final Box _box = Hive.box('settings');

  late ThemeMode _themeMode;
  late Color _seedColor;

  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;

  @override
  void initState() {
    super.initState();
    final savedColorVal =
        _box.get('seedColor', defaultValue: 0xFF6A1B9A) as int;
    _seedColor = Color(savedColorVal);

    final savedModeIndex =
        _box.get('themeMode', defaultValue: ThemeMode.dark.index) as int;
    _themeMode = ThemeMode.values[savedModeIndex];
  }

  void updateTheme(Color newSeedColor) {
    setState(() {
      _seedColor = newSeedColor;
    });
    _box.put('seedColor', newSeedColor.value);
  }

  void updateThemeMode(ThemeMode newMode) {
    setState(() {
      _themeMode = newMode;
    });
    _box.put('themeMode', newMode.index);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Khwopa Student App',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.light().textTheme,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _seedColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
          surface: const Color(0xFF0D0D0D),
          surfaceContainerLowest: const Color(0xFF121212),
          surfaceContainerLow: const Color(0xFF1A1A1A),
          surfaceContainer: const Color(0xFF1E1E1E),
          surfaceContainerHigh: const Color(0xFF252525),
          surfaceContainerHighest: const Color(0xFF2C2C2C),
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 32,
            letterSpacing: -0.5,
          ),
          displayMedium: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 28,
            letterSpacing: -0.3,
          ),
          headlineLarge: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 24,
            letterSpacing: -0.2,
          ),
          titleLarge: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0,
          ),
          titleMedium: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.95),
            fontWeight: FontWeight.w500,
            fontSize: 16,
            letterSpacing: 0.1,
          ),
          bodyLarge: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.87),
            fontSize: 16,
            letterSpacing: 0.15,
          ),
          bodyMedium: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.87),
            fontSize: 14,
            letterSpacing: 0.15,
          ),
          labelLarge: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
            letterSpacing: 0.3,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          hintStyle: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 14,
          ),
          labelStyle: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
          prefixIconColor: Colors.white.withValues(alpha: 0.6),
          suffixIconColor: Colors.white.withValues(alpha: 0.6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: _seedColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFFF5252),
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFFF5252),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              letterSpacing: 0.2,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFF1E1E1E),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titleTextStyle: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
          contentTextStyle: GoogleFonts.inter(
            color: Colors.white.withValues(alpha: 0.87),
            fontSize: 14,
            height: 1.5,
            letterSpacing: 0.15,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: Colors.white.withValues(alpha: 0.08),
          thickness: 1,
          space: 1,
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withValues(alpha: 0.87),
          size: 24,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0D0D0D),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
            size: 24,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFF121212),
          selectedItemColor: _seedColor,
          unselectedItemColor: Colors.white.withValues(alpha: 0.6),
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFF121212),
          indicatorColor: _seedColor.withValues(alpha: 0.2),
        ),
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
      },
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}
