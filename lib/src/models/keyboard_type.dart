/// Built-in keyboard types.
///
/// Note: Dart reserves the word `default`, so the standard alphanumeric
/// keyboard is named [VKeyboardType.standard] (not `default`).
enum VKeyboardType {
  /// Full QWERTY with letters, numbers, symbols and emoji pages.
  standard('QWERTY'),

  /// Full QWERTY with letters, numbers and symbols pages, without emoji.
  text('Text'),

  /// Digits only (0-9).
  number('Number'),

  /// Digits plus a decimal separator.
  decimal('Decimal'),

  /// Telephone-style pad (digits, `+`, `*`, `#`).
  phone('Phone'),

  /// Large numeric pad for PIN entry.
  pin('PIN'),

  /// QWERTY tuned for password entry (no auto-shift, obscured field).
  password('Password'),

  /// QWERTY with `@` and `.` promoted for email entry.
  email('Email'),

  /// QWERTY with `/`, `.` and a `.com` key for URL entry.
  url('URL'),

  /// QWERTY where the action key inserts a newline.
  multiline('Multiline'),

  /// A full physical-style desktop keyboard (Windows OSK-like): function row,
  /// number row, full QWERTY, modifiers, navigation cluster, numeric keypad and
  /// optional media keys. Responsive — sections collapse on narrow windows.
  desktop('Desktop'),

  /// A developer-supplied custom layout.
  custom('Custom');

  const VKeyboardType(this.label);

  /// Human-readable display label for this keyboard type (e.g. 'QWERTY', 'Number', 'PIN').
  final String label;
}
