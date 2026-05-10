enum AutoSyncStatusType { idle, success, failure }

class AutoSyncStatus {
  const AutoSyncStatus({
    required this.type,
    this.lastSuccessAt,
    this.retryAt,
  });

  const AutoSyncStatus.idle()
      : type = AutoSyncStatusType.idle,
        lastSuccessAt = null,
        retryAt = null;

  final AutoSyncStatusType type;
  final DateTime? lastSuccessAt;
  final DateTime? retryAt;

  AutoSyncStatus copyWith({
    AutoSyncStatusType? type,
    DateTime? lastSuccessAt,
    DateTime? retryAt,
    bool clearLastSuccessAt = false,
    bool clearRetryAt = false,
  }) {
    return AutoSyncStatus(
      type: type ?? this.type,
      lastSuccessAt: clearLastSuccessAt
          ? null
          : (lastSuccessAt ?? this.lastSuccessAt),
      retryAt: clearRetryAt ? null : (retryAt ?? this.retryAt),
    );
  }
}
