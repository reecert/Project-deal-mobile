import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/config/env.dart';
import 'core/config/supabase_config.dart';
import 'core/router/app_router.dart';

// App color palette - User's 3-color aesthetic
class AppColors {
  // Primary colors
  static const Color white = Colors.white;
  static const Color headerFooter = Color(0xFF161617); // Dark charcoal
  static const Color primary = Color(0xFF1D4ED8); // Blue

  // Light Mode
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Colors.white;
  static const Color lightText = Color(0xFF161617);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  // Dark Mode
  static const Color darkBackground = Color(0xFF161617);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2A2A2A);
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  // Price colors
  static const Color priceGreen = Color(0xFF16A34A);
  static const Color priceMrp = Color(0xFF9CA3AF);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Env.flavor = Flavor.dev;
  await Env.init();
  await SupabaseConfig.initialize();

  if (Env.isProduction && Env.sentryDsn.isNotEmpty) {
    await SentryFlutter.init((options) {
      options.dsn = Env.sentryDsn;
      options.environment = Env.flavor.name;
      options.tracesSampleRate = 0.2;
    }, appRunner: () => runApp(const ProviderScope(child: GetOnDealsApp())));
  } else {
    runApp(const ProviderScope(child: GetOnDealsApp()));
  }
}

class GetOnDealsApp extends ConsumerWidget {
  const GetOnDealsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'GetOnDeals',
      debugShowCheckedModeBanner: false,

      // Light Theme
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.headerFooter,
          onSecondary: Colors.white,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightText,
          error: Color(0xFFDC2626),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.headerFooter,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.headerFooter,
          elevation: 0,
          indicatorColor: AppColors.primary,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.white);
            }
            return const IconThemeData(color: Colors.grey);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              );
            }
            return const TextStyle(color: Colors.grey, fontSize: 11);
          }),
        ),
        cardTheme: CardThemeData(
          color: AppColors.lightCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.grey.shade200,
          selectedColor: AppColors.primary,
          labelStyle: const TextStyle(color: AppColors.lightText),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide.none,
        ),
      ),

      // Dark Theme
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.primary,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkText,
          error: Color(0xFFEF4444),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          foregroundColor: AppColors.darkText,
          elevation: 0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.darkBackground,
          elevation: 0,
          indicatorColor: AppColors.primary,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.white);
            }
            return const IconThemeData(color: Colors.grey);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              );
            }
            return const TextStyle(color: Colors.grey, fontSize: 11);
          }),
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.darkCard,
          selectedColor: AppColors.primary,
          labelStyle: const TextStyle(color: AppColors.darkText),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide.none,
        ),
      ),

      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
