import 'package:flutter/services.dart' hide ModifierKey;
import 'package:flutter/widgets.dart';

import '../actions/keyboard_action_handler.dart';
import '../config/virtual_keyboard_config.dart';
import '../desktop/clipboard_actions.dart';
import '../desktop/keyboard_modifier_controller.dart';
import '../desktop/keyboard_navigation.dart';
import '../desktop/keyboard_shortcut_manager.dart';
import '../engine/text_input_engine.dart';
import '../models/key_data.dart';
import '../models/key_intents.dart';
import '../models/keyboard_layout.dart';
import '../widgets/virtual_keyboard_shortcuts.dart';
import 'keyboard_session.dart';

/// Orchestrates the virtual keyboard for both the mobile and desktop layouts.
///
/// Owns the *transient* keyboard state (active field, visibility, current page)
/// and delegates modifier/lock state to a [KeyboardModifierController]. Routes
/// key taps to the active [KeyboardSession]; the editable text itself lives in
/// each field's [TextEditingController], so switching fields or hiding the
/// keyboard never loses editing state.
///
/// Plain typing does **not** rebuild the keyboard; only structural changes
/// (attach/detach, page switch, modifier/lock toggles) notify listeners.
class VirtualKeyboardController extends ChangeNotifier {
  VirtualKeyboardController({VirtualKeyboardConfig? config})
      : _defaultConfig = config ?? const VirtualKeyboardConfig() {
    modifiers.addListener(notifyListeners);
  }

  final VirtualKeyboardConfig _defaultConfig;

  /// Modifier and lock state (Shift/Ctrl/Alt/AltGr/Meta, Caps/Num/Scroll Lock).
  final KeyboardModifierController modifiers = KeyboardModifierController();

  KeyboardSession? _session;
  String _page = '';
  bool _visible = false;

  KeyboardSession? get session => _session;
  bool get isVisible => _visible && _session != null;

  /// Whether letters should currently render/insert upper case.
  bool get isUpperCase => modifiers.isUpperCase;

  String get currentPage => _page;

  VirtualKeyboardConfig get config => _session?.config ?? _defaultConfig;
  KeyboardLayout? get layout => _session?.layout;

  List<List<KeyData>>? get currentRows {
    final l = layout;
    if (l == null) return null;
    return l.rowsFor(_page);
  }

  @override
  void dispose() {
    modifiers.removeListener(notifyListeners);
    modifiers.dispose();
    super.dispose();
  }

  // ---- Session lifecycle ----------------------------------------------------

  void attach(KeyboardSession session) {
    final sameField = _session?.id == session.id;
    _session = session;
    if (!sameField) {
      _page = session.layout.initialPage;
      modifiers.reset();
      if (session.allowsAutoShift && session.value.text.isEmpty) {
        modifiers.armShift();
      }
    }
    _visible = true;
    notifyListeners();
  }

  void detach(KeyboardSession session) {
    if (_session?.id != session.id) return;
    _session = null;
    _visible = false;
    modifiers.reset();
    notifyListeners();
  }

  void hide() {
    final s = _session;
    _visible = false;
    _session = null;
    modifiers.reset();
    notifyListeners();
    s?.focusNode.unfocus();
  }

  // ---- Key handling ---------------------------------------------------------

  void handleKey(KeyData key) {
    final session = _session;
    if (session == null) return;

    switch (key.kind) {
      case KeyKind.character:
        _handleCharacter(session, key);
      case KeyKind.space:
        _insert(session, ' ');
        modifiers.clearMomentary();
      case KeyKind.backspace:
        _handleBackspace(session);
      case KeyKind.enter:
        if (session.insertsNewline) {
          session.value = TextInputEngine.newline(session.value);
          session.onChanged?.call(session.value.text);
        } else {
          _performAction(session);
        }
        modifiers.clearMomentary();
      case KeyKind.action:
        _performAction(session);
      case KeyKind.shift:
        handleShiftTap();
      case KeyKind.switchLayout:
        if (key.switchTarget != null) switchPage(key.switchTarget!);
      case KeyKind.custom:
        if (key.text != null) {
          _insert(session, key.text!);
          modifiers.clearMomentary();
        }
      case KeyKind.spacer:
        break;

      // ---- Desktop kinds ----
      case KeyKind.modifier:
        if (key.modifier != null) modifiers.toggleModifier(key.modifier!);
      case KeyKind.lock:
        if (key.lock != null) modifiers.toggleLock(key.lock!);
      case KeyKind.navigation:
        _handleNavigation(session, key);
      case KeyKind.clipboard:
        if (key.clip != null) _handleClipboard(session, key.clip!);
      case KeyKind.function:
        _handleFunction(session, key);
      case KeyKind.media:
        if (key.media != null) _shortcuts(session)?.onMedia?.call(key.media!);
    }
  }

  void _handleCharacter(KeyboardSession session, KeyData key) {
    final text = key.resolveText(shifted: isUpperCase) ?? '';
    if (modifiers.hasCommandModifier) {
      // A command modifier (Ctrl/Alt/Meta) turns the key into a shortcut.
      _handleCharCommand(session, key, text);
    } else {
      _insert(session, text);
    }
    modifiers.clearMomentary();
  }

