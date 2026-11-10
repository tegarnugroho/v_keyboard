import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;

import 'key_data.dart';
import 'key_intents.dart';

/// Semantic classification for a key inside [DesktopFullKeyboard].
enum KeyType {
  /// Standard printable character key (letters, numbers, punctuation, numpad digits).
  character,

  /// Momentary modifier key (Shift, Ctrl, Alt, AltGr, Win/Super, Fn).
  modifier,

  /// Toggleable lock key with active LED state (Caps Lock, Num Lock, Scroll Lock).
  lock,

  /// Special non-character action key (Enter, Backspace, Tab, Menu).
  action,

  /// Navigation & cursor control key (Ins, Del, Home, End, PgUp, PgDn, Arrows).
  navigation,

  /// Top function row & system key (Esc, F1–F12, PrtSc, Pause).
  function,

  /// Primary space bar key.
  space,

  /// Proportional empty gap used to keep clusters aligned.
  spacer,
}

/// High-level semantic actions triggered by non-character desktop keys.
enum VirtualKeyAction {
  escape,
  f1,
  f2,
  f3,
  f4,
  f5,
  f6,
  f7,
  f8,
  f9,
  f10,
  f11,
  f12,
  printScreen,
  scrollLock,
  pause,
  backspace,
  tab,
  capsLock,
  enter,
  numpadEnter,
  leftShift,
  rightShift,
  leftCtrl,
  rightCtrl,
  winSuper,
  leftAlt,
  altGr,
  fn,
  menu,
  space,
  insert,
  delete,
  home,
  end,
  pageUp,
  pageDown,
  arrowUp,
  arrowDown,
  arrowLeft,
  arrowRight,
  numLock,
  numpadDivide,
  numpadMultiply,
  numpadSubtract,
  numpadAdd,
  numpadDecimal,
}

/// Immutable structural definition for a proportional key in [DesktopFullKeyboard].
///
/// Keys use [flex] relative units (standard 1u key = `1.0`) so rows fit
/// edge-to-edge inside a [Row] or [Column] via `Expanded` without hardcoded pixels.
@immutable
class KeyModel {
  const KeyModel({
    required this.id,
    required this.label,
    required this.type,
    this.shiftLabel,
    this.secondaryLabel,
    this.value,
    this.shiftValue,
    this.action,
    this.flex = 1.0,
    this.icon,
    this.iconBeforeLabel = false,
    this.iconAfterLabel = false,
    this.isAccent = false,
    this.isDanger = false,
    this.hasLed = false,
    this.repeatable = false,
    this.shortcutKey,
    this.navIntent,
    this.secondaryNavIntent,
    this.secondaryAction,
    this.modifierKey,
    this.lockKey,
    this.logicalKey,
    this.isNumpadDigit = false,
  });

  /// Creates a printable character key with optional [shiftLabel]/[shiftValue].
  factory KeyModel.char(
    String value, {
    String? shift,
    String? id,
    double flex = 1.0,
    String? shortcutKey,
  }) {
    return KeyModel(
      id: id ?? 'char_$value',
      label: value,
      shiftLabel: shift,
      value: value,
      shiftValue: shift ?? value.toUpperCase(),
      type: KeyType.character,
      flex: flex,
      repeatable: true,
      shortcutKey: shortcutKey ?? value.toUpperCase(),
    );
  }

  /// Creates a numpad key with optional secondary navigation intent when NumLock is off.
  factory KeyModel.numpad(
    String value, {
    String? id,
    double flex = 1.0,
    VirtualKeyAction? action,
    VirtualKeyAction? secondaryAction,
    NavIntent? secondaryNavIntent,
    String? secondaryLabel,
    bool isNumpadDigit = false,
    bool isAccent = false,
    IconData? icon,
  }) {
    return KeyModel(
      id: id ?? 'num_$value',
      label: value,
      secondaryLabel: secondaryLabel,
      value: value,
      shiftValue: value,
      type: isAccent ? KeyType.action : KeyType.character,
      action: action,
      secondaryAction: secondaryAction,
      secondaryNavIntent: secondaryNavIntent,
      flex: flex,
      repeatable: true,
      isAccent: isAccent,
      isNumpadDigit: isNumpadDigit,
      icon: icon,
      shortcutKey: value,
    );
  }

