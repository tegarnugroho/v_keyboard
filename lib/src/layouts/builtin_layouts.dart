import '../models/key_data.dart';
import '../models/keyboard_layout.dart';
import '../models/keyboard_type.dart';
import 'desktop_layouts.dart';

/// Built-in keyboard layouts and the resolver that maps a
/// [VKeyboardType] to a [KeyboardLayout].
class BuiltinLayouts {
  const BuiltinLayouts._();

  /// Resolves [type] to a layout. [custom] is required (and returned) for
  /// [VKeyboardType.custom].
  static KeyboardLayout resolve(
    VKeyboardType type, {
    KeyboardLayout? custom,
    bool numericAction = false,
  }) {
    switch (type) {
      case VKeyboardType.standard:
      case VKeyboardType.password:
        return qwerty;
      case VKeyboardType.email:
        return email;
      case VKeyboardType.url:
        return url;
      case VKeyboardType.multiline:
        return multiline;
      case VKeyboardType.desktop:
        return custom ?? DesktopLayouts.layout;
      case VKeyboardType.number:
        return _number(action: numericAction);
      case VKeyboardType.decimal:
        return _decimal(action: numericAction);
      case VKeyboardType.phone:
        return _phone(action: numericAction);
      case VKeyboardType.pin:
        return _pin(action: numericAction);
      case VKeyboardType.custom:
        assert(custom != null, 'A custom layout must be provided.');
        return custom ?? qwerty;
    }
  }

  /// The action/enter key when enabled, otherwise a spacer — used to fill an
  /// empty slot in a numeric pad.
  static KeyData _actionOrSpacer(bool action, {double flex = 1}) =>
      action ? KeyData.enter(flex: flex) : KeyData.spacer(flex: flex);

  /// Full-width action/enter row, appended only when the pad has no empty slot
  /// to host the key (e.g. the decimal pad).
  static List<List<KeyData>> _actionRow(bool action) =>
      action ? [[KeyData.enter(flex: 1)]] : const [];

  // ---- Alphabetic (QWERTY) with 123 and symbols pages -----------------------

  static List<KeyData> _row(String chars) =>
      chars.split('').map((c) => KeyData.char(c)).toList();

  static final KeyboardLayout qwerty = KeyboardLayout(
    id: 'qwerty',
    initialPage: 'abc',
    pages: {
      'abc': [
        _row('qwertyuiop'),
        _row('asdfghjkl'),
        [
          KeyData.shift(flex: 1.5),
          ..._row('zxcvbnm'),
          KeyData.backspace(flex: 1.5),
        ],
        [
          KeyData.switchTo('123', label: '123', flex: 1.4),
          KeyData.switchTo('emoji', label: '☺', flex: 1.1),
          KeyData.symbol(',', flex: 1),
          KeyData.space(flex: 4),
          KeyData.symbol('.', flex: 1),
          KeyData.enter(flex: 2),
        ],
      ],
      '123': _numericSymbolPage('symbols'),
      'symbols': _symbolPage('123'),
      'emoji': emojiPage,
    },
  );

