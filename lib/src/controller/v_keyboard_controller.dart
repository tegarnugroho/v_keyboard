import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart' hide ModifierKey;
import 'package:flutter/widgets.dart';

import '../actions/keyboard_action_handler.dart';
import '../clipboard/clipboard_history_item.dart';
import '../clipboard/clipboard_history_manager.dart';
import '../config/v_keyboard_config.dart';
import '../desktop/clipboard_actions.dart';
import '../desktop/keyboard_modifier_controller.dart';
import '../desktop/keyboard_navigation.dart';
import '../desktop/keyboard_shortcut_manager.dart';
import '../desktop/native_print_screen.dart';
import '../engine/hangul_composer.dart';
import '../engine/ime_engine.dart';
import '../engine/japanese_ime_engine.dart';
import '../engine/kana_composer.dart';
import '../engine/pinyin_ime_engine.dart';
import '../engine/telex_composer.dart';
import '../engine/text_input_engine.dart';
import '../engine/zhuyin_ime_engine.dart';
import '../layouts/layout_selection_storage.dart';
import '../models/keyboard_type.dart';
import '../layouts/v_keyboard_layouts.dart';
import '../models/key_data.dart';
import '../models/key_intents.dart';
import '../models/keyboard_layout.dart';
import '../models/v_keyboard_locale.dart';
import '../widgets/v_keyboard_shortcuts.dart';
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
class VKeyboardController extends ChangeNotifier {
  VKeyboardController({
    VKeyboardConfig? config,
    ClipboardHistoryManager? clipboardHistory,
    LayoutSelectionStorage? layoutStorage,
  }) : _defaultConfig = config ?? const VKeyboardConfig() {
    this.clipboardHistory = clipboardHistory ??
        ClipboardHistoryManager(
          maxItems: _defaultConfig.maxClipboardHistoryItems,
          enabled: _defaultConfig.enableClipboardHistory,
          syncSystemClipboard: _defaultConfig.syncSystemClipboard,
        );
    _layoutStorage = layoutStorage ??
        (_defaultConfig.persistLayoutSelection
            ? LayoutSelectionStorage.defaultStorage()
            : null);
    _currentLayoutId = _defaultConfig.defaultLayout ??
        (_defaultConfig.enabledLayouts.isNotEmpty
            ? _defaultConfig.enabledLayouts.first
            : 'en_US');

    modifiers.addListener(notifyListeners);
    this.clipboardHistory.addListener(notifyListeners);

    if (_defaultConfig.persistLayoutSelection && _layoutStorage != null) {
      _restorePersistedLayout();
    }
  }

  VKeyboardConfig _defaultConfig;
  LayoutSelectionStorage? _layoutStorage;
  late String _currentLayoutId;
  final StreamController<String> _layoutChangeController =
      StreamController<String>.broadcast();
  String? _spaceBarBanner;
  Timer? _spaceBarTimer;

  Completer<String?>? _layoutPickerCompleter;

  /// Whether the layout picker panel is currently open.
  ///
  /// The picker is rendered by [VKeyboardScope] next to the keyboard (not as
  /// a route), so it works without a `Navigator` above the scope and doesn't
  /// steal focus from the active field.
  bool get isLayoutPickerOpen => _layoutPickerCompleter != null;

  /// Opens the layout picker. Completes with the selected layout id, or
  /// `null` if the picker was dismissed without a selection.
  Future<String?> openLayoutPicker() {
    if (_isDisposed) return Future.value(null);
    if (config.enabledLayouts.isEmpty) return Future.value(null);
    final completer = _layoutPickerCompleter ??= Completer<String?>();
    notifyListeners();
    return completer.future;
  }

  /// Closes the layout picker, switching to [layoutId] when given.
  void closeLayoutPicker([String? layoutId]) {
    if (_isDisposed) return;
    final completer = _layoutPickerCompleter;
    if (completer == null) return;
    _layoutPickerCompleter = null;
    if (layoutId != null) setLayout(layoutId);
    completer.complete(layoutId);
    notifyListeners();
  }

