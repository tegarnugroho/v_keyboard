import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;

import 'key_data.dart';
import 'key_intents.dart';

/// Hardware OS layout convention used by [DesktopFullKeyboard].
enum DesktopKeyboardPlatform {
  /// Windows / PC ANSI keyboard convention:
  /// - Bottom row: `Ctrl`, `Win`, `Alt`, `SPACEBAR`, `AltGr`, `Fn`, `Menu`, `Ctrl`
  /// - Action/System labels: `Esc`, `Backspace`, `Tab`, `Caps`, `Enter`, `PrtSc`, `ScrLk`, `Pause`
  windows('Windows', 'WIN'),

  /// macOS / Apple Magic Keyboard convention:
  /// - Bottom row: `fn`, `⌃ ctrl`, `⌥ opt`, `⌘ cmd`, `SPACE`, `⌘ cmd`, `⌥ opt`, `⌃ ctrl`
  /// - Action/System labels: `esc`, `delete`, `tab`, `caps lock`, `return`, `F13`, `F14`, `F15`
  macos('macOS', 'MAC');

  const DesktopKeyboardPlatform(this.label, this.shortLabel);

  /// Human-readable OS platform label (e.g. `'Windows'`, `'macOS'`).
  final String label;

  /// Short uppercase pill badge label (e.g. `'WIN'`, `'MAC'`).
  final String shortLabel;

  /// Resolves the appropriate convention from Flutter's ambient [TargetPlatform].
  static DesktopKeyboardPlatform fromTargetPlatform(TargetPlatform target) {
    return target == TargetPlatform.macOS ? macos : windows;
  }
}

/// Standard mechanical / OSK form-factor presets supported by [DesktopFullKeyboard].
enum KeyboardLayoutType {
  /// 60% compact layout: pure number row + alphanumeric block with `Fn` layer
  /// for Function keys, navigation, and arrows (15u wide, 5 rows).
  layout60('60% Compact', '60%'),

  /// 65% compact layout: number row + alphanumeric + integrated arrows +
  /// 1-column navigation strip, without top F-row or Numpad (16u wide, 5 rows).
  layout65('65% Compact', '65%'),

  /// 75% compact layout: includes top F-row + 1-column right navigation strip +
  /// tucked arrow keys, without Numpad (16u wide, 6 rows).
  layout75('75% Compact', '75%'),

  /// 87% Tenkeyless (TKL) layout: full alphanumeric + F-row + separated 3x2
  /// navigation block + Inverted-T arrows, without Numpad (15u + 3u).
  layout87TKL('87% TKL', '87% TKL'),

  /// 98% (1800-compact) layout: full alphanumeric + F-row + tightly tucked
  /// arrows + 4-column Numpad with zero inter-cluster gap (19u unified).
  layout98('98% Compact', '98%'),

  /// 100% Full-Size layout: Main alphanumeric (15u) + Navigation cluster (3u) +
  /// Standard 4-column Numpad (4u) with clear cluster spacing.
  layout100('100% Full-Size', '100%');

  const KeyboardLayoutType(this.label, this.shortLabel);

  /// Descriptive human-readable name (e.g. `'100% Full-Size'`).
  final String label;

  /// Compact badge label (e.g. `'60%'`, `'87% TKL'`).
  final String shortLabel;

  /// Whether this form-factor natively includes a 4-column Numpad cluster.
  bool get hasNumpad =>
      this == KeyboardLayoutType.layout98 || this == KeyboardLayoutType.layout100;

  /// Whether this form-factor natively includes the top Function row (`Esc`, `F1`–`F12`).
  bool get hasFunctionRow =>
      this == KeyboardLayoutType.layout75 ||
      this == KeyboardLayoutType.layout87TKL ||
      this == KeyboardLayoutType.layout98 ||
      this == KeyboardLayoutType.layout100;

  /// Whether this form-factor uses an `Fn` secondary layer prominently for missing keys.
  bool get hasFnLayer =>
      this == KeyboardLayoutType.layout60 || this == KeyboardLayoutType.layout65;
}

/// Semantic classification for a key inside [DesktopFullKeyboard].
enum KeyType {
  /// Standard printable character key (letters, numbers, punctuation, numpad digits).
  character,

  /// Momentary modifier key (Shift, Ctrl, Alt, AltGr, Win/Super, Cmd, Opt, Fn).
  modifier,

  /// Toggleable lock key with active LED state (Caps Lock, Num Lock, Scroll Lock).
  lock,

  /// Special non-character action key (Enter/Return, Backspace/Delete, Tab, Menu).
  action,

  /// Navigation & cursor control key (Ins, Del, Home, End, PgUp, PgDn, Arrows).
  navigation,

