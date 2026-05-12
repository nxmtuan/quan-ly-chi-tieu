part of '../settings_screen.dart';

class _AuthSettingsRow extends ConsumerWidget {
  const _AuthSettingsRow({required this.authUser});

  final AuthUser? authUser;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (authUser == null) {
      if (kIsWeb) {
        return AppBounceBuilder(
          onTap: null,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.scaled(8),
              vertical: context.scaled(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: context.scaled(46),
                      height: context.scaled(46),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(context.scaled(16)),
                      ),
                      child: Icon(
                        Icons.login_rounded,
                        color: AppColors.primary,
                        size: context.scaled(22),
                      ),
                    ),
                    SizedBox(width: context.scaled(14)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tài khoản',
                            style: context.appText.bodyStrong.copyWith(
                              fontSize: context.scaledFont(15, min: 14),
                            ),
                          ),
                          SizedBox(height: context.scaled(5)),
                          Text(
                            'Kết nối tài khoản Google',
                            style: context.appText.caption.copyWith(
                              color: context.appPalette.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.scaled(12)),
                SizedBox(
                  height: context.scaled(42),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: GoogleWebSignInButton(),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return _SettingsRow(
        icon: Icons.login_rounded,
        iconColor: AppColors.primary,
        title: 'Đăng nhập',
        subtitle: 'Kết nối tài khoản Google',
        trailing: const Icon(Icons.login_rounded),
        onTap: () => _signIn(context, ref),
      );
    }

    return _SettingsRow(
      icon: Icons.logout_rounded,
      iconColor: AppColors.danger,
      title: 'Đăng xuất',
      subtitle: authUser!.email,
      trailing: const Icon(Icons.logout_rounded, color: AppColors.danger),
      onTap: () => _confirmSignOut(context, ref),
    );
  }

  Future<void> _signIn(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(authProvider.notifier).signInWithGoogle();
      if (context.mounted && ref.read(authProvider) != null) {
        AppToast.show(
          context,
          message: 'Đăng nhập thành công',
          type: AppToastType.success,
        );

        try {
          final synced = await ref
              .read(authProvider.notifier)
              .syncAfterSignIn();
          if (synced) {
            ref.read(transactionsProvider.notifier).reload();
            ref.read(categoriesProvider.notifier).reload();
            ref.read(moneySourcesProvider.notifier).reload();

            if (!context.mounted) {
              return;
            }

            AppToast.show(
              context,
              message: 'Đồng bộ dữ liệu thành công',
              type: AppToastType.success,
            );
          }
        } catch (_) {}
      }
    } catch (_) {
      if (context.mounted) {
        AppToast.show(
          context,
          message:
              'Không thể đăng nhập Google. Vui lòng kiểm tra cấu hình OAuth.',
          type: AppToastType.error,
        );
      }
    }
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Đăng xuất',
      message: 'Bạn có chắc muốn đăng xuất khỏi ứng dụng không?',
      confirmText: 'Đăng xuất',
      confirmBackgroundColor: context.appPalette.dangerSoft,
      confirmTextColor: const Color(0xFFDC2626),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authProvider.notifier).signOut();
      if (!context.mounted) {
        return;
      }
      AppToast.show(
        context,
        message: 'Đăng xuất thành công',
        type: AppToastType.success,
      );
    }
  }
}