  void _closeLayoutPickerSilently() {
    final completer = _layoutPickerCompleter;
    _layoutPickerCompleter = null;
    completer?.complete(null);
  }

  /// Updates the default configuration when the parent scope's config changes.
  void updateConfig(VKeyboardConfig newConfig) {
    _defaultConfig = newConfig;
    if (_layoutStorage == null && newConfig.persistLayoutSelection) {
      _layoutStorage = LayoutSelectionStorage.defaultStorage();
      _restorePersistedLayout();
    }
    notifyListeners();
  }

  /// The identifier of the currently active keyboard layout (e.g. 'en_US', 'de_DE').
  String get currentLayoutId => _currentLayoutId;

  /// The currently active locale enum if it is one of the built-in [VKeyboardLocale]s,
  /// or null if a custom layout is active.
  VKeyboardLocale? get currentLocale =>
      VKeyboardLocale.fromId(_currentLayoutId);

  /// Switches the active layout using a type-safe [VKeyboardLocale].
  void setLocale(VKeyboardLocale locale) => setLayout(locale.id);

  /// Stream emitting the layout id whenever the active layout changes.
  Stream<String> get onLayoutChanged => _layoutChangeController.stream;

  /// Transient layout name shown briefly on the space bar after switching.
  String? get spaceBarBanner => _spaceBarBanner;

  /// Modifier and lock state (Shift/Ctrl/Alt/AltGr/Meta, Caps/Num/Scroll Lock).
  final KeyboardModifierController modifiers = KeyboardModifierController();

  /// Clipboard history manager.
  late final ClipboardHistoryManager clipboardHistory;

  KeyboardSession? _session;
  KeyboardSession? _targetSession;
  String _page = '';
  String _previousPage = '';
  bool _visible = false;

  KeyboardSession? get session => _session ?? _targetSession;
  bool get isVisible =>
      _visible &&
      (_session != null || (_targetSession != null && _page == 'clipboard'));

  /// Whether letters should currently render/insert upper case.
  bool get isUpperCase => modifiers.isUpperCase;

  /// Effective shift for a specific key: Caps Lock affects only letters, while
  /// Shift affects every character key (so the number row shows symbols on
  /// Shift but stays digits on Caps Lock).
  bool isShiftedForKey(KeyData key) =>
      key.isLetter ? modifiers.isUpperCase : modifiers.shift;

  String get currentPage => _page;

  static const Map<String, ImeEngine> _imeEngines = {
    'zh_CN': PinyinImeEngine(),
    'zh_TW': ZhuyinImeEngine(),
    'ja_JP': JapaneseImeEngine(),
  };

  /// The active [ImeEngine] for the current layout, if IME candidate handling is enabled.
  ImeEngine? get activeImeEngine {
    if (!config.enableImeCandidates) return null;
    final sess = session;
    if (sess != null &&
        (sess.type == VKeyboardType.password ||
            sess.type == VKeyboardType.pin ||
            sess.type == VKeyboardType.email ||
            sess.type == VKeyboardType.url)) {
      return null;
    }
    return _imeEngines[_currentLayoutId];
  }

  String _composingText = '';
  List<String> _candidates = const [];

  /// Current composing buffer for IME (e.g. Pinyin or Kana sequence).
  String get composingText => _composingText;

  /// Current candidate suggestions for the active [composingText].
  List<String> get candidates => _candidates;

  /// Whether candidate suggestions are available for selection.
  bool get hasCandidates => _candidates.isNotEmpty;

  void _clearComposingInternal() {
    _composingText = '';
    _candidates = const [];
  }

  /// Clears the current IME composing text and candidate suggestions.
  void clearComposing() {
    if (_composingText.isEmpty && _candidates.isEmpty) return;
    _clearComposingInternal();
    notifyListeners();
  }

