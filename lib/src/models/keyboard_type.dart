/// Built-in keyboard types.
///
/// Note: Dart reserves the word `default`, so the standard alphanumeric
/// keyboard is named [VirtualKeyboardType.standard] (not `default`).
enum VirtualKeyboardType {
  /// Full QWERTY with letters, numbers and symbols pages.
  standard,

  /// Digits only (0-9).
  number,

  /// Digits plus a decimal separator.
  decimal,

  /// Telephone-style pad (digits, `+`, `*`, `#`).
  phone,

  /// Large numeric pad for PIN entry.
  pin,

  /// QWERTY tuned for password entry (no auto-shift, obscured field).
  password,

  /// QWERTY with `@` and `.` promoted for email entry.
  email,

  /// QWERTY with `/`, `.` and a `.com` key for URL entry.
  url,

  /// QWERTY where the action key inserts a newline.
  multiline,

  /// A developer-supplied custom layout.
  custom,
}
