import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/auth_user.dart';
import 'storage_provider.dart';

const googleOAuthClientId =
    '963215650668-s93bo1c4q8rgk1vlhqdvpbcdph98q0fo.apps.googleusercontent.com';
const authSessionDuration = Duration(days: 30);

class AuthNotifier extends Notifier<AuthUser?> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId: googleOAuthClientId,
  );

  @override
  AuthUser? build() {
    final user = ref.read(authStorageProvider).readUser();

    if (user == null) {
      return null;
    }

    final now = DateTime.now();
    final isExpired = now.difference(user.lastLoginAt) > authSessionDuration;

    if (isExpired) {
      unawaited(ref.read(authStorageProvider).clearUser());
      return null;
    }

    final refreshedUser = user.copyWith(lastLoginAt: now);
    unawaited(ref.read(authStorageProvider).saveUser(refreshedUser));
    return refreshedUser;
  }

  Future<void> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();

    if (account == null) {
      return;
    }

    final user = AuthUser(
      id: account.id,
      email: account.email,
      name: account.displayName ?? account.email,
      lastLoginAt: DateTime.now(),
      photoUrl: account.photoUrl,
    );

    state = user;
    await ref.read(authStorageProvider).saveUser(user);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await ref.read(authStorageProvider).clearUser();
    state = null;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthUser?>(
  AuthNotifier.new,
);
