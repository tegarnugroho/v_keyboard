import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' hide ModifierKey;

import '../models/key_intents.dart';

/// Tracks modifier and lock state for the desktop keyboard.
///
/// Modifiers (Shift/Ctrl/Alt/AltGr/Meta) are *sticky-momentary*: tapping one
/// arms it (like the Windows On-Screen Keyboard), and it is cleared by
/// [clearMomentary] after a committing key (a character, clipboard action or
/// Enter). Locks (Caps/Num/Scroll) persist until tapped again.
///
/// This is a small, focused [ChangeNotifier] so key widgets can rebuild their
/// "active/locked" appearance independently of the rest of the keyboard.
class KeyboardModifierController extends ChangeNotifier {
  final Set<ModifierKey> _active = <ModifierKey>{};
  final Set<LockKey> _locks = <LockKey>{};

  bool isModifierActive(ModifierKey m) => _active.contains(m);
  bool isLocked(LockKey l) => _locks.contains(l);

  bool get shift => _active.contains(ModifierKey.shift);
  bool get control => _active.contains(ModifierKey.control);
  bool get alt => _active.contains(ModifierKey.alt);
  bool get altGr => _active.contains(ModifierKey.altGr);
  bool get meta => _active.contains(ModifierKey.meta);

  bool get capsLock => _locks.contains(LockKey.capsLock);
  bool get numLock => _locks.contains(LockKey.numLock);
  bool get scrollLock => _locks.contains(LockKey.scrollLock);

  /// Whether letters should currently be upper case (Shift XOR Caps Lock).
  bool get isUpperCase => shift ^ capsLock;

  /// Whether any non-shift "command" modifier is armed (so a character key
  /// should be treated as a shortcut rather than text).
  bool get hasCommandModifier => control || alt || altGr || meta;

  /// The set of currently-armed modifiers as generic logical keys, for
  /// building a [LogicalKeySet] to match shortcuts.
  Set<LogicalKeyboardKey> get logicalModifiers =>
      _active.map((m) => m.logicalKey).toSet();

  void toggleModifier(ModifierKey m) {
    if (!_active.add(m)) _active.remove(m);
    notifyListeners();
  }

  void toggleLock(LockKey l) {
    if (!_locks.add(l)) _locks.remove(l);
    notifyListeners();
  }

  /// Arms [m] if not already (used by auto-shift on empty fields).
  void armShift() {
    if (_active.add(ModifierKey.shift)) notifyListeners();
  }

  /// Clears momentary modifiers (kept: locks). Call after a committing key.
  void clearMomentary() {
    if (_active.isEmpty) return;
    _active.clear();
    notifyListeners();
  }

  /// Resets everything (e.g. when detaching the session).
  void reset() {
    if (_active.isEmpty && _locks.isEmpty) return;
    _active.clear();
    _locks.clear();
    notifyListeners();
  }
}