  void _handleCharCommand(KeyboardSession session, KeyData key, String char) {
    final lower = char.toLowerCase();
    // Built-in clipboard / select-all (Ctrl only).
    if (modifiers.control && !modifiers.alt && !modifiers.meta) {
      switch (lower) {
        case 'a':
          _handleClipboard(session, ClipboardIntent.selectAll);
          return;
        case 'c':
          _handleClipboard(session, ClipboardIntent.copy);
          return;
        case 'x':
          _handleClipboard(session, ClipboardIntent.cut);
          return;
        case 'v':
          _handleClipboard(session, ClipboardIntent.paste);
          return;
      }
    }
    final trigger = key.logicalKey ?? logicalKeyForChar(char);
    if (trigger != null) _runShortcut(session, trigger);
  }

  void _handleBackspace(KeyboardSession session) {
    if (modifiers.control) {
      session.value = _deleteWordBackward(session.value);
    } else {
      session.value = TextInputEngine.deleteBackward(session.value);
    }
    session.onChanged?.call(session.value.text);
    if (modifiers.isUpperCase == false &&
        session.allowsAutoShift &&
        session.value.text.isEmpty) {
      modifiers.armShift();
    }
  }

  void _handleNavigation(KeyboardSession session, KeyData key) {
    if (key.nav == null) return;
    session.value = KeyboardNavigation.move(
      session.value,
      key.nav!,
      extend: modifiers.shift,
      word: modifiers.control,
    );
    // Keep modifiers armed so Shift/Ctrl+arrow can repeat / chain.
  }

  void _handleClipboard(KeyboardSession session, ClipboardIntent intent) {
    final shortcuts = _shortcuts(session);
    ClipboardActions.perform(
      intent,
      session.editingController,
      onChanged: session.onChanged,
      callbacks: shortcuts?.clipboardCallbacks,
    );
  }

  void _handleFunction(KeyboardSession session, KeyData key) {
    final lk = key.logicalKey;
    // Try a registered shortcut first (covers F-keys, Esc, etc.).
    if (lk != null && _runShortcut(session, lk)) {
      modifiers.clearMomentary();
      return;
    }
    if (lk == LogicalKeyboardKey.delete) {
      session.value = modifiers.control
          ? _deleteWordForward(session.value)
          : TextInputEngine.deleteForward(session.value);
      session.onChanged?.call(session.value.text);
      return;
    }
    if (lk == LogicalKeyboardKey.meta || lk == LogicalKeyboardKey.metaLeft) {
      _shortcuts(session)?.onMetaKey?.call();
      return;
    }
    if (lk == LogicalKeyboardKey.contextMenu) {
      _shortcuts(session)?.onMenuKey?.call();
      return;
    }
    if (key.text != null) {
      // e.g. Tab inserts a tab character.
      _insert(session, key.text!);
      modifiers.clearMomentary();
    }
  }

  /// Looks up registered shortcuts and runs the one matching the current
  /// modifiers + [trigger]. Returns whether one fired.
  bool _runShortcut(KeyboardSession session, LogicalKeyboardKey trigger) {
    final shortcuts = _shortcuts(session);
    if (shortcuts == null) return false;
    final pressed =
        KeyboardShortcutManager.pressedSet(modifiers.logicalModifiers, trigger);
    final callback = shortcuts.manager.match(pressed);
    if (callback != null) {
      callback();
      return true;
    }
    return false;
  }

  VirtualKeyboardShortcuts? _shortcuts(KeyboardSession session) {
    final context = session.contextRef();
    if (context == null || !context.mounted) return null;
    return VirtualKeyboardShortcuts.read(context);
  }

  void _insert(KeyboardSession session, String text) {
    session.value = TextInputEngine.insert(session.value, text);
    session.onChanged?.call(session.value.text);
  }

  void _performAction(KeyboardSession session) {
    final result = KeyboardActionHandler.perform(session);
    if (result == ActionResult.close) hide();
  }

  TextEditingValue _deleteWordBackward(TextEditingValue value) {
    final sel = value.selection;
    if (sel.isValid && !sel.isCollapsed) {
      return TextInputEngine.deleteBackward(value); // delete the range
    }
    final moved = KeyboardNavigation.move(value, NavIntent.left,
        extend: true, word: true);
    return TextInputEngine.deleteBackward(moved);
  }

  TextEditingValue _deleteWordForward(TextEditingValue value) {
    final sel = value.selection;
    if (sel.isValid && !sel.isCollapsed) {
      return TextInputEngine.deleteForward(value);
    }
    final moved = KeyboardNavigation.move(value, NavIntent.right,
        extend: true, word: true);
    return TextInputEngine.deleteForward(moved);
  }

  // ---- Shift (mobile compatibility) -----------------------------------------

  bool get isShiftActive => modifiers.shift;
  bool get isCapsLock => modifiers.capsLock;

  /// Single tap: toggles Shift on/off (and clears Caps Lock).
  void handleShiftTap() {
    if (modifiers.capsLock) {
      modifiers.toggleLock(LockKey.capsLock);
      if (modifiers.shift) modifiers.toggleModifier(ModifierKey.shift);
      return;
    }
    modifiers.toggleModifier(ModifierKey.shift);
  }

  /// Double tap: engages Caps Lock.
  void handleShiftDoubleTap() {
    if (modifiers.shift) modifiers.toggleModifier(ModifierKey.shift);
    if (!modifiers.capsLock) modifiers.toggleLock(LockKey.capsLock);
  }

  // ---- Pages ----------------------------------------------------------------

  void switchPage(String pageId) {
    if (_page == pageId) return;
    _page = pageId;
    if (pageId != layout?.initialPage && modifiers.shift) {
      modifiers.toggleModifier(ModifierKey.shift);
    }
    notifyListeners();
  }
}
