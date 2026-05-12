part of '../settings_screen.dart';

class _SettingsActionCard extends StatelessWidget {
  const _SettingsActionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(context.scaled(22)),
        border: Border.all(color: palette.border),
      ),
      child: child,
    );
  }
}

class _InlineSettingsSwitchRow extends StatelessWidget {
  const _InlineSettingsSwitchRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaled(8),
        vertical: context.scaled(12),
      ),
      child: Row(
        children: [
          Container(
            width: context.scaled(46),
            height: context.scaled(46),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(context.scaled(16)),
            ),
            child: Icon(icon, color: iconColor, size: context.scaled(22)),
          ),
          SizedBox(width: context.scaled(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.appText.bodyStrong.copyWith(
                    fontSize: context.scaledFont(15, min: 14),
                  ),
                ),
                SizedBox(height: context.scaled(5)),
                Text(
                  subtitle,
                  style: context.appText.caption.copyWith(
                    color: context.appPalette.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SettingsTipCard extends StatelessWidget {
  const _SettingsTipCard();

  @override
  Widget build(BuildContext context) {
    return FlatCard(
      radius: context.scaled(24),
      showShadow: false,
      color: context.appPalette.primarySoft,
      child: Row(
        children: [
          Container(
            width: context.scaled(48),
            height: context.scaled(48),
            decoration: BoxDecoration(
              color: context.appPalette.surfaceElevated.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(context.scaled(15)),
            ),
            child: Icon(
              Icons.tips_and_updates_rounded,
              color: AppColors.primary,
              size: context.scaled(22),
            ),
          ),
          SizedBox(width: context.scaled(14)),
          Expanded(
            child: Text(
              'Ghi lại các khoản chi nhỏ mỗi ngày để có bức tranh tài chính rõ hơn.',
              style: context.appText.bodyStrong.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppBounceBuilder(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.scaled(8),
          vertical: context.scaled(12),
        ),
        child: Row(
          children: [
            Container(
              width: context.scaled(46),
              height: context.scaled(46),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(context.scaled(16)),
              ),
              child: Icon(icon, color: iconColor, size: context.scaled(22)),
            ),
            SizedBox(width: context.scaled(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.appText.bodyStrong.copyWith(
                      fontSize: context.scaledFont(15, min: 14),
                    ),
                  ),
                  SizedBox(height: context.scaled(5)),
                  Text(
                    subtitle,
                    style: context.appText.caption.copyWith(
                      color: context.appPalette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: context.scaled(12)),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _DividerIndent extends StatelessWidget {
  const _DividerIndent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: context.scaled(66)),
      child: Divider(height: 1, color: context.appPalette.border),
    );
  }
}
