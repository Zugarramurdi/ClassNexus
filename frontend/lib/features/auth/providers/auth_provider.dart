import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.session?.user ?? ref.read(supabaseClientProvider).auth.currentUser;
});

class AuthNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Estado inicial
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(supabaseClientProvider);
      await client.auth.signInWithPassword(email: email, password: password);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    await ref.read(supabaseClientProvider).auth.signOut();
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      final client = ref.read(supabaseClientProvider);
      await client.auth.updateUser(UserAttributes(password: newPassword));
      // No actualizamos el estado global para evitar refrescos de la app durante el proceso del diálogo
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, void>(() {
  return AuthNotifier();
});
