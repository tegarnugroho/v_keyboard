import 'package:flutter/services.dart' hide ModifierKey;

import '../models/key_data.dart';
import '../models/key_intents.dart';
import '../models/keyboard_layout.dart';

/// Builds the desktop (Windows On-Screen-Keyboard style) layout.
///
/// The layout is *responsive by width*: optional sections collapse as the
/// window narrows, while the typing keys always remain. The standard navigation
/// block (Insert/Home/PageUp on top, Delete/End/PageDown below) is rendered as
/// extra columns aligned to the right of the main block (so all rows keep a
/// single height), and Esc/F-row is a full-width row shown only when there is room.
///
/// Section breakpoints (effective content width):
/// * `>= 1000` — navigation block columns (Ins/Home/PgUp, Del/End/PgDn)
/// * `>=  900` — function-key row (Esc, F1–F12, PrtSc, ScrLk, Pause)
/// * always    — number row, QWERTY, modifiers, space, arrow keys
class DesktopLayouts {
  const DesktopLayouts._();

  static const double fnRowMinWidth = 900;

  // Grid alignment: every row pads its main block to [_mainFlex] then renders a
  // fixed 3-column right cluster, so the cluster forms an aligned grid (Up sits
  // directly above Down, consistent gutter) regardless of each row's contents.
  static const double _mainFlex = 15;
  static const double _gutterFlex = 0.6;
  static const double _colFlex = 1.4;

  /// A stable layout used for session bookkeeping; real rows come from [rows].
  static final KeyboardLayout layout = KeyboardLayout(
    id: 'desktop',
    initialPage: 'main',
    pages: {'main': rows(1600)},
  );

  /// The rows to render for the given available content [width].
  static List<List<KeyData>> rows(double width) {
    final showFn = width >= fnRowMinWidth;
    return [
      if (showFn)
        _assemble(_functionMain(), _cluster(_prtSc(), _scrLk(), _pause())),
      _assemble(_numberMain(),
          _cluster(_fn('Ins', LogicalKeyboardKey.insert),
              _nav(NavIntent.home, 'Home'), _nav(NavIntent.pageUp, 'PgUp'))),
      _assemble(_tabMain(),
          _cluster(_fn('Del', LogicalKeyboardKey.delete, repeatable: true),
              _nav(NavIntent.end, 'End'), _nav(NavIntent.pageDown, 'PgDn'))),
      _assemble(_capsMain(), _cluster(null, null, null)),
      _assemble(_shiftMain(), _cluster(null, _navIcon(NavIntent.up), null)),
      _assemble(
          _controlMain(),
          _cluster(_navIcon(NavIntent.left), _navIcon(NavIntent.down),
              _navIcon(NavIntent.right))),
    ];
  }

  // ---- Assembly -------------------------------------------------------------

  /// Pads [main] to [_mainFlex] (+gutter) then appends the right [cluster].
  static List<KeyData> _assemble(List<KeyData> main, List<KeyData> cluster) {
    final sum = main.fold<double>(0, (a, k) => a + k.flex);
    final filler = (_mainFlex - sum).clamp(0.0, _mainFlex) + _gutterFlex;
    return [...main, KeyData.spacer(flex: filler), ...cluster];
  }

  /// A fixed 3-column cluster; nulls become spacers so columns stay aligned.
  static List<KeyData> _cluster(KeyData? a, KeyData? b, KeyData? c) => [
        a ?? KeyData.spacer(flex: _colFlex),
        b ?? KeyData.spacer(flex: _colFlex),
        c ?? KeyData.spacer(flex: _colFlex),
      ];

  static KeyData _fn(String label, LogicalKeyboardKey key,
          {bool repeatable = false}) =>
      KeyData.function(label, key, flex: _colFlex, repeatable: repeatable);
  static KeyData _nav(NavIntent n, String label) =>
      KeyData.nav(n, label: label, flex: _colFlex);
  static KeyData _navIcon(NavIntent n) => KeyData.nav(n, flex: _colFlex);
  static KeyData _prtSc() => _fn('PrtSc', LogicalKeyboardKey.printScreen);
  static KeyData _scrLk() => _fn('ScrLk', LogicalKeyboardKey.scrollLock);
  static KeyData _pause() => _fn('Pause', LogicalKeyboardKey.pause);

