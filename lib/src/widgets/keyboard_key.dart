import 'dart:async';

import 'package:flutter/material.dart';

import '../controller/virtual_keyboard_controller.dart';
import '../models/key_data.dart';
import '../theme/virtual_keyboard_theme.dart';

/// A single rendered key.
///
/// Owns its own pressed-state ([ValueNotifier]) so tapping a key repaints only
/// that key — the rest of the keyboard never rebuilds. Also implements
/// long-press continuous delete and held-key repeat using the active config.
class KeyboardKey extends StatefulWidget {
  const KeyboardKey({
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
  State<KeyboardKey> createState() => _KeyboardKeyState();
}

class _KeyboardKeyState extends State<KeyboardKey> {
  final ValueNotifier<bool> _pressed = ValueNotifier<bool>(false);
  Timer? _repeatTimer;
  Timer? _delayTimer;
  int _lastShiftTapMs = 0;

  KeyData get _data => widget.data;

  bool get _isSpecial =>
      _data.kind != KeyKind.character && _data.kind != KeyKind.space;

  @override
  void dispose() {
    _cancelRepeat();
    _pressed.dispose();
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
    final config = widget.controller.config;
    final isBackspace = _data.kind == KeyKind.backspace;
    final canRepeat = isBackspace
        ? config.enableLongPressDelete
        : (_data.repeatable && config.enableKeyRepeat);
    if (!canRepeat) return;

    final delay = isBackspace ? config.longPressDeleteDelay : config.keyRepeatDelay;
    _delayTimer = Timer(delay, () {
      _repeatTimer = Timer.periodic(config.keyRepeatInterval, (_) {
        widget.controller.handleKey(_data);
      });
    });
  }

  void _onTap() {
    _cancelRepeat();
    if (_data.kind == KeyKind.shift) {
      _handleShift();
      return;
    }
    widget.controller.handleKey(_data);
  }

  void _handleShift() {
    // Detect double tap for caps-lock using a manual timestamp (no Date.now
    // dependency — uses the scheduler's frame timestamp).
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastShiftTapMs < 300) {
      widget.controller.handleShiftDoubleTap();
    } else {
      widget.controller.handleShiftTap();
    }
    _lastShiftTapMs = now;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    if (_data.kind == KeyKind.spacer) {
      return Expanded(flex: (_data.flex * 10).round(), child: const SizedBox());
    }
    if (_data.kind == KeyKind.custom && _data.builder != null) {
      return Expanded(
        flex: (_data.flex * 10).round(),
        child: Padding(
          padding: theme.keyPadding,
          child: GestureDetector(
            onTap: _data.text != null ? _onTap : null,
            child: _data.builder!(context),
          ),
        ),
      );
    }

    final baseColor = _isSpecial ? theme.specialKeyColor : theme.keyColor;

    return Expanded(
      flex: (_data.flex * 10).round(),
      child: Padding(
        padding: theme.keyPadding,
        child: Semantics(
          button: true,
          label: _semanticLabel(),
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: _onTap,
            child: ValueListenableBuilder<bool>(
              valueListenable: _pressed,
              builder: (context, pressed, _) {
                return RepaintBoundary(
                  child: Material(
                    color: pressed ? theme.pressedKeyColor : baseColor,
                    elevation: theme.elevation,
                    shadowColor: theme.shadowColor,
                    borderRadius: theme.borderRadius is BorderRadius
                        ? theme.borderRadius as BorderRadius
                        : BorderRadius.circular(8),
                    child: SizedBox(
                      height: widget.height,
                      child: Center(child: _buildContent(theme)),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(VirtualKeyboardTheme theme) {
    final shifted = widget.controller.isUpperCase;

    if (_data.icon != null) {
      final highlight = _data.kind == KeyKind.shift &&
          widget.controller.shiftState != ShiftState.off;
      return Icon(
        _data.kind == KeyKind.shift && widget.controller.shiftState == ShiftState.capsLock
            ? Icons.keyboard_capslock
            : _data.icon,
        color: highlight ? Theme.of(context).colorScheme.primary : theme.iconColor,
        size: theme.textStyle.fontSize! * 1.1,
      );
    }

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

    final isWordKey = label.length > 1; // e.g. .com, ABC, 123
    return Text(
      label,
      style: isWordKey
          ? theme.textStyle.copyWith(fontSize: theme.textStyle.fontSize! * 0.62)
          : theme.textStyle,
    );
  }

  String _semanticLabel() {
    return switch (_data.kind) {
      KeyKind.backspace => 'Delete',
      KeyKind.shift => 'Shift',
      KeyKind.space => 'Space',
      KeyKind.enter => 'Enter',
      KeyKind.switchLayout => _data.label ?? 'Switch layout',
      _ => _data.resolveLabel(shifted: widget.controller.isUpperCase) ??
          _data.label ??
          '',
    };
  }
}
