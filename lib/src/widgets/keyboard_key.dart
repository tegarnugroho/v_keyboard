import 'dart:async';

import 'package:flutter/material.dart';

import '../controller/v_keyboard_controller.dart';
import '../models/key_data.dart';
import '../models/key_intents.dart';
import '../theme/v_keyboard_theme.dart';

/// A single rendered key.
///
/// Owns its own pressed/hover state ([ValueNotifier]) so pointer interaction
/// repaints only that key — the rest of the keyboard never rebuilds. Implements
/// long-press continuous delete and held-key repeat (chars, navigation, delete,
/// space). Active modifiers and engaged locks are highlighted with the theme
/// accent (the controller rebuilds keys when that state changes).
class VirtualKey extends StatefulWidget {
  const VirtualKey({
    super.key,
    required this.data,
    required this.controller,
    required this.theme,
    required this.height,
  });

  final KeyData data;
  final VKeyboardController controller;
  final VKeyboardTheme theme;
  final double height;

  @override
  State<VirtualKey> createState() => _VirtualKeyState();
}

class _VirtualKeyState extends State<VirtualKey> {
  final ValueNotifier<bool> _pressed = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _hovered = ValueNotifier<bool>(false);
  Timer? _repeatTimer;
  Timer? _delayTimer;
  int _lastShiftTapMs = 0;

  KeyData get _data => widget.data;
  VKeyboardController get _controller => widget.controller;

  @override
  void dispose() {
    _cancelRepeat();
    _pressed.dispose();
    _hovered.dispose();
    super.dispose();
  }

  void _cancelRepeat() {
    _repeatTimer?.cancel();
    _delayTimer?.cancel();
    _repeatTimer = null;
    _delayTimer = null;
  }

  void _onTapDown(TapDownDetails _) {
    if (_data.kind == KeyKind.spacer || !_isEnabled) return;
    _pressed.value = true;
    _maybeStartRepeat();
  }

  void _onTapUp(TapUpDetails _) => _pressed.value = false;
  void _onTapCancel() {
    _pressed.value = false;
    _cancelRepeat();
  }

  void _maybeStartRepeat() {
    final config = _controller.config;
    final isBackspace = _data.kind == KeyKind.backspace;
    final canRepeat = isBackspace
        ? config.enableLongPressDelete
        : (_data.repeatable && config.enableKeyRepeat);
    if (!canRepeat) return;

    final delay =
        isBackspace ? config.longPressDeleteDelay : config.keyRepeatDelay;
    _delayTimer = Timer(delay, () {
      _repeatTimer = Timer.periodic(config.keyRepeatInterval, (_) {
        _controller.handleKey(_data);
      });
    });
  }

  void _onTap() {
    _cancelRepeat();
    if (!_isEnabled) return;
    if (_data.kind == KeyKind.shift) {
      _handleShift();
      return;
    }
    _controller.handleKey(_data);
  }

