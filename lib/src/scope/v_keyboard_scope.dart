import 'package:flutter/material.dart';

import '../config/v_keyboard_config.dart';
import '../controller/v_keyboard_controller.dart';
import '../layouts/desktop_layouts.dart';
import '../models/key_data.dart';
import '../models/keyboard_type.dart';
import '../responsive/keyboard_metrics.dart';
import '../theme/v_keyboard_theme.dart';
import '../widgets/emoji_panel.dart';
import '../widgets/keyboard_view.dart';

/// Root of the virtual keyboard system. Wrap your app (or any subtree
/// containing [VTextField]s) in one of these.
///
/// It owns the [VKeyboardController], animates the keyboard in/out, and
/// — like the system keyboard — increases `MediaQuery.viewInsets.bottom` so
/// any `Scaffold` with `resizeToAvoidBottomInset` pushes its content up.
class VKeyboardScope extends StatefulWidget {
  const VKeyboardScope({
    super.key,
    required this.child,
    this.controller,
    this.theme,
    this.config = const VKeyboardConfig(),
    this.floating = false,
  });

  final Widget child;

  /// Optionally supply your own controller (e.g. to drive the keyboard
  /// programmatically). One is created and disposed automatically otherwise.
  final VKeyboardController? controller;

  /// Visual theme; derived from the ambient [ThemeData] when null.
  final VKeyboardTheme? theme;

  /// Default behavioural config for descendant fields.
  final VKeyboardConfig config;

  /// When true the keyboard floats above content instead of pushing it.
  final bool floating;

  /// Looks up the nearest controller. Throws if there is no scope above.
  static VKeyboardController of(BuildContext context) {
    final marker = maybeOf(context);
    assert(marker != null,
        'No VKeyboardScope found above this VTextField.');
    return marker!.controller;
  }

  static VKeyboardScopeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_VKeyboardScopeMarker>()
        ?.data;
  }

  @override
  State<VKeyboardScope> createState() => _VKeyboardScopeState();
}

class _VKeyboardScopeState extends State<VKeyboardScope>
    with SingleTickerProviderStateMixin {
  late final VKeyboardController _controller;
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
    _controller = widget.controller ?? VKeyboardController(config: widget.config);
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

  /// Sizing for the desktop layout: key height scales with width, total height
  /// follows the (responsive) row count, and the grid is centred + width-capped.
  KeyboardMetrics _desktopMetrics(
      MediaQueryData mq, int rowCount, double contentWidth) {
    final rowHeight = (contentWidth / 24).clamp(34.0, 58.0);
    const rowSpacing = 6.0;
    const contentVertical = 16.0; // KeyboardView contentPadding.vertical
    final height =
        rowCount * rowHeight + rowSpacing * (rowCount - 1) + contentVertical;
    return KeyboardMetrics(
      height: height,
      maxWidth: contentWidth,
      horizontalPadding: 8,
      rowSpacing: rowSpacing,
      formFactor: DeviceFormFactor.desktop,
      isLandscape: mq.size.width >= mq.size.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final theme = widget.theme ?? VKeyboardTheme.fromTheme(Theme.of(context));

    final isDesktopLayout =
        _controller.session?.type == VKeyboardType.desktop &&
            _controller.session?.customLayout == null;

    final List<List<KeyData>>? rows;
    final KeyboardMetrics? metrics;
    if (isDesktopLayout) {
      // Desktop layout is built responsively from the available width and is
      // centred + width-limited; rows collapse as the window narrows.
      final contentWidth = mq.size.width.clamp(320.0, 1320.0);
      rows = DesktopLayouts.rows(contentWidth);
      metrics = _desktopMetrics(mq, rows.length, contentWidth);
    } else {
      rows = _controller.currentRows;
      final type = _controller.session?.type;
      final compact = type == VKeyboardType.number ||
          type == VKeyboardType.decimal ||
          type == VKeyboardType.pin ||
          type == VKeyboardType.phone;
      metrics = rows == null
          ? null
          : KeyboardMetrics.resolve(mq, rows: rows.length, compact: compact);
    }
    if (metrics != null) _lastHeight = metrics.height;

    final bottomInset = mq.padding.bottom; // safe area
    final fullHeight = _lastHeight + bottomInset;

    return _VKeyboardScopeMarker(
      data: VKeyboardScopeData(
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
                    child: _controller.currentPage == 'emoji'
                        ? EmojiPanel(
                            controller: _controller,
                            theme: theme,
                            height: metrics.height,
                            maxWidth: metrics.maxWidth,
                            bottomSafeArea: bottomInset,
                          )
                        : KeyboardView(
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

/// Data exposed by [VKeyboardScope] to descendants.
@immutable
class VKeyboardScopeData {
  const VKeyboardScopeData({
    required this.controller,
    required this.theme,
    required this.config,
    required this.tapGroup,
  });

  final VKeyboardController controller;
  final VKeyboardTheme theme;
  final VKeyboardConfig config;
  final Object tapGroup;
}

class _VKeyboardScopeMarker extends InheritedWidget {
  const _VKeyboardScopeMarker({required this.data, required super.child});

  final VKeyboardScopeData data;

  @override
  bool updateShouldNotify(_VKeyboardScopeMarker oldWidget) =>
      data.controller != oldWidget.data.controller ||
      data.theme != oldWidget.data.theme ||
      data.tapGroup != oldWidget.data.tapGroup;
}
