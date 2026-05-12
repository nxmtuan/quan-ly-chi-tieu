enum BiometricAuthFailure {
  notSupported,
  notEnrolled,
  passcodeNotSet,
  notAvailable,
  lockedOut,
  canceled,
  authInProgress,
  failed,
  unknown,
}

class BiometricAuthResult {
  const BiometricAuthResult._({
    required this.success,
    this.failure,
    this.message,
    this.canRetry = false,
    this.canDisableLock = false,
  });

  const BiometricAuthResult.success() : this._(success: true);

  const BiometricAuthResult.failure({
    required BiometricAuthFailure failure,
    required String message,
    bool canRetry = false,
    bool canDisableLock = false,
  }) : this._(
         success: false,
         failure: failure,
         message: message,
         canRetry: canRetry,
         canDisableLock: canDisableLock,
       );

  final bool success;
  final BiometricAuthFailure? failure;
  final String? message;
  final bool canRetry;
  final bool canDisableLock;
}