  void _handleShift() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastShiftTapMs < 300) {
      _controller.handleShiftDoubleTap();
    } else {
      _controller.handleShiftTap();
    }
    _lastShiftTapMs = now;
  }

  /// Whether this key is currently enabled and clickable.
  bool get _isEnabled {
    if (_data.kind == KeyKind.clipboard &&
        _data.clip == ClipboardIntent.history) {
      return _controller.config.enableClipboardHistory;
    }
    return true;
  }

  /// Whether this key is in an "engaged" state (active modifier / lock / open panel).
  bool get _isEngaged {
    final m = _controller.modifiers;
    return switch (_data.kind) {
      KeyKind.shift => _controller.isShiftActive || _controller.isCapsLock,
      KeyKind.modifier =>
        _data.modifier != null && m.isModifierActive(_data.modifier!),
      KeyKind.lock => _data.lock != null && m.isLocked(_data.lock!),
      KeyKind.clipboard => _data.clip == ClipboardIntent.history &&
          _controller.currentPage == 'clipboard',
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final flex = (_data.flex * 10).round();

    if (_data.kind == KeyKind.spacer) {
      return Expanded(flex: flex, child: const SizedBox());
    }
    if (_data.kind == KeyKind.custom && _data.builder != null) {
      return Expanded(
        flex: flex,
        child: Padding(
          padding: theme.keyPadding,
          child: GestureDetector(
            onTap: _data.text != null ? _onTap : null,
            child: _data.builder!(context),
          ),
        ),
      );
    }

    final enabled = _isEnabled;
    final engaged = _isEngaged;
    Color baseColor = engaged
        ? Color.alphaBlend(
            theme.accentColor.withValues(alpha: 0.35), theme.keyColor)
        : _baseColor(theme);
    if (!enabled) {
      baseColor = baseColor.withValues(alpha: 0.5);
    }

    Widget keyCard(Widget? child) {
      Widget keyWidget = SizedBox(
        height: widget.height,
        child: Center(child: child),
      );
      if (_data.kind == KeyKind.clipboard &&
          _data.clip == ClipboardIntent.history &&
          Overlay.maybeOf(context) != null) {
        keyWidget = Tooltip(
          message: 'Clipboard History',
          waitDuration: const Duration(milliseconds: 500),
          child: keyWidget,
        );
      }
      return keyWidget;
    }

    return Expanded(
      flex: flex,
      child: Padding(
        padding: theme.keyPadding,
        child: Semantics(
          button: true,
          label: _semanticLabel(),
          toggled: engaged,
          enabled: enabled,
          excludeSemantics: true,
          child: MouseRegion(
            cursor:
                enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
            onEnter: (_) => _hovered.value = true,
            onExit: (_) => _hovered.value = false,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: _onTap,
              child: ValueListenableBuilder<bool>(
                valueListenable: _pressed,
                builder: (context, pressed, child) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: _hovered,
                    builder: (context, hovered, _) {
                      Color color = pressed ? theme.pressedKeyColor : baseColor;
                      if (!pressed && hovered && enabled) {
                        color = Color.alphaBlend(
                            theme.accentColor.withValues(alpha: 0.12), color);
                      }
                      return RepaintBoundary(
                        child: Material(
                          color: color,
                          elevation: theme.elevation,
                          shadowColor: theme.shadowColor,
                          borderRadius: theme.borderRadius is BorderRadius
                              ? theme.borderRadius as BorderRadius
                              : BorderRadius.circular(8),
                          child: keyCard(child),
                        ),
                      );
                    },
                  );
                },
                child: _buildContent(theme, engaged),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _baseColor(VKeyboardTheme theme) {
    return switch (_data.kind) {
      KeyKind.character || KeyKind.space => theme.keyColor,
      KeyKind.function => theme.functionKeyColor,
      KeyKind.modifier ||
      KeyKind.lock ||
      KeyKind.navigation =>
        theme.modifierKeyColor,
      KeyKind.clipboard => theme.specialKeyColor,
      _ => theme.specialKeyColor,
    };
  }

  Widget _buildContent(VKeyboardTheme theme, bool engaged) {
    final enabled = _isEnabled;
    final baseIconColor = engaged ? theme.accentColor : theme.iconColor;
    final iconColor =
        enabled ? baseIconColor : baseIconColor.withValues(alpha: 0.38);

    // Icon keys (shift, backspace, enter, arrows, clipboard…).
    final icon = _resolveIcon();
    if (icon != null) {
      return Icon(icon,
          color: iconColor, size: theme.textStyle.fontSize! * 1.05);
    }

    final shifted = _controller.isShiftedForKey(_data);
    final label = _data.resolveLabel(shifted: shifted) ?? _data.label ?? '';

    if (_data.subLabel != null) {
      // Scale down so the two-line label always fits short keys (no overflow).
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: theme.textStyle),
            Text(_data.subLabel!, style: theme.subLabelStyle),
          ],
        ),
      );
    }

    // Word keys (.com, ABC, 123, Ctrl…) scale cleanly; single glyphs stay full size.
    final isWordKey = label.runes.length > 1;
    final fontSize = isWordKey
        ? (theme.textStyle.fontSize! * 0.68).clamp(13.5, 16.0)
        : theme.textStyle.fontSize;
    final fontWeight = isWordKey ? FontWeight.w500 : theme.textStyle.fontWeight;

    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.fade,
      softWrap: false,
      style: theme.textStyle.copyWith(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: isWordKey ? -0.2 : 0.1,
        color: engaged ? theme.accentColor : null,
      ),
    );
  }

  IconData? _resolveIcon() {
    if (_data.kind == KeyKind.shift) {
      if (_controller.isCapsLock) {
        return Icons.keyboard_capslock_rounded;
      }
      return Icons.arrow_upward_rounded;
    }
    if (_data.icon != null) return _data.icon;
    if (_data.kind == KeyKind.navigation) {
      return switch (_data.nav) {
        NavIntent.left => Icons.keyboard_arrow_left_rounded,
        NavIntent.right => Icons.keyboard_arrow_right_rounded,
        NavIntent.up => Icons.keyboard_arrow_up_rounded,
        NavIntent.down => Icons.keyboard_arrow_down_rounded,
        _ => null, // Home/End/PageUp/Down render as text labels.
      };
    }
    return null;
  }

  String _semanticLabel() {
    return switch (_data.kind) {
      KeyKind.backspace => 'Backspace',
      KeyKind.shift => 'Shift',
      KeyKind.space => 'Space',
      KeyKind.enter => 'Enter',
      KeyKind.switchLayout => _data.label ?? 'Switch layout',
      KeyKind.modifier => _data.label ?? _data.modifier?.name ?? 'Modifier',
      KeyKind.lock => _data.label ?? _data.lock?.name ?? 'Lock',
      KeyKind.navigation => _data.label ?? _data.nav?.name ?? 'Navigate',
      KeyKind.function => _data.label ?? 'Function',
      KeyKind.clipboard => _data.clip == ClipboardIntent.history
          ? 'Clipboard History'
          : (_data.label ?? _data.clip?.name ?? 'Clipboard'),
      KeyKind.media => _data.label ?? _data.media?.name ?? 'Media',
      _ => _data.resolveLabel(shifted: _controller.isUpperCase) ??
          _data.label ??
          '',
    };
  }
}
