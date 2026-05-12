import 'biometric_auth_result.dart';

class BiometricAuthService {
  const BiometricAuthService();

  Future<BiometricAuthResult> checkAvailability() async {
    return const BiometricAuthResult.failure(
      failure: BiometricAuthFailure.notSupported,
      message: 'Nền tảng này chưa hỗ trợ mở khóa bằng bảo mật thiết bị.',
      canDisableLock: true,
    );
  }

  Future<BiometricAuthResult> authenticate({required String reason}) async {
    return checkAvailability();
  }
}
