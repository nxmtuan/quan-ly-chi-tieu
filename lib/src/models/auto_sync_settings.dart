enum AutoSyncScheduleType { daily, weekly }

class AutoSyncSettings {
  const AutoSyncSettings({
    required this.enabled,
    required this.scheduleType,
    required this.hour,
    required this.minute,
    required this.weekday,
  });

  const AutoSyncSettings.defaults()
      : enabled = false,
        scheduleType = AutoSyncScheduleType.daily,
        hour = 8,
        minute = 0,
        weekday = 1;

  final bool enabled;
  final AutoSyncScheduleType scheduleType;
  final int hour;
  final int minute;
  final int weekday;

  AutoSyncSettings copyWith({
    bool? enabled,
    AutoSyncScheduleType? scheduleType,
    int? hour,
    int? minute,
    int? weekday,
  }) {
    return AutoSyncSettings(
      enabled: enabled ?? this.enabled,
      scheduleType: scheduleType ?? this.scheduleType,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      weekday: weekday ?? this.weekday,
    );
  }
}