  /// Top function row & system key (Esc, F1–F15, PrtSc, Pause).
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
  f13,
  f14,
  f15,
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
  leftCommand,
  rightCommand,
  leftAlt,
  rightOption,
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
    this.fnLabel,
    this.fnIcon,
    this.fnAction,
    this.fnNavIntent,
    this.fnLogicalKey,
    this.fnShortcutKey,
  });

  /// Creates a printable character key with optional [shiftLabel]/[shiftValue]
  /// and optional `Fn`-layer overrides (used on compact 60%/65% presets).
  factory KeyModel.char(
    String value, {
    String? shift,
    String? id,
    double flex = 1.0,
    String? shortcutKey,
    String? fnLabel,
    IconData? fnIcon,
    VirtualKeyAction? fnAction,
    NavIntent? fnNavIntent,
    LogicalKeyboardKey? fnLogicalKey,
    String? fnShortcutKey,
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
      fnLabel: fnLabel,
      fnIcon: fnIcon,
      fnAction: fnAction,
      fnNavIntent: fnNavIntent,
      fnLogicalKey: fnLogicalKey,
      fnShortcutKey: fnShortcutKey,
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
        isNumpadDigit = false,
        fnLabel = null,
        fnIcon = null,
        fnAction = null,
        fnNavIntent = null,
        fnLogicalKey = null,
        fnShortcutKey = null;

  final String id;
  final String label;

  /// Top legend on dual-legend character keys (e.g. `'!'`) or symbol glyph
  /// above macOS modifier names (e.g. `'⌘'`, `'⌥'`, `'⌃'`).
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

  /// Secondary `Fn`-layer label displayed when the `Fn` modifier is active.
  final String? fnLabel;

  /// Secondary `Fn`-layer icon (e.g. arrow icons on `W`/`A`/`S`/`D`).
  final IconData? fnIcon;

  /// Semantic action triggered instead of normal output when `Fn` is active.
  final VirtualKeyAction? fnAction;

  /// Navigation intent executed in [VKeyboardController] when `Fn` is active.
  final NavIntent? fnNavIntent;

  /// Logical key executed in [VKeyboardController] when `Fn` is active.
  final LogicalKeyboardKey? fnLogicalKey;

  /// Shortcut token used if combined with Ctrl/Alt/Cmd while `Fn` is active.
  final String? fnShortcutKey;

  bool get isSpacer => type == KeyType.spacer;

  bool get hasFnMapping =>
      fnAction != null || fnNavIntent != null || fnLogicalKey != null;

  /// Whether this key is a single cased letter (`a`–`z`, Cyrillic `й`–`я`,
  /// Greek `α`–`ω`, German `ä`/`ö`/`ü`, etc.) whose visual case toggles cleanly
  /// under Shift and Caps Lock.
  bool get isLetter {
    final v = value;
    if (v == null || v.length != 1) return false;
    final upper = v.toUpperCase();
    if (upper.length != 1) return false;
    if (upper == v.toLowerCase()) return false;
    return shiftValue == null || shiftValue == upper;
  }

  /// Whether this key displays two stacked legends (top shifted/glyph symbol, bottom base label).
  bool get hasDualLegend =>
      type == KeyType.character && shiftLabel != null && !isLetter;

  /// Whether this modifier displays a macOS glyph (`⌘`, `⌥`, `⌃`) above its label.
  bool get hasModifierGlyph =>
      type == KeyType.modifier && shiftLabel != null;

  /// Resolves the output text to emit given current [shifted] and [capsLock] state.
  String? resolveOutput({required bool shifted, required bool capsLock}) {
    if (type == KeyType.space) return ' ';
    if (type != KeyType.character || value == null) return null;
    if (isLetter) {
      final upper = shifted ^ capsLock;
      return upper ? (shiftValue ?? value!.toUpperCase()) : value!;
    }
    return shifted ? (shiftValue ?? value) : value;
  }

  /// Resolves the visible primary label on the keycap for letter keys.
  String resolveDisplayLabel({required bool shifted, required bool capsLock}) {
    if (isLetter && value != null) {
      final upper = shifted ^ capsLock;
      return upper ? (shiftValue ?? value!.toUpperCase()) : value!;
    }
    return label;
  }

  /// Resolves the active [KeyData] for its `Fn`-layer action, if configured.
  KeyData? toFnKeyData() {
    if (fnNavIntent != null) {
      return KeyData.nav(fnNavIntent!, label: fnLabel, flex: flex);
    }
    if (fnLogicalKey != null) {
      return KeyData.function(
        fnLabel ?? label,
        fnLogicalKey!,
        flex: flex,
        repeatable: fnAction == VirtualKeyAction.delete || repeatable,
      );
    }
    return null;
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

/// Provides modular, mathematically verified keycap row factories across all 6
/// desktop form factors (`layout60`, `layout65`, `layout75`, `layout87TKL`,
/// `layout98`, `layout100`) and both hardware OS conventions (`windows`, `macos`).
class DesktopFullLayoutData {
  const DesktopFullLayoutData._();

  // ---- Shared Reusable Keys -------------------------------------------------

  static KeyModel _fKey(int n) {
    final actions = [
      VirtualKeyAction.f1,
      VirtualKeyAction.f2,
      VirtualKeyAction.f3,
      VirtualKeyAction.f4,
      VirtualKeyAction.f5,
      VirtualKeyAction.f6,
      VirtualKeyAction.f7,
      VirtualKeyAction.f8,
      VirtualKeyAction.f9,
      VirtualKeyAction.f10,
      VirtualKeyAction.f11,
      VirtualKeyAction.f12,
    ];
    final logicals = [
      LogicalKeyboardKey.f1,
      LogicalKeyboardKey.f2,
      LogicalKeyboardKey.f3,
      LogicalKeyboardKey.f4,
      LogicalKeyboardKey.f5,
      LogicalKeyboardKey.f6,
      LogicalKeyboardKey.f7,
      LogicalKeyboardKey.f8,
      LogicalKeyboardKey.f9,
      LogicalKeyboardKey.f10,
      LogicalKeyboardKey.f11,
      LogicalKeyboardKey.f12,
    ];
    return KeyModel(
      id: 'f$n',
      label: 'F$n',
      type: KeyType.function,
      action: actions[n - 1],
      logicalKey: logicals[n - 1],
      shortcutKey: 'F$n',
    );
  }

  static KeyModel _escKey(DesktopKeyboardPlatform platform, {double flex = 1.4}) {
    final isMac = platform == DesktopKeyboardPlatform.macos;
    return KeyModel(
      id: 'esc',
      label: isMac ? 'esc' : 'Esc',
      type: KeyType.function,
      action: VirtualKeyAction.escape,
      logicalKey: LogicalKeyboardKey.escape,
      shortcutKey: 'Esc',
      flex: flex,
    );
  }

  static KeyModel _backspaceKey(
    DesktopKeyboardPlatform platform, {
    bool includeFnLayer = false,
    double flex = 2.0,
  }) {
    final isMac = platform == DesktopKeyboardPlatform.macos;
    return KeyModel(
      id: 'backspace',
      label: isMac ? 'delete' : 'Backspace',
      type: KeyType.action,
      action: VirtualKeyAction.backspace,
      icon: Icons.backspace_outlined,
      iconBeforeLabel: false,
      iconAfterLabel: isMac,
      repeatable: true,
      flex: flex,
      shortcutKey: isMac ? 'Delete' : 'Backspace',
      fnLabel: includeFnLayer ? (isMac ? '⌦' : 'Del') : null,
      fnAction: includeFnLayer ? VirtualKeyAction.delete : null,
      fnLogicalKey: includeFnLayer ? LogicalKeyboardKey.delete : null,
      fnShortcutKey: includeFnLayer ? 'Del' : null,
    );
  }

  static KeyModel _tabKey(DesktopKeyboardPlatform platform, {double flex = 1.5}) {
    final isMac = platform == DesktopKeyboardPlatform.macos;
    return KeyModel(
      id: 'tab',
      label: isMac ? 'tab' : 'Tab',
      type: KeyType.action,
      action: VirtualKeyAction.tab,
      logicalKey: LogicalKeyboardKey.tab,
      flex: flex,
      shortcutKey: 'Tab',
    );
  }

  static KeyModel _capsKey(DesktopKeyboardPlatform platform, {double flex = 1.75}) {
    final isMac = platform == DesktopKeyboardPlatform.macos;
    return KeyModel(
      id: 'caps_lock',
      label: isMac ? 'caps lock' : 'Caps',
      type: KeyType.lock,
      action: VirtualKeyAction.capsLock,
      lockKey: LockKey.capsLock,
      hasLed: true,
      flex: flex,
    );
  }

  static KeyModel _enterKey(DesktopKeyboardPlatform platform, {double flex = 2.25}) {
    final isMac = platform == DesktopKeyboardPlatform.macos;
    return KeyModel(
      id: 'enter',
      label: isMac ? 'return' : 'Enter',
      type: KeyType.action,
      action: VirtualKeyAction.enter,
      icon: Icons.keyboard_return_rounded,
      iconAfterLabel: true,
      isAccent: true,
      flex: flex,
      shortcutKey: isMac ? 'Return' : 'Enter',
    );
  }

  static KeyModel _shiftKey(
    DesktopKeyboardPlatform platform, {
    required bool isLeft,
    required double flex,
  }) {
    final isMac = platform == DesktopKeyboardPlatform.macos;
    return KeyModel(
      id: isLeft ? 'shift_left' : 'shift_right',
      label: isMac ? 'shift' : 'Shift',
      type: KeyType.modifier,
      action:
          isLeft ? VirtualKeyAction.leftShift : VirtualKeyAction.rightShift,
      modifierKey: ModifierKey.shift,
      icon: Icons.north_rounded,
      iconBeforeLabel: isLeft,
      iconAfterLabel: !isLeft,
      flex: flex,
    );
  }

  static KeyModel _delKeyFor(DesktopKeyboardPlatform platform) {
    final isMac = platform == DesktopKeyboardPlatform.macos;
    return KeyModel(
      id: 'delete',
      label: isMac ? 'del ⌦' : 'Del',
      type: KeyType.navigation,
      action: VirtualKeyAction.delete,
      logicalKey: LogicalKeyboardKey.delete,
      repeatable: true,
      isDanger: true,
      shortcutKey: 'Del',
    );
  }

  static KeyModel _spaceKey(
    DesktopKeyboardPlatform platform, {
    required double flex,
    String? spaceLabel,
  }) {
    final isMac = platform == DesktopKeyboardPlatform.macos;
    return KeyModel(
      id: 'spacebar',
      label: spaceLabel ?? (isMac ? '' : 'SPACEBAR'),
      value: ' ',
      shiftValue: ' ',
      type: KeyType.space,
      action: VirtualKeyAction.space,
      repeatable: true,
      flex: flex,
      shortcutKey: 'Space',
    );
  }

  // ---- Main Alphanumeric Cluster (100% / 87% TKL: 15.0u each row) -----------

  static List<KeyModel> functionRow({
    DesktopKeyboardPlatform platform = DesktopKeyboardPlatform.windows,
  }) =>
      [
        _escKey(platform, flex: 1.4),
        const KeyModel.spacer(flex: 0.6, id: 'fn_gap_1'),
        for (var i = 1; i <= 4; i++) _fKey(i),
        const KeyModel.spacer(flex: 0.5, id: 'fn_gap_2'),
        for (var i = 5; i <= 8; i++) _fKey(i),
        const KeyModel.spacer(flex: 0.5, id: 'fn_gap_3'),
        for (var i = 9; i <= 12; i++) _fKey(i),
      ];

  static List<KeyModel> numberRow({
    DesktopKeyboardPlatform platform = DesktopKeyboardPlatform.windows,
    String layoutId = 'en_US',
    bool includeFnLayer = false,
  }) {
    final isMac = platform == DesktopKeyboardPlatform.macos;

    // Localized overrides for non-US number rows preserving exact 13u + 2u flex.
    if (layoutId == 'th_TH') {
      const pairs = [
        ('_', '%', 'grave'),
        ('ๅ', '+', 'digit_1'),
        ('/', '๑', 'digit_2'),
        ('-', '๒', 'digit_3'),
        ('ภ', '๓', 'digit_4'),
        ('ถ', '๔', 'digit_5'),
        ('ุ', 'ู', 'digit_6'),
        ('ึ', '฿', 'digit_7'),
        ('ค', '๕', 'digit_8'),
        ('ต', '๖', 'digit_9'),
        ('จ', '๗', 'digit_0'),
        ('ข', '๘', 'minus'),
        ('ช', '๙', 'equal'),
      ];
      return [
        KeyModel.char(
          pairs[0].$1,
          shift: pairs[0].$2,
          id: pairs[0].$3,
          fnLabel: includeFnLayer ? (isMac ? 'esc' : 'Esc') : null,
          fnAction: includeFnLayer ? VirtualKeyAction.escape : null,
          fnLogicalKey: includeFnLayer ? LogicalKeyboardKey.escape : null,
          fnShortcutKey: includeFnLayer ? 'Esc' : null,
        ),
        for (var i = 1; i <= 12; i++)
          KeyModel.char(
            pairs[i].$1,
            shift: pairs[i].$2,
            id: pairs[i].$3,
            fnLabel: includeFnLayer ? 'F$i' : null,
            fnAction: includeFnLayer ? _fKey(i).action : null,
            fnLogicalKey: includeFnLayer ? _fKey(i).logicalKey : null,
            fnShortcutKey: includeFnLayer ? 'F$i' : null,
          ),
        _backspaceKey(platform, includeFnLayer: includeFnLayer),
      ];
    }

    // Zhuyin top number row gives direct access to final symbols `ㄤ`, `ㄥ`, `ㄦ`
    // and tone marks on Shift (`ˊ`, `ˇ`, `ˋ`, `˙`).
    if (layoutId == 'zh_TW') {
      const pairs = [
        ('ㄦ', '~', 'grave'),
        ('1', '!', 'digit_1'),
        ('2', '@', 'digit_2'),
        ('3', 'ˇ', 'digit_3'),
        ('4', 'ˋ', 'digit_4'),
        ('5', '%', 'digit_5'),
        ('6', 'ˊ', 'digit_6'),
        ('7', '˙', 'digit_7'),
        ('8', '*', 'digit_8'),
        ('9', '(', 'digit_9'),
        ('0', ')', 'digit_0'),
        ('ㄤ', '_', 'minus'),
        ('ㄥ', '+', 'equal'),
      ];
      return [
        KeyModel.char(
          pairs[0].$1,
          shift: pairs[0].$2,
          id: pairs[0].$3,
          fnLabel: includeFnLayer ? (isMac ? 'esc' : 'Esc') : null,
          fnAction: includeFnLayer ? VirtualKeyAction.escape : null,
          fnLogicalKey: includeFnLayer ? LogicalKeyboardKey.escape : null,
          fnShortcutKey: includeFnLayer ? 'Esc' : null,
        ),
        for (var i = 1; i <= 12; i++)
          KeyModel.char(
            pairs[i].$1,
            shift: pairs[i].$2,
            id: pairs[i].$3,
            fnLabel: includeFnLayer ? 'F$i' : null,
            fnAction: includeFnLayer ? _fKey(i).action : null,
            fnLogicalKey: includeFnLayer ? _fKey(i).logicalKey : null,
            fnShortcutKey: includeFnLayer ? 'F$i' : null,
          ),
        _backspaceKey(platform, includeFnLayer: includeFnLayer),
      ];
    }

    final digit3Shift = layoutId == 'en_GB' ? '£' : '#';
    final minusChar = layoutId == 'ja_JP' ? 'ー' : '-';
    final equalShift = layoutId == 'ja_JP' ? '¥' : '+';

    return [
      KeyModel.char(
        '`',
        shift: '~',
        id: 'grave',
        fnLabel: includeFnLayer ? (isMac ? 'esc' : 'Esc') : null,
        fnAction: includeFnLayer ? VirtualKeyAction.escape : null,
        fnLogicalKey: includeFnLayer ? LogicalKeyboardKey.escape : null,
        fnShortcutKey: includeFnLayer ? 'Esc' : null,
      ),
      KeyModel.char('1', shift: '!', id: 'digit_1',
          fnLabel: includeFnLayer ? 'F1' : null,
          fnAction: includeFnLayer ? VirtualKeyAction.f1 : null,
          fnLogicalKey: includeFnLayer ? LogicalKeyboardKey.f1 : null,
          fnShortcutKey: includeFnLayer ? 'F1' : null),
      KeyModel.char('2', shift: layoutId == 'en_GB' ? '"' : '@', id: 'digit_2',
          fnLabel: includeFnLayer ? 'F2' : null,
          fnAction: includeFnLayer ? VirtualKeyAction.f2 : null,
          fnLogicalKey: includeFnLayer ? LogicalKeyboardKey.f2 : null,
          fnShortcutKey: includeFnLayer ? 'F2' : null),
      KeyModel.char('3', shift: digit3Shift, id: 'digit_3',
          fnLabel: includeFnLayer ? 'F3' : null,
          fnAction: includeFnLayer ? VirtualKeyAction.f3 : null,
          fnLogicalKey: includeFnLayer ? LogicalKeyboardKey.f3 : null,
          fnShortcutKey: includeFnLayer ? 'F3' : null),
      KeyModel.char('4', shift: r'$', id: 'digit_4',
          fnLabel: includeFnLayer ? 'F4' : null,
          fnAction: includeFnLayer ? VirtualKeyAction.f4 : null,
          fnLogicalKey: includeFnLayer ? LogicalKeyboardKey.f4 : null,
          fnShortcutKey: includeFnLayer ? 'F4' : null),
      KeyModel.char('5', shift: '%', id: 'digit_5',
          fnLabel: includeFnLayer ? 'F5' : null,
          fnAction: includeFnLayer ? VirtualKeyAction.f5 : null,
          fnLogicalKey: includeFnLayer ? LogicalKeyboardKey.f5 : null,
          fnShortcutKey: includeFnLayer ? 'F5' : null),
      KeyModel.char('6', shift: '^', id: 'digit_6',
          fnLabel: includeFnLayer ? 'F6' : null,
          fnAction: includeFnLayer ? VirtualKeyAction.f6 : null,
          fnLogicalKey: includeFnLayer ? LogicalKeyboardKey.f6 : null,
          fnShortcutKey: includeFnLayer ? 'F6' : null),
      KeyModel.char('7', shift: '&', id: 'digit_7',
          fnLabel: includeFnLayer ? 'F7' : null,
          fnAction: includeFnLayer ? VirtualKeyAction.f7 : null,
          fnLogicalKey: includeFnLayer ? LogicalKeyboardKey.f7 : null,
          fnShortcutKey: includeFnLayer ? 'F7' : null),
      KeyModel.char('8', shift: '*', id: 'digit_8',
          fnLabel: includeFnLayer ? 'F8' : null,
          fnAction: includeFnLayer ? VirtualKeyAction.f8 : null,
          fnLogicalKey: includeFnLayer ? LogicalKeyboardKey.f8 : null,
          fnShortcutKey: includeFnLayer ? 'F8' : null),
      KeyModel.char('9', shift: '(', id: 'digit_9',
          fnLabel: includeFnLayer ? 'F9' : null,
          fnAction: includeFnLayer ? VirtualKeyAction.f9 : null,
          fnLogicalKey: includeFnLayer ? LogicalKeyboardKey.f9 : null,
          fnShortcutKey: includeFnLayer ? 'F9' : null),
      KeyModel.char('0', shift: ')', id: 'digit_0',
          fnLabel: includeFnLayer ? 'F10' : null,
          fnAction: includeFnLayer ? VirtualKeyAction.f10 : null,
          fnLogicalKey: includeFnLayer ? LogicalKeyboardKey.f10 : null,
          fnShortcutKey: includeFnLayer ? 'F10' : null),
      KeyModel.char(minusChar, shift: '_', id: 'minus',
          fnLabel: includeFnLayer ? 'F11' : null,
          fnAction: includeFnLayer ? VirtualKeyAction.f11 : null,
          fnLogicalKey: includeFnLayer ? LogicalKeyboardKey.f11 : null,
          fnShortcutKey: includeFnLayer ? 'F11' : null),
      KeyModel.char('=', shift: equalShift, id: 'equal',
          fnLabel: includeFnLayer ? 'F12' : null,
          fnAction: includeFnLayer ? VirtualKeyAction.f12 : null,
          fnLogicalKey: includeFnLayer ? LogicalKeyboardKey.f12 : null,
          fnShortcutKey: includeFnLayer ? 'F12' : null),
      _backspaceKey(platform, includeFnLayer: includeFnLayer),
    ];
  }

  static List<KeyModel> topAlphaRow({
    DesktopKeyboardPlatform platform = DesktopKeyboardPlatform.windows,
    String layoutId = 'en_US',
    bool includeFnArrows = false,
  }) {
    if (layoutId == 'en_US' ||
        layoutId == 'en_GB' ||
        layoutId == 'zh_CN' ||
        layoutId == 'vi_VN') {
      return [
        _tabKey(platform),
        KeyModel.char('q'),
        KeyModel.char(
          'w',
          fnLabel: includeFnArrows ? '▲' : null,
          fnIcon: includeFnArrows ? Icons.keyboard_arrow_up_rounded : null,
          fnAction: includeFnArrows ? VirtualKeyAction.arrowUp : null,
          fnNavIntent: includeFnArrows ? NavIntent.up : null,
          fnShortcutKey: includeFnArrows ? 'Up' : null,
        ),
        KeyModel.char('e'),
        KeyModel.char('r'),
        KeyModel.char('t'),
        KeyModel.char('y'),
        KeyModel.char(
          'u',
          fnLabel: includeFnArrows ? 'Home' : null,
          fnAction: includeFnArrows ? VirtualKeyAction.home : null,
          fnNavIntent: includeFnArrows ? NavIntent.home : null,
          fnShortcutKey: includeFnArrows ? 'Home' : null,
        ),
        KeyModel.char(
          'i',
          fnLabel: includeFnArrows ? 'PgUp' : null,
          fnAction: includeFnArrows ? VirtualKeyAction.pageUp : null,
          fnNavIntent: includeFnArrows ? NavIntent.pageUp : null,
          fnShortcutKey: includeFnArrows ? 'PgUp' : null,
        ),
        KeyModel.char(
          'o',
          fnLabel: includeFnArrows ? 'End' : null,
          fnAction: includeFnArrows ? VirtualKeyAction.end : null,
          fnNavIntent: includeFnArrows ? NavIntent.end : null,
          fnShortcutKey: includeFnArrows ? 'End' : null,
        ),
        KeyModel.char('p'),
        KeyModel.char('[', shift: '{', id: 'bracket_left'),
        KeyModel.char(']', shift: '}', id: 'bracket_right'),
        KeyModel.char(r'\', shift: '|', id: 'backslash', flex: 1.5),
      ];
    }

    if (layoutId == 'ko_KR') {
      return [
        _tabKey(platform),
        KeyModel.char('ㅂ', shift: 'ㅃ', id: 'ko_0'),
        KeyModel.char('ㅈ', shift: 'ㅉ', id: 'ko_1',
            fnLabel: includeFnArrows ? '▲' : null,
            fnIcon: includeFnArrows ? Icons.keyboard_arrow_up_rounded : null,
            fnAction: includeFnArrows ? VirtualKeyAction.arrowUp : null,
            fnNavIntent: includeFnArrows ? NavIntent.up : null),
        KeyModel.char('ㄷ', shift: 'ㄸ', id: 'ko_2'),
        KeyModel.char('ㄱ', shift: 'ㄲ', id: 'ko_3'),
        KeyModel.char('ㅅ', shift: 'ㅆ', id: 'ko_4'),
        KeyModel.char('ㅛ', id: 'ko_5'),
        KeyModel.char('ㅕ', id: 'ko_6'),
        KeyModel.char('ㅑ', id: 'ko_7'),
        KeyModel.char('ㅐ', shift: 'ㅒ', id: 'ko_8'),
        KeyModel.char('ㅔ', shift: 'ㅖ', id: 'ko_9'),
        KeyModel.char('[', shift: '{', id: 'bracket_left'),
        KeyModel.char(']', shift: '}', id: 'bracket_right'),
        KeyModel.char(r'\', shift: '|', id: 'backslash', flex: 1.5),
      ];
    }

    if (layoutId == 'th_TH') {
      const specs = [
        ('ๆ', '๐'),
        ('ไ', '"'),
        ('ำ', 'ฎ'),
        ('พ', 'ฑ'),
        ('ะ', 'ธ'),
        ('ั', 'ํ'),
        ('ี', '๊'),
        ('ร', 'ณ'),
        ('น', 'ฯ'),
        ('ย', 'ญ'),
        ('บ', 'ฐ'),
        ('ล', 'ฅ'),
        ('ฃ', '|'),
      ];
      return [
        _tabKey(platform),
        for (var i = 0; i < 12; i++)
          KeyModel.char(specs[i].$1, shift: specs[i].$2, id: 'top_$i'),
        KeyModel.char(specs[12].$1,
            shift: specs[12].$2, id: 'top_12', flex: 1.5),
      ];
    }

    final (List<String> keys, String? lastShift) = switch (layoutId) {
      'de_DE' => (['q', 'w', 'e', 'r', 't', 'z', 'u', 'i', 'o', 'p', 'ü', '+', '#'], "'"),
      'fr_FR' => (['a', 'z', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '^', r'$', '*'], 'µ'),
      'es_ES' => (['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', r'\', '+', 'ç'], null),
      'nordic' => (['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', 'å', '¨', "'"], '*'),
      'tr_TR' => (['q', 'w', 'e', 'r', 't', 'y', 'u', 'ı', 'o', 'p', 'ğ', 'ü', ','], ';'),
      'ru_RU' => (['й', 'ц', 'у', 'к', 'е', 'н', 'г', 'ш', 'щ', 'з', 'х', 'ъ', r'\'], '/'),
      'el_GR' => ([';', 'ς', 'ε', 'ρ', 'τ', 'υ', 'θ', 'ι', 'ο', 'π', '[', ']', r'\'], '|'),
      'ja_JP' => (['た', 'て', 'い', 'す', 'か', 'ん', 'な', 'に', 'ら', 'せ', '゛', '゜', 'む'], '「'),
      'zh_TW' => (['ㄅ', 'ㄆ', 'ㄇ', 'ㄈ', 'ㄉ', 'ㄊ', 'ㄋ', 'ㄌ', 'ㄍ', 'ㄎ', 'ㄏ', 'ㄐ', 'ㄑ'], null),
      _ => (['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', r'\'], '|'),
    };

    return [
      _tabKey(platform),
      for (var i = 0; i < 12; i++)
        KeyModel.char(
          keys[i],
          id: 'top_$i',
          shift: layoutId == 'el_GR' && i == 0
              ? ':'
              : (layoutId == 'ja_JP' && keys[i] == 'い' ? 'ぃ' : null),
          fnLabel: includeFnArrows && i == 1 ? '▲' : null,
          fnIcon: includeFnArrows && i == 1
              ? Icons.keyboard_arrow_up_rounded
              : null,
          fnAction: includeFnArrows && i == 1 ? VirtualKeyAction.arrowUp : null,
          fnNavIntent: includeFnArrows && i == 1 ? NavIntent.up : null,
        ),
      KeyModel.char(
        keys[12],
        shift: lastShift,
        id: 'top_12',
        flex: 1.5,
      ),
    ];
  }

  static List<KeyModel> homeAlphaRow({
    DesktopKeyboardPlatform platform = DesktopKeyboardPlatform.windows,
    String layoutId = 'en_US',
    bool includeFnArrows = false,
  }) {
    if (layoutId == 'en_US' ||
        layoutId == 'en_GB' ||
        layoutId == 'zh_CN' ||
        layoutId == 'vi_VN') {
      return [
        _capsKey(platform),
        KeyModel.char(
          'a',
          fnLabel: includeFnArrows ? '◀' : null,
          fnIcon: includeFnArrows ? Icons.keyboard_arrow_left_rounded : null,
          fnAction: includeFnArrows ? VirtualKeyAction.arrowLeft : null,
          fnNavIntent: includeFnArrows ? NavIntent.left : null,
          fnShortcutKey: includeFnArrows ? 'Left' : null,
        ),
        KeyModel.char(
          's',
          fnLabel: includeFnArrows ? '▼' : null,
          fnIcon: includeFnArrows ? Icons.keyboard_arrow_down_rounded : null,
          fnAction: includeFnArrows ? VirtualKeyAction.arrowDown : null,
          fnNavIntent: includeFnArrows ? NavIntent.down : null,
          fnShortcutKey: includeFnArrows ? 'Down' : null,
        ),
        KeyModel.char(
          'd',
          fnLabel: includeFnArrows ? '▶' : null,
          fnIcon: includeFnArrows ? Icons.keyboard_arrow_right_rounded : null,
          fnAction: includeFnArrows ? VirtualKeyAction.arrowRight : null,
          fnNavIntent: includeFnArrows ? NavIntent.right : null,
          fnShortcutKey: includeFnArrows ? 'Right' : null,
        ),
        KeyModel.char('f'),
        KeyModel.char('g'),
        KeyModel.char('h'),
        KeyModel.char('j'),
        KeyModel.char(
          'k',
          fnLabel: includeFnArrows ? 'PgDn' : null,
          fnAction: includeFnArrows ? VirtualKeyAction.pageDown : null,
          fnNavIntent: includeFnArrows ? NavIntent.pageDown : null,
          fnShortcutKey: includeFnArrows ? 'PgDn' : null,
        ),
        KeyModel.char('l'),
        KeyModel.char(';', shift: ':', id: 'semicolon'),
        KeyModel.char("'", shift: '"', id: 'quote'),
        _enterKey(platform),
      ];
    }

    if (layoutId == 'th_TH') {
      const specs = [
        ('ฟ', 'ฤ'),
        ('ห', 'ฆ'),
        ('ก', 'ฏ'),
        ('ด', 'โ'),
        ('เ', 'ฌ'),
        ('้', '็'),
        ('่', '๋'),
        ('า', 'ษ'),
        ('ส', 'ศ'),
        ('ว', 'ซ'),
        ('ง', '.'),
      ];
      return [
        _capsKey(platform),
        for (var i = 0; i < 11; i++)
          KeyModel.char(specs[i].$1, shift: specs[i].$2, id: 'home_$i'),
        _enterKey(platform),
      ];
    }

    final List<String> keys = switch (layoutId) {
      'de_DE' => ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'ö', 'ä'],
      'fr_FR' => ['q', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'ù'],
      'es_ES' => ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'ñ', '{'],
      'nordic' => ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'ö', 'ä'],
      'tr_TR' => ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'ş', 'i'],
      'ru_RU' => ['ф', 'ы', 'в', 'а', 'п', 'р', 'о', 'л', 'д', 'ж', 'э'],
      'el_GR' => ['α', 'σ', 'δ', 'φ', 'γ', 'η', 'ξ', 'κ', 'λ', '´', "'"],
      'ko_KR' => ['ㅁ', 'ㄴ', 'ㅇ', 'ㄹ', 'ㅎ', 'ㅗ', 'ㅓ', 'ㅏ', 'ㅣ', ';', "'"],
      'ja_JP' => ['ち', 'と', 'し', 'は', 'き', 'く', 'ま', 'の', 'り', 'れ', 'け'],
      'zh_TW' => ['ㄒ', 'ㄓ', 'ㄔ', 'ㄕ', 'ㄖ', 'ㄗ', 'ㄘ', 'ㄙ', 'ㄧ', 'ㄨ', 'ㄩ'],
      _ => ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', "'"],
    };

    return [
      _capsKey(platform),
      for (var i = 0; i < 11; i++)
        KeyModel.char(
          keys[i],
          id: 'home_$i',
          shift: layoutId == 'tr_TR' && keys[i] == 'i'
              ? 'İ'
              : (keys[i] == ';' ? ':' : (keys[i] == "'" ? '"' : null)),
          fnLabel: includeFnArrows && i == 0
              ? '◀'
              : (includeFnArrows && i == 1
                  ? '▼'
                  : (includeFnArrows && i == 2 ? '▶' : null)),
          fnIcon: includeFnArrows && i == 0
              ? Icons.keyboard_arrow_left_rounded
              : (includeFnArrows && i == 1
                  ? Icons.keyboard_arrow_down_rounded
                  : (includeFnArrows && i == 2
                      ? Icons.keyboard_arrow_right_rounded
                      : null)),
          fnAction: includeFnArrows && i == 0
              ? VirtualKeyAction.arrowLeft
              : (includeFnArrows && i == 1
                  ? VirtualKeyAction.arrowDown
                  : (includeFnArrows && i == 2
                      ? VirtualKeyAction.arrowRight
                      : null)),
          fnNavIntent: includeFnArrows && i == 0
              ? NavIntent.left
              : (includeFnArrows && i == 1
                  ? NavIntent.down
                  : (includeFnArrows && i == 2 ? NavIntent.right : null)),
        ),
      _enterKey(platform),
    ];
  }

  /// Resolves the 10 character/punctuation keys inside the Shift row (exact 10.0u).
  static List<KeyModel> _localizedBottomKeys(String layoutId) {
    if (layoutId == 'zh_CN') {
      return [
        for (final c in const ['z', 'x', 'c', 'v', 'b', 'n', 'm'])
          KeyModel.char(c),
        KeyModel.char('，', shift: '<', id: 'comma'),
        KeyModel.char('。', shift: '>', id: 'period'),
        KeyModel.char('/', shift: '?', id: 'slash'),
      ];
    }

    if (layoutId == 'th_TH') {
      const specs = [
        ('ผ', '('),
        ('ป', ')'),
        ('แ', 'ฉ'),
        ('อ', 'ฮ'),
        ('ิ', 'ฺ'),
        ('ื', '์'),
        ('ท', '?'),
        ('ม', 'ฒ'),
        ('ใ', 'ฬ'),
        ('ฝ', 'ฦ'),
      ];
      return [
        for (var i = 0; i < 10; i++)
          KeyModel.char(specs[i].$1, shift: specs[i].$2, id: 'bot_$i'),
      ];
    }

    final (List<String> keys, List<String?> shifts) = switch (layoutId) {
      'de_DE' => (['y', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '-'], [null, null, null, null, null, null, null, ';', ':', '_']),
      'fr_FR' => (['w', 'x', 'c', 'v', 'b', 'n', ',', ';', ':', '!'], [null, null, null, null, null, null, '?', '.', '/', '§']),
      'es_ES' || 'nordic' => (['z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '-'], [null, null, null, null, null, null, null, ';', ':', '_']),
      'tr_TR' => (['z', 'x', 'c', 'v', 'b', 'n', 'm', 'ö', 'ç', '.'], [null, null, null, null, null, null, null, 'Ö', 'Ç', ':']),
      'ru_RU' => (['я', 'ч', 'с', 'м', 'и', 'т', 'ь', 'б', 'ю', '.'], ['Я', 'Ч', 'С', 'М', 'И', 'Т', 'Ь', 'Б', 'Ю', ',']),
      'ko_KR' => (['ㅋ', 'ㅌ', 'ㅊ', 'ㅍ', 'ㅠ', 'ㅜ', 'ㅡ', ',', '.', '/'], [null, null, null, null, null, null, null, '<', '>', '?']),
      'ja_JP' => (['つ', 'さ', 'そ', 'ひ', 'こ', 'み', 'も', 'ね', 'る', 'め'], ['っ', null, null, null, null, null, null, '、', '。', 'ろ']),
      'zh_TW' => (['ㄚ', 'ㄛ', 'ㄜ', 'ㄝ', 'ㄞ', 'ㄟ', 'ㄠ', 'ㄡ', 'ㄢ', 'ㄣ'], [null, null, null, null, null, null, null, null, null, null]),
      'el_GR' => (['ζ', 'χ', 'ψ', 'ω', 'β', 'ν', 'μ', ',', '.', '/'], ['Ζ', 'Χ', 'Ψ', 'Ω', 'Β', 'Ν', 'Μ', '<', '>', '?']),
      _ => (['z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/'], [null, null, null, null, null, null, null, '<', '>', '?']),
    };

    return [
      for (var i = 0; i < 10; i++)
        KeyModel.char(
          keys[i],
          shift: shifts[i],
          id: i == 7
              ? 'comma'
              : (i == 8 ? 'period' : (i == 9 ? 'slash' : null)),
        ),
    ];
  }

  static List<KeyModel> bottomAlphaRow({
    DesktopKeyboardPlatform platform = DesktopKeyboardPlatform.windows,
    String layoutId = 'en_US',
  }) =>
      [
        _shiftKey(platform, isLeft: true, flex: 2.25),
        ..._localizedBottomKeys(layoutId),
        _shiftKey(platform, isLeft: false, flex: 2.75),
      ];

  /// Bottom control row (15.0u total) tailored for either Windows or macOS modifier conventions.
  static List<KeyModel> bottomControlRow({
    DesktopKeyboardPlatform platform = DesktopKeyboardPlatform.windows,
    String? spaceLabel,
  }) {
    if (platform == DesktopKeyboardPlatform.macos) {
      return [
        const KeyModel(
          id: 'fn_key',
          label: 'fn',
          shiftLabel: '🌐',
          type: KeyType.modifier,
          action: VirtualKeyAction.fn,
          flex: 1.15,
        ),
        const KeyModel(
          id: 'ctrl_left',
          label: 'control',
          shiftLabel: '⌃',
          type: KeyType.modifier,
          action: VirtualKeyAction.leftCtrl,
          modifierKey: ModifierKey.control,
          flex: 1.2,
        ),
        const KeyModel(
          id: 'alt_left',
          label: 'option',
          shiftLabel: '⌥',
          type: KeyType.modifier,
          action: VirtualKeyAction.leftAlt,
          modifierKey: ModifierKey.alt,
          flex: 1.2,
        ),
        const KeyModel(
          id: 'cmd_left',
          label: 'command',
          shiftLabel: '⌘',
          type: KeyType.modifier,
          action: VirtualKeyAction.leftCommand,
          modifierKey: ModifierKey.meta,
          flex: 1.45,
        ),
        _spaceKey(platform, flex: 5.85, spaceLabel: spaceLabel),
        const KeyModel(
          id: 'cmd_right',
          label: 'command',
          shiftLabel: '⌘',
          type: KeyType.modifier,
          action: VirtualKeyAction.rightCommand,
          modifierKey: ModifierKey.meta,
          flex: 1.45,
        ),
        const KeyModel(
          id: 'opt_right',
          label: 'option',
          shiftLabel: '⌥',
          type: KeyType.modifier,
          action: VirtualKeyAction.rightOption,
          modifierKey: ModifierKey.alt,
          flex: 1.35,
        ),
        const KeyModel(
          id: 'ctrl_right',
          label: 'control',
          shiftLabel: '⌃',
          type: KeyType.modifier,
          action: VirtualKeyAction.rightCtrl,
          modifierKey: ModifierKey.control,
          flex: 1.35,
        ),
      ];
    }

    return [
      const KeyModel(
        id: 'ctrl_left',
        label: 'Ctrl',
        type: KeyType.modifier,
        action: VirtualKeyAction.leftCtrl,
        modifierKey: ModifierKey.control,
        flex: 1.25,
      ),
      const KeyModel(
        id: 'win_super',
        label: 'Win',
        type: KeyType.modifier,
        action: VirtualKeyAction.winSuper,
        modifierKey: ModifierKey.meta,
        icon: Icons.window_rounded,
        flex: 1.2,
      ),
      const KeyModel(
        id: 'alt_left',
        label: 'Alt',
        type: KeyType.modifier,
        action: VirtualKeyAction.leftAlt,
        modifierKey: ModifierKey.alt,
        flex: 1.2,
      ),
      _spaceKey(platform, flex: 6.1, spaceLabel: spaceLabel),
      const KeyModel(
        id: 'alt_gr',
        label: 'AltGr',
        type: KeyType.modifier,
        action: VirtualKeyAction.altGr,
        modifierKey: ModifierKey.altGr,
        flex: 1.35,
      ),
      const KeyModel(
        id: 'fn_key',
        label: 'Fn',
        type: KeyType.modifier,
        action: VirtualKeyAction.fn,
        flex: 1.15,
      ),
      const KeyModel(
        id: 'menu_key',
        label: 'Menu',
        type: KeyType.action,
        action: VirtualKeyAction.menu,
        logicalKey: LogicalKeyboardKey.contextMenu,
        icon: Icons.menu_rounded,
        flex: 1.15,
      ),
      const KeyModel(
        id: 'ctrl_right',
        label: 'Ctrl',
        type: KeyType.modifier,
        action: VirtualKeyAction.rightCtrl,
        modifierKey: ModifierKey.control,
        flex: 1.6,
      ),
    ];
  }

  // ---- Navigation Cluster (100% / 87% TKL: 3.0u each row) -----------------

  static List<KeyModel> navSystemRow({
    DesktopKeyboardPlatform platform = DesktopKeyboardPlatform.windows,
  }) {
    if (platform == DesktopKeyboardPlatform.macos) {
      return const [
        KeyModel(
          id: 'f13',
          label: 'F13',
          type: KeyType.function,
          action: VirtualKeyAction.f13,
          logicalKey: LogicalKeyboardKey.f13,
          shortcutKey: 'F13',
        ),
        KeyModel(
          id: 'f14',
          label: 'F14',
          type: KeyType.function,
          action: VirtualKeyAction.f14,
          logicalKey: LogicalKeyboardKey.f14,
          shortcutKey: 'F14',
        ),
        KeyModel(
          id: 'f15',
          label: 'F15',
          type: KeyType.function,
          action: VirtualKeyAction.f15,
          logicalKey: LogicalKeyboardKey.f15,
          shortcutKey: 'F15',
        ),
      ];
    }

    return const [
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
  }

  static List<KeyModel> navTopEditRow({
    DesktopKeyboardPlatform platform = DesktopKeyboardPlatform.windows,
  }) =>
      [
        KeyModel(
          id: 'insert',
          label: platform == DesktopKeyboardPlatform.macos ? 'fn' : 'Ins',
          type: platform == DesktopKeyboardPlatform.macos
              ? KeyType.modifier
              : KeyType.navigation,
          action: platform == DesktopKeyboardPlatform.macos
              ? VirtualKeyAction.fn
              : VirtualKeyAction.insert,
          logicalKey: platform == DesktopKeyboardPlatform.macos
              ? null
              : LogicalKeyboardKey.insert,
          shortcutKey:
              platform == DesktopKeyboardPlatform.macos ? 'Fn' : 'Ins',
        ),
        _homeKey,
        _pgUpKey,
      ];

  static List<KeyModel> navBottomEditRow({
    DesktopKeyboardPlatform platform = DesktopKeyboardPlatform.windows,
  }) =>
      [
        _delKeyFor(platform),
        _endKey,
        _pgDnKey,
      ];

  static List<KeyModel> navEmptyRow() => const [
        KeyModel.spacer(flex: 3.0, id: 'nav_empty'),
      ];

  static List<KeyModel> navArrowUpRow() => const [
        KeyModel.spacer(flex: 1.0, id: 'arrow_up_l'),
        _arrowUpKey,
        KeyModel.spacer(flex: 1.0, id: 'arrow_up_r'),
      ];

  static List<KeyModel> navArrowBottomRow() => const [
        _arrowLeftKey,
        _arrowDownKey,
        _arrowRightKey,
      ];

  // ---- Numpad Cluster (4.0u total width) ------------------------------------

  static List<KeyModel> numpadTopRow({
    DesktopKeyboardPlatform platform = DesktopKeyboardPlatform.windows,
  }) =>
      [
        KeyModel(
          id: 'num_lock',
          label: platform == DesktopKeyboardPlatform.macos ? 'clear' : 'Num',
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

  // ---- Factory Builders for Compact Presets (60%, 65%, 75%, 98%) ------------

  static const _arrowUpKey = KeyModel(
    id: 'arrow_up',
    label: 'Up',
    type: KeyType.navigation,
    action: VirtualKeyAction.arrowUp,
    navIntent: NavIntent.up,
    icon: Icons.keyboard_arrow_up_rounded,
    repeatable: true,
    shortcutKey: 'Up',
  );

  static const _arrowDownKey = KeyModel(
    id: 'arrow_down',
    label: 'Down',
    type: KeyType.navigation,
    action: VirtualKeyAction.arrowDown,
    navIntent: NavIntent.down,
    icon: Icons.keyboard_arrow_down_rounded,
    repeatable: true,
    shortcutKey: 'Down',
  );

  static const _arrowLeftKey = KeyModel(
    id: 'arrow_left',
    label: 'Left',
    type: KeyType.navigation,
    action: VirtualKeyAction.arrowLeft,
    navIntent: NavIntent.left,
    icon: Icons.keyboard_arrow_left_rounded,
    repeatable: true,
    shortcutKey: 'Left',
  );

  static const _arrowRightKey = KeyModel(
    id: 'arrow_right',
    label: 'Right',
    type: KeyType.navigation,
    action: VirtualKeyAction.arrowRight,
    navIntent: NavIntent.right,
    icon: Icons.keyboard_arrow_right_rounded,
    repeatable: true,
    shortcutKey: 'Right',
  );

  static const _homeKey = KeyModel(
    id: 'home',
    label: 'Home',
    type: KeyType.navigation,
    action: VirtualKeyAction.home,
    navIntent: NavIntent.home,
    shortcutKey: 'Home',
  );

  static const _endKey = KeyModel(
    id: 'end',
    label: 'End',
    type: KeyType.navigation,
    action: VirtualKeyAction.end,
    navIntent: NavIntent.end,
    shortcutKey: 'End',
  );

  static const _pgUpKey = KeyModel(
    id: 'pgup',
    label: 'PgUp',
    type: KeyType.navigation,
    action: VirtualKeyAction.pageUp,
    navIntent: NavIntent.pageUp,
    shortcutKey: 'PgUp',
  );

  static const _pgDnKey = KeyModel(
    id: 'pgdn',
    label: 'PgDn',
    type: KeyType.navigation,
    action: VirtualKeyAction.pageDown,
    navIntent: NavIntent.pageDown,
    shortcutKey: 'PgDn',
  );

  static const _insKey = KeyModel(
    id: 'insert',
    label: 'Ins',
    type: KeyType.navigation,
    action: VirtualKeyAction.insert,
    logicalKey: LogicalKeyboardKey.insert,
    shortcutKey: 'Ins',
  );

  /// **60% Compact Layout (15.0u, 5 rows)**: Pure alphanumeric rows + `Fn` layer
  /// supporting `Esc`, `F1`–`F12`, `Del`, navigation, and directional arrows.
  static List<List<KeyModel>> layout60Rows({
    DesktopKeyboardPlatform platform = DesktopKeyboardPlatform.windows,
    String layoutId = 'en_US',
    String? spaceLabel,
  }) =>
      [
        numberRow(platform: platform, includeFnLayer: true, layoutId: layoutId),
        topAlphaRow(
          platform: platform,
          includeFnArrows: true,
          layoutId: layoutId,
        ),
        homeAlphaRow(
          platform: platform,
          includeFnArrows: true,
          layoutId: layoutId,
        ),
        bottomAlphaRow(platform: platform, layoutId: layoutId),
        bottomControlRow(platform: platform, spaceLabel: spaceLabel),
      ];

  /// Bottom modifier row + arrows for 16u presets (`layout65`, `layout75`).
  static List<KeyModel> _compact16ControlWithArrowsRow(
    DesktopKeyboardPlatform platform, {
    String? spaceLabel,
  }) {
    if (platform == DesktopKeyboardPlatform.macos) {
      return [
        const KeyModel(
          id: 'fn_key',
          label: 'fn',
          shiftLabel: '🌐',
          type: KeyType.modifier,
          action: VirtualKeyAction.fn,
          flex: 1.0,
        ),
        const KeyModel(
          id: 'ctrl_left',
          label: 'ctrl',
          shiftLabel: '⌃',
          type: KeyType.modifier,
          action: VirtualKeyAction.leftCtrl,
          modifierKey: ModifierKey.control,
          flex: 1.1,
        ),
        const KeyModel(
          id: 'alt_left',
          label: 'opt',
          shiftLabel: '⌥',
          type: KeyType.modifier,
          action: VirtualKeyAction.leftAlt,
          modifierKey: ModifierKey.alt,
          flex: 1.1,
        ),
        const KeyModel(
          id: 'cmd_left',
          label: 'cmd',
          shiftLabel: '⌘',
          type: KeyType.modifier,
          action: VirtualKeyAction.leftCommand,
          modifierKey: ModifierKey.meta,
          flex: 1.35,
        ),
        _spaceKey(platform, flex: 6.05, spaceLabel: spaceLabel),
        const KeyModel(
          id: 'cmd_right',
          label: 'cmd',
          shiftLabel: '⌘',
          type: KeyType.modifier,
          action: VirtualKeyAction.rightCommand,
          modifierKey: ModifierKey.meta,
          flex: 1.3,
        ),
        const KeyModel(
          id: 'opt_right',
          label: 'opt',
          shiftLabel: '⌥',
          type: KeyType.modifier,
          action: VirtualKeyAction.rightOption,
          modifierKey: ModifierKey.alt,
          flex: 1.1,
        ),
        _arrowLeftKey,
        _arrowDownKey,
        _arrowRightKey,
      ];
    }

    return [
      const KeyModel(
        id: 'ctrl_left',
        label: 'Ctrl',
        type: KeyType.modifier,
        action: VirtualKeyAction.leftCtrl,
        modifierKey: ModifierKey.control,
        flex: 1.25,
      ),
      const KeyModel(
        id: 'win_super',
        label: 'Win',
        type: KeyType.modifier,
        action: VirtualKeyAction.winSuper,
        modifierKey: ModifierKey.meta,
        icon: Icons.window_rounded,
        flex: 1.25,
      ),
      const KeyModel(
        id: 'alt_left',
        label: 'Alt',
        type: KeyType.modifier,
        action: VirtualKeyAction.leftAlt,
        modifierKey: ModifierKey.alt,
        flex: 1.25,
      ),
      _spaceKey(platform, flex: 6.25, spaceLabel: spaceLabel),
      const KeyModel(
        id: 'alt_gr',
        label: 'AltGr',
        type: KeyType.modifier,
        action: VirtualKeyAction.altGr,
        modifierKey: ModifierKey.altGr,
        flex: 1.0,
      ),
      const KeyModel(
        id: 'fn_key',
        label: 'Fn',
        type: KeyType.modifier,
        action: VirtualKeyAction.fn,
        flex: 1.0,
      ),
      const KeyModel(
        id: 'ctrl_right',
        label: 'Ctrl',
        type: KeyType.modifier,
        action: VirtualKeyAction.rightCtrl,
        modifierKey: ModifierKey.control,
        flex: 1.0,
      ),
      _arrowLeftKey,
      _arrowDownKey,
      _arrowRightKey,
    ];
  }

  /// **65% Compact Layout (16.0u, 5 rows)**: Hides top F-row and Numpad; integrates
  /// directional arrows and a 1-column right navigation rail (`Del`, `PgUp`, `PgDn`, `Home`).
  static List<List<KeyModel>> layout65Rows({
    DesktopKeyboardPlatform platform = DesktopKeyboardPlatform.windows,
    String layoutId = 'en_US',
    String? spaceLabel,
  }) =>
      [
        [
          ...numberRow(
            platform: platform,
            includeFnLayer: true,
            layoutId: layoutId,
          ),
          _delKeyFor(platform),
        ],
        [...topAlphaRow(platform: platform, layoutId: layoutId), _pgUpKey],
        [...homeAlphaRow(platform: platform, layoutId: layoutId), _pgDnKey],
        [
          _shiftKey(platform, isLeft: true, flex: 2.25),
          ..._localizedBottomKeys(layoutId),
          _shiftKey(platform, isLeft: false, flex: 1.75),
          _arrowUpKey,
          _homeKey,
        ],
        _compact16ControlWithArrowsRow(platform, spaceLabel: spaceLabel),
      ];

  /// **75% Compact Layout (16.0u, 6 rows)**: Keeps top F-row, hides Numpad,
  /// compresses nav into a single right column (`Del`, `Home`, `PgUp`, `PgDn`, `End`),
  /// and tucks arrows tightly under Right Shift.
  static List<List<KeyModel>> layout75Rows({
    DesktopKeyboardPlatform platform = DesktopKeyboardPlatform.windows,
    bool includeFunctionRow = true,
    String layoutId = 'en_US',
    String? spaceLabel,
  }) {
    final isMac = platform == DesktopKeyboardPlatform.macos;
    return [
      if (includeFunctionRow)
        [
          _escKey(platform, flex: 1.0),
          const KeyModel.spacer(flex: 0.25, id: 'fn75_gap_1'),
          for (var i = 1; i <= 4; i++) _fKey(i),
          const KeyModel.spacer(flex: 0.25, id: 'fn75_gap_2'),
          for (var i = 5; i <= 8; i++) _fKey(i),
          const KeyModel.spacer(flex: 0.25, id: 'fn75_gap_3'),
          for (var i = 9; i <= 12; i++) _fKey(i),
          KeyModel(
            id: isMac ? 'f13' : 'prtsc',
            label: isMac ? 'F13' : 'PrtSc',
            type: KeyType.function,
            action:
                isMac ? VirtualKeyAction.f13 : VirtualKeyAction.printScreen,
            logicalKey: isMac
                ? LogicalKeyboardKey.f13
                : LogicalKeyboardKey.printScreen,
            shortcutKey: isMac ? 'F13' : 'PrtSc',
            flex: 1.25,
          ),
          _delKeyFor(platform),
        ],
      [...numberRow(platform: platform, layoutId: layoutId), _homeKey],
      [...topAlphaRow(platform: platform, layoutId: layoutId), _pgUpKey],
      [...homeAlphaRow(platform: platform, layoutId: layoutId), _pgDnKey],
      [
        _shiftKey(platform, isLeft: true, flex: 2.25),
        ..._localizedBottomKeys(layoutId),
        _shiftKey(platform, isLeft: false, flex: 1.75),
        _arrowUpKey,
        _endKey,
      ],
      _compact16ControlWithArrowsRow(platform, spaceLabel: spaceLabel),
    ];
  }

  /// **98% Compact 1800-Style Left Block (15.0u)**: Compact arrows tucked tightly
  /// flush next to the 4-column Numpad (zero inter-cluster gap).
  static List<List<KeyModel>> layout98MainRows({
    DesktopKeyboardPlatform platform = DesktopKeyboardPlatform.windows,
    bool includeFunctionRow = true,
    String layoutId = 'en_US',
    String? spaceLabel,
  }) {
    final isMac = platform == DesktopKeyboardPlatform.macos;
    return [
      if (includeFunctionRow)
        [
          _escKey(platform, flex: 1.2),
          const KeyModel.spacer(flex: 0.3, id: 'fn98_gap_1'),
          for (var i = 1; i <= 4; i++) _fKey(i),
          const KeyModel.spacer(flex: 0.25, id: 'fn98_gap_2'),
          for (var i = 5; i <= 8; i++) _fKey(i),
          const KeyModel.spacer(flex: 0.25, id: 'fn98_gap_3'),
          for (var i = 9; i <= 12; i++) _fKey(i),
          KeyModel(
            id: isMac ? 'f13' : 'prtsc',
            label: isMac ? 'F13' : 'PrtSc',
            type: KeyType.function,
            action:
                isMac ? VirtualKeyAction.f13 : VirtualKeyAction.printScreen,
            logicalKey: isMac
                ? LogicalKeyboardKey.f13
                : LogicalKeyboardKey.printScreen,
            shortcutKey: isMac ? 'F13' : 'PrtSc',
            flex: 1.0,
          ),
        ],
      numberRow(platform: platform, layoutId: layoutId),
      topAlphaRow(platform: platform, layoutId: layoutId),
      homeAlphaRow(platform: platform, layoutId: layoutId),
      [
        _shiftKey(platform, isLeft: true, flex: 1.75),
        ..._localizedBottomKeys(layoutId),
        _shiftKey(platform, isLeft: false, flex: 1.25),
        _arrowUpKey,
        _pgDnKey,
      ],
      if (isMac)
        [
          const KeyModel(
            id: 'fn_key',
            label: 'fn',
            shiftLabel: '🌐',
            type: KeyType.modifier,
            action: VirtualKeyAction.fn,
            flex: 1.0,
          ),
          const KeyModel(
            id: 'ctrl_left',
            label: 'ctrl',
            shiftLabel: '⌃',
            type: KeyType.modifier,
            action: VirtualKeyAction.leftCtrl,
            modifierKey: ModifierKey.control,
            flex: 1.0,
          ),
          const KeyModel(
            id: 'alt_left',
            label: 'opt',
            shiftLabel: '⌥',
            type: KeyType.modifier,
            action: VirtualKeyAction.leftAlt,
            modifierKey: ModifierKey.alt,
            flex: 1.0,
          ),
          const KeyModel(
            id: 'cmd_left',
            label: 'cmd',
            shiftLabel: '⌘',
            type: KeyType.modifier,
            action: VirtualKeyAction.leftCommand,
            modifierKey: ModifierKey.meta,
            flex: 1.25,
          ),
          _spaceKey(platform, flex: 5.55, spaceLabel: spaceLabel),
          const KeyModel(
            id: 'cmd_right',
            label: 'cmd',
            shiftLabel: '⌘',
            type: KeyType.modifier,
            action: VirtualKeyAction.rightCommand,
            modifierKey: ModifierKey.meta,
            flex: 1.2,
          ),
          const KeyModel(
            id: 'opt_right',
            label: 'opt',
            shiftLabel: '⌥',
            type: KeyType.modifier,
            action: VirtualKeyAction.rightOption,
            modifierKey: ModifierKey.alt,
            flex: 1.0,
          ),
          _arrowLeftKey,
          _arrowDownKey,
          _arrowRightKey,
        ]
      else
        [
          const KeyModel(
            id: 'ctrl_left',
            label: 'Ctrl',
            type: KeyType.modifier,
            action: VirtualKeyAction.leftCtrl,
            modifierKey: ModifierKey.control,
            flex: 1.25,
          ),
          const KeyModel(
            id: 'win_super',
            label: 'Win',
            type: KeyType.modifier,
            action: VirtualKeyAction.winSuper,
            modifierKey: ModifierKey.meta,
            icon: Icons.window_rounded,
            flex: 1.0,
          ),
          const KeyModel(
            id: 'alt_left',
            label: 'Alt',
            type: KeyType.modifier,
            action: VirtualKeyAction.leftAlt,
            modifierKey: ModifierKey.alt,
            flex: 1.0,
          ),
          _spaceKey(platform, flex: 5.75, spaceLabel: spaceLabel),
          const KeyModel(
            id: 'alt_gr',
            label: 'AltGr',
            type: KeyType.modifier,
            action: VirtualKeyAction.altGr,
            modifierKey: ModifierKey.altGr,
            flex: 1.0,
          ),
          const KeyModel(
            id: 'fn_key',
            label: 'Fn',
            type: KeyType.modifier,
            action: VirtualKeyAction.fn,
            flex: 1.0,
          ),
          const KeyModel(
            id: 'ctrl_right',
            label: 'Ctrl',
            type: KeyType.modifier,
            action: VirtualKeyAction.rightCtrl,
            modifierKey: ModifierKey.control,
            flex: 1.0,
          ),
          _arrowLeftKey,
          _arrowDownKey,
          _arrowRightKey,
        ],
    ];
  }

  /// **98% Top Utility Strip (4.0u)**: Compact navigation/edit keys positioned
  /// directly above the 4-column Numpad (`Ins`, `Del`, `Home`, `PgUp`).
  static List<KeyModel> layout98NumpadUtilityRow({
    DesktopKeyboardPlatform platform = DesktopKeyboardPlatform.windows,
  }) =>
      [
        if (platform == DesktopKeyboardPlatform.macos)
          const KeyModel(
            id: 'f14',
            label: 'F14',
            type: KeyType.function,
            action: VirtualKeyAction.f14,
            logicalKey: LogicalKeyboardKey.f14,
            shortcutKey: 'F14',
          )
        else
          _insKey,
        _delKeyFor(platform),
        _homeKey,
        _pgUpKey,
      ];
}
