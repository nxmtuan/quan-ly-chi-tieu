import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/gradient_button.dart';
import '../../providers/auth_provider.dart';
import 'google_web_sign_in_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child:
              Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: colors.primary,
                          size: 38,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Quản lý tài chính',
                        style: context.appText.pageTitle,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Đăng nhập bằng Google để lưu dữ liệu cá nhân trên thiết bị này.',
                        style: context.appText.pageSubtitle.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.64),
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (kIsWeb)
                        const SizedBox(
                          width: 240,
                          height: 44,
                          child: GoogleWebSignInButton(),
                        )
                      else
                        GradientButton(
                          label: _isLoading
                              ? 'Đang đăng nhập...'
                              : 'Tiếp tục với Google',
                          icon: Icons.login_rounded,
                          onTap: _isLoading ? null : _signIn,
                        ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _errorMessage!,
                          style: context.appText.bodyStrong.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                      const Spacer(),
                    ],
                  )
                  .animate()
                  .fadeIn(duration: 260.ms)
                  .slideY(
                    begin: 0.04,
                    end: 0,
                    duration: 340.ms,
                    curve: Curves.easeOutCubic,
                  ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Không thể đăng nhập Google. Vui lòng kiểm tra cấu hình OAuth.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
