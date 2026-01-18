import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';
import '../../core/config/env.dart';
import '../../core/config/supabase_config.dart';

/// Auth repository for handling authentication
class AuthRepository {
  final SupabaseClient _client;
  
  AuthRepository(this._client);
  
  // Current session
  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;
  
  // Auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  /// Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  /// Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? username,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: username != null ? {'username': username} : null,
    );
  }
  
  /// Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    final googleUser = await GoogleSignIn(
      clientId: Platform.isIOS ? Env.googleClientIdIos : null,
      serverClientId: Env.googleServerClientId,
    ).signIn();
    
    if (googleUser == null) {
      throw AuthException('Google sign in cancelled');
    }
    
    final googleAuth = await googleUser.authentication;
    
    if (googleAuth.idToken == null) {
      throw AuthException('No Google ID token');
    }
    
    return await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );
  }
  
  /// Sign in with Apple
  Future<AuthResponse> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    
    if (credential.identityToken == null) {
      throw AuthException('No Apple identity token');
    }
    
    return await _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: credential.identityToken!,
    );
  }
  
  /// Sign out
  Future<void> signOut() async {
    // Sign out from Google if signed in
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    
    await _client.auth.signOut();
  }
  
  /// Reset password
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
}

/// Riverpod provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(supabase);
});
