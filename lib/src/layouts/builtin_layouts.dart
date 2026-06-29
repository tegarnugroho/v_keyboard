import '../models/key_data.dart';
import '../models/keyboard_layout.dart';
import '../models/keyboard_type.dart';

/// Built-in keyboard layouts and the resolver that maps a
/// [VirtualKeyboardType] to a [KeyboardLayout].
class BuiltinLayouts {
  const BuiltinLayouts._();

  /// Resolves [type] to a layout. [custom] is required (and returned) for
  /// [VirtualKeyboardType.custom].
  static KeyboardLayout resolve(
    VirtualKeyboardType type, {
    KeyboardLayout? custom,
  }) {
    switch (type) {
      case VirtualKeyboardType.standard:
      case VirtualKeyboardType.password:
        return qwerty;
      case VirtualKeyboardType.email:
        return email;
      case VirtualKeyboardType.url:
        return url;
      case VirtualKeyboardType.multiline:
        return multiline;
      case VirtualKeyboardType.number:
        return number;
      case VirtualKeyboardType.decimal:
        return decimal;
      case VirtualKeyboardType.phone:
        return phone;
      case VirtualKeyboardType.pin:
        return pin;
      case VirtualKeyboardType.custom:
        assert(custom != null, 'A custom layout must be provided.');
        return custom ?? qwerty;
    }
  }

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
          KeyData.switchTo('123', label: '123', flex: 1.5),
          KeyData.symbol(',', flex: 1),
          KeyData.space(),
          KeyData.symbol('.', flex: 1),
          KeyData.enter(flex: 2),
        ],
      ],
      '123': _numericSymbolPage('symbols'),
      'symbols': _symbolPage('123'),
    },
  );

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

  static final KeyboardLayout number = KeyboardLayout(
    id: 'number',
    initialPage: 'num',
    pages: {
      'num': [
        _symbols('123'),
        _symbols('456'),
        _symbols('789'),
        [KeyData.spacer(), KeyData.symbol('0'), KeyData.backspace()],
      ],
    },
  );

  // ---- Decimal --------------------------------------------------------------

  static final KeyboardLayout decimal = KeyboardLayout(
    id: 'decimal',
    initialPage: 'num',
    pages: {
      'num': [
        _symbols('123'),
        _symbols('456'),
        _symbols('789'),
        [KeyData.symbol('.'), KeyData.symbol('0'), KeyData.backspace()],
      ],
    },
  );

  // ---- Phone ----------------------------------------------------------------

  static final KeyboardLayout phone = KeyboardLayout(
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
        [KeyData.spacer(), KeyData.backspace(flex: 1)],
      ],
    },
  );

  // ---- PIN ------------------------------------------------------------------

  static final KeyboardLayout pin = KeyboardLayout(
    id: 'pin',
    initialPage: 'num',
    pages: {
      'num': [
        _symbols('123'),
        _symbols('456'),
        _symbols('789'),
        [KeyData.spacer(), KeyData.symbol('0'), KeyData.backspace()],
      ],
    },
  );
}
