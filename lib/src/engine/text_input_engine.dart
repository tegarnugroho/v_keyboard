import 'package:flutter/widgets.dart';

/// Pure text-editing operations on [TextEditingValue].
///
/// Every method returns a *new* value and never mutates its input. The engine
/// correctly handles collapsed cursors, ranged selections (selection
/// replacement / deletion) and UTF-16 surrogate pairs (e.g. emoji), keeping
/// the cursor in the right place — exactly like the native editor.
class TextInputEngine {
  const TextInputEngine._();

  /// Normalises a possibly-invalid selection to a concrete one at the end of
  /// the text (matching Flutter's behaviour when nothing is selected yet).
  static TextSelection _effectiveSelection(TextEditingValue value) {
    final sel = value.selection;
    if (sel.isValid) return sel;
    return TextSelection.collapsed(offset: value.text.length);
  }

  /// Replaces [selection]'s range with [replacement] and collapses the cursor
  /// after it.
  static TextEditingValue _replaceRange(
    TextEditingValue value,
    TextSelection selection,
    String replacement,
  ) {
    final text = selection.textBefore(value.text) +
        replacement +
        selection.textAfter(value.text);
    final offset = selection.start + replacement.length;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }

  /// Inserts [insertion] at the cursor, replacing any active selection.
  static TextEditingValue insert(TextEditingValue value, String insertion) {
    if (insertion.isEmpty) return value;
    return _replaceRange(value, _effectiveSelection(value), insertion);
  }

  /// Deletes backward: removes the selection if ranged, otherwise the single
  /// grapheme before the cursor.
  static TextEditingValue deleteBackward(TextEditingValue value) {
    final selection = _effectiveSelection(value);
    if (!selection.isCollapsed) {
      return _replaceRange(value, selection, '');
    }
    final offset = selection.baseOffset;
    if (offset <= 0) return value;
    final removed = _charsToDeleteBefore(value.text, offset);
    final newText =
        value.text.substring(0, offset - removed) + value.text.substring(offset);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: offset - removed),
      composing: TextRange.empty,
    );
  }

  /// Deletes forward: removes the selection if ranged, otherwise the single
  /// grapheme after the cursor.
  static TextEditingValue deleteForward(TextEditingValue value) {
    final selection = _effectiveSelection(value);
    if (!selection.isCollapsed) {
      return _replaceRange(value, selection, '');
    }
    final offset = selection.baseOffset;
    if (offset >= value.text.length) return value;
    final removed = _charsToDeleteAfter(value.text, offset);
    final newText =
        value.text.substring(0, offset) + value.text.substring(offset + removed);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: offset),
      composing: TextRange.empty,
    );
  }

  /// Inserts a newline at the cursor.
  static TextEditingValue newline(TextEditingValue value) => insert(value, '\n');

  /// Moves the collapsed cursor by [delta] graphemes (negative = left).
  static TextEditingValue moveCursor(TextEditingValue value, int delta) {
    final selection = _effectiveSelection(value);
    final base = selection.isCollapsed ? selection.baseOffset : selection.start;
    final next = (base + delta).clamp(0, value.text.length);
    return value.copyWith(selection: TextSelection.collapsed(offset: next));
  }

  /// Selects the entire text.
  static TextEditingValue selectAll(TextEditingValue value) {
    return value.copyWith(
      selection: TextSelection(baseOffset: 0, extentOffset: value.text.length),
    );
  }

  // Number of UTF-16 code units forming the grapheme ending at [offset].
  static int _charsToDeleteBefore(String text, int offset) {
    if (offset >= 2) {
      final low = text.codeUnitAt(offset - 1);
      final high = text.codeUnitAt(offset - 2);
      if (_isLowSurrogate(low) && _isHighSurrogate(high)) return 2;
    }
    return 1;
  }

  static int _charsToDeleteAfter(String text, int offset) {
    if (offset + 1 < text.length) {
      final high = text.codeUnitAt(offset);
      final low = text.codeUnitAt(offset + 1);
      if (_isHighSurrogate(high) && _isLowSurrogate(low)) return 2;
    }
    return 1;
  }

  static bool _isHighSurrogate(int c) => c >= 0xD800 && c <= 0xDBFF;
  static bool _isLowSurrogate(int c) => c >= 0xDC00 && c <= 0xDFFF;
}
