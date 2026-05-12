import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';
import '../utils/adaptive.dart';
import '../../models/auth_user.dart';
import '../../providers/auth_provider.dart';
import 'app_bounce_builder.dart';

class AppPageHeader extends ConsumerWidget {
  const AppPageHeader({
    super.key,
    this.subtitle,
    required this.title,
    this.titleColor,
    this.showAvatar = true,
  });

  final String? subtitle;
  final String title;
  final Color? titleColor;
  final bool showAvatar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authProvider);
    final scale = context.adaptiveScale;
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                Text(subtitle!, style: context.appText.pageEyebrow),
                const SizedBox(height: 5),
              ],
              Text(
                title,
                style: context.appText.pageTitle.copyWith(
                  color: titleColor ?? colors.onSurface,
                  fontSize: context.scaledFont(27, min: 24),
                  letterSpacing: -1.0 * scale,
                ),
              ),
            ],
          ),
        ),
        if (showAvatar) ...[
          SizedBox(width: context.scaled(12)),
          _ProfileAvatarButton(
            authUser: authUser,
            onTap: () => context.push('/settings'),
          ),
        ],
      ],
    );
  }
}

class _ProfileAvatarButton extends StatelessWidget {
  const _ProfileAvatarButton({required this.authUser, required this.onTap});

  final AuthUser? authUser;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final avatarLabel = _avatarLabel(authUser);
    final size = context.scaled(60);
    final photoUrl = authUser?.photoUrl;

    return AppBounceBuilder(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: photoUrl == null || photoUrl.isEmpty
              ? AppColors.primary.withValues(alpha: 0.12)
              : colors.surface,
          boxShadow: appSurfaceShadow(context),
        ),
        child: ClipOval(
          child: photoUrl == null || photoUrl.isEmpty
              ? _AvatarFallback(label: avatarLabel)
              : Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _AvatarFallback(label: avatarLabel);
                  },
                ),
        ),
      ),
    );
  }

  String _avatarLabel(AuthUser? authUser) {
    final source = authUser?.name.trim();
    if (source == null || source.isEmpty) {
      return 'A';
    }

    return source.substring(0, 1).toUpperCase();
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        label,
        style: context.appText.pageTitle.copyWith(
          color: AppColors.primary,
          fontSize: context.scaledFont(22, min: 18),
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
