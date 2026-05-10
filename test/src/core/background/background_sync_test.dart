import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_chi_tieu/src/core/background/background_sync.dart';
import 'package:quan_ly_chi_tieu/src/models/auto_sync_settings.dart';
import 'package:quan_ly_chi_tieu/src/models/auto_sync_status.dart';

void main() {
  group('resolveNextAutoSyncRunTime', () {
    const dailySettings = AutoSyncSettings(
      enabled: true,
      scheduleType: AutoSyncScheduleType.daily,
      hour: 8,
      minute: 0,
      weekday: 1,
    );

    test('keeps persisted future schedule on app restart', () {
      final now = DateTime(2026, 5, 10, 7, 55);
      final persistedNextRunAt = DateTime(2026, 5, 10, 8, 0);

      final resolved = resolveNextAutoSyncRunTime(
        settings: dailySettings,
        status: const AutoSyncStatus.idle(),
        now: now,
        persistedNextRunAt: persistedNextRunAt,
      );

      expect(resolved, persistedNextRunAt);
    });

    test('runs immediately when persisted schedule is already overdue', () {
      final now = DateTime(2026, 5, 10, 8, 5);
      final persistedNextRunAt = DateTime(2026, 5, 10, 8, 0);

      final resolved = resolveNextAutoSyncRunTime(
        settings: dailySettings,
        status: const AutoSyncStatus.idle(),
        now: now,
        persistedNextRunAt: persistedNextRunAt,
      );

      expect(resolved, now);
    });

    test('prefers retryAt while a failed retry window is still pending', () {
      final now = DateTime(2026, 5, 10, 8, 5);
      final retryAt = DateTime(2026, 5, 10, 8, 20);

      final resolved = resolveNextAutoSyncRunTime(
        settings: dailySettings,
        status: AutoSyncStatus(
          type: AutoSyncStatusType.failure,
          retryAt: retryAt,
        ),
        now: now,
        persistedNextRunAt: DateTime(2026, 5, 11, 8, 0),
      );

      expect(resolved, retryAt);
    });
  });
}
