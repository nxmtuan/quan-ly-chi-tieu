enum AutoSyncStatusType { idle, success, failure }

class AutoSyncStatus {
  const AutoSyncStatus({
    required this.type,
    this.lastSuccessAt,
    this.retryAt,
    this.retryAttempt = 0,
  });

  const AutoSyncStatus.idle()
    : type = AutoSyncStatusType.idle,
      lastSuccessAt = null,
      retryAt = null,
      retryAttempt = 0;

  final AutoSyncStatusType type;
  final DateTime? lastSuccessAt;
  final DateTime? retryAt;
  final int retryAttempt;

  AutoSyncStatus copyWith({
    AutoSyncStatusType? type,
    DateTime? lastSuccessAt,
    DateTime? retryAt,
    int? retryAttempt,
    bool clearLastSuccessAt = false,
    bool clearRetryAt = false,
  }) {
    return AutoSyncStatus(
      type: type ?? this.type,
      lastSuccessAt: clearLastSuccessAt
          ? null
          : (lastSuccessAt ?? this.lastSuccessAt),
      retryAt: clearRetryAt ? null : (retryAt ?? this.retryAt),
      retryAttempt: retryAttempt ?? this.retryAttempt,
    );
  }
}