  /// Creates a proportional blank gap.
  const KeyModel.spacer({this.flex = 1.0, String? id})
      : id = id ?? 'spacer',
        label = '',
        shiftLabel = null,
        secondaryLabel = null,
        value = null,
        shiftValue = null,
        type = KeyType.spacer,
        action = null,
        icon = null,
        iconBeforeLabel = false,
        iconAfterLabel = false,
        isAccent = false,
        isDanger = false,
        hasLed = false,
        repeatable = false,
        shortcutKey = null,
        navIntent = null,
        secondaryNavIntent = null,
        secondaryAction = null,
        modifierKey = null,
        lockKey = null,
        logicalKey = null,
        isNumpadDigit = false;

  final String id;
  final String label;
  final String? shiftLabel;

  /// Optional hint displayed when Num Lock is disabled (e.g. `Home`, `PgUp`).
  final String? secondaryLabel;
  final String? value;
  final String? shiftValue;
  final KeyType type;
  final VirtualKeyAction? action;

  /// Relative flex weight (standard 1u key = `1.0`). Converted to `int` flex
  /// via `(flex * 100).round()` inside [Expanded].
  final double flex;

  final IconData? icon;
  final bool iconBeforeLabel;
  final bool iconAfterLabel;
  final bool isAccent;
  final bool isDanger;
  final bool hasLed;
  final bool repeatable;

  /// Canonical token used when composing shortcut strings (e.g. `'A'`, `'Tab'`).
  final String? shortcutKey;

  /// Optional integration hooks with [VKeyboardController].
  final NavIntent? navIntent;
  final NavIntent? secondaryNavIntent;
  final VirtualKeyAction? secondaryAction;
  final ModifierKey? modifierKey;
  final LockKey? lockKey;
  final LogicalKeyboardKey? logicalKey;
  final bool isNumpadDigit;

  bool get isSpacer => type == KeyType.spacer;

  /// Whether this key is a single ASCII letter (`a`–`z`).
  bool get isLetter {
    final v = value;
    if (v == null || v.length != 1) return false;
    final code = v.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }

  /// Whether this key displays two stacked legends (top shifted symbol, bottom base symbol).
  bool get hasDualLegend =>
      type == KeyType.character && shiftLabel != null && !isLetter;

  /// Resolves the output text to emit given current [shifted] and [capsLock] state.
  String? resolveOutput({required bool shifted, required bool capsLock}) {
    if (type == KeyType.space) return ' ';
    if (type != KeyType.character || value == null) return null;
    if (isLetter) {
      final upper = shifted ^ capsLock;
      return upper ? value!.toUpperCase() : value!.toLowerCase();
    }
    return shifted ? (shiftValue ?? value) : value;
  }

  /// Resolves the visible primary label on the keycap for letter keys.
  String resolveDisplayLabel({required bool shifted, required bool capsLock}) {
    if (isLetter && value != null) {
      final upper = shifted ^ capsLock;
      return upper ? value!.toUpperCase() : value!.toLowerCase();
    }
    return label;
  }

  /// Converts this desktop key into a package [KeyData] when routing through
  /// an attached [VKeyboardController].
  KeyData? toKeyData() {
    switch (type) {
      case KeyType.spacer:
        return KeyData.spacer(flex: flex);
      case KeyType.space:
        return KeyData.space(flex: flex);
      case KeyType.character:
        if (value == null) return null;
        return KeyData.char(value!, shift: shiftValue, flex: flex);
      case KeyType.modifier:
        if (modifierKey != null) {
          return KeyData.modifier(modifierKey!, label: label, flex: flex);
        }
        return null;
      case KeyType.lock:
        if (lockKey != null) {
          return KeyData.lock(lockKey!, label: label, flex: flex);
        }
        return null;
      case KeyType.navigation:
        if (navIntent != null) {
          return KeyData.nav(navIntent!, label: label, flex: flex);
        }
        if (logicalKey != null) {
          return KeyData.function(
            label,
            logicalKey!,
            flex: flex,
            repeatable: repeatable,
          );
        }
        return null;
      case KeyType.function:
        if (logicalKey != null) {
          return KeyData.function(
            label,
            logicalKey!,
            flex: flex,
            repeatable: repeatable,
          );
        }
        return null;
      case KeyType.action:
        if (action == VirtualKeyAction.backspace) {
          return KeyData.backspace(flex: flex);
        }
        if (action == VirtualKeyAction.enter ||
            action == VirtualKeyAction.numpadEnter) {
          return KeyData.enter(flex: flex);
        }
        if (action == VirtualKeyAction.tab) {
          return KeyData.function(
            'Tab',
            LogicalKeyboardKey.tab,
            insert: '\t',
            flex: flex,
          );
        }
        if (logicalKey != null) {
          return KeyData.function(label, logicalKey!, flex: flex);
        }
        return null;
    }
  }
}

