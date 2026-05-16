import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/adaptive.dart';
import '../../providers/settings_provider.dart';

class BiometricLockGate extends ConsumerStatefulWidget {
  const BiometricLockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<BiometricLockGate> createState() => _BiometricLockGateState();
}

class _BiometricLockGateState extends ConsumerState<BiometricLockGate>
    with WidgetsBindingObserver {
  static const _screenEvents = EventChannel(
    'com.easyproducts.quanlytaichinh/screen_events',
  );

  StreamSubscription<dynamic>? _screenEventsSubscription;
  Timer? _delayedLockTimer;
  bool _promptScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _listenToScreenEvents();
  }

  @override
  void dispose() {
    _screenEventsSubscription?.cancel();
    _delayedLockTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lockState = ref.read(biometricLockProvider);
    if (state == AppLifecycleState.resumed) {
      _delayedLockTimer?.cancel();
      _delayedLockTimer = null;
      return;
    }

    if (state != AppLifecycleState.paused &&
        state != AppLifecycleState.hidden) {
      return;
    }

    if (lockState.isAuthenticating) {
      return;
    }

    switch (lockState.lockTrigger) {
      case BiometricLockTrigger.onAppExit:
        ref.read(biometricLockProvider.notifier).lock();
      case BiometricLockTrigger.afterTwoMinutes:
        _delayedLockTimer?.cancel();
        _delayedLockTimer = Timer(const Duration(minutes: 2), () {
          if (!mounted) {
            return;
          }

          final currentState = ref.read(biometricLockProvider);
          if (currentState.lockTrigger ==
                  BiometricLockTrigger.afterTwoMinutes &&
              !currentState.isAuthenticating) {
            ref.read(biometricLockProvider.notifier).lock();
          }
        });
      case BiometricLockTrigger.onScreenOff:
        if (defaultTargetPlatform != TargetPlatform.android) {
          ref.read(biometricLockProvider.notifier).lock();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(biometricLockProvider);
    _scheduleUnlockPrompt(lockState);

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (lockState.isLocked) _BiometricLockOverlay(state: lockState),
      ],
    );
  }

  void _scheduleUnlockPrompt(BiometricLockState state) {
    if (!state.isLocked ||
        state.isAuthenticating ||
        state.lastResult != null ||
        _promptScheduled) {
      return;
    }

    _promptScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _promptScheduled = false;
      if (!mounted) {
        return;
      }

      final currentState = ref.read(biometricLockProvider);
      if (currentState.isLocked && !currentState.isAuthenticating) {
        await ref.read(biometricLockProvider.notifier).unlock();
      }
    });
  }

  void _listenToScreenEvents() {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    _screenEventsSubscription = _screenEvents.receiveBroadcastStream().listen((
      event,
    ) {
      if (event != 'screenOff') {
        return;
      }

      final lockState = ref.read(biometricLockProvider);
      if (lockState.lockTrigger != BiometricLockTrigger.onScreenOff ||
          lockState.isAuthenticating) {
        return;
      }

      unawaited(ref.read(biometricLockProvider.notifier).lockForScreenOff());
    }, onError: (_) {});
  }
}

class _BiometricLockOverlay extends ConsumerWidget {
  const _BiometricLockOverlay({required this.state});

  final BiometricLockState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.appPalette;
    final message =
        state.errorMessage ?? 'Đang chờ xác thực bằng bảo mật thiết bị.';

    return Material(
      color: palette.background,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.scaled(24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: context.scaled(88),
                  height: context.scaled(88),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(context.scaled(28)),
                  ),
                  child: Icon(
                    Icons.fingerprint_rounded,
                    color: AppColors.primary,
                    size: context.scaled(44),
                  ),
                ),
              ),
              SizedBox(height: context.scaled(26)),
              Text(
                'Ứng dụng đang khóa',
                textAlign: TextAlign.center,
                style: context.appText.pageTitle.copyWith(
                  fontSize: context.scaledFont(24, min: 21),
                ),
              ),
              SizedBox(height: context.scaled(10)),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.appText.body.copyWith(
                  color: palette.textSecondary,
                  height: 1.45,
                ),
              ),
              SizedBox(height: context.scaled(24)),
              FilledButton.icon(
                onPressed: state.isAuthenticating || !state.canRetry
                    ? null
                    : () => ref.read(biometricLockProvider.notifier).unlock(),
                icon: state.isAuthenticating
                    ? SizedBox(
                        width: context.scaled(18),
                        height: context.scaled(18),
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.lock_open_rounded),
                label: Text(
                  state.isAuthenticating ? 'Đang xác thực' : 'Mở khóa',
                ),
              ),
              if (state.canDisableLock) ...[
                SizedBox(height: context.scaled(10)),
                TextButton(
                  onPressed: state.isAuthenticating
                      ? null
                      : () =>
                            ref.read(biometricLockProvider.notifier).disable(),
                  child: const Text('Tắt khóa bảo mật thiết bị'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
