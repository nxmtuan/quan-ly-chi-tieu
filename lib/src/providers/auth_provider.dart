import 'dart:async';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import '../models/auth_user.dart';
import 'storage_provider.dart';

const googleAndroidOAuthClientId =
    '963215650668-s93bo1c4q8rgk1vlhqdvpbcdph98q0fo.apps.googleusercontent.com';
const googleWebOAuthClientId =
    '963215650668-8vbiq9htbe7he1801j53212fm9df26bp.apps.googleusercontent.com';
const authSessionDuration = Duration(days: 30);

class AuthNotifier extends Notifier<AuthUser?> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      drive.DriveApi.driveAppdataScope,
    ],
    clientId: kIsWeb ? googleWebOAuthClientId : null,
  );
  StreamSubscription<GoogleSignInAccount?>? _accountSubscription;
  Completer<drive.DriveApi?>? _driveApiCompleter;

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

  Future<drive.DriveApi?> getDriveApi() async {
    final pendingRequest = _driveApiCompleter;
    if (pendingRequest != null) {
      return pendingRequest.future;
    }

    final completer = Completer<drive.DriveApi?>();
    _driveApiCompleter = completer;
    try {
      final driveApi = await _resolveDriveApi();
      completer.complete(driveApi);
      return driveApi;
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
      rethrow;
    } finally {
      _driveApiCompleter = null;
    }
  }

  Future<drive.DriveApi?> _resolveDriveApi() async {
    if (state == null) {
      return null;
    }

    Object? lastError;

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        GoogleSignInAccount? account = _googleSignIn.currentUser;
        account ??= await _googleSignIn.signInSilently(
          suppressErrors: attempt < 2,
          reAuthenticate: attempt == 2,
        );

        if (account == null) {
          await _delayBeforeRetry(attempt);
          continue;
        }

        if (state?.id != account.id || state?.email != account.email) {
          await _saveGoogleAccount(account);
        }

        final httpClient = await _googleSignIn.authenticatedClient();
        if (httpClient != null) {
          return drive.DriveApi(httpClient);
        }
      } on PlatformException catch (error) {
        lastError = error;

        if (error.code == GoogleSignIn.kSignInRequiredError) {
          await ref.read(authStorageProvider).clearUser();
          state = null;
          return null;
        }

        if (error.code != GoogleSignIn.kNetworkError || attempt == 2) {
          break;
        }
      } catch (error) {
        lastError = error;
      }

      await _delayBeforeRetry(attempt);
    }

    if (lastError != null) {
      debugPrint('getDriveApi failed: $lastError');
    }
    return null;
  }

  Future<void> _delayBeforeRetry(int attempt) async {
    if (attempt >= 2) {
      return;
    }
    await Future<void>.delayed(
      Duration(milliseconds: 250 * (attempt + 1)),
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthUser?>(
  AuthNotifier.new,
);
