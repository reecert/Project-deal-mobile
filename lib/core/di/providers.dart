import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Provider for the Supabase client
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return supabase;
});

/// Provider for the current auth state stream
final authStateProvider = StreamProvider<AuthState>((ref) {
  return supabase.auth.onAuthStateChange;
});

/// Provider for the current user
final currentUserProvider = Provider<User?>((ref) {
  return supabase.auth.currentUser;
});

/// Provider for checking if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return supabase.auth.currentUser != null;
});
