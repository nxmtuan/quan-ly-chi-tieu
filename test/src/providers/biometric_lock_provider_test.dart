import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:quan_ly_chi_tieu/src/core/storage/settings_storage.dart';
import 'package:quan_ly_chi_tieu/src/providers/settings_provider.dart';
import 'package:quan_ly_chi_tieu/src/providers/storage_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BiometricLockNotifier', () {
    test(
      'does not start locked for screen-off trigger without screen-off event',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storage = SettingsStorage(prefs);
        await storage.saveBiometricUnlockEnabled(true);
        await storage.saveBiometricLockTrigger(
          BiometricLockTrigger.onScreenOff.name,
        );
        await storage.saveBiometricScreenOffLockPending(false);

        final container = _createContainer(prefs);
        addTearDown(container.dispose);

        final state = container.read(biometricLockProvider);
        expect(state.enabled, isTrue);
        expect(state.lockTrigger, BiometricLockTrigger.onScreenOff);
        expect(state.isLocked, isFalse);
      },
    );

    test('persists lock only after screen-off event', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = SettingsStorage(prefs);
      await storage.saveBiometricUnlockEnabled(true);
      await storage.saveBiometricLockTrigger(
        BiometricLockTrigger.onScreenOff.name,
      );

      final container = _createContainer(prefs);
      addTearDown(container.dispose);

      await container.read(biometricLockProvider.notifier).lockForScreenOff();
      expect(container.read(biometricLockProvider).isLocked, isTrue);
      expect(storage.readBiometricScreenOffLockPending(), isTrue);

      final restartedContainer = _createContainer(prefs);
      addTearDown(restartedContainer.dispose);
      expect(restartedContainer.read(biometricLockProvider).isLocked, isTrue);
    });

    test('still starts locked for app-exit trigger', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = SettingsStorage(prefs);
      await storage.saveBiometricUnlockEnabled(true);
      await storage.saveBiometricLockTrigger(
        BiometricLockTrigger.onAppExit.name,
      );

      final container = _createContainer(prefs);
      addTearDown(container.dispose);

      final state = container.read(biometricLockProvider);
      expect(state.lockTrigger, BiometricLockTrigger.onAppExit);
      expect(state.isLocked, isTrue);
    });
  });
}

ProviderContainer _createContainer(SharedPreferences prefs) {
  return ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
}
