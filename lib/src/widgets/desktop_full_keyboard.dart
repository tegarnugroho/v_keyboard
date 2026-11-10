import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide ModifierKey;

import '../controller/v_keyboard_controller.dart';
import '../models/desktop_key_model.dart';
import '../models/key_data.dart';
import '../models/key_intents.dart';
import '../scope/v_keyboard_scope.dart';
import 'virtual_key_button.dart';

/// A full-size 100% ANSI Desktop On-Screen Keyboard widget engineered for
/// edge-to-edge wide-screen monitors (Windows, macOS, Linux, Web).
///
/// Renders 3 proportionally-sized clusters side-by-side (`15 : 3 : 4` flex ratio):
/// 1. **Main Alphanumeric Cluster**: Function row (`Esc`, `F1`–`F12`), dual-legend
///    number row, QWERTY rows, modifiers (`Shift`, `Ctrl`, `Win`, `Alt`, `AltGr`,
///    `Fn`, `Menu`), and wide `SPACEBAR`.
/// 2. **Navigation Cluster**: System keys (`PrtSc`, `ScrLk`, `Pause`), edit block
///    (`Ins`, `Home`, `PgUp`, `Del`, `End`, `PgDn`), and Inverted-T arrows.
/// 3. **Numpad Cluster**: `NumLock`, operators (`/`, `*`, `-`), 4x3 keypad with
///    double-wide `0`, and double-height spanning `+` and `Enter` keys.
///
/// Works both standalone via [onKeyPressed], [onSpecialKeyPressed], and
/// [onShortcutTriggered] callbacks, or connected to a [VKeyboardController].
class DesktopFullKeyboard extends StatefulWidget {
  const DesktopFullKeyboard({
    super.key,
    this.themeData,
    this.showNumpad = true,
    this.showFunctionRow = true,
    this.showHeader = true,
    this.maxKeyboardHeightRatio = 0.38,
    this.initialCapsLock = false,
    this.initialNumLock = true,
    this.onKeyPressed,
    this.onSpecialKeyPressed,
    this.onShortcutTriggered,
    this.onDismiss,
    this.controller,
  });

  /// Visual theme data for background, keycaps, borders, and active LEDs.
  /// Defaults to [DesktopKeyboardThemeData.dark()].
  final DesktopKeyboardThemeData? themeData;

  /// Initial visibility of the right-hand Numpad cluster. Can also be toggled
  /// interactively via the top header button when [showHeader] is true.
  final bool showNumpad;

  /// Whether to render the top function row (`Esc`, `F1`–`F12`, `PrtSc`, `ScrLk`, `Pause`).
  final bool showFunctionRow;

  /// Whether to render the OSK status header bar (`Full Desktop 100% Grid`,
  /// `Hide Numpad` toggle button, and `CAPS` / `NUM` LED status indicators).
  final bool showHeader;

  /// Maximum fraction of the total viewport height this keyboard may occupy
  /// (e.g. `0.38` = max 38% of screen height).
  final double maxKeyboardHeightRatio;

  /// Initial active state for Caps Lock.
  final bool initialCapsLock;

  /// Initial active state for Num Lock. Defaults to `true`.
  final bool initialNumLock;

  /// Invoked when a printable character (or space `' '`) is typed without
  /// a command shortcut modifier held.
  final ValueChanged<String>? onKeyPressed;

  /// Invoked when a special, modifier, lock, function, or navigation key is pressed.
  final ValueChanged<VirtualKeyAction>? onSpecialKeyPressed;

  /// Invoked when a modifier shortcut combo is triggered (e.g. `'Ctrl+A'`,
  /// `'Ctrl+Shift+Z'`, `'Alt+Tab'`).
  final ValueChanged<String>? onShortcutTriggered;

  /// Optional callback invoked when the bottom dismiss button is tapped.
  /// When non-null, a subtle circular chevron button appears centered at the bottom.
  final VoidCallback? onDismiss;

  /// Optional [VKeyboardController] for direct integration with [VTextField]
  /// sessions and hardware shortcut dispatch.
  final VKeyboardController? controller;

  @override
  State<DesktopFullKeyboard> createState() => _DesktopFullKeyboardState();
}