  // ---- Main blocks (no cluster) ---------------------------------------------

  static List<KeyData> _functionMain() {
    KeyData f(int i) => KeyData.function(_fns[i].$1, _fns[i].$2);
    return [
      KeyData.function('Esc', LogicalKeyboardKey.escape, flex: 1.4),
      KeyData.spacer(flex: 0.6),
      f(0), f(1), f(2), f(3), // F1–F4
      KeyData.spacer(flex: 0.5),
      f(4), f(5), f(6), f(7), // F5–F8
      KeyData.spacer(flex: 0.5),
      f(8), f(9), f(10), f(11), // F9–F12
    ];
  }

  static List<KeyData> _numberMain() => [
        KeyData.char('`', shift: '~'),
        for (final p in _digits) KeyData.char(p.$1, shift: p.$2),
        KeyData.char('-', shift: '_'),
        KeyData.char('=', shift: '+'),
        KeyData.backspace(flex: 2),
      ];

  static List<KeyData> _tabMain() => [
        KeyData.function('Tab', LogicalKeyboardKey.tab, insert: '\t', flex: 1.5),
        for (final c in 'qwertyuiop'.split('')) KeyData.char(c),
        KeyData.char('[', shift: '{'),
        KeyData.char(']', shift: '}'),
        KeyData.char('\\', shift: '|', flex: 1.5),
      ];

  static List<KeyData> _capsMain() => [
        KeyData.lock(LockKey.capsLock, label: 'Caps', flex: 1.8),
        for (final c in 'asdfghjkl'.split('')) KeyData.char(c),
        KeyData.char(';', shift: ':'),
        KeyData.char("'", shift: '"'),
        KeyData.enter(flex: 2.2),
      ];

  static List<KeyData> _shiftMain() => [
        KeyData.modifier(ModifierKey.shift, label: 'Shift', flex: 2.3),
        for (final c in 'zxcvbnm'.split('')) KeyData.char(c),
        KeyData.char(',', shift: '<'),
        KeyData.char('.', shift: '>'),
        KeyData.char('/', shift: '?'),
        // Wider right Shift so its edge lines up with the row above.
        KeyData.modifier(ModifierKey.shift, label: 'Shift', flex: 2.7),
      ];

  static List<KeyData> _controlMain() => [
        KeyData.modifier(ModifierKey.control, label: 'Ctrl', flex: 1.4),
        KeyData.function('Win', LogicalKeyboardKey.meta, flex: 1.2),
        KeyData.modifier(ModifierKey.alt, label: 'Alt', flex: 1.2),
        KeyData.space(flex: 6),
        KeyData.modifier(ModifierKey.altGr, label: 'AltGr', flex: 1.2),
        KeyData.function('Menu', LogicalKeyboardKey.contextMenu, flex: 1.2),
        KeyData.function('Fn', LogicalKeyboardKey.fn, flex: 1.2),
        // Wider right Ctrl so its edge lines up with the row above.
        KeyData.modifier(ModifierKey.control, label: 'Ctrl', flex: 1.6),
      ];

  static const List<(String, String)> _digits = [
    ('1', '!'),
    ('2', '@'),
    ('3', '#'),
    ('4', '\$'),
    ('5', '%'),
    ('6', '^'),
    ('7', '&'),
    ('8', '*'),
    ('9', '('),
    ('0', ')'),
  ];

  static const List<(String, LogicalKeyboardKey)> _fns = [
    ('F1', LogicalKeyboardKey.f1),
    ('F2', LogicalKeyboardKey.f2),
    ('F3', LogicalKeyboardKey.f3),
    ('F4', LogicalKeyboardKey.f4),
    ('F5', LogicalKeyboardKey.f5),
    ('F6', LogicalKeyboardKey.f6),
    ('F7', LogicalKeyboardKey.f7),
    ('F8', LogicalKeyboardKey.f8),
    ('F9', LogicalKeyboardKey.f9),
    ('F10', LogicalKeyboardKey.f10),
    ('F11', LogicalKeyboardKey.f11),
    ('F12', LogicalKeyboardKey.f12),
  ];
}
