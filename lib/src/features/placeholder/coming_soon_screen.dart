import 'package:flutter/material.dart';

import '../../core/widgets/app_page_header.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/adaptive.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        context.scaled(24),
        context.scaled(22),
        context.scaled(24),
        context.scaled(120) + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        AppPageHeader(
          subtitle: title,
          title: title,
        ),
        SizedBox(height: context.scaled(30)),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.64),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(icon, color: colors.primary, size: 42),
              ),
              const SizedBox(height: 22),
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.appText.pageTitle.copyWith(
                  color: colors.onSurface,
                  fontSize: context.scaledFont(24, min: 22),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tính năng này đang được phát triển.',
                textAlign: TextAlign.center,
                style: context.appText.pageSubtitle.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.62),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