/// Provides the full 100% ANSI Desktop OSK row definitions across the 3 clusters
/// (Main Alphanumeric 15u, Navigation 3u, Numpad 4u).
class DesktopFullLayoutData {
  const DesktopFullLayoutData._();

  // ---- Main Alphanumeric Cluster (each row sums to 15.0u) -------------------

  static List<KeyModel> functionRow() => const [
        KeyModel(
          id: 'esc',
          label: 'Esc',
          type: KeyType.function,
          action: VirtualKeyAction.escape,
          logicalKey: LogicalKeyboardKey.escape,
          shortcutKey: 'Esc',
          flex: 1.4,
        ),
        KeyModel.spacer(flex: 0.6, id: 'fn_gap_1'),
        KeyModel(
          id: 'f1',
          label: 'F1',
          type: KeyType.function,
          action: VirtualKeyAction.f1,
          logicalKey: LogicalKeyboardKey.f1,
          shortcutKey: 'F1',
        ),
        KeyModel(
          id: 'f2',
          label: 'F2',
          type: KeyType.function,
          action: VirtualKeyAction.f2,
          logicalKey: LogicalKeyboardKey.f2,
          shortcutKey: 'F2',
        ),
        KeyModel(
          id: 'f3',
          label: 'F3',
          type: KeyType.function,
          action: VirtualKeyAction.f3,
          logicalKey: LogicalKeyboardKey.f3,
          shortcutKey: 'F3',
        ),
        KeyModel(
          id: 'f4',
          label: 'F4',
          type: KeyType.function,
          action: VirtualKeyAction.f4,
          logicalKey: LogicalKeyboardKey.f4,
          shortcutKey: 'F4',
        ),
        KeyModel.spacer(flex: 0.5, id: 'fn_gap_2'),
        KeyModel(
          id: 'f5',
          label: 'F5',
          type: KeyType.function,
          action: VirtualKeyAction.f5,
          logicalKey: LogicalKeyboardKey.f5,
          shortcutKey: 'F5',
        ),
        KeyModel(
          id: 'f6',
          label: 'F6',
          type: KeyType.function,
          action: VirtualKeyAction.f6,
          logicalKey: LogicalKeyboardKey.f6,
          shortcutKey: 'F6',
        ),
        KeyModel(
          id: 'f7',
          label: 'F7',
          type: KeyType.function,
          action: VirtualKeyAction.f7,
          logicalKey: LogicalKeyboardKey.f7,
          shortcutKey: 'F7',
        ),
        KeyModel(
          id: 'f8',
          label: 'F8',
          type: KeyType.function,
          action: VirtualKeyAction.f8,
          logicalKey: LogicalKeyboardKey.f8,
          shortcutKey: 'F8',
        ),
        KeyModel.spacer(flex: 0.5, id: 'fn_gap_3'),
        KeyModel(
          id: 'f9',
          label: 'F9',
          type: KeyType.function,
          action: VirtualKeyAction.f9,
          logicalKey: LogicalKeyboardKey.f9,
          shortcutKey: 'F9',
        ),
        KeyModel(
          id: 'f10',
          label: 'F10',
          type: KeyType.function,
          action: VirtualKeyAction.f10,
          logicalKey: LogicalKeyboardKey.f10,
          shortcutKey: 'F10',
        ),
        KeyModel(
          id: 'f11',
          label: 'F11',
          type: KeyType.function,
          action: VirtualKeyAction.f11,
          logicalKey: LogicalKeyboardKey.f11,
          shortcutKey: 'F11',
        ),
        KeyModel(
          id: 'f12',
          label: 'F12',
          type: KeyType.function,
          action: VirtualKeyAction.f12,
          logicalKey: LogicalKeyboardKey.f12,
          shortcutKey: 'F12',
        ),
      ];