  /// A simple emoji page (one grid of common emoji + an ABC/space/⌫ bar).
  /// Switched to via an `☺` key and back via `ABC`.
  static final List<List<KeyData>> emojiPage = [
    _emojis(['😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '😊', '🙂']),
    _emojis(['😉', '😍', '😘', '😗', '😜', '🤔', '🤨', '😐', '😴', '😎']),
    _emojis(['🥳', '😭', '😡', '👍', '👎', '👏', '🙏', '💪', '🔥', '✨']),
    _emojis(['❤️', '🧡', '💛', '💚', '💙', '💜', '🎉', '⭐', '🙌', '👀']),
    [
      KeyData.switchTo('abc', label: 'ABC', flex: 2),
      KeyData.space(flex: 6),
      KeyData.backspace(flex: 2),
    ],
  ];

  static List<KeyData> _emojis(List<String> emojis) =>
      emojis.map((e) => KeyData.symbol(e)).toList();

  static List<List<KeyData>> _numericSymbolPage(String moreTarget) => [
        _symbols('1234567890'),
        _symbols('-/:;()\$&@"'),
        [
          KeyData.switchTo(moreTarget, label: '#+=', flex: 1.5),
          ..._symbols('.,?!\''),
          KeyData.backspace(flex: 1.5),
        ],
        [
          KeyData.switchTo('abc', label: 'ABC', flex: 1.5),
          KeyData.space(),
          KeyData.enter(flex: 2),
        ],
      ];

  static List<List<KeyData>> _symbolPage(String backTarget) => [
        _symbols('[]{}#%^*+='),
        _symbols('_\\|~<>€£¥•'),
        [
          KeyData.switchTo(backTarget, label: '123', flex: 1.5),
          ..._symbols('.,?!\''),
          KeyData.backspace(flex: 1.5),
        ],
        [
          KeyData.switchTo('abc', label: 'ABC', flex: 1.5),
          KeyData.space(),
          KeyData.enter(flex: 2),
        ],
      ];

  static List<KeyData> _symbols(String chars) =>
      chars.split('').map((c) => KeyData.symbol(c)).toList();

  // ---- Email ----------------------------------------------------------------

  static final KeyboardLayout email = KeyboardLayout(
    id: 'email',
    initialPage: 'abc',
    pages: {
      'abc': [
        _row('qwertyuiop'),
        _row('asdfghjkl'),
        [
          KeyData.shift(flex: 1.5),
          ..._row('zxcvbnm'),
          KeyData.backspace(flex: 1.5),
        ],
        [
          KeyData.switchTo('123', label: '123', flex: 1.5),
          KeyData.symbol('@', flex: 1.4),
          KeyData.space(flex: 4),
          KeyData.symbol('.', flex: 1),
          KeyData.enter(flex: 2),
        ],
      ],
      '123': _numericSymbolPage('symbols'),
      'symbols': _symbolPage('123'),
    },
  );

  // ---- URL ------------------------------------------------------------------

  static final KeyboardLayout url = KeyboardLayout(
    id: 'url',
    initialPage: 'abc',
    pages: {
      'abc': [
        _row('qwertyuiop'),
        _row('asdfghjkl'),
        [
          KeyData.shift(flex: 1.5),
          ..._row('zxcvbnm'),
          KeyData.backspace(flex: 1.5),
        ],
        [
          KeyData.switchTo('123', label: '123', flex: 1.4),
          KeyData.symbol('/', flex: 1),
          KeyData.symbol('.', flex: 1),
          KeyData.space(flex: 3),
          KeyData.symbol('.com', label: '.com', flex: 1.8),
          KeyData.enter(flex: 1.8),
        ],
      ],
      '123': _numericSymbolPage('symbols'),
      'symbols': _symbolPage('123'),
    },
  );

  // ---- Multiline ------------------------------------------------------------

  static final KeyboardLayout multiline = KeyboardLayout(
    id: 'multiline',
    initialPage: 'abc',
    pages: {
      'abc': [
        _row('qwertyuiop'),
        _row('asdfghjkl'),
        [
          KeyData.shift(flex: 1.5),
          ..._row('zxcvbnm'),
          KeyData.backspace(flex: 1.5),
        ],
        [
          KeyData.switchTo('123', label: '123', flex: 1.5),
          KeyData.symbol(',', flex: 1),
          KeyData.space(),
          KeyData.symbol('.', flex: 1),
          // Enter inserts a newline for multiline fields (handled by session).
          KeyData.enter(label: '⏎', flex: 2),
        ],
      ],
      '123': _numericSymbolPage('symbols'),
      'symbols': _symbolPage('123'),
    },
  );

  // ---- Number ---------------------------------------------------------------

  static KeyboardLayout _number({bool action = false}) => KeyboardLayout(
        id: 'number',
        initialPage: 'num',
        pages: {
          'num': [
            _symbols('123'),
            _symbols('456'),
            _symbols('789'),
            // Enter fills the empty bottom-left slot.
            [_actionOrSpacer(action), KeyData.symbol('0'), KeyData.backspace()],
          ],
        },
      );

  // ---- Decimal --------------------------------------------------------------

  static KeyboardLayout _decimal({bool action = false}) => KeyboardLayout(
        id: 'decimal',
        initialPage: 'num',
        pages: {
          'num': [
            _symbols('123'),
            _symbols('456'),
            _symbols('789'),
            // No empty slot ('.' takes the left) → append a full-width row.
            [KeyData.symbol('.'), KeyData.symbol('0'), KeyData.backspace()],
            ..._actionRow(action),
          ],
        },
      );

  // ---- Phone ----------------------------------------------------------------

  static KeyboardLayout _phone({bool action = false}) => KeyboardLayout(
        id: 'phone',
        initialPage: 'num',
        pages: {
          'num': [
            [
              KeyData.charWithHint('1', ' '),
              KeyData.charWithHint('2', 'ABC'),
              KeyData.charWithHint('3', 'DEF'),
            ],
            [
              KeyData.charWithHint('4', 'GHI'),
              KeyData.charWithHint('5', 'JKL'),
              KeyData.charWithHint('6', 'MNO'),
            ],
            [
              KeyData.charWithHint('7', 'PQRS'),
              KeyData.charWithHint('8', 'TUV'),
              KeyData.charWithHint('9', 'WXYZ'),
            ],
            [
              KeyData.symbol('*'),
              KeyData.charWithHint('0', '+'),
              KeyData.symbol('#'),
            ],
            // Enter fills the empty bottom-left slot.
            [_actionOrSpacer(action), KeyData.backspace(flex: 1)],
          ],
        },
      );

  // ---- PIN ------------------------------------------------------------------

  static KeyboardLayout _pin({bool action = false}) => KeyboardLayout(
        id: 'pin',
        initialPage: 'num',
        pages: {
          'num': [
            _symbols('123'),
            _symbols('456'),
            _symbols('789'),
            // Enter fills the empty bottom-left slot.
            [_actionOrSpacer(action), KeyData.symbol('0'), KeyData.backspace()],
          ],
        },
      );
}
