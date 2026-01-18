import 'package:flutter_dotenv/flutter_dotenv.dart';

// Environment configuration for dev/stage/prod flavors
enum Flavor { dev, stage, prod }

class Env {
  static late Flavor flavor;

  static Future<void> init() async {
    await dotenv.load(fileName: 'assets/.env');
  }

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static String get sentryDsn => dotenv.env['SENTRY_DSN'] ?? '';
  static String get googleClientIdIos =>
      dotenv.env['GOOGLE_CLIENT_ID_IOS'] ?? '';
  static String get googleServerClientId =>
      dotenv.env['GOOGLE_SERVER_CLIENT_ID'] ?? '';

  static bool get isProduction => flavor == Flavor.prod;
  static bool get isDevelopment => flavor == Flavor.dev;
}
