import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../config/v_keyboard_config.dart';
import '../controller/v_keyboard_controller.dart';
import '../layouts/desktop_layouts.dart';
import '../models/desktop_key_model.dart';
import '../models/key_data.dart';
import '../models/keyboard_type.dart';
import '../responsive/keyboard_metrics.dart';
import '../theme/v_keyboard_theme.dart';
import '../widgets/clipboard_history_panel.dart';
import '../widgets/desktop_full_keyboard.dart';
import '../widgets/virtual_key_button.dart';
import '../widgets/emoji_panel.dart';
import '../widgets/keyboard_view.dart';
import '../widgets/layout_picker_dialog.dart';

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
    this.renderKeyboard = true,
    this.onLayoutChanged,
  });

  final Widget child;

  /// Optional callback invoked when the keyboard layout changes.
  final ValueChanged<String>? onLayoutChanged;

  /// Optionally supply your own controller (e.g. to drive the keyboard
  /// programmatically). One is created and disposed automatically otherwise.
  final VKeyboardController? controller;

  /// Visual theme; derived from the ambient [ThemeData] when null.
  final VKeyboardTheme? theme;

  /// Default behavioural config for descendant fields.
  final VKeyboardConfig config;

  /// When true the keyboard floats above content instead of pushing it.
  final bool floating;

  /// When false, [VKeyboardScope] will not render the bottom keyboard overlay,
  /// allowing custom or embedded keyboard placement while preserving session binding.
  final bool renderKeyboard;

  /// Looks up the nearest controller. Throws if there is no scope above.
  static VKeyboardController of(BuildContext context) {
    final marker = maybeOf(context);
    assert(marker != null, 'No VKeyboardScope found above this VTextField.');
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final VKeyboardController _controller;
  late final AnimationController _anim;
  late final Animation<double> _curved;
  bool _ownsController = false;
  StreamSubscription<String>? _layoutSub;

  /// Last computed height; reused while animating out (no session present).
  double _lastHeight = 280;

  /// Shared TapRegion group so taps on the keyboard don't dismiss the field.
  final Object _tapGroup = Object();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller =
        widget.controller ?? VKeyboardController(config: widget.config);
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
    _layoutSub = _controller.onLayoutChanged.listen((id) {
      widget.onLayoutChanged?.call(id);
    });
  }

  @override
  void didUpdateWidget(VKeyboardScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.config != oldWidget.config) {
      _controller.updateConfig(widget.config);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _controller.config.enableClipboardHistory &&
        _controller.config.syncSystemClipboard) {
      _controller.clipboardHistory.syncFromSystemClipboard();
    }
  }

  bool _pendingRebuild = false;

  void _onControllerChanged() {
    if (!mounted) return;
    if (_controller.isVisible) {
      _anim.forward();
    } else {
      _anim.reverse();
    }

    // If the widget tree is currently locked (e.g. during build, layout, or unmounting),
    // defer setState to post-frame callback to avoid "setState() called when locked".
    final phase = WidgetsBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks) {
      if (!_pendingRebuild) {
        _pendingRebuild = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pendingRebuild = false;
          if (mounted) setState(() {});
        });
      }
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _layoutSub?.cancel();
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

  static const double _fullKeyboardHeightRatio = 0.44;

  /// Height of a headerless, full-width [DesktopFullKeyboard] — mirrors its
  /// own sizing so the simulated viewInsets match what it paints.
  KeyboardMetrics _fullKeyboardMetrics(
    MediaQueryData mq,
    KeyboardLayoutType formFactor, {
    bool hasBottomBar = false,
  }) {
    final width = mq.size.width;
    final totalUnits = switch (formFactor) {
      KeyboardLayoutType.layout60 => 15,
      KeyboardLayoutType.layout65 || KeyboardLayoutType.layout75 => 16,
      KeyboardLayoutType.layout87TKL => width >= 540 ? 18 : 15,
      KeyboardLayoutType.layout98 => width >= 720 ? 19 : 15,
      KeyboardLayoutType.layout100 =>
        15 + (width >= 540 ? 3 : 0) + (width >= 720 ? 4 : 0),
    };
    final rowCount = formFactor.hasFunctionRow ? 6 : 5;
    final hPadding = (width * 0.008).clamp(6.0, 16.0);
    final unitWidth = (width - hPadding * 2) / totalUnits;
    final rowHeight = (unitWidth * 0.85).clamp(32.0, 54.0);
    final vPadding = (rowHeight * 0.24).clamp(6.0, 12.0);
    final verticalOuterPadding = vPadding + (hasBottomBar ? 0.0 : vPadding);
    final screenH = mq.size.height > 0 ? mq.size.height : 900.0;
    final cap =
        (screenH * _fullKeyboardHeightRatio).clamp(190.0, screenH * 0.65);
    final height =
        math.min(rowCount * rowHeight + verticalOuterPadding, cap).toDouble();
    return KeyboardMetrics(
      height: height,
      maxWidth: width,
      horizontalPadding: hPadding,
      rowSpacing: 0,
      formFactor: DeviceFormFactor.desktop,
      isLandscape: mq.size.width >= mq.size.height,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final theme = widget.theme ?? VKeyboardTheme.fromTheme(Theme.of(context));

    final effectiveConfig = widget.controller?.config ?? widget.config;
    final isClipboard = _controller.currentPage == 'clipboard';
    final isDesktopLayout =
        _controller.session?.type == VKeyboardType.desktop &&
            _controller.session?.customLayout == null;

    final isFullDesktopOverlay =
        isDesktopLayout && effectiveConfig.desktopFormFactor != null;
    final showFullDesktopHide = effectiveConfig.showHideKeyboardButton;
    final showFullDesktopClipboard = effectiveConfig.enableClipboardHistory &&
        effectiveConfig.showClipboardButton;
    final showFullDesktopGlobe = effectiveConfig.showGlobeKey &&
        _controller.config.enabledLayouts.length >= 2;
    final fullDesktopHasBottomBar =
        showFullDesktopHide || showFullDesktopClipboard || showFullDesktopGlobe;

    final List<List<KeyData>>? rows;
    final KeyboardMetrics? metrics;
    if (isDesktopLayout) {
      // Desktop layout is built responsively from the available width and is
      // centred + width-limited; rows collapse as the window narrows.
      final formFactor = effectiveConfig.desktopFormFactor;
      if (formFactor != null) {
        // Rendered by DesktopFullKeyboard; rows are unused but non-null.
        rows = const [];
        metrics = _fullKeyboardMetrics(
          mq,
          formFactor,
          hasBottomBar: fullDesktopHasBottomBar,
        );
      } else {
        final contentWidth = mq.size.width.clamp(320.0, 1320.0);
        rows = DesktopLayouts.rows(contentWidth,
            layoutId: _controller.currentLayoutId);
        metrics = _desktopMetrics(mq, rows.length, contentWidth);
      }
    } else {
      rows = _controller.currentRows;
      final type = _controller.session?.type;
      final compact = type == VKeyboardType.number ||
          type == VKeyboardType.decimal ||
          type == VKeyboardType.pin ||
          type == VKeyboardType.phone;
      metrics = isClipboard
          ? KeyboardMetrics.resolve(mq, rows: 6, compact: false)
          : (rows != null
              ? KeyboardMetrics.resolve(mq, rows: rows.length, compact: compact)
              : null);
    }
    if (metrics != null) _lastHeight = metrics.height;

    final type = _controller.session?.type;
    final isTextLike = type == VKeyboardType.standard ||
        type == VKeyboardType.text ||
        type == VKeyboardType.email ||
        type == VKeyboardType.url ||
        type == VKeyboardType.password ||
        type == VKeyboardType.multiline;
    final shouldShowGlobe = isTextLike &&
        !isDesktopLayout &&
        _controller.config.showGlobeKey &&
        _controller.config.enabledLayouts.length >= 2;

    final showHideButton = effectiveConfig.showHideKeyboardButton &&
        (!isDesktopLayout || isFullDesktopOverlay);
    final showClipboardButton = effectiveConfig.enableClipboardHistory &&
        effectiveConfig.showClipboardButton &&
        (!isDesktopLayout || isFullDesktopOverlay);
    final hasBottomBar = showHideButton ||
        shouldShowGlobe ||
        showClipboardButton ||
        (isFullDesktopOverlay && showFullDesktopGlobe);
    final bottomInset =
        hasBottomBar ? math.max(mq.padding.bottom, 36.0) : mq.padding.bottom;
    final fullHeight = _lastHeight + bottomInset;

    return _VKeyboardScopeMarker(
      data: VKeyboardScopeData(
        controller: _controller,
        theme: theme,
        config: effectiveConfig,
        tapGroup: _tapGroup,
      ),
      child: Stack(
        children: [
          // Content with simulated viewInsets so Scaffolds resize like native.
          AnimatedBuilder(
            animation: _curved,
            builder: (context, child) {
              final inset = (!widget.renderKeyboard || widget.floating)
                  ? 0.0
                  : fullHeight * _curved.value;
              return MediaQuery(
                data: mq.copyWith(
                  viewInsets: mq.viewInsets
                      .copyWith(bottom: mq.viewInsets.bottom + inset),
                ),
                child: child!,
              );
            },
            child: widget.child,
          ),

          // The keyboard itself.
          if (widget.renderKeyboard &&
              (rows != null || isClipboard) &&
              metrics != null)
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
                        : _controller.currentPage == 'clipboard'
                            ? ClipboardHistoryPanel(
                                controller: _controller,
                                theme: theme,
                                height: metrics.height,
                                maxWidth: metrics.maxWidth,
                                bottomSafeArea: bottomInset,
                              )
                            : (isDesktopLayout &&
                                    effectiveConfig.desktopFormFactor != null)
                                ? SizedBox(
                                    height: metrics.height + bottomInset,
                                    // The scope usually sits above the
                                    // Navigator (MaterialApp.builder), so
                                    // provide the Material text defaults
                                    // DesktopFullKeyboard relies on.
                                    child: Material(
                                      type: MaterialType.transparency,
                                      child: DesktopFullKeyboard(
                                        controller: _controller,
                                        layoutType:
                                            effectiveConfig.desktopFormFactor!,
                                        themeData: DesktopKeyboardThemeData
                                            .fromVKeyboardTheme(theme),
                                        showHeader: false,
                                        showPlatformToggle: false,
                                        showHideKeyboardButton: showHideButton,
                                        showGlobeKey: showFullDesktopGlobe,
                                        showClipboardButton:
                                            showClipboardButton,
                                        bottomSafeArea: bottomInset,
                                        onDismiss: _controller.hide,
                                        maxKeyboardHeightRatio:
                                            _fullKeyboardHeightRatio,
                                      ),
                                    ),
                                  )
                                : KeyboardView(
                                    controller: _controller,
                                    theme: theme,
                                    metrics: metrics,
                                    rows: rows ?? const [],
                                    bottomSafeArea: bottomInset,
                                    showHideKeyboardButton: showHideButton,
                                    showGlobeKey: shouldShowGlobe,
                                    showClipboardButton: showClipboardButton,
                                  ),
                  ),
                ),
              ),
            ),

          // Layout picker, drawn here rather than pushed as a route so it
          // needs no Navigator and the active field keeps focus. Shares the
          // keyboard's tap group so taps on it don't dismiss the keyboard.
          if (_controller.isLayoutPickerOpen)
            Positioned.fill(
              child: TapRegion(
                groupId: _tapGroup,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _controller.closeLayoutPicker,
                        child: const ColoredBox(color: Colors.black54),
                      ),
                    ),
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: math.min(380, mq.size.width - 32),
                          maxHeight: math.min(420, mq.size.height - 32),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: VKeyboardLayoutPickerPanel(
                            controller: _controller,
                            theme: theme,
                            onSelected: _controller.closeLayoutPicker,
                          ),
                        ),
                      ),
                    ),
                  ],
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
