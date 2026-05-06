import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/auth_user.dart';
import 'storage_provider.dart';

const googleAndroidOAuthClientId =
    '963215650668-s93bo1c4q8rgk1vlhqdvpbcdph98q0fo.apps.googleusercontent.com';
const googleWebOAuthClientId =
    '963215650668-8vbiq9htbe7he1801j53212fm9df26bp.apps.googleusercontent.com';
const authSessionDuration = Duration(days: 30);

class AuthNotifier extends Notifier<AuthUser?> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId: kIsWeb ? googleWebOAuthClientId : null,
    serverClientId: kIsWeb ? null : googleAndroidOAuthClientId,
  );
  StreamSubscription<GoogleSignInAccount?>? _accountSubscription;

  @override
  AuthUser? build() {
    _accountSubscription ??= _googleSignIn.onCurrentUserChanged.listen(
      _handleGoogleAccountChanged,
    );
    ref.onDispose(() {
      unawaited(_accountSubscription?.cancel());
      _accountSubscription = null;
    });

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
    if (kIsWeb) {
      return;
    }

    final account = await _googleSignIn.signIn();

    if (account == null) {
      return;
    }

    await _saveGoogleAccount(account);
  }

  Future<void> _handleGoogleAccountChanged(GoogleSignInAccount? account) async {
    if (account == null) {
      await ref.read(authStorageProvider).clearUser();
      state = null;
      return;
    }

    await _saveGoogleAccount(account);
  }

  Future<void> _saveGoogleAccount(GoogleSignInAccount account) async {
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
