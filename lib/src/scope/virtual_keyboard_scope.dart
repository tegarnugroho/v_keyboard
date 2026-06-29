import 'package:flutter/material.dart';

import '../config/virtual_keyboard_config.dart';
import '../controller/virtual_keyboard_controller.dart';
import '../responsive/keyboard_metrics.dart';
import '../theme/virtual_keyboard_theme.dart';
import '../widgets/keyboard_view.dart';

/// Root of the virtual keyboard system. Wrap your app (or any subtree
/// containing [VirtualTextField]s) in one of these.
///
/// It owns the [VirtualKeyboardController], animates the keyboard in/out, and
/// — like the system keyboard — increases `MediaQuery.viewInsets.bottom` so
/// any `Scaffold` with `resizeToAvoidBottomInset` pushes its content up.
class VirtualKeyboardScope extends StatefulWidget {
  const VirtualKeyboardScope({
    super.key,
    required this.child,
    this.controller,
    this.theme,
    this.config = const VirtualKeyboardConfig(),
    this.floating = false,
  });

  final Widget child;

  /// Optionally supply your own controller (e.g. to drive the keyboard
  /// programmatically). One is created and disposed automatically otherwise.
  final VirtualKeyboardController? controller;

  /// Visual theme; derived from the ambient [ThemeData] when null.
  final VirtualKeyboardTheme? theme;

  /// Default behavioural config for descendant fields.
  final VirtualKeyboardConfig config;

  /// When true the keyboard floats above content instead of pushing it.
  final bool floating;

  /// Looks up the nearest controller. Throws if there is no scope above.
  static VirtualKeyboardController of(BuildContext context) {
    final marker = maybeOf(context);
    assert(marker != null,
        'No VirtualKeyboardScope found above this VirtualTextField.');
    return marker!.controller;
  }

  static VirtualKeyboardScopeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_VirtualKeyboardScopeMarker>()
        ?.data;
  }

  @override
  State<VirtualKeyboardScope> createState() => _VirtualKeyboardScopeState();
}

class _VirtualKeyboardScopeState extends State<VirtualKeyboardScope>
    with SingleTickerProviderStateMixin {
  late final VirtualKeyboardController _controller;
  late final AnimationController _anim;
  late final Animation<double> _curved;
  bool _ownsController = false;

  /// Last computed height; reused while animating out (no session present).
  double _lastHeight = 280;

  /// Shared TapRegion group so taps on the keyboard don't dismiss the field.
  final Object _tapGroup = Object();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? VirtualKeyboardController(config: widget.config);
    _ownsController = widget.controller == null;
    _anim = AnimationController(
      vsync: this,
      duration: widget.config.animationDuration,
      reverseDuration: widget.config.animationDuration,
    );
    _curved = CurvedAnimation(
      parent: _anim,
      curve: widget.config.animationCurve,
      reverseCurve: widget.config.animationCurve.flipped,
    );
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (_controller.isVisible) {
      _anim.forward();
    } else {
      _anim.reverse();
    }
    if (mounted) setState(() {}); // page/shift/layout changes
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _anim.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final rows = _controller.currentRows;
    final theme = widget.theme ?? VirtualKeyboardTheme.fromTheme(Theme.of(context));

    final metrics = rows == null
        ? null
        : KeyboardMetrics.resolve(mq, rows: rows.length);
    if (metrics != null) _lastHeight = metrics.height;

    final bottomInset = mq.padding.bottom; // safe area
    final fullHeight = _lastHeight + bottomInset;

    return _VirtualKeyboardScopeMarker(
      data: VirtualKeyboardScopeData(
        controller: _controller,
        theme: theme,
        config: widget.config,
        tapGroup: _tapGroup,
      ),
      child: Stack(
        children: [
          // Content with simulated viewInsets so Scaffolds resize like native.
          AnimatedBuilder(
            animation: _curved,
            builder: (context, child) {
              final inset = widget.floating ? 0.0 : fullHeight * _curved.value;
              return MediaQuery(
                data: mq.copyWith(
                  viewInsets:
                      mq.viewInsets.copyWith(bottom: mq.viewInsets.bottom + inset),
                ),
                child: child!,
              );
            },
            child: widget.child,
          ),

          // The keyboard itself.
          if (rows != null && metrics != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _curved,
                builder: (context, child) {
                  return FractionalTranslation(
                    translation: Offset(0, 1 - _curved.value),
                    child: IgnorePointer(
                      ignoring: _curved.value < 0.5,
                      child: child,
                    ),
                  );
                },
                child: TapRegion(
                  groupId: _tapGroup,
                  child: RepaintBoundary(
                    child: KeyboardView(
                      controller: _controller,
                      theme: theme,
                      metrics: metrics,
                      rows: rows,
                      bottomSafeArea: bottomInset,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Data exposed by [VirtualKeyboardScope] to descendants.
@immutable
class VirtualKeyboardScopeData {
  const VirtualKeyboardScopeData({
    required this.controller,
    required this.theme,
    required this.config,
    required this.tapGroup,
  });

  final VirtualKeyboardController controller;
  final VirtualKeyboardTheme theme;
  final VirtualKeyboardConfig config;
  final Object tapGroup;
}

class _VirtualKeyboardScopeMarker extends InheritedWidget {
  const _VirtualKeyboardScopeMarker({required this.data, required super.child});

  final VirtualKeyboardScopeData data;

  @override
  bool updateShouldNotify(_VirtualKeyboardScopeMarker oldWidget) =>
      data.controller != oldWidget.data.controller ||
      data.theme != oldWidget.data.theme ||
      data.tapGroup != oldWidget.data.tapGroup;
}
