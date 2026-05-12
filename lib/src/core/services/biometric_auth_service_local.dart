import 'dart:io';

import 'package:local_auth/local_auth.dart';

import 'biometric_auth_result.dart';

class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? localAuthentication})
    : _localAuthentication = localAuthentication ?? LocalAuthentication();

  final LocalAuthentication _localAuthentication;

  Future<BiometricAuthResult> checkAvailability() async {
    if (Platform.isLinux || Platform.isWindows) {
      return const BiometricAuthResult.failure(
        failure: BiometricAuthFailure.notSupported,
        message:
            'Nền tảng này chưa hỗ trợ chế độ khóa ứng dụng bằng bảo mật thiết bị.',
        canDisableLock: true,
      );
    }

    try {
      final isDeviceSupported = await _localAuthentication.isDeviceSupported();
      if (!isDeviceSupported) {
        return const BiometricAuthResult.failure(
          failure: BiometricAuthFailure.notSupported,
          message: 'Thiết bị không hỗ trợ bảo mật thiết bị.',
          canDisableLock: true,
        );
      }

      return const BiometricAuthResult.success();
    } on LocalAuthException catch (error) {
      return _mapException(error);
    } catch (_) {
      return const BiometricAuthResult.failure(
        failure: BiometricAuthFailure.unknown,
        message: 'Không thể kiểm tra bảo mật thiết bị trên máy này.',
        canRetry: true,
      );
    }
  }

  Future<BiometricAuthResult> authenticate({required String reason}) async {
    final availability = await checkAvailability();
    if (!availability.success) {
      return availability;
    }

    try {
      final authenticated = await _localAuthentication.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );

      if (authenticated) {
        return const BiometricAuthResult.success();
      }

      return const BiometricAuthResult.failure(
        failure: BiometricAuthFailure.failed,
        message: 'Không thể xác thực bằng bảo mật thiết bị. Vui lòng thử lại.',
        canRetry: true,
      );
    } on LocalAuthException catch (error) {
      return _mapException(error);
    } catch (_) {
      return const BiometricAuthResult.failure(
        failure: BiometricAuthFailure.unknown,
        message: 'Xác thực bằng bảo mật thiết bị thất bại. Vui lòng thử lại.',
        canRetry: true,
      );
    }
  }

  BiometricAuthResult _mapException(LocalAuthException error) {
    return switch (error.code) {
      LocalAuthExceptionCode.noBiometricsEnrolled =>
        const BiometricAuthResult.failure(
          failure: BiometricAuthFailure.notEnrolled,
          message:
              'Thiết bị chưa đăng ký vân tay hoặc Face ID. Vui lòng dùng PIN, mật khẩu hoặc pattern nếu hệ thống hỗ trợ.',
          canRetry: true,
          canDisableLock: true,
        ),
      LocalAuthExceptionCode.noCredentialsSet =>
        const BiometricAuthResult.failure(
          failure: BiometricAuthFailure.passcodeNotSet,
          message:
              'Thiết bị chưa đặt PIN, mật khẩu, pattern hoặc passcode màn hình.',
          canRetry: true,
          canDisableLock: true,
        ),
      LocalAuthExceptionCode.noBiometricHardware =>
        const BiometricAuthResult.failure(
          failure: BiometricAuthFailure.notSupported,
          message: 'Thiết bị không hỗ trợ bảo mật sinh trắc học.',
          canDisableLock: true,
        ),
      LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable =>
        const BiometricAuthResult.failure(
          failure: BiometricAuthFailure.notAvailable,
          message: 'Sinh trắc học hiện không khả dụng. Vui lòng thử lại sau.',
          canRetry: true,
          canDisableLock: true,
        ),
      LocalAuthExceptionCode.temporaryLockout ||
      LocalAuthExceptionCode
          .biometricLockout => const BiometricAuthResult.failure(
        failure: BiometricAuthFailure.lockedOut,
        message:
            'Sinh trắc học đang bị khóa do thử sai nhiều lần. Vui lòng dùng khóa màn hình hoặc thử lại sau.',
        canRetry: true,
      ),
      LocalAuthExceptionCode.userCanceled ||
      LocalAuthExceptionCode.systemCanceled ||
      LocalAuthExceptionCode.timeout ||
      LocalAuthExceptionCode.userRequestedFallback =>
        const BiometricAuthResult.failure(
          failure: BiometricAuthFailure.canceled,
          message: 'Bạn cần xác thực bằng bảo mật thiết bị để mở ứng dụng.',
          canRetry: true,
        ),
      LocalAuthExceptionCode.authInProgress =>
        const BiometricAuthResult.failure(
          failure: BiometricAuthFailure.authInProgress,
          message: 'Đang có phiên xác thực bảo mật thiết bị khác.',
          canRetry: true,
        ),
      LocalAuthExceptionCode.uiUnavailable => const BiometricAuthResult.failure(
        failure: BiometricAuthFailure.notAvailable,
        message: 'Không thể hiển thị hộp thoại bảo mật thiết bị lúc này.',
        canRetry: true,
      ),
      LocalAuthExceptionCode.deviceError ||
      LocalAuthExceptionCode.unknownError => BiometricAuthResult.failure(
        failure: BiometricAuthFailure.unknown,
        message:
            error.description ??
            'Xác thực bằng bảo mật thiết bị thất bại. Vui lòng thử lại.',
        canRetry: true,
      ),
    };
  }
}
