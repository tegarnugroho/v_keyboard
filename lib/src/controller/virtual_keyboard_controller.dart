import 'package:flutter/foundation.dart';

import '../actions/keyboard_action_handler.dart';
import '../config/virtual_keyboard_config.dart';
import '../engine/text_input_engine.dart';
import '../models/key_data.dart';
import '../models/keyboard_layout.dart';
import 'keyboard_session.dart';

/// Shift state of the keyboard.
enum ShiftState {
  /// Lower case.
  off,

  /// Next letter upper case, then back to [off].
  shifted,

  /// Locked upper case until toggled off.
  capsLock,
}

/// Orchestrates the virtual keyboard.
///
/// Owns the *transient* keyboard state (which field is active, visibility,
/// shift, current page) and routes key taps to the active [KeyboardSession].
/// The editable text itself lives in each field's [TextEditingController], so
/// switching fields or hiding the keyboard never loses editing state.
///
/// Only mutating structural state ([attach]/[detach]/[switchPage]/shift)
/// notifies listeners — plain typing does **not** rebuild the keyboard.
class VirtualKeyboardController extends ChangeNotifier {
  VirtualKeyboardController({VirtualKeyboardConfig? config})
      : _defaultConfig = config ?? const VirtualKeyboardConfig();

  final VirtualKeyboardConfig _defaultConfig;

  KeyboardSession? _session;
  ShiftState _shift = ShiftState.off;
  String _page = '';
  bool _visible = false;

  /// The active session, or null when no field is focused.
  KeyboardSession? get session => _session;

  /// Whether the keyboard should currently be shown.
  bool get isVisible => _visible && _session != null;

  ShiftState get shiftState => _shift;

  /// Whether letters should currently render/insert upper case.
  bool get isUpperCase =>
      _shift == ShiftState.shifted || _shift == ShiftState.capsLock;

  String get currentPage => _page;

  /// Config of the active session, or the controller default.
  VirtualKeyboardConfig get config => _session?.config ?? _defaultConfig;

  KeyboardLayout? get layout => _session?.layout;

  /// Current rows to render, or null when hidden.
  List<List<KeyData>>? get currentRows {
    final l = layout;
    if (l == null) return null;
    return l.rowsFor(_page);
  }

  // ---- Session lifecycle ----------------------------------------------------

  /// Attaches [session] and shows the keyboard. If the same field re-attaches,
  /// visibility is simply ensured without resetting more than necessary.
  void attach(KeyboardSession session) {
    final sameField = _session?.id == session.id;
    _session = session;
    if (!sameField) {
      _page = session.layout.initialPage;
      _shift = _initialShift(session);
    }
    _visible = true;
    notifyListeners();
  }

  /// Detaches [session] if it is the active one, hiding the keyboard.
  void detach(KeyboardSession session) {
    if (_session?.id != session.id) return;
    _session = null;
    _visible = false;
    notifyListeners();
  }

  /// Hides the keyboard and unfocuses the active field.
  void hide() {
    final s = _session;
    _visible = false;
    _session = null;
    notifyListeners();
    s?.focusNode.unfocus();
  }

  ShiftState _initialShift(KeyboardSession session) {
    if (session.allowsAutoShift && session.value.text.isEmpty) {
      return ShiftState.shifted;
    }
    return ShiftState.off;
  }

  // ---- Key handling ---------------------------------------------------------

  /// Routes a tapped [key] to the active session.
  void handleKey(KeyData key) {
    final session = _session;
    if (session == null) return;

    switch (key.kind) {
      case KeyKind.character:
        final text = key.resolveText(shifted: isUpperCase);
        if (text != null) _insert(session, text);
        if (_shift == ShiftState.shifted) {
          _shift = ShiftState.off;
          notifyListeners();
        }
      case KeyKind.space:
        _insert(session, ' ');
      case KeyKind.backspace:
        session.value = TextInputEngine.deleteBackward(session.value);
        session.onChanged?.call(session.value.text);
        _maybeAutoShift(session);
      case KeyKind.enter:
        if (session.insertsNewline) {
          session.value = TextInputEngine.newline(session.value);
          session.onChanged?.call(session.value.text);
        } else {
          _performAction(session);
        }
      case KeyKind.action:
        _performAction(session);
      case KeyKind.shift:
        handleShiftTap();
      case KeyKind.switchLayout:
        if (key.switchTarget != null) switchPage(key.switchTarget!);
      case KeyKind.custom:
        if (key.text != null) _insert(session, key.text!);
      case KeyKind.spacer:
        break;
    }
  }

  void _insert(KeyboardSession session, String text) {
    session.value = TextInputEngine.insert(session.value, text);
    session.onChanged?.call(session.value.text);
  }

  void _performAction(KeyboardSession session) {
    final result = KeyboardActionHandler.perform(session);
    if (result == ActionResult.close) hide();
  }

  /// Re-engages temporary shift when the field becomes empty (native feel).
  void _maybeAutoShift(KeyboardSession session) {
    if (_shift == ShiftState.off &&
        session.allowsAutoShift &&
        session.value.text.isEmpty) {
      _shift = ShiftState.shifted;
      notifyListeners();
    }
  }

  // ---- Shift ----------------------------------------------------------------

  /// Single tap: toggles between [ShiftState.off] and [ShiftState.shifted]
  /// (leaves caps-lock -> off).
  void handleShiftTap() {
    _shift = switch (_shift) {
      ShiftState.off => ShiftState.shifted,
      ShiftState.shifted => ShiftState.off,
      ShiftState.capsLock => ShiftState.off,
    };
    notifyListeners();
  }

  /// Double tap: engages caps-lock.
  void handleShiftDoubleTap() {
    _shift = ShiftState.capsLock;
    notifyListeners();
  }

  // ---- Pages ----------------------------------------------------------------

  void switchPage(String pageId) {
    if (_page == pageId) return;
    _page = pageId;
    // Leaving the alphabetic page clears any pending temporary shift.
    if (pageId != layout?.initialPage && _shift == ShiftState.shifted) {
      _shift = ShiftState.off;
    }
    notifyListeners();
  }
}
