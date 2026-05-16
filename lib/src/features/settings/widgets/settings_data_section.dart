part of '../settings_screen.dart';

const _deleteAllDataConfirmationText = 'Delete all data';

class _DeleteAllDataRow extends ConsumerStatefulWidget {
  const _DeleteAllDataRow();

  @override
  ConsumerState<_DeleteAllDataRow> createState() => _DeleteAllDataRowState();
}

class _DeleteAllDataRowState extends ConsumerState<_DeleteAllDataRow> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return _SettingsRow(
      icon: Icons.delete_forever_rounded,
      iconColor: AppColors.danger,
      title: 'Xóa toàn bộ dữ liệu',
      subtitle: _isDeleting
          ? 'Đang xóa dữ liệu cục bộ'
          : 'Xóa giao dịch, ngân sách, tiết kiệm, định kỳ và dữ liệu quản lý',
      trailing: _isDeleting
          ? SizedBox(
              width: context.scaled(20),
              height: context.scaled(20),
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              Icons.chevron_right_rounded,
              color: context.appPalette.textSecondary,
            ),
      onTap: _isDeleting ? null : _startDeleteFlow,
    );
  }

  Future<void> _startDeleteFlow() async {
    final acceptedWarning = await showAppConfirmDialog(
      context,
      title: 'Xóa toàn bộ dữ liệu',
      message:
          'Hành động này sẽ xóa toàn bộ dữ liệu cục bộ trong ứng dụng, gồm giao dịch, ngân sách, tiết kiệm, định kỳ, danh mục và nguồn tiền đã lưu. Dữ liệu trên Google Drive không bị xóa. Không thể hoàn tác.',
      cancelText: 'Hủy',
      confirmText: 'Vẫn xóa',
      confirmBackgroundColor: AppColors.danger,
    );

    if (acceptedWarning != true || !mounted) {
      return;
    }

    final typedCorrectly = await _showDeletePhraseDialog(context);
    if (typedCorrectly != true || !mounted) {
      return;
    }

    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Xác nhận xóa dữ liệu',
      message: 'Toàn bộ dữ liệu sẽ bị xóa. Xác nhận?',
      cancelText: 'Hủy',
      confirmText: 'Xác nhận',
      confirmBackgroundColor: AppColors.danger,
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _isDeleting = true);
    try {
      await deleteAllLocalAppData(ref);
      if (mounted) {
        AppToast.show(
          context,
          message: 'Đã xóa toàn bộ dữ liệu cục bộ',
          type: AppToastType.success,
        );
      }
    } catch (_) {
      if (mounted) {
        AppToast.show(
          context,
          message: 'Không thể xóa dữ liệu. Vui lòng thử lại.',
          type: AppToastType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }
}

Future<bool?> _showDeletePhraseDialog(BuildContext context) async {
  final controller = TextEditingController();
  var matches = false;

  try {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              alignment: Alignment.bottomCenter,
              insetPadding: EdgeInsets.all(context.scaled(16)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.scaled(28)),
              ),
              child: Padding(
                padding: EdgeInsets.all(context.scaled(24)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Nhập xác nhận',
                      style: context.appText.sheetTitle,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: context.scaled(10)),
                    Text(
                      'Nhập chính xác "$_deleteAllDataConfirmationText" để tiếp tục.',
                      textAlign: TextAlign.center,
                      style: context.appText.body.copyWith(
                        color: context.appPalette.textSecondary,
                      ),
                    ),
                    SizedBox(height: context.scaled(18)),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      cursorColor: AppColors.primary,
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {
                        setState(
                          () => matches =
                              value.trim() == _deleteAllDataConfirmationText,
                        );
                      },
                      onSubmitted: (_) {
                        if (matches) {
                          Navigator.of(context).pop(true);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: _deleteAllDataConfirmationText,
                        filled: true,
                        fillColor: context.appPalette.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            context.scaled(16),
                          ),
                          borderSide: BorderSide(
                            color: context.appPalette.border,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            context.scaled(16),
                          ),
                          borderSide: BorderSide(
                            color: context.appPalette.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            context.scaled(16),
                          ),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.3,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: context.scaled(22)),
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
                                borderRadius: BorderRadius.circular(
                                  context.scaled(16),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Hủy',
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
                            onTap: matches
                                ? () => Navigator.of(context).pop(true)
                                : null,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: context.scaled(16),
                              ),
                              decoration: BoxDecoration(
                                color: matches
                                    ? AppColors.danger
                                    : context.appPalette.inputBackground,
                                borderRadius: BorderRadius.circular(
                                  context.scaled(16),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Tiếp tục',
                                style: context.appText.buttonLabel.copyWith(
                                  color: matches
                                      ? Colors.white
                                      : context.appPalette.textSecondary
                                            .withValues(alpha: 0.55),
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
            );
          },
        );
      },
    );
  } finally {
    controller.dispose();
  }
}