class _DesktopFullKeyboardState extends State<DesktopFullKeyboard> {
  late bool _showNumpad = widget.showNumpad;
  bool _isShiftActive = false;
  late bool _isCapsLockActive = widget.initialCapsLock;
  late bool _isNumLockActive = widget.initialNumLock;
  bool _isCtrlActive = false;
  bool _isAltActive = false;
  bool _isAltGrActive = false;
  bool _isWinActive = false;
  bool _isFnActive = false;
  bool _isScrollLockActive = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.modifiers.addListener(_syncFromController);
    if (widget.controller != null) {
      _syncFromController();
    }
  }

  @override
  void didUpdateWidget(covariant DesktopFullKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showNumpad != oldWidget.showNumpad) {
      _showNumpad = widget.showNumpad;
    }
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.modifiers.removeListener(_syncFromController);
      widget.controller?.modifiers.addListener(_syncFromController);
      if (widget.controller != null) {
        _syncFromController();
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.modifiers.removeListener(_syncFromController);
    super.dispose();
  }

  void _syncFromController() {
    final m = widget.controller?.modifiers;
    if (m == null || !mounted) return;
    setState(() {
      _isShiftActive = m.shift;
      _isCapsLockActive = m.capsLock;
      _isScrollLockActive = m.scrollLock;
      _isCtrlActive = m.control;
      _isAltActive = m.alt;
      _isAltGrActive = m.altGr;
      _isWinActive = m.meta;
    });
  }

  bool get _hasShortcutModifier =>
      _isCtrlActive || _isAltActive || _isWinActive;

  bool _isKeyEngaged(KeyModel model) {
    return switch (model.action) {
      VirtualKeyAction.leftShift || VirtualKeyAction.rightShift => _isShiftActive,
      VirtualKeyAction.capsLock => _isCapsLockActive,
      VirtualKeyAction.numLock => _isNumLockActive,
      VirtualKeyAction.scrollLock => _isScrollLockActive,
      VirtualKeyAction.leftCtrl || VirtualKeyAction.rightCtrl => _isCtrlActive,
      VirtualKeyAction.leftAlt => _isAltActive,
      VirtualKeyAction.altGr => _isAltGrActive,
      VirtualKeyAction.winSuper => _isWinActive,
      VirtualKeyAction.fn => _isFnActive,
      _ => false,
    };
  }

  void _handleKeyTap(KeyModel key) {
    final action = key.action;
    final controller = widget.controller;

    // 1. Handle Modifier & Lock State Keys.
    if (key.type == KeyType.modifier || key.type == KeyType.lock) {
      _toggleStateKey(key);
      if (action != null) {
        widget.onSpecialKeyPressed?.call(action);
      }
      return;
    }

    // 2. Numpad digit / decimal when Num Lock is OFF behaves as navigation/edit.
    if (key.isNumpadDigit && !_isNumLockActive) {
      final secAction = key.secondaryAction;
      if (secAction != null) {
        widget.onSpecialKeyPressed?.call(secAction);
      }
      if (controller != null) {
        if (key.secondaryNavIntent != null) {
          controller.handleKey(
            KeyData.nav(key.secondaryNavIntent!, label: key.secondaryLabel),
          );
        } else if (secAction == VirtualKeyAction.insert) {
          controller.handleKey(
            KeyData.function('Ins', LogicalKeyboardKey.insert),
          );
        } else if (secAction == VirtualKeyAction.delete) {
          controller.handleKey(
            KeyData.function('Del', LogicalKeyboardKey.delete),
          );
        }
      }
      _clearMomentaryModifiers();
      return;
    }

    // 3. Check for shortcut combo (Ctrl / Alt / Win held + target key).
    if (_hasShortcutModifier) {
      final shortcutToken = key.shortcutKey ??
          key.value?.toUpperCase() ??
          key.label;
      final combo = _buildShortcutCombo(shortcutToken);
      widget.onShortcutTriggered?.call(combo);

      if (controller != null) {
        final keyData = key.toKeyData();
        if (keyData != null) {
          controller.handleKey(keyData);
        }
      }
      _clearMomentaryModifiers();
      return;
    }

    // 4. Spacebar: invokes onKeyPressed(' ') (plus optional onSpecialKeyPressed).
    if (key.type == KeyType.space) {
      widget.onKeyPressed?.call(' ');
      if (controller != null) {
        controller.handleKey(KeyData.space());
      }
      _clearMomentaryModifiers();
      return;
    }

    // 5. Printable characters (Alphanumeric, Dual-Legend symbols, Numpad active digits/ops).
    if (key.type == KeyType.character) {
      final output = key.resolveOutput(
        shifted: _isShiftActive,
        capsLock: _isCapsLockActive,
      );
      if (output != null) {
        widget.onKeyPressed?.call(output);
        if (controller != null) {
          final keyData = key.toKeyData();
          if (keyData != null && controller.session != null) {
            controller.handleKey(keyData);
          } else {
            controller.insertText(output);
          }
        }
      }
      _clearMomentaryModifiers();
      return;
    }

    // 6. Special / Action / Function / Navigation keys (Enter, Backspace, Tab, Del, Arrows, etc.).
    if (action != null) {
      widget.onSpecialKeyPressed?.call(action);
    }
    if (controller != null) {
      final keyData = key.toKeyData();
      if (keyData != null) {
        controller.handleKey(keyData);
      }
    }
    _clearMomentaryModifiers();
  }

  void _toggleStateKey(KeyModel key) {
    final controller = widget.controller;
    if (key.action == VirtualKeyAction.numLock) {
      setState(() => _isNumLockActive = !_isNumLockActive);
      controller?.modifiers.toggleLock(LockKey.numLock);
      return;
    }
    if (controller != null) {
      if (key.modifierKey != null) {
        controller.modifiers.toggleModifier(key.modifierKey!);
        return;
      }
      if (key.lockKey != null) {
        controller.modifiers.toggleLock(key.lockKey!);
        return;
      }
    }

    setState(() {
      switch (key.action) {
        case VirtualKeyAction.leftShift:
        case VirtualKeyAction.rightShift:
          _isShiftActive = !_isShiftActive;
        case VirtualKeyAction.capsLock:
          _isCapsLockActive = !_isCapsLockActive;
        case VirtualKeyAction.numLock:
          _isNumLockActive = !_isNumLockActive;
        case VirtualKeyAction.scrollLock:
          _isScrollLockActive = !_isScrollLockActive;
        case VirtualKeyAction.leftCtrl:
        case VirtualKeyAction.rightCtrl:
          _isCtrlActive = !_isCtrlActive;
        case VirtualKeyAction.leftAlt:
          _isAltActive = !_isAltActive;
        case VirtualKeyAction.altGr:
          _isAltGrActive = !_isAltGrActive;
        case VirtualKeyAction.winSuper:
          _isWinActive = !_isWinActive;
        case VirtualKeyAction.fn:
          _isFnActive = !_isFnActive;
        default:
          break;
      }
    });
  }

  void _clearMomentaryModifiers() {
    if (widget.controller != null) {
      widget.controller!.modifiers.clearMomentary();
    }
    if (_isShiftActive ||
        _isCtrlActive ||
        _isAltActive ||
        _isAltGrActive ||
        _isWinActive) {
      setState(() {
        _isShiftActive = false;
        _isCtrlActive = false;
        _isAltActive = false;
        _isAltGrActive = false;
        _isWinActive = false;
      });
    }
  }

  String _buildShortcutCombo(String target) {
    final parts = <String>[
      if (_isCtrlActive) 'Ctrl',
      if (_isWinActive) 'Win',
      if (_isAltActive) 'Alt',
      if (_isShiftActive) 'Shift',
      target,
    ];
    return parts.join('+');
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.themeData ?? DesktopKeyboardThemeData.dark();
    final tapGroup = VKeyboardScope.maybeOf(context)?.tapGroup;

    Widget content = SizedBox(
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mq = MediaQuery.of(context);
          final screenH = mq.size.height > 0 ? mq.size.height : 900.0;
          final availW = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : mq.size.width;

          // Responsive collapse thresholds for unusually narrow panes.
          final canShowNav = availW >= 540;
          final canShowNumpad = availW >= 720;
          final effectiveShowNumpad = _showNumpad && canShowNumpad;

          // Proportional units across active clusters (15 : 3 : 4).
          final totalUnits = 15 +
              (canShowNav ? 3 : 0) +
              (effectiveShowNumpad ? 4 : 0);

          final rowCount = widget.showFunctionRow ? 6 : 5;
          final keyGap = (availW * 0.004).clamp(2.5, 7.0);
          final keyMargin = keyGap / 2;
          final clusterGap = (availW * 0.011).clamp(6.0, 20.0);
          final hPadding = (availW * 0.008).clamp(6.0, 16.0);

          // Derive clean proportional row height from screen dimensions & ratio cap.
          final ratioCap = (screenH * widget.maxKeyboardHeightRatio)
              .clamp(190.0, screenH * 0.65);
          final maxAllowedH = constraints.hasBoundedHeight
              ? math.min(constraints.maxHeight, ratioCap)
              : ratioCap;

          final unitWidth = (availW - hPadding * 2) / totalUnits;
          final idealRowHeight = (unitWidth * 0.85).clamp(32.0, 54.0);
          final headerHeight =
              widget.showHeader ? (idealRowHeight * 0.72).clamp(26.0, 36.0) : 0.0;
          final dismissHeight = widget.onDismiss != null ? 24.0 : 0.0;
          final vPadding = (idealRowHeight * 0.24).clamp(6.0, 12.0);
          final idealTotalH = headerHeight +
              (widget.showHeader ? 6.0 : 0.0) +
              rowCount * idealRowHeight +
              vPadding * 2 +
              dismissHeight;

          final totalHeight = math
              .min(idealTotalH, maxAllowedH)
              .clamp(math.min(180.0, maxAllowedH), maxAllowedH).toDouble();

          final actualGridHeight = math.max(
            100.0,
            totalHeight -
                headerHeight -
                (widget.showHeader ? 6.0 : 0.0) -
                vPadding * 2 -
                dismissHeight,
          );
          final actualRowHeight = actualGridHeight / rowCount;
          final baseFontSize = math
              .min(actualRowHeight * 0.36, unitWidth * 0.34)
              .clamp(9.5, 20.0);

          return Container(
            width: double.infinity,
            height: totalHeight,
            padding: EdgeInsets.symmetric(
              horizontal: hPadding,
              vertical: vPadding,
            ),
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              borderRadius: theme.containerBorderRadius,
              border: Border(
                top: BorderSide(color: theme.containerBorderColor, width: 1),
                bottom: theme.containerBorderRadius != BorderRadius.zero
                    ? BorderSide(color: theme.containerBorderColor, width: 1)
                    : BorderSide.none,
                left: theme.containerBorderRadius != BorderRadius.zero
                    ? BorderSide(color: theme.containerBorderColor, width: 1)
                    : BorderSide.none,
                right: theme.containerBorderRadius != BorderRadius.zero
                    ? BorderSide(color: theme.containerBorderColor, width: 1)
                    : BorderSide.none,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.showHeader) ...[
                  SizedBox(
                    height: headerHeight,
                    child: _buildHeaderBar(
                      theme: theme,
                      availW: availW,
                      canShowNumpad: canShowNumpad,
                      effectiveShowNumpad: effectiveShowNumpad,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Cluster 1: Main Alphanumeric (flex 15)
                      Expanded(
                        flex: 15,
                        child: _buildMainCluster(
                          theme: theme,
                          baseFontSize: baseFontSize,
                          keyMargin: keyMargin,
                        ),
                      ),
                      if (canShowNav) ...[
                        SizedBox(width: clusterGap),
                        // Cluster 2: Navigation & Arrows (flex 3)
                        Expanded(
                          flex: 3,
                          child: _buildNavigationCluster(
                            theme: theme,
                            baseFontSize: baseFontSize,
                            keyMargin: keyMargin,
                          ),
                        ),
                      ],
                      if (effectiveShowNumpad) ...[
                        SizedBox(width: clusterGap),
                        // Cluster 3: Numpad (flex 4)
                        Expanded(
                          flex: 4,
                          child: _buildNumpadCluster(
                            theme: theme,
                            baseFontSize: baseFontSize,
                            keyMargin: keyMargin,
                            mainRowCount: rowCount,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.onDismiss != null)
                  SizedBox(
                    height: dismissHeight,
                    child: Center(
                      child: InkWell(
                        onTap: widget.onDismiss,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.specialKeyColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: theme.keyBorderColor),
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: theme.secondaryTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
    if (tapGroup != null) {
      content = TapRegion(groupId: tapGroup, child: content);
    }
    return content;
  }

  Widget _buildHeaderBar({
    required DesktopKeyboardThemeData theme,
    required double availW,
    required bool canShowNumpad,
    required bool effectiveShowNumpad,
  }) {
    final showSubtitle = availW >= 780;
    return Row(
      children: [
        Icon(
          Icons.desktop_windows_outlined,
          size: 15,
          color: theme.navigationIconColor,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Full Desktop 100% Grid',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.headerTextColor,
                ),
              ),
              if (showSubtitle) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '|',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.keyBorderColor,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    'Proportional Key Sizing (Flex-Grow Engine)',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: theme.headerSubtitleColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (canShowNumpad)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () => setState(() => _showNumpad = !_showNumpad),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.specialKeyColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: theme.keyBorderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.dialpad_rounded,
                      size: 13,
                      color: theme.navigationIconColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      effectiveShowNumpad ? 'Hide Numpad' : 'Show Numpad',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.headerTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        _buildStatusLed(
          label: 'CAPS',
          active: _isCapsLockActive,
          theme: theme,
        ),
        const SizedBox(width: 10),
        _buildStatusLed(
          label: 'NUM',
          active: _isNumLockActive,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildStatusLed({
    required String label,
    required bool active,
    required DesktopKeyboardThemeData theme,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? theme.ledActiveColor : theme.ledInactiveColor,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: theme.ledActiveColor.withValues(alpha: 0.75),
                      blurRadius: 5,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: active ? theme.headerTextColor : theme.headerSubtitleColor,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyButton(
    KeyModel model, {
    required DesktopKeyboardThemeData theme,
    required double baseFontSize,
    required double keyMargin,
  }) {
    return VirtualKeyButton(
      key: ValueKey('dk_${model.id}'),
      model: model,
      theme: theme,
      baseFontSize: baseFontSize,
      isShiftActive: _isShiftActive,
      isCapsLockActive: _isCapsLockActive,
      isNumLockActive: _isNumLockActive,
      isEngaged: _isKeyEngaged(model),
      horizontalMargin: keyMargin,
      verticalMargin: keyMargin,
      onTap: _handleKeyTap,
    );
  }

  Widget _buildRow(
    List<KeyModel> keys, {
    required DesktopKeyboardThemeData theme,
    required double baseFontSize,
    required double keyMargin,
  }) {
    return Expanded(
      flex: 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final k in keys)
            _buildKeyButton(
              k,
              theme: theme,
              baseFontSize: baseFontSize,
              keyMargin: keyMargin,
            ),
        ],
      ),
    );
  }

  Widget _buildMainCluster({
    required DesktopKeyboardThemeData theme,
    required double baseFontSize,
    required double keyMargin,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showFunctionRow)
          _buildRow(
            DesktopFullLayoutData.functionRow(),
            theme: theme,
            baseFontSize: baseFontSize,
            keyMargin: keyMargin,
          ),
        _buildRow(
          DesktopFullLayoutData.numberRow(),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
        _buildRow(
          DesktopFullLayoutData.topAlphaRow(),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
        _buildRow(
          DesktopFullLayoutData.homeAlphaRow(),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
        _buildRow(
          DesktopFullLayoutData.bottomAlphaRow(),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
        _buildRow(
          DesktopFullLayoutData.bottomControlRow(),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
      ],
    );
  }

  Widget _buildNavigationCluster({
    required DesktopKeyboardThemeData theme,
    required double baseFontSize,
    required double keyMargin,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showFunctionRow)
          _buildRow(
            DesktopFullLayoutData.navSystemRow(),
            theme: theme,
            baseFontSize: baseFontSize,
            keyMargin: keyMargin,
          ),
        _buildRow(
          DesktopFullLayoutData.navTopEditRow(),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
        _buildRow(
          DesktopFullLayoutData.navBottomEditRow(),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
        _buildRow(
          DesktopFullLayoutData.navEmptyRow(),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
        _buildRow(
          DesktopFullLayoutData.navArrowUpRow(),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
        _buildRow(
          DesktopFullLayoutData.navArrowBottomRow(),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
      ],
    );
  }

  Widget _buildNumpadCluster({
    required DesktopKeyboardThemeData theme,
    required double baseFontSize,
    required double keyMargin,
    required int mainRowCount,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row 0 (`Num`, `/`, `*`, `-`) aligns cleanly with Main's top row.
        _buildRow(
          DesktopFullLayoutData.numpadTopRow(),
          theme: theme,
          baseFontSize: baseFontSize,
          keyMargin: keyMargin,
        ),
        // Remaining 4 Numpad rows fill the exact height of the remaining Main rows
        // (5 rows when Function row is shown, 4 rows when hidden), with `+` and `Enter`
        // each spanning 2 rows vertically.
        Expanded(
          flex: mainRowCount - 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildRow(
                      DesktopFullLayoutData.numpadRow789(),
                      theme: theme,
                      baseFontSize: baseFontSize,
                      keyMargin: keyMargin,
                    ),
                    _buildRow(
                      DesktopFullLayoutData.numpadRow456(),
                      theme: theme,
                      baseFontSize: baseFontSize,
                      keyMargin: keyMargin,
                    ),
                    _buildRow(
                      DesktopFullLayoutData.numpadRow123(),
                      theme: theme,
                      baseFontSize: baseFontSize,
                      keyMargin: keyMargin,
                    ),
                    _buildRow(
                      DesktopFullLayoutData.numpadRow0Dot(),
                      theme: theme,
                      baseFontSize: baseFontSize,
                      keyMargin: keyMargin,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildKeyButton(
                      DesktopFullLayoutData.numpadPlusKey(),
                      theme: theme,
                      baseFontSize: baseFontSize,
                      keyMargin: keyMargin,
                    ),
                    _buildKeyButton(
                      DesktopFullLayoutData.numpadEnterKey(),
                      theme: theme,
                      baseFontSize: baseFontSize,
                      keyMargin: keyMargin,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