  static List<KeyModel> numberRow() => [
        KeyModel.char('`', shift: '~', id: 'grave'),
        KeyModel.char('1', shift: '!', id: 'digit_1'),
        KeyModel.char('2', shift: '@', id: 'digit_2'),
        KeyModel.char('3', shift: '#', id: 'digit_3'),
        KeyModel.char('4', shift: r'$', id: 'digit_4'),
        KeyModel.char('5', shift: '%', id: 'digit_5'),
        KeyModel.char('6', shift: '^', id: 'digit_6'),
        KeyModel.char('7', shift: '&', id: 'digit_7'),
        KeyModel.char('8', shift: '*', id: 'digit_8'),
        KeyModel.char('9', shift: '(', id: 'digit_9'),
        KeyModel.char('0', shift: ')', id: 'digit_0'),
        KeyModel.char('-', shift: '_', id: 'minus'),
        KeyModel.char('=', shift: '+', id: 'equal'),
        const KeyModel(
          id: 'backspace',
          label: 'Backspace',
          type: KeyType.action,
          action: VirtualKeyAction.backspace,
          icon: Icons.backspace_outlined,
          repeatable: true,
          flex: 2.0,
          shortcutKey: 'Backspace',
        ),
      ];

  static List<KeyModel> topAlphaRow() => [
        const KeyModel(
          id: 'tab',
          label: 'Tab',
          type: KeyType.action,
          action: VirtualKeyAction.tab,
          logicalKey: LogicalKeyboardKey.tab,
          flex: 1.5,
          shortcutKey: 'Tab',
        ),
        for (final c in const ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'])
          KeyModel.char(c),
        KeyModel.char('[', shift: '{', id: 'bracket_left'),
        KeyModel.char(']', shift: '}', id: 'bracket_right'),
        KeyModel.char(r'\', shift: '|', id: 'backslash', flex: 1.5),
      ];

  static List<KeyModel> homeAlphaRow() => [
        const KeyModel(
          id: 'caps_lock',
          label: 'Caps',
          type: KeyType.lock,
          action: VirtualKeyAction.capsLock,
          lockKey: LockKey.capsLock,
          hasLed: true,
          flex: 1.75,
        ),
        for (final c in const ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'])
          KeyModel.char(c),
        KeyModel.char(';', shift: ':', id: 'semicolon'),
        KeyModel.char("'", shift: '"', id: 'quote'),
        const KeyModel(
          id: 'enter',
          label: 'Enter',
          type: KeyType.action,
          action: VirtualKeyAction.enter,
          icon: Icons.keyboard_return_rounded,
          iconAfterLabel: true,
          isAccent: true,
          flex: 2.25,
          shortcutKey: 'Enter',
        ),
      ];

  static List<KeyModel> bottomAlphaRow() => [
        const KeyModel(
          id: 'shift_left',
          label: 'Shift',
          type: KeyType.modifier,
          action: VirtualKeyAction.leftShift,
          modifierKey: ModifierKey.shift,
          icon: Icons.north_rounded,
          iconBeforeLabel: true,
          flex: 2.25,
        ),
        for (final c in const ['z', 'x', 'c', 'v', 'b', 'n', 'm'])
          KeyModel.char(c),
        KeyModel.char(',', shift: '<', id: 'comma'),
        KeyModel.char('.', shift: '>', id: 'period'),
        KeyModel.char('/', shift: '?', id: 'slash'),
        const KeyModel(
          id: 'shift_right',
          label: 'Shift',
          type: KeyType.modifier,
          action: VirtualKeyAction.rightShift,
          modifierKey: ModifierKey.shift,
          icon: Icons.north_rounded,
          iconAfterLabel: true,
          flex: 2.75,
        ),
      ];

  static List<KeyModel> bottomControlRow() => const [
        KeyModel(
          id: 'ctrl_left',
          label: 'Ctrl',
          type: KeyType.modifier,
          action: VirtualKeyAction.leftCtrl,
          modifierKey: ModifierKey.control,
          flex: 1.25,
        ),
        KeyModel(
          id: 'win_super',
          label: 'Win',
          type: KeyType.modifier,
          action: VirtualKeyAction.winSuper,
          modifierKey: ModifierKey.meta,
          icon: Icons.window_rounded,
          flex: 1.2,
        ),
        KeyModel(
          id: 'alt_left',
          label: 'Alt',
          type: KeyType.modifier,
          action: VirtualKeyAction.leftAlt,
          modifierKey: ModifierKey.alt,
          flex: 1.2,
        ),
        KeyModel(
          id: 'spacebar',
          label: 'SPACEBAR',
          value: ' ',
          shiftValue: ' ',
          type: KeyType.space,
          action: VirtualKeyAction.space,
          repeatable: true,
          flex: 6.1,
          shortcutKey: 'Space',
        ),
        KeyModel(
          id: 'alt_gr',
          label: 'AltGr',
          type: KeyType.modifier,
          action: VirtualKeyAction.altGr,
          modifierKey: ModifierKey.altGr,
          flex: 1.35,
        ),
        KeyModel(
          id: 'fn_key',
          label: 'Fn',
          type: KeyType.modifier,
          action: VirtualKeyAction.fn,
          flex: 1.15,
        ),
        KeyModel(
          id: 'menu_key',
          label: 'Menu',
          type: KeyType.action,
          action: VirtualKeyAction.menu,
          logicalKey: LogicalKeyboardKey.contextMenu,
          icon: Icons.menu_rounded,
          flex: 1.15,
        ),
        KeyModel(
          id: 'ctrl_right',
          label: 'Ctrl',
          type: KeyType.modifier,
          action: VirtualKeyAction.rightCtrl,
          modifierKey: ModifierKey.control,
          flex: 1.6,
        ),
      ];

  // ---- Navigation Cluster (each row sums to 3.0u) ---------------------------

  static List<KeyModel> navSystemRow() => const [
        KeyModel(
          id: 'prtsc',
          label: 'PrtSc',
          type: KeyType.function,
          action: VirtualKeyAction.printScreen,
          logicalKey: LogicalKeyboardKey.printScreen,
          shortcutKey: 'PrtSc',
        ),
        KeyModel(
          id: 'scrlk',
          label: 'ScrLk',
          type: KeyType.lock,
          action: VirtualKeyAction.scrollLock,
          lockKey: LockKey.scrollLock,
          logicalKey: LogicalKeyboardKey.scrollLock,
          shortcutKey: 'ScrLk',
        ),
        KeyModel(
          id: 'pause',
          label: 'Pause',
          type: KeyType.function,
          action: VirtualKeyAction.pause,
          logicalKey: LogicalKeyboardKey.pause,
          shortcutKey: 'Pause',
        ),
      ];

  static List<KeyModel> navTopEditRow() => const [
        KeyModel(
          id: 'insert',
          label: 'Ins',
          type: KeyType.navigation,
          action: VirtualKeyAction.insert,
          logicalKey: LogicalKeyboardKey.insert,
          shortcutKey: 'Ins',
        ),
        KeyModel(
          id: 'home',
          label: 'Home',
          type: KeyType.navigation,
          action: VirtualKeyAction.home,
          navIntent: NavIntent.home,
          shortcutKey: 'Home',
        ),
        KeyModel(
          id: 'pgup',
          label: 'PgUp',
          type: KeyType.navigation,
          action: VirtualKeyAction.pageUp,
          navIntent: NavIntent.pageUp,
          shortcutKey: 'PgUp',
        ),
      ];

  static List<KeyModel> navBottomEditRow() => const [
        KeyModel(
          id: 'delete',
          label: 'Del',
          type: KeyType.navigation,
          action: VirtualKeyAction.delete,
          logicalKey: LogicalKeyboardKey.delete,
          repeatable: true,
          isDanger: true,
          shortcutKey: 'Del',
        ),
        KeyModel(
          id: 'end',
          label: 'End',
          type: KeyType.navigation,
          action: VirtualKeyAction.end,
          navIntent: NavIntent.end,
          shortcutKey: 'End',
        ),
        KeyModel(
          id: 'pgdn',
          label: 'PgDn',
          type: KeyType.navigation,
          action: VirtualKeyAction.pageDown,
          navIntent: NavIntent.pageDown,
          shortcutKey: 'PgDn',
        ),
      ];

  static List<KeyModel> navEmptyRow() => const [
        KeyModel.spacer(flex: 3.0, id: 'nav_empty'),
      ];

  static List<KeyModel> navArrowUpRow() => const [
        KeyModel.spacer(flex: 1.0, id: 'arrow_up_l'),
        KeyModel(
          id: 'arrow_up',
          label: 'Up',
          type: KeyType.navigation,
          action: VirtualKeyAction.arrowUp,
          navIntent: NavIntent.up,
          icon: Icons.keyboard_arrow_up_rounded,
          repeatable: true,
          shortcutKey: 'Up',
        ),
        KeyModel.spacer(flex: 1.0, id: 'arrow_up_r'),
      ];

  static List<KeyModel> navArrowBottomRow() => const [
        KeyModel(
          id: 'arrow_left',
          label: 'Left',
          type: KeyType.navigation,
          action: VirtualKeyAction.arrowLeft,
          navIntent: NavIntent.left,
          icon: Icons.keyboard_arrow_left_rounded,
          repeatable: true,
          shortcutKey: 'Left',
        ),
        KeyModel(
          id: 'arrow_down',
          label: 'Down',
          type: KeyType.navigation,
          action: VirtualKeyAction.arrowDown,
          navIntent: NavIntent.down,
          icon: Icons.keyboard_arrow_down_rounded,
          repeatable: true,
          shortcutKey: 'Down',
        ),
        KeyModel(
          id: 'arrow_right',
          label: 'Right',
          type: KeyType.navigation,
          action: VirtualKeyAction.arrowRight,
          navIntent: NavIntent.right,
          icon: Icons.keyboard_arrow_right_rounded,
          repeatable: true,
          shortcutKey: 'Right',
        ),
      ];

  // ---- Numpad Cluster (4.0u total width) ------------------------------------

  static List<KeyModel> numpadTopRow() => [
        const KeyModel(
          id: 'num_lock',
          label: 'Num',
          type: KeyType.lock,
          action: VirtualKeyAction.numLock,
          lockKey: LockKey.numLock,
          logicalKey: LogicalKeyboardKey.numLock,
          hasLed: true,
        ),
        KeyModel.numpad('/', action: VirtualKeyAction.numpadDivide, id: 'num_div'),
        KeyModel.numpad('*', action: VirtualKeyAction.numpadMultiply, id: 'num_mul'),
        KeyModel.numpad('-', action: VirtualKeyAction.numpadSubtract, id: 'num_sub'),
      ];

  static List<KeyModel> numpadRow789() => [
        KeyModel.numpad(
          '7',
          isNumpadDigit: true,
          secondaryLabel: 'Home',
          secondaryNavIntent: NavIntent.home,
          secondaryAction: VirtualKeyAction.home,
        ),
        KeyModel.numpad(
          '8',
          isNumpadDigit: true,
          secondaryLabel: '▲',
          secondaryNavIntent: NavIntent.up,
          secondaryAction: VirtualKeyAction.arrowUp,
        ),
        KeyModel.numpad(
          '9',
          isNumpadDigit: true,
          secondaryLabel: 'PgUp',
          secondaryNavIntent: NavIntent.pageUp,
          secondaryAction: VirtualKeyAction.pageUp,
        ),
      ];

  static List<KeyModel> numpadRow456() => [
        KeyModel.numpad(
          '4',
          isNumpadDigit: true,
          secondaryLabel: '◀',
          secondaryNavIntent: NavIntent.left,
          secondaryAction: VirtualKeyAction.arrowLeft,
        ),
        KeyModel.numpad(
          '5',
          isNumpadDigit: true,
        ),
        KeyModel.numpad(
          '6',
          isNumpadDigit: true,
          secondaryLabel: '▶',
          secondaryNavIntent: NavIntent.right,
          secondaryAction: VirtualKeyAction.arrowRight,
        ),
      ];

  static List<KeyModel> numpadRow123() => [
        KeyModel.numpad(
          '1',
          isNumpadDigit: true,
          secondaryLabel: 'End',
          secondaryNavIntent: NavIntent.end,
          secondaryAction: VirtualKeyAction.end,
        ),
        KeyModel.numpad(
          '2',
          isNumpadDigit: true,
          secondaryLabel: '▼',
          secondaryNavIntent: NavIntent.down,
          secondaryAction: VirtualKeyAction.arrowDown,
        ),
        KeyModel.numpad(
          '3',
          isNumpadDigit: true,
          secondaryLabel: 'PgDn',
          secondaryNavIntent: NavIntent.pageDown,
          secondaryAction: VirtualKeyAction.pageDown,
        ),
      ];

  static List<KeyModel> numpadRow0Dot() => [
        KeyModel.numpad(
          '0',
          flex: 2.0,
          isNumpadDigit: true,
          secondaryLabel: 'Ins',
          secondaryAction: VirtualKeyAction.insert,
        ),
        KeyModel.numpad(
          '.',
          id: 'num_dot',
          isNumpadDigit: true,
          secondaryLabel: 'Del',
          secondaryAction: VirtualKeyAction.delete,
        ),
      ];

  static KeyModel numpadPlusKey() => KeyModel.numpad(
        '+',
        id: 'num_plus',
        action: VirtualKeyAction.numpadAdd,
        flex: 1.0,
      );

  static KeyModel numpadEnterKey() => KeyModel.numpad(
        'Enter',
        id: 'num_enter',
        action: VirtualKeyAction.numpadEnter,
        icon: Icons.keyboard_return_rounded,
        isAccent: true,
        flex: 1.0,
      );
}
