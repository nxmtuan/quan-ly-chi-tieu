import 'package:flutter/material.dart';

class AppBounceBuilder extends StatefulWidget {
  const AppBounceBuilder({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.90,
    this.pressInDuration = const Duration(milliseconds: 70),
    this.releaseDuration = const Duration(milliseconds: 140),
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final Duration pressInDuration;
  final Duration releaseDuration;

  @override
  State<AppBounceBuilder> createState() => _AppBounceBuilderState();
}

class _AppBounceBuilderState extends State<AppBounceBuilder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.pressInDuration,
      reverseDuration: widget.releaseDuration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleDown).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}
