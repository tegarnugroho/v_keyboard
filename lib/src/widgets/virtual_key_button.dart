import 'dart:async';

import 'package:flutter/material.dart';

import '../models/desktop_key_model.dart';
import '../theme/v_keyboard_theme.dart';

/// Visual styling theme tailored for [DesktopFullKeyboard].
@immutable
class DesktopKeyboardThemeData {
  const DesktopKeyboardThemeData({
    required this.backgroundColor,
    required this.headerTextColor,
    required this.headerSubtitleColor,
    required this.keyColor,
    required this.specialKeyColor,
    required this.hoverKeyColor,
    required this.pressedKeyColor,
    required this.keyBorderColor,
    required this.activeKeyColor,
    required this.activeBorderColor,
    required this.accentKeyColor,
    required this.accentKeyBorderColor,
    required this.dangerKeyColor,
    required this.dangerKeyBorderColor,
    required this.dangerTextColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.activeTextColor,
    required this.navigationIconColor,
    required this.ledActiveColor,
    required this.ledInactiveColor,
    required this.containerBorderColor,
    this.keyBorderRadius = const BorderRadius.all(Radius.circular(6)),
    this.containerBorderRadius = BorderRadius.zero,
    this.shadowColor = const Color(0x40000000),
  });

  /// Modern dark desktop OSK theme matching native desktop virtual keyboards.
  factory DesktopKeyboardThemeData.dark({Color accentColor = const Color(0xFF3B82F6)}) {
    return DesktopKeyboardThemeData(
      backgroundColor: const Color(0xFF13151B),
      containerBorderColor: const Color(0xFF1E2330),
      headerTextColor: const Color(0xFFE2E8F0),
      headerSubtitleColor: const Color(0xFF64748B),
      keyColor: const Color(0xFF21242D),
      specialKeyColor: const Color(0xFF1A1D26),
      hoverKeyColor: const Color(0xFF2B303E),
      pressedKeyColor: const Color(0xFF353C4E),
      keyBorderColor: const Color(0xFF2B3140),
      activeKeyColor: accentColor.withValues(alpha: 0.24),
      activeBorderColor: accentColor,
      accentKeyColor: const Color(0xFF1E3A6D),
      accentKeyBorderColor: accentColor,
      dangerKeyColor: const Color(0xFF2A191F),
      dangerKeyBorderColor: const Color(0xFF532833),
      dangerTextColor: const Color(0xFFF87171),
      textColor: const Color(0xFFF1F5F9),
      secondaryTextColor: const Color(0xFF94A3B8),
      activeTextColor: Colors.white,
      navigationIconColor: const Color(0xFF60A5FA),
      ledActiveColor: const Color(0xFF38BDF8),
      ledInactiveColor: const Color(0xFF475569),
    );
  }

  /// Crisp light theme variant for daylight desktop interfaces.
  factory DesktopKeyboardThemeData.light({Color accentColor = const Color(0xFF2563EB)}) {
    return DesktopKeyboardThemeData(
      backgroundColor: const Color(0xFFE2E8F0),
      containerBorderColor: const Color(0xFFCBD5E1),
      headerTextColor: const Color(0xFF0F172A),
      headerSubtitleColor: const Color(0xFF64748B),
      keyColor: Colors.white,
      specialKeyColor: const Color(0xFFF1F5F9),
      hoverKeyColor: const Color(0xFFF8FAFC),
      pressedKeyColor: accentColor.withValues(alpha: 0.16),
      keyBorderColor: const Color(0xFFCBD5E1),
      activeKeyColor: accentColor,
      activeBorderColor: accentColor,
      accentKeyColor: accentColor,
      accentKeyBorderColor: accentColor,
      dangerKeyColor: const Color(0xFFFEE2E2),
      dangerKeyBorderColor: const Color(0xFFFCA5A5),
      dangerTextColor: const Color(0xFFDC2626),
      textColor: const Color(0xFF0F172A),
      secondaryTextColor: const Color(0xFF64748B),
      activeTextColor: Colors.white,
      navigationIconColor: accentColor,
      ledActiveColor: accentColor,
      ledInactiveColor: const Color(0xFF94A3B8),
      shadowColor: const Color(0x1A000000),
    );
  }

  /// Derives a [DesktopKeyboardThemeData] from an existing [VKeyboardTheme].
  factory DesktopKeyboardThemeData.fromVKeyboardTheme(VKeyboardTheme theme) {
    final base = theme.isDark
        ? DesktopKeyboardThemeData.dark(accentColor: theme.accentColor)
        : DesktopKeyboardThemeData.light(accentColor: theme.accentColor);
    return base.copyWith(
      keyBorderRadius: theme.borderRadius is BorderRadius
          ? theme.borderRadius as BorderRadius
          : const BorderRadius.all(Radius.circular(6)),
    );
  }

