import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Resolves developer-registered keyboard shortcuts.
///
/// Works for both the virtual keyboard (modifier state tracked by
/// [KeyboardModifierController]) and a hardware keyboard, since both ultimately
/// produce a set of pressed [LogicalKeyboardKey]s.
///
/// ```dart
/// KeyboardShortcutManager({
///   LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): save,
/// })
/// ```
@immutable
class KeyboardShortcutManager {
  const KeyboardShortcutManager([this.shortcuts = const {}]);

  final Map<LogicalKeySet, VoidCallback> shortcuts;

  /// Returns the callback whose key-set exactly matches [pressed], or null.
  VoidCallback? match(Set<LogicalKeyboardKey> pressed) {
    if (pressed.isEmpty) return null;
    for (final entry in shortcuts.entries) {
      if (setEquals(entry.key.keys, pressed)) return entry.value;
    }
    return null;
  }

  /// Builds the pressed-key set from armed [modifiers] plus the [trigger] key.
  static Set<LogicalKeyboardKey> pressedSet(
    Set<LogicalKeyboardKey> modifiers,
    LogicalKeyboardKey trigger,
  ) =>
      {...modifiers, trigger};

  KeyboardShortcutManager merge(KeyboardShortcutManager other) =>
      KeyboardShortcutManager({...shortcuts, ...other.shortcuts});
}

/// Maps a single character to a [LogicalKeyboardKey] for shortcut matching
/// (letters and digits — enough for the common Ctrl/Alt combos).
LogicalKeyboardKey? logicalKeyForChar(String char) {
  if (char.isEmpty) return null;
  final c = char.toLowerCase();
  final code = c.codeUnitAt(0);
  // a-z
  if (code >= 0x61 && code <= 0x7A) {
    return LogicalKeyboardKey(LogicalKeyboardKey.keyA.keyId + (code - 0x61));
  }
  // 0-9
  if (code >= 0x30 && code <= 0x39) {
    return LogicalKeyboardKey(LogicalKeyboardKey.digit0.keyId + (code - 0x30));
  }
  return null;
}
