import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/auth_user.dart';
import 'storage_provider.dart';

class AuthNotifier extends Notifier<AuthUser?> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  AuthUser? build() {
    return ref.read(authStorageProvider).readUser();
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