  final Color backgroundColor;
  final Color containerBorderColor;
  final Color headerTextColor;
  final Color headerSubtitleColor;
  final Color keyColor;
  final Color specialKeyColor;
  final Color hoverKeyColor;
  final Color pressedKeyColor;
  final Color keyBorderColor;
  final Color activeKeyColor;
  final Color activeBorderColor;
  final Color accentKeyColor;
  final Color accentKeyBorderColor;
  final Color dangerKeyColor;
  final Color dangerKeyBorderColor;
  final Color dangerTextColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color activeTextColor;
  final Color navigationIconColor;
  final Color ledActiveColor;
  final Color ledInactiveColor;
  final BorderRadius keyBorderRadius;
  final BorderRadius containerBorderRadius;
  final Color shadowColor;

  DesktopKeyboardThemeData copyWith({
    Color? backgroundColor,
    Color? containerBorderColor,
    Color? headerTextColor,
    Color? headerSubtitleColor,
    Color? keyColor,
    Color? specialKeyColor,
    Color? hoverKeyColor,
    Color? pressedKeyColor,
    Color? keyBorderColor,
    Color? activeKeyColor,
    Color? activeBorderColor,
    Color? accentKeyColor,
    Color? accentKeyBorderColor,
    Color? dangerKeyColor,
    Color? dangerKeyBorderColor,
    Color? dangerTextColor,
    Color? textColor,
    Color? secondaryTextColor,
    Color? activeTextColor,
    Color? navigationIconColor,
    Color? ledActiveColor,
    Color? ledInactiveColor,
    BorderRadius? keyBorderRadius,
    BorderRadius? containerBorderRadius,
    Color? shadowColor,
  }) {
    return DesktopKeyboardThemeData(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      containerBorderColor: containerBorderColor ?? this.containerBorderColor,
      headerTextColor: headerTextColor ?? this.headerTextColor,
      headerSubtitleColor: headerSubtitleColor ?? this.headerSubtitleColor,
      keyColor: keyColor ?? this.keyColor,
      specialKeyColor: specialKeyColor ?? this.specialKeyColor,
      hoverKeyColor: hoverKeyColor ?? this.hoverKeyColor,
      pressedKeyColor: pressedKeyColor ?? this.pressedKeyColor,
      keyBorderColor: keyBorderColor ?? this.keyBorderColor,
      activeKeyColor: activeKeyColor ?? this.activeKeyColor,
      activeBorderColor: activeBorderColor ?? this.activeBorderColor,
      accentKeyColor: accentKeyColor ?? this.accentKeyColor,
      accentKeyBorderColor: accentKeyBorderColor ?? this.accentKeyBorderColor,
      dangerKeyColor: dangerKeyColor ?? this.dangerKeyColor,
      dangerKeyBorderColor: dangerKeyBorderColor ?? this.dangerKeyBorderColor,
      dangerTextColor: dangerTextColor ?? this.dangerTextColor,
      textColor: textColor ?? this.textColor,
      secondaryTextColor: secondaryTextColor ?? this.secondaryTextColor,
      activeTextColor: activeTextColor ?? this.activeTextColor,
      navigationIconColor: navigationIconColor ?? this.navigationIconColor,
      ledActiveColor: ledActiveColor ?? this.ledActiveColor,
      ledInactiveColor: ledInactiveColor ?? this.ledInactiveColor,
      keyBorderRadius: keyBorderRadius ?? this.keyBorderRadius,
      containerBorderRadius:
          containerBorderRadius ?? this.containerBorderRadius,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }
}

/// A proportional keycap widget powered by [Expanded] so every row adapts
/// edge-to-edge across arbitrary desktop monitor widths and resolutions.
class VirtualKeyButton extends StatefulWidget {
  const VirtualKeyButton({
    super.key,
    required this.model,
    required this.theme,
    required this.baseFontSize,
    required this.onTap,
    this.isShiftActive = false,
    this.isCapsLockActive = false,
    this.isNumLockActive = true,
    this.isEngaged = false,
    this.horizontalMargin = 2.0,
    this.verticalMargin = 2.0,
    this.enableRepeat = true,
  });

  final KeyModel model;
  final DesktopKeyboardThemeData theme;
  final double baseFontSize;
  final ValueChanged<KeyModel> onTap;
  final bool isShiftActive;
  final bool isCapsLockActive;
  final bool isNumLockActive;
  final bool isEngaged;
  final double horizontalMargin;
  final double verticalMargin;
  final bool enableRepeat;

  @override
  State<VirtualKeyButton> createState() => _VirtualKeyButtonState();
}

class _VirtualKeyButtonState extends State<VirtualKeyButton> {
  final ValueNotifier<bool> _pressed = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _hovered = ValueNotifier<bool>(false);
  Timer? _delayTimer;
  Timer? _repeatTimer;

