import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_typography.dart';
import '../utils/adaptive.dart';

enum AppToastType { success, error, info }

class AppToast {
  AppToast._();

  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;
  static ValueNotifier<bool>? _visibilityNotifier;

  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(milliseconds: 2200),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      return;
    }

    _dismissTimer?.cancel();
    _visibilityNotifier?.dispose();
    _visibilityNotifier = null;
    _currentEntry?.remove();
    final visibilityNotifier = ValueNotifier<bool>(true);
    _visibilityNotifier = visibilityNotifier;

    _currentEntry = OverlayEntry(
      builder: (overlayContext) {
        return _ToastOverlay(
          message: message,
          type: type,
          visibility: visibilityNotifier,
          onDismissed: () {
            if (identical(_visibilityNotifier, visibilityNotifier)) {
              _dismissTimer?.cancel();
              _dismissTimer = null;
              _currentEntry?.remove();
              _currentEntry = null;
              _visibilityNotifier?.dispose();
              _visibilityNotifier = null;
            }
          },
        );
      },
    );

    overlay.insert(_currentEntry!);
    _dismissTimer = Timer(duration, dismiss);
  }

  static void dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _visibilityNotifier?.value = false;
  }
}

class _ToastOverlay extends StatefulWidget {
  const _ToastOverlay({
    required this.message,
    required this.type,
    required this.visibility,
    required this.onDismissed,
  });

  final String message;
  final AppToastType type;
  final ValueNotifier<bool> visibility;
  final VoidCallback onDismissed;

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..forward();
    widget.visibility.addListener(_handleVisibilityChanged);
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _offset = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        widget.onDismissed();
      }
    });
  }

  void _handleVisibilityChanged() {
    if (!widget.visibility.value) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    widget.visibility.removeListener(_handleVisibilityChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = switch (widget.type) {
      AppToastType.success => AppColors.success,
      AppToastType.error => AppColors.danger,
      AppToastType.info => AppColors.primary,
    };
    final icon = switch (widget.type) {
      AppToastType.success => Icons.check_circle_rounded,
      AppToastType.error => Icons.error_rounded,
      AppToastType.info => Icons.info_rounded,
    };

    return IgnorePointer(
      ignoring: true,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                context.scaled(16),
                context.scaled(10),
                context.scaled(16),
                0,
              ),
              child: FadeTransition(
                opacity: _opacity,
                child: SlideTransition(
                  position: _offset,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: context.scaled(520),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.scaled(14),
                        vertical: context.scaled(12),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(context.scaled(18)),
                        border: Border.all(
                          color: color.withValues(alpha: 0.18),
                        ),
                        boxShadow: appSurfaceShadow(context),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: context.scaled(28),
                            height: context.scaled(28),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Icon(
                              icon,
                              size: context.scaled(18),
                              color: color,
                            ),
                          ),
                          SizedBox(width: context.scaled(10)),
                          Expanded(
                            child: Text(
                              widget.message,
                              style: context.appText.bodyStrong.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
