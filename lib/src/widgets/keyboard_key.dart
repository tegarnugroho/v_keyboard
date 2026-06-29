import 'dart:async';

import 'package:flutter/material.dart';

import '../controller/virtual_keyboard_controller.dart';
import '../models/key_data.dart';
import '../models/key_intents.dart';
import '../theme/virtual_keyboard_theme.dart';

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
  final VirtualKeyboardController controller;
  final VirtualKeyboardTheme theme;
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
  VirtualKeyboardController get _controller => widget.controller;

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
    if (_data.kind == KeyKind.spacer) return;
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

    final delay = isBackspace ? config.longPressDeleteDelay : config.keyRepeatDelay;
    _delayTimer = Timer(delay, () {
      _repeatTimer = Timer.periodic(config.keyRepeatInterval, (_) {
        _controller.handleKey(_data);
      });
    });
  }

  void _onTap() {
    _cancelRepeat();
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

  /// Whether this key is in an "engaged" state (active modifier / lock).
  bool get _isEngaged {
    final m = _controller.modifiers;
    return switch (_data.kind) {
      KeyKind.shift => _controller.isShiftActive || _controller.isCapsLock,
      KeyKind.modifier => _data.modifier != null && m.isModifierActive(_data.modifier!),
      KeyKind.lock => _data.lock != null && m.isLocked(_data.lock!),
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

    final engaged = _isEngaged;
    final baseColor = engaged
        ? Color.alphaBlend(theme.accentColor.withValues(alpha: 0.35), theme.keyColor)
        : _baseColor(theme);

    return Expanded(
      flex: flex,
      child: Padding(
        padding: theme.keyPadding,
        child: Semantics(
          button: true,
          label: _semanticLabel(),
          toggled: engaged,
          excludeSemantics: true,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
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
                      if (!pressed && hovered) {
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
                          child: SizedBox(
                            height: widget.height,
                            child: Center(child: child),
                          ),
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

  Color _baseColor(VirtualKeyboardTheme theme) {
    return switch (_data.kind) {
      KeyKind.character || KeyKind.space => theme.keyColor,
      KeyKind.function => theme.functionKeyColor,
      KeyKind.modifier || KeyKind.lock || KeyKind.navigation => theme.modifierKeyColor,
      _ => theme.specialKeyColor,
    };
  }

  Widget _buildContent(VirtualKeyboardTheme theme, bool engaged) {
    final iconColor = engaged ? theme.accentColor : theme.iconColor;

    // Icon keys (shift, backspace, enter, arrows…).
    final icon = _resolveIcon();
    if (icon != null) {
      return Icon(icon, color: iconColor, size: theme.textStyle.fontSize! * 1.05);
    }

    final shifted = _controller.isUpperCase;
    final label = _data.resolveLabel(shifted: shifted) ?? _data.label ?? '';

    if (_data.subLabel != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textStyle),
          Text(_data.subLabel!, style: theme.subLabelStyle),
        ],
      );
    }

    final isWordKey = label.length > 1; // .com, ABC, 123, Ctrl, Esc…
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.fade,
      softWrap: false,
      style: (isWordKey
              ? theme.textStyle.copyWith(fontSize: theme.textStyle.fontSize! * 0.5)
              : theme.textStyle)
          .copyWith(color: engaged ? theme.accentColor : null),
    );
  }

  IconData? _resolveIcon() {
    if (_data.kind == KeyKind.shift && _controller.isCapsLock) {
      return Icons.keyboard_capslock;
    }
    if (_data.icon != null) return _data.icon;
    if (_data.kind == KeyKind.navigation) {
      return switch (_data.nav) {
        NavIntent.left => Icons.keyboard_arrow_left,
        NavIntent.right => Icons.keyboard_arrow_right,
        NavIntent.up => Icons.keyboard_arrow_up,
        NavIntent.down => Icons.keyboard_arrow_down,
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
      KeyKind.clipboard => _data.label ?? _data.clip?.name ?? 'Clipboard',
      KeyKind.media => _data.label ?? _data.media?.name ?? 'Media',
      _ => _data.resolveLabel(shifted: _controller.isUpperCase) ??
          _data.label ??
          '',
    };
  }
}