  KeyModel get _model => widget.model;

  @override
  void dispose() {
    _cancelRepeat();
    _pressed.dispose();
    _hovered.dispose();
    super.dispose();
  }

  void _cancelRepeat() {
    _delayTimer?.cancel();
    _repeatTimer?.cancel();
    _delayTimer = null;
    _repeatTimer = null;
  }

  void _handleTapDown(TapDownDetails _) {
    if (_model.isSpacer) return;
    _pressed.value = true;
    if (widget.enableRepeat && _model.repeatable) {
      _delayTimer = Timer(const Duration(milliseconds: 420), () {
        _repeatTimer = Timer.periodic(const Duration(milliseconds: 55), (_) {
          widget.onTap(_model);
        });
      });
    }
  }

  void _handleTapUp(TapUpDetails _) {
    _pressed.value = false;
    _cancelRepeat();
  }

  void _handleTapCancel() {
    _pressed.value = false;
    _cancelRepeat();
  }

  @override
  Widget build(BuildContext context) {
    final flex = (_model.flex * 100).round().clamp(1, 10000);

    if (_model.isSpacer) {
      return Expanded(flex: flex, child: const SizedBox.shrink());
    }

    final theme = widget.theme;
    final engaged = widget.isEngaged;
    final isDanger = _model.isDanger;
    final isAccent = _model.isAccent;
    final isSpecial = _model.type != KeyType.character &&
        _model.type != KeyType.space;

    Color resolveBackground(bool pressed, bool hovered) {
      if (pressed) {
        if (isAccent) {
          return Color.alphaBlend(
              Colors.white.withValues(alpha: 0.16), theme.accentKeyColor);
        }
        return theme.pressedKeyColor;
      }
      if (engaged) {
        return theme.activeKeyColor;
      }
      if (isAccent) {
        return hovered
            ? Color.alphaBlend(
                Colors.white.withValues(alpha: 0.08), theme.accentKeyColor)
            : theme.accentKeyColor;
      }
      if (isDanger) {
        return hovered
            ? Color.alphaBlend(
                Colors.red.withValues(alpha: 0.12), theme.dangerKeyColor)
            : theme.dangerKeyColor;
      }
      if (hovered) {
        return theme.hoverKeyColor;
      }
      return isSpecial ? theme.specialKeyColor : theme.keyColor;
    }

    Color resolveBorderColor(bool pressed, bool hovered) {
      if (engaged) return theme.activeBorderColor;
      if (isAccent) return theme.accentKeyBorderColor;
      if (isDanger) return theme.dangerKeyBorderColor;
      if (pressed || hovered) {
        return theme.activeBorderColor.withValues(alpha: 0.55);
      }
      return theme.keyBorderColor;
    }

    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.horizontalMargin,
          vertical: widget.verticalMargin,
        ),
        child: Semantics(
          button: true,
          toggled: engaged,
          label: _model.label,
          excludeSemantics: true,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => _hovered.value = true,
            onExit: (_) => _hovered.value = false,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: _handleTapDown,
              onTapUp: _handleTapUp,
              onTapCancel: _handleTapCancel,
              onTap: () => widget.onTap(_model),
              child: ValueListenableBuilder<bool>(
                valueListenable: _pressed,
                builder: (context, pressed, child) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: _hovered,
                    builder: (context, hovered, _) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 90),
                        curve: Curves.easeOutCubic,
                        transform: pressed
                            ? Matrix4.diagonal3Values(0.97, 0.97, 1.0)
                            : Matrix4.identity(),
                        transformAlignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: resolveBackground(pressed, hovered),
                          borderRadius: theme.keyBorderRadius,
                          border: Border.all(
                            color: resolveBorderColor(pressed, hovered),
                            width: engaged || isAccent ? 1.2 : 1.0,
                          ),
                          boxShadow: [
                            if (!pressed)
                              BoxShadow(
                                color: theme.shadowColor,
                                offset: const Offset(0, 1.5),
                                blurRadius: 1,
                              ),
                          ],
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: child,
                          ),
                        ),
                      );
                    },
                  );
                },
                child: _buildKeycapContent(theme),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeycapContent(DesktopKeyboardThemeData theme) {
    final engaged = widget.isEngaged;
    final baseFont = widget.baseFontSize;
    final specialFont = (baseFont * 0.78).clamp(9.0, 16.0);
    final subFont = (baseFont * 0.68).clamp(8.0, 13.0);

    final Color primaryFg = _model.isDanger
        ? theme.dangerTextColor
        : (engaged || _model.isAccent
            ? theme.activeTextColor
            : (_model.id == 'num_lock' && widget.isNumLockActive
                ? theme.ledActiveColor
                : theme.textColor));

    // Spacebar with subtle centered text + horizontal grip bar.
    if (_model.type == KeyType.space) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _model.label,
              style: TextStyle(
                fontSize: (specialFont * 0.86).clamp(9.0, 13.0),
                letterSpacing: 1.6,
                fontWeight: FontWeight.w500,
                color: theme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 56,
              height: 1.5,
              decoration: BoxDecoration(
                color: theme.secondaryTextColor.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      );
    }

    // Dual-legend key (Number row & punctuation keys: e.g. `!` above `1`).
    if (_model.hasDualLegend) {
      final topActive = widget.isShiftActive;
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _model.shiftLabel!,
              style: TextStyle(
                fontSize: subFont,
                height: 1.05,
                fontWeight: topActive ? FontWeight.w700 : FontWeight.w500,
                color: topActive ? theme.activeTextColor : theme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              _model.label,
              style: TextStyle(
                fontSize: baseFont * 0.92,
                height: 1.05,
                fontWeight: topActive ? FontWeight.w400 : FontWeight.w600,
                color: topActive
                    ? theme.secondaryTextColor
                    : primaryFg,
              ),
            ),
          ],
        ),
      );
    }

    // Numpad digit when Num Lock is disabled shows secondary navigation hint cleanly.
    if (_model.isNumpadDigit &&
        !widget.isNumLockActive &&
        _model.secondaryLabel != null) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _model.label,
              style: TextStyle(
                fontSize: baseFont * 0.85,
                height: 1.05,
                fontWeight: FontWeight.w500,
                color: theme.secondaryTextColor,
              ),
            ),
            Text(
              _model.secondaryLabel!,
              style: TextStyle(
                fontSize: (subFont * 0.82).clamp(7.5, 11.0),
                height: 1.05,
                fontWeight: FontWeight.w600,
                color: theme.navigationIconColor,
              ),
            ),
          ],
        ),
      );
    }

    // Lock keys with LED indicator dot on the keycap (e.g. `Caps •`).
    if (_model.hasLed && _model.id == 'caps_lock') {
      final ledOn = widget.isCapsLockActive;
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _model.label,
              style: TextStyle(
                fontSize: specialFont,
                fontWeight: FontWeight.w600,
                color: primaryFg,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ledOn ? theme.ledActiveColor : theme.ledInactiveColor,
                boxShadow: ledOn
                    ? [
                        BoxShadow(
                          color: theme.ledActiveColor.withValues(alpha: 0.7),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      );
    }

    // Combo keys with Icon + Text (`⇧ Shift`, `Shift ⇧`, `Enter ⏎`).
    if (_model.icon != null && (_model.iconBeforeLabel || _model.iconAfterLabel)) {
      final iconWidget = Icon(
        _model.icon,
        size: (specialFont * 1.15).clamp(11.0, 18.0),
        color: primaryFg,
      );
      final labelWidget = Text(
        _model.label,
        style: TextStyle(
          fontSize: specialFont,
          fontWeight: FontWeight.w600,
          color: primaryFg,
        ),
      );
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _model.iconBeforeLabel
              ? [iconWidget, const SizedBox(width: 3), labelWidget]
              : [labelWidget, const SizedBox(width: 4), iconWidget],
        ),
      );
    }

    // Pure icon keys (Backspace, Win, Menu, Arrows, Numpad Enter).
    if (_model.icon != null) {
      final isArrow = _model.action == VirtualKeyAction.arrowUp ||
          _model.action == VirtualKeyAction.arrowDown ||
          _model.action == VirtualKeyAction.arrowLeft ||
          _model.action == VirtualKeyAction.arrowRight;
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Icon(
          _model.icon,
          size: (baseFont * 1.15).clamp(13.0, 22.0),
          color: isArrow && !engaged
              ? theme.navigationIconColor
              : primaryFg,
        ),
      );
    }

    // Standard single-label key (Letters, Esc, F1-F12, Nav words, Modifiers, Numpad digits).
    final displayText = _model.resolveDisplayLabel(
      shifted: widget.isShiftActive,
      capsLock: widget.isCapsLockActive,
    );
    final isFunctionOrNav = _model.type == KeyType.function ||
        _model.type == KeyType.navigation ||
        _model.type == KeyType.modifier ||
        _model.type == KeyType.lock ||
        _model.type == KeyType.action;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        displayText,
        maxLines: 1,
        style: TextStyle(
          fontSize: isFunctionOrNav ? specialFont : baseFont,
          fontWeight: _model.isLetter || _model.isNumpadDigit
              ? FontWeight.w500
              : FontWeight.w600,
          color: primaryFg,
        ),
      ),
    );
  }
}
