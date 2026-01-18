import 'package:supabase_flutter/supabase_flutter.dart';
import 'env.dart';

class SupabaseConfig {
  static late SupabaseClient client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
    client = Supabase.instance.client;
  }
}

/// Convenience getter
SupabaseClient get supabase => SupabaseConfig.client;
