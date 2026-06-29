import 'package:flutter/widgets.dart';

/// Semantic kind of a keyboard key. Drives how the controller reacts to a tap.
enum KeyKind {
  /// Inserts [KeyData.text] (or [KeyData.shiftText] when shifted).
  character,

  /// Deletes backward. Supports long-press continuous delete.
  backspace,

  /// Toggles shift / caps-lock.
  shift,

  /// Inserts a space.
  space,

  /// Performs the field's [TextInputAction] (or newline for multiline).
  enter,

  /// Performs an explicit action regardless of layout (e.g. a "Go" key).
  action,

  /// Switches to another layout page (see [KeyData.switchTarget]).
  switchLayout,

  /// A fully developer-defined key rendered via [KeyData.builder].
  custom,

  /// Visual spacer that does nothing.
  spacer,
}

/// Immutable description of a single key.
///
/// Use the named factories for the common cases:
/// ```dart
/// KeyData.char('a');
/// KeyData.backspace();
/// KeyData.switchTo('123', label: '123');
/// ```
@immutable
class KeyData {
  const KeyData({
    required this.kind,
    this.text,
    this.shiftText,
    this.label,
    this.icon,
    this.subLabel,
    this.switchTarget,
    this.builder,
    this.flex = 1,
    this.repeatable = false,
  });

  /// A character key. [shiftText] defaults to the upper-cased [char].
  factory KeyData.char(String char, {String? shift, double flex = 1}) {
    return KeyData(
      kind: KeyKind.character,
      text: char,
      shiftText: shift ?? char.toUpperCase(),
      flex: flex,
      repeatable: true,
    );
  }

  /// A character key with a secondary hint label (e.g. phone `2 ABC`).
  factory KeyData.charWithHint(String char, String hint, {double flex = 1}) {
    return KeyData(
      kind: KeyKind.character,
      text: char,
      shiftText: char,
      subLabel: hint,
      flex: flex,
      repeatable: true,
    );
  }

  /// A literal symbol key whose value never changes with shift.
  factory KeyData.symbol(String value, {String? label, double flex = 1}) {
    return KeyData(
      kind: KeyKind.character,
      text: value,
      shiftText: value,
      label: label ?? value,
      flex: flex,
      repeatable: true,
    );
  }

  factory KeyData.backspace({double flex = 1}) =>
      KeyData(kind: KeyKind.backspace, icon: _kBackspace, flex: flex);

  factory KeyData.shift({double flex = 1}) =>
      KeyData(kind: KeyKind.shift, icon: _kShift, flex: flex);

  factory KeyData.space({String? label, double flex = 5}) =>
      KeyData(kind: KeyKind.space, label: label, text: ' ', flex: flex);

  factory KeyData.enter({String? label, IconData? icon, double flex = 2}) =>
      KeyData(kind: KeyKind.enter, label: label, icon: icon ?? _kEnter, flex: flex);

  factory KeyData.switchTo(String target, {required String label, double flex = 2}) =>
      KeyData(kind: KeyKind.switchLayout, switchTarget: target, label: label, flex: flex);

  factory KeyData.spacer({double flex = 1}) =>
      KeyData(kind: KeyKind.spacer, flex: flex);

  /// A developer-defined key. [builder] paints the content; [onTapText] (if
  /// any) is inserted when tapped, otherwise [builder] handles interaction.
  factory KeyData.custom(WidgetBuilder builder, {double flex = 1, String? insert}) =>
      KeyData(kind: KeyKind.custom, builder: builder, text: insert, flex: flex);

  final KeyKind kind;

  /// Text inserted when the key is tapped (unshifted).
  final String? text;

  /// Text inserted when the keyboard is shifted.
  final String? shiftText;

  /// Display label override. When null the key shows [text]/[icon].
  final String? label;

  /// Small secondary label (e.g. the `ABC` under `2`).
  final String? subLabel;

  /// Icon shown instead of a text label.
  final IconData? icon;

  /// Target page id for [KeyKind.switchLayout] keys.
  final String? switchTarget;

  /// Builder for [KeyKind.custom] keys.
  final WidgetBuilder? builder;

  /// Width weight relative to sibling keys in the same row.
  final double flex;

  /// Whether holding the key repeats its action (chars + backspace).
  final bool repeatable;

  /// Resolves the label to render for the given shift state.
  String? resolveLabel({required bool shifted}) {
    if (label != null) return label;
    if (kind == KeyKind.character) {
      return shifted ? (shiftText ?? text) : text;
    }
    return null;
  }

  /// Resolves the text to insert for the given shift state.
  String? resolveText({required bool shifted}) {
    if (kind == KeyKind.space) return ' ';
    if (kind != KeyKind.character) return text;
    return shifted ? (shiftText ?? text) : text;
  }
}

// Private icon constants so callers don't need to import material.
const IconData _kBackspace =
    IconData(0xe157, fontFamily: 'MaterialIcons', matchTextDirection: true);
const IconData _kShift =
    IconData(0xe5d8, fontFamily: 'MaterialIcons'); // arrow_upward
const IconData _kEnter =
    IconData(0xe31b, fontFamily: 'MaterialIcons'); // keyboard_return