  /// Commits a selected candidate string to the active text field,
  /// clearing the active composing text and candidates.
  void commitCandidate(String candidate) {
    final s = _session ?? _targetSession;
    _clearComposingInternal();
    if (s != null) {
      if (!s.focusNode.hasFocus) {
        s.focusNode.requestFocus();
      }
      _insert(s, candidate);
      modifiers.clearMomentary();
    }
    notifyListeners();
  }

  VKeyboardConfig get config => session?.config ?? _defaultConfig;
  KeyboardLayout? get layout => session?.getLayout(_currentLayoutId);

  List<List<KeyData>>? get currentRows {
    final l = layout;
    if (l == null) return null;
    return l.rowsFor(_page);
  }

  bool _notificationScheduled = false;
  bool _isDisposed = false;

  /// Whether this controller has been disposed.
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    _isDisposed = true;
    _closeLayoutPickerSilently();
    _spaceBarTimer?.cancel();
    _layoutChangeController.close();
    modifiers.removeListener(notifyListeners);
    modifiers.dispose();
    clipboardHistory.removeListener(notifyListeners);
    clipboardHistory.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    try {
      final binding = WidgetsBinding.instance;
      if (binding.schedulerPhase == SchedulerPhase.persistentCallbacks) {
        if (!_notificationScheduled) {
          _notificationScheduled = true;
          binding.addPostFrameCallback((_) {
            _notificationScheduled = false;
            if (!_isDisposed) {
              super.notifyListeners();
            }
          });
        }
        return;
      }
    } catch (_) {
      // Binding not initialized (e.g. pure Dart unit test).
    }
    super.notifyListeners();
  }

  // ---- Layout switching ----------------------------------------------------

  /// Switches the active layout to [id].
  void setLayout(String id) {
    if (_currentLayoutId == id && _page != '123' && _page != 'symbols') return;
    _clearComposingInternal();
    _currentLayoutId = id;
    if (config.persistLayoutSelection) {
      _layoutStorage ??= LayoutSelectionStorage.defaultStorage();
      _layoutStorage?.save(id);
    }
    _layoutChangeController.add(id);

    // Switching while on symbols page returns to the new layout's main page
    if (_page == '123' || _page == 'symbols') {
      _page = layout?.initialPage ?? 'abc';
    }

    if (modifiers.shift) {
      modifiers.toggleModifier(ModifierKey.shift);
    }

    final displayName = VKeyboardLayouts.getDisplayName(id);
    _triggerSpaceBarAnnouncement(displayName);

    try {
      // ignore: deprecated_member_use
      SemanticsService.announce('Switched to $displayName', TextDirection.ltr)
          .catchError((_) {});
    } catch (_) {}

    notifyListeners();
  }

  /// Cycles to the next layout in [VKeyboardConfig.enabledLayouts].
  void nextLayout() {
    final enabled = config.enabledLayouts;
    if (enabled.isEmpty) return;
    final currentIndex = enabled.indexOf(_currentLayoutId);
    final nextIndex =
        currentIndex >= 0 ? (currentIndex + 1) % enabled.length : 0;
    setLayout(enabled[nextIndex]);
  }

  void _triggerSpaceBarAnnouncement(String name) {
    _spaceBarBanner = name;
    _spaceBarTimer?.cancel();
    _spaceBarTimer = Timer(const Duration(milliseconds: 1500), () {
      _spaceBarBanner = null;
      notifyListeners();
    });
  }

  Future<void> _restorePersistedLayout() async {
    try {
      final saved = await _layoutStorage?.load();
      if (saved != null && saved.isNotEmpty) {
        if (_defaultConfig.enabledLayouts.contains(saved) ||
            _defaultConfig.enabledLayouts.length == 1) {
          _currentLayoutId = saved;
          _layoutChangeController.add(saved);
          notifyListeners();
        }
      }
    } catch (_) {}
  }

  // ---- Session lifecycle ----------------------------------------------------

  void attach(KeyboardSession session) {
    if (_isDisposed) return;
    final sameField =
        _session?.id == session.id || _targetSession?.id == session.id;
    final typeChanged = _session != null && _session!.type != session.type;
    _session = session;
    _targetSession = session;
    if ((!sameField || typeChanged) && _page != 'clipboard') {
      _clearComposingInternal();
      _page = session.getLayout(_currentLayoutId).initialPage;
      modifiers.reset(notify: false);
      if (session.allowsAutoShift && session.value.text.isEmpty) {
        modifiers.armShift(notify: false);
      }
    }
    _visible = true;
    notifyListeners();
  }

  void detach(KeyboardSession session) {
    if (_isDisposed) return;
    if (_session?.id != session.id) return;
    _clearComposingInternal();
    if (_page == 'clipboard') {
      _targetSession = session;
      _session = null;
      notifyListeners();
      return;
    }
    _session = null;
    _targetSession = null;
    _visible = false;
    _closeLayoutPickerSilently();
    modifiers.reset(notify: false);
    notifyListeners();
  }

  void hide() {
    if (_isDisposed) return;
    final s = _session ?? _targetSession;
    _visible = false;
    _session = null;
    _targetSession = null;
    _closeLayoutPickerSilently();
    _clearComposingInternal();
    modifiers.reset(notify: false);
    notifyListeners();
    s?.focusNode.unfocus();
  }

  // ---- Clipboard History ---------------------------------------------------

  /// Opens the clipboard history panel.
  void openClipboardHistory() {
    if (!config.enableClipboardHistory) return;
    if (_page != 'clipboard') {
      _previousPage = _page.isNotEmpty
          ? _page
          : (session?.getLayout(_currentLayoutId).initialPage ?? 'abc');
    }
    if (_session != null) {
      _targetSession = _session;
    }
    _page = 'clipboard';
    notifyListeners();
    clipboardHistory.syncFromSystemClipboard();
  }

  /// Closes the clipboard history panel and returns to the previous layout page.
  void closeClipboardHistory() {
    final target = _previousPage.isNotEmpty
        ? _previousPage
        : (session?.getLayout(_currentLayoutId).initialPage ?? 'abc');
    _page = target;
    final s = _session ?? _targetSession;
    if (s != null && !s.focusNode.hasFocus) {
      s.focusNode.requestFocus();
    }
    notifyListeners();
  }

  /// Synchronizes clipboard history with the operating system clipboard.
  Future<bool> syncClipboardFromSystem() =>
      clipboardHistory.syncFromSystemClipboard();

  /// Inserts [text] into the active text field using the input editing pipeline.
  void insertText(String text) {
    final s = _session ?? _targetSession;
    if (s == null) return;
    if (!s.focusNode.hasFocus) {
      s.focusNode.requestFocus();
    }
    s.insertText(text);
  }

  /// Pastes a saved [ClipboardHistoryItem] into the active text field.
  void pasteClipboardItem(ClipboardHistoryItem item) {
    pasteText(item.text);
  }

  /// Pastes [text] into the active text field using the input editing pipeline.
  void pasteText(String text) {
    final s = _session ?? _targetSession;
    if (s == null) return;
    if (!s.focusNode.hasFocus) {
      s.focusNode.requestFocus();
    }
    s.insertText(text);
    Clipboard.setData(ClipboardData(text: text));
  }

  // ---- Key handling ---------------------------------------------------------

  void handleKey(KeyData key) {
    final session = _session;
    if (session == null) return;

    switch (key.kind) {
      case KeyKind.character:
        _handleCharacter(session, key);
      case KeyKind.space:
        if (_composingText.isNotEmpty) {
          final engine = activeImeEngine;
          if (_candidates.isNotEmpty && (engine?.commitOnSpace ?? true)) {
            commitCandidate(_candidates.first);
            return;
          } else {
            final raw = _composingText;
            _clearComposingInternal();
            _insert(session, raw);
            notifyListeners();
            modifiers.clearMomentary();
            return;
          }
        }
        _insert(session, ' ');
        modifiers.clearMomentary();
      case KeyKind.backspace:
        if (_composingText.isNotEmpty) {
          final engine = activeImeEngine;
          if (_currentLayoutId == 'ja_JP' &&
              KanaComposer.canDecompose(
                  _composingText[_composingText.length - 1])) {
            final lastChar = _composingText[_composingText.length - 1];
            final decomp = KanaComposer.dakutenMap.entries
                    .where((e) => e.value == lastChar)
                    .map((e) => e.key)
                    .firstOrNull ??
                KanaComposer.handakutenMap.entries
                    .where((e) => e.value == lastChar)
                    .map((e) => e.key)
                    .firstOrNull;
            if (decomp != null) {
              _composingText =
                  _composingText.substring(0, _composingText.length - 1) + decomp;
            } else {
              _composingText =
                  _composingText.substring(0, _composingText.length - 1);
            }
          } else {
            _composingText =
                _composingText.substring(0, _composingText.length - 1);
          }
          if (_composingText.isNotEmpty && engine != null) {
            _candidates = engine.getCandidates(_composingText,
                maxCandidates: config.maxImeCandidates);
          } else {
            _candidates = const [];
          }
          notifyListeners();
          return;
        }
        _handleBackspace(session);
      case KeyKind.enter:
        if (_composingText.isNotEmpty) {
          final raw = _composingText;
          _clearComposingInternal();
          _insert(session, raw);
          notifyListeners();
          modifiers.clearMomentary();
          return;
        }
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
        if (key.media != null) {
          sendNativeKey(_mediaVk(key.media!), extended: true);
          _shortcuts(session)?.onMedia?.call(key.media!);
        }
    }
  }

  void _handleCharacter(KeyboardSession session, KeyData key) {
    if (modifiers.altGr && !modifiers.control && !modifiers.meta) {
      final keyChar = key.text ?? '';
      final altChar = VKeyboardLayouts.getAltGr(_currentLayoutId)[keyChar];
      if (altChar != null) {
        _insert(session, altChar);
        modifiers.clearMomentary();
        return;
      }
    }

    final text = key.resolveText(shifted: isShiftedForKey(key)) ?? '';
    if (modifiers.hasCommandModifier) {
      // A command modifier (Ctrl/Alt/Meta) turns the key into a shortcut.
      _handleCharCommand(session, key, text);
      return;
    }

    final engine = activeImeEngine;
    if (engine != null && engine.isValidInput(text)) {
      if (session.readOnly || !session.enabled) return;
      final normalized = engine.normalizeInput(text);

      if (_currentLayoutId == 'ja_JP' && KanaComposer.isVoicingMark(text)) {
        if (_composingText.isNotEmpty) {
          final lastChar = _composingText[_composingText.length - 1];
          final voiced = KanaComposer.composeMark(lastChar, text);
          if (voiced != null) {
            _composingText =
                _composingText.substring(0, _composingText.length - 1) + voiced;
            _candidates = engine.getCandidates(_composingText,
                maxCandidates: config.maxImeCandidates);
            notifyListeners();
            modifiers.clearMomentary();
            return;
          }
        } else {
          final oldValue = session.value;
          final newValue = KanaComposer.compose(value: oldValue, mark: text);
          if (newValue != oldValue) {
            session.value = newValue;
            session.onChanged?.call(newValue.text);
            modifiers.clearMomentary();
            return;
          }
        }
      }

      _composingText += normalized;
      _candidates = engine.getCandidates(_composingText,
          maxCandidates: config.maxImeCandidates);
      notifyListeners();
      modifiers.clearMomentary();
      return;
    }

    if (_composingText.isNotEmpty) {
      final commitText =
          _candidates.isNotEmpty ? _candidates.first : _composingText;
      _insert(session, commitText);
      _clearComposingInternal();
      notifyListeners();
    }

    final isRawAsciiField = session.type == VKeyboardType.password ||
        session.type == VKeyboardType.pin ||
        session.type == VKeyboardType.email ||
        session.type == VKeyboardType.url;

    if (!isRawAsciiField &&
        _currentLayoutId == 'ko_KR' &&
        (HangulComposer.isChoseong(text) ||
            HangulComposer.isJungseong(text) ||
            HangulComposer.isHangulSyllable(text))) {
      if (session.readOnly || !session.enabled) return;
      final oldValue = session.value;
      var newValue = HangulComposer.compose(
        value: oldValue,
        jamo: text,
      );
      if (session.inputFormatters != null && session.inputFormatters!.isNotEmpty) {
        for (final formatter in session.inputFormatters!) {
          newValue = formatter.formatEditUpdate(oldValue, newValue);
        }
      }
      if (newValue != oldValue) {
        session.value = newValue;
        session.onChanged?.call(newValue.text);
      }
    } else if (!isRawAsciiField &&
        _currentLayoutId == 'ja_JP' &&
        KanaComposer.isVoicingMark(text)) {
      if (session.readOnly || !session.enabled) return;
      final oldValue = session.value;
      var newValue = KanaComposer.compose(
        value: oldValue,
        mark: text,
      );
      if (session.inputFormatters != null && session.inputFormatters!.isNotEmpty) {
        for (final formatter in session.inputFormatters!) {
          newValue = formatter.formatEditUpdate(oldValue, newValue);
        }
      }
      if (newValue != oldValue) {
        session.value = newValue;
        session.onChanged?.call(newValue.text);
      }
    } else if (!isRawAsciiField &&
        _currentLayoutId == 'vi_VN' &&
        TelexComposer.isTelexKey(text)) {
      if (session.readOnly || !session.enabled) return;
      final oldValue = session.value;
      var newValue = TelexComposer.compose(
        value: oldValue,
        char: text,
      );
      if (session.inputFormatters != null && session.inputFormatters!.isNotEmpty) {
        for (final formatter in session.inputFormatters!) {
          newValue = formatter.formatEditUpdate(oldValue, newValue);
        }
      }
      if (newValue != oldValue) {
        session.value = newValue;
        session.onChanged?.call(newValue.text);
      }
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
    // Win + V -> Clipboard history
    if (modifiers.meta && !modifiers.control && lower == 'v') {
      openClipboardHistory();
      return;
    }
    final trigger = key.logicalKey ?? logicalKeyForChar(char);
    if (trigger != null) _runShortcut(session, trigger);
  }

  void _handleBackspace(KeyboardSession session) {
    if (session.readOnly || !session.enabled) return;
    final isRawAsciiField = session.type == VKeyboardType.password ||
        session.type == VKeyboardType.pin ||
        session.type == VKeyboardType.email ||
        session.type == VKeyboardType.url;

    if (modifiers.control) {
      session.value = _deleteWordBackward(session.value);
    } else if (!isRawAsciiField &&
        _currentLayoutId == 'ko_KR' &&
        session.value.selection.isCollapsed) {
      final offset = session.value.selection.baseOffset;
      if (offset > 0 &&
          HangulComposer.canDecompose(session.value.text[offset - 1])) {
        session.value = HangulComposer.backspace(value: session.value);
      } else {
        session.value = TextInputEngine.deleteBackward(session.value);
      }
    } else if (!isRawAsciiField &&
        _currentLayoutId == 'ja_JP' &&
        session.value.selection.isCollapsed) {
      final offset = session.value.selection.baseOffset;
      if (offset > 0 &&
          KanaComposer.canDecompose(session.value.text[offset - 1])) {
        session.value = KanaComposer.backspace(value: session.value);
      } else {
        session.value = TextInputEngine.deleteBackward(session.value);
      }
    } else if (!isRawAsciiField &&
        _currentLayoutId == 'vi_VN' &&
        session.value.selection.isCollapsed) {
      final offset = session.value.selection.baseOffset;
      if (offset > 0 &&
          TelexComposer.canDecompose(session.value.text[offset - 1])) {
        session.value = TelexComposer.backspace(value: session.value);
      } else {
        session.value = TextInputEngine.deleteBackward(session.value);
      }
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
    if (intent == ClipboardIntent.history) {
      openClipboardHistory();
      return;
    }
    final shortcuts = _shortcuts(session);
    ClipboardActions.perform(
      intent,
      session.editingController,
      onChanged: session.onChanged,
      callbacks: shortcuts?.clipboardCallbacks,
      history: session.config.enableClipboardHistory ? clipboardHistory : null,
      isSensitive: session.isSensitive,
      readOnly: session.readOnly || !session.enabled,
      onOpenHistory: openClipboardHistory,
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
      sendNativeKey(_vkLWin); // opens Start on Windows
      _shortcuts(session)?.onMetaKey?.call();
      return;
    }
    if (lk == LogicalKeyboardKey.contextMenu) {
      sendNativeKey(_vkApps);
      _shortcuts(session)?.onMenuKey?.call();
      return;
    }
    // Keys with a native Windows effect (screen capture / lock toggles).
    final vk = _nativeVkFor(lk);
    if (vk != null) {
      sendNativeKey(vk);
      _shortcuts(session)?.onFunctionKey?.call(lk!);
      return;
    }
    if (key.text != null) {
      // e.g. Tab inserts a tab character.
      _insert(session, key.text!);
      modifiers.clearMomentary();
      return;
    }
    // Unhandled function/special key (Esc, F1–F12, PrtSc, ScrLk, Pause, Fn…).
    // OS-level keys can't be triggered from Dart — hand off to the developer.
    if (lk != null) _shortcuts(session)?.onFunctionKey?.call(lk);
  }

  // Windows virtual-key codes for keys with a native OS effect.
  static const int _vkLWin = 0x5B;
  static const int _vkApps = 0x5D;

  /// Windows VK for a function key with a native effect, or null.
  int? _nativeVkFor(LogicalKeyboardKey? lk) => switch (lk) {
        LogicalKeyboardKey.printScreen => 0x2C,
        LogicalKeyboardKey.scrollLock => 0x91,
        LogicalKeyboardKey.pause => 0x13,
        LogicalKeyboardKey.numLock => 0x90,
        _ => null,
      };

  /// Windows VK for a media intent (all extended keys).
  int _mediaVk(MediaIntent intent) => switch (intent) {
        MediaIntent.playPause => 0xB3,
        MediaIntent.stop => 0xB2,
        MediaIntent.next => 0xB0,
        MediaIntent.previous => 0xB1,
        MediaIntent.mute => 0xAD,
        MediaIntent.volumeDown => 0xAE,
        MediaIntent.volumeUp => 0xAF,
      };

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

  VKeyboardShortcuts? _shortcuts(KeyboardSession session) {
    final context = session.contextRef();
    if (context == null || !context.mounted) return null;
    return VKeyboardShortcuts.read(context);
  }

  void _insert(KeyboardSession session, String text) {
    session.insertText(text);
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
    if (_composingText.isNotEmpty) {
      final commit =
          _candidates.isNotEmpty ? _candidates.first : _composingText;
      final s = _session ?? _targetSession;
      if (s != null) _insert(s, commit);
      _clearComposingInternal();
    }
    if (pageId == 'clipboard') {
      openClipboardHistory();
      return;
    }
    _page = pageId;
    if (pageId != layout?.initialPage && modifiers.shift) {
      modifiers.toggleModifier(ModifierKey.shift);
    }
    notifyListeners();
  }
}
