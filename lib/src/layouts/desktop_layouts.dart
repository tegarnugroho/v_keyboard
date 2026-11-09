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

  /// Below this width the right cluster (Esc/F-row, nav block, arrows) is
  /// dropped so the typing keys get full width — keeps it usable on phones.
  static const double clusterMinWidth = 920;

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

  /// Returns a desktop [KeyboardLayout] for the specified [layoutId].
  static KeyboardLayout layoutFor(String layoutId) => KeyboardLayout(
        id: 'desktop_$layoutId',
        initialPage: 'main',
        pages: {'main': rows(1600, layoutId: layoutId)},
      );

  /// The rows to render for the given available content [width] and [layoutId].
  static List<List<KeyData>> rows(double width, {String layoutId = 'en_US'}) {
    // Narrow (phone) → just the typing block, full width, bigger keys.
    if (width < clusterMinWidth) {
      return [
        _numberMain(layoutId),
        _tabMain(layoutId),
        _capsMain(layoutId),
        [..._shiftMain(layoutId), _navIcon(NavIntent.up)],
        [
          ..._controlMain(),
          _clip(),
          _navIcon(NavIntent.left),
          _navIcon(NavIntent.down),
          _navIcon(NavIntent.right),
        ],
      ];
    }

    // Wide (desktop) → full layout with the aligned right cluster grid.
    final showFn = width >= fnRowMinWidth;
    return [
      if (showFn)
        _assemble(_functionMain(), _cluster(_prtSc(), _scrLk(), _pause())),
      _assemble(
          _numberMain(layoutId),
          _cluster(_fn('Ins', LogicalKeyboardKey.insert),
              _nav(NavIntent.home, 'Home'), _nav(NavIntent.pageUp, 'PgUp'))),
      _assemble(
          _tabMain(layoutId),
          _cluster(_fn('Del', LogicalKeyboardKey.delete, repeatable: true),
              _nav(NavIntent.end, 'End'), _nav(NavIntent.pageDown, 'PgDn'))),
      _assemble(_capsMain(layoutId), _cluster(null, null, _clip())),
      _assemble(_shiftMain(layoutId), _cluster(null, _navIcon(NavIntent.up), null)),
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
  static KeyData _clip() => KeyData.clipboardHistory(flex: _colFlex);

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

  static List<KeyData> _numberMain(String layoutId) => [
        KeyData.char('`', shift: '~'),
        for (final p in _digits) KeyData.char(p.$1, shift: p.$2),
        KeyData.char('-', shift: '_'),
        KeyData.char('=', shift: '+'),
        KeyData.backspace(flex: 2),
      ];

  static List<KeyData> _tabMain(String layoutId) {
    if (layoutId == 'ko_KR') {
      return [
        KeyData.function('Tab', LogicalKeyboardKey.tab, insert: '\t', flex: 1.5),
        KeyData.char('ㅂ', shift: 'ㅃ'),
        KeyData.char('ㅈ', shift: 'ㅉ'),
        KeyData.char('ㄷ', shift: 'ㄸ'),
        KeyData.char('ㄱ', shift: 'ㄲ'),
        KeyData.char('ㅅ', shift: 'ㅆ'),
        KeyData.char('ㅛ'),
        KeyData.char('ㅕ'),
        KeyData.char('ㅑ'),
        KeyData.char('ㅐ', shift: 'ㅒ'),
        KeyData.char('ㅔ', shift: 'ㅖ'),
        KeyData.char('[', shift: '{'),
        KeyData.char(']', shift: '}'),
        KeyData.char('\\', shift: '|', flex: 1.5),
      ];
    }

    final (letters, k1, k2, k3) = switch (layoutId) {
      'de_DE' => (
          'qwertzuiop',
          KeyData.char('ü', shift: 'Ü'),
          KeyData.char('+', shift: '*'),
          KeyData.char('#', shift: "'", flex: 1.5)
        ),
      'fr_FR' => (
          'azertyuiop',
          KeyData.char('^', shift: '¨'),
          KeyData.char('\$', shift: '£'),
          KeyData.char('*', shift: 'µ', flex: 1.5)
        ),
      'es_ES' => (
          'qwertyuiop',
          KeyData.char('\\', shift: '|'),
          KeyData.char('+', shift: '*'),
          KeyData.char('ç', shift: 'Ç', flex: 1.5)
        ),
      'nordic' => (
          'qwertyuiop',
          KeyData.char('å', shift: 'Å'),
          KeyData.char('¨', shift: '^'),
          KeyData.char("'", shift: '*', flex: 1.5)
        ),
      'tr_TR' => (
          'qwertyuıop',
          KeyData.char('ğ', shift: 'Ğ'),
          KeyData.char('ü', shift: 'Ü'),
          KeyData.char(',', shift: ';', flex: 1.5)
        ),
      'ru_RU' => (
          'йцукенгшщз',
          KeyData.char('х', shift: 'Х'),
          KeyData.char('ъ', shift: 'Ъ'),
          KeyData.char('\\', shift: '/', flex: 1.5)
        ),
      'el_GR' => (
          ';ςερτυθιοπ',
          KeyData.char('[', shift: '{'),
          KeyData.char(']', shift: '}'),
          KeyData.char('\\', shift: '|', flex: 1.5)
        ),
      _ => (
          'qwertyuiop',
          KeyData.char('[', shift: '{'),
          KeyData.char(']', shift: '}'),
          KeyData.char('\\', shift: '|', flex: 1.5)
        ),
    };

    return [
      KeyData.function('Tab', LogicalKeyboardKey.tab, insert: '\t', flex: 1.5),
      for (final c in letters.split('')) KeyData.char(c),
      k1,
      k2,
      k3,
    ];
  }

  static List<KeyData> _capsMain(String layoutId) {
    final (letters, k1, k2) = switch (layoutId) {
      'de_DE' => ('asdfghjkl', KeyData.char('ö', shift: 'Ö'), KeyData.char('ä', shift: 'Ä')),
      'fr_FR' => ('qsdfghjkl', KeyData.char('m', shift: 'M'), KeyData.char('ù', shift: 'Ù')),
      'es_ES' => ('asdfghjkl', KeyData.char('ñ', shift: 'Ñ'), KeyData.char('{', shift: '[')),
      'nordic' => ('asdfghjkl', KeyData.char('ö', shift: 'Ö'), KeyData.char('ä', shift: 'Ä')),
      'tr_TR' => ('asdfghjkl', KeyData.char('ş', shift: 'Ş'), KeyData.char('i', shift: 'İ')),
      'ru_RU' => ('фывапролд', KeyData.char('ж', shift: 'Ж'), KeyData.char('э', shift: 'Э')),
      'el_GR' => ('ασδφγηξκλ', KeyData.char('´', shift: '¨'), KeyData.char("'", shift: '"')),
      'ko_KR' => ('ㅁㄴㅇㄹㅎㅗㅓㅏㅣ', KeyData.char(';', shift: ':'), KeyData.char("'", shift: '"')),
      _ => ('asdfghjkl', KeyData.char(';', shift: ':'), KeyData.char("'", shift: '"')),
    };

    return [
      KeyData.lock(LockKey.capsLock, label: 'Caps', flex: 1.8),
      for (final c in letters.split('')) KeyData.char(c),
      k1,
      k2,
      KeyData.enter(label: 'Enter ↵', flex: 2.2),
    ];
  }

  static List<KeyData> _shiftMain(String layoutId) {
    // ISO layouts have an extra key between left Shift and the first letter.
    final (KeyData? isoKey, String letters, KeyData p1, KeyData p2, KeyData p3) =
        switch (layoutId) {
      'en_GB' => (
          KeyData.char('\\', shift: '|'),
          'zxcvbnm',
          KeyData.char(',', shift: '<'),
          KeyData.char('.', shift: '>'),
          KeyData.char('/', shift: '?')
        ),
      'de_DE' => (
          KeyData.char('<', shift: '>'),
          'yxcvbnm',
          KeyData.char(',', shift: ';'),
          KeyData.char('.', shift: ':'),
          KeyData.char('-', shift: '_')
        ),
      'fr_FR' => (
          KeyData.char('<', shift: '>'),
          'wxcvbn',
          KeyData.char(',', shift: '?'),
          KeyData.char(';', shift: '.'),
          KeyData.char(':', shift: '/')
        ),
      'es_ES' => (
          KeyData.char('<', shift: '>'),
          'zxcvbnm',
          KeyData.char(',', shift: ';'),
          KeyData.char('.', shift: ':'),
          KeyData.char('-', shift: '_')
        ),
      'nordic' => (
          KeyData.char('<', shift: '>'),
          'zxcvbnm',
          KeyData.char(',', shift: ';'),
          KeyData.char('.', shift: ':'),
          KeyData.char('-', shift: '_')
        ),
      'tr_TR' => (
          KeyData.char('<', shift: '>'),
          'zxcvbnm',
          KeyData.char('ö', shift: 'Ö'),
          KeyData.char('ç', shift: 'Ç'),
          KeyData.char('.', shift: ':')
        ),
      'ru_RU' => (
          KeyData.char('ё', shift: 'Ё'),
          'ячсмить',
          KeyData.char('б', shift: 'Б'),
          KeyData.char('ю', shift: 'Ю'),
          KeyData.char('.', shift: ',')
        ),
      'el_GR' => (
          null,
          'ζχψωβνμ',
          KeyData.char(',', shift: '<'),
          KeyData.char('.', shift: '>'),
          KeyData.char('/', shift: '?')
        ),
      'ko_KR' => (
          null,
          'ㅋㅌㅊㅍㅠㅜㅡ',
          KeyData.char(',', shift: '<'),
          KeyData.char('.', shift: '>'),
          KeyData.char('/', shift: '?')
        ),
      _ => (
          null,
          'zxcvbnm',
          KeyData.char(',', shift: '<'),
          KeyData.char('.', shift: '>'),
          KeyData.char('/', shift: '?')
        ),
    };

    return [
      if (isoKey != null) ...[
        KeyData.modifier(ModifierKey.shift, label: 'Shift', flex: 1.3),
        isoKey,
      ] else
        KeyData.modifier(ModifierKey.shift, label: 'Shift', flex: 2.3),
      for (final c in letters.split('')) KeyData.char(c),
      p1,
      p2,
      p3,
      KeyData.modifier(ModifierKey.shift, label: 'Shift', flex: 2.7),
    ];
  }

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
