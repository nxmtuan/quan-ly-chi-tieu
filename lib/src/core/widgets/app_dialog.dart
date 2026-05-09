import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/adaptive.dart';
import 'app_bounce_builder.dart';

Future<bool?> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String cancelText = 'Hủy',
  String confirmText = 'Xác nhận',
  Color? confirmTextColor,
  Color? confirmBackgroundColor,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.fromLTRB(
        context.scaled(16),
        context.scaled(16),
        context.scaled(16),
        context.scaled(16), // Adjusted to 16 based on user recent change
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.scaled(28)),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.scaled(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: context.appText.sheetTitle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.scaled(12)),
            Text(
              message,
              style: context.appText.body.copyWith(
                color: context.appPalette.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.scaled(24)),
            Row(
              children: [
                Expanded(
                  child: AppBounceBuilder(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: context.scaled(16),
                      ),
                      decoration: BoxDecoration(
                        color: context.appPalette.inputBackground,
                        borderRadius: BorderRadius.circular(context.scaled(16)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        cancelText,
                        style: context.appText.buttonLabel.copyWith(
                          color: context.appPalette.iconMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: context.scaled(12)),
                Expanded(
                  child: AppBounceBuilder(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: context.scaled(16),
                      ),
                      decoration: BoxDecoration(
                        color: confirmBackgroundColor ?? AppColors.primary,
                        borderRadius: BorderRadius.circular(context.scaled(16)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        confirmText,
                        style: context.appText.buttonLabel.copyWith(
                          color: confirmTextColor ?? Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
