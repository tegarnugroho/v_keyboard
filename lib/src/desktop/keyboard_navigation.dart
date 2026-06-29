import 'package:flutter/widgets.dart';

import '../models/key_intents.dart';

/// Pure cursor / selection navigation over [TextEditingValue].
///
/// Mirrors native [EditableText] behaviour for *logical* lines: horizontal
/// char/word movement, Home/End (line, or document with Ctrl), and vertical
/// up/down/page movement that preserves the column. `extend` keeps the
/// selection base fixed and moves only the extent (Shift+arrow); `word` jumps
/// by word (Ctrl+arrow). Operates on logical newlines — for soft-wrapped lines
/// it moves by paragraph, which is the documented limitation.
class KeyboardNavigation {
  const KeyboardNavigation._();

  static const int _pageLines = 10;

  static TextEditingValue move(
    TextEditingValue value,
    NavIntent intent, {
    required bool extend,
    required bool word,
  }) {
    final text = value.text;
    final sel = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: text.length);

    switch (intent) {
      case NavIntent.left:
        return _horizontal(text, sel, forward: false, extend: extend, word: word);
      case NavIntent.right:
        return _horizontal(text, sel, forward: true, extend: extend, word: word);
      case NavIntent.home:
        return _toLineEdge(text, sel, start: true, extend: extend, doc: word);
      case NavIntent.end:
        return _toLineEdge(text, sel, start: false, extend: extend, doc: word);
      case NavIntent.up:
        return _vertical(text, sel, down: false, extend: extend, lines: 1);
      case NavIntent.down:
        return _vertical(text, sel, down: true, extend: extend, lines: 1);
      case NavIntent.pageUp:
        return _vertical(text, sel, down: false, extend: extend, lines: _pageLines);
      case NavIntent.pageDown:
        return _vertical(text, sel, down: true, extend: extend, lines: _pageLines);
    }
  }

  static TextEditingValue _result(
      TextEditingValue base, TextSelection sel, int extent, bool extend) {
    final selection = extend
        ? TextSelection(baseOffset: sel.baseOffset, extentOffset: extent)
        : TextSelection.collapsed(offset: extent);
    return base.copyWith(selection: selection);
  }

  static TextEditingValue _horizontal(
    String text,
    TextSelection sel, {
    required bool forward,
    required bool extend,
    required bool word,
  }) {
    final value = TextEditingValue(text: text, selection: sel);
    if (!extend && !sel.isCollapsed) {
      // A bare arrow collapses a range to its leading/trailing edge.
      return value.copyWith(
        selection: TextSelection.collapsed(offset: forward ? sel.end : sel.start),
      );
    }
    final from = sel.extentOffset;
    final to = forward
        ? (word ? _nextWord(text, from) : _nextGrapheme(text, from))
        : (word ? _prevWord(text, from) : _prevGrapheme(text, from));
    return _result(value, sel, to, extend);
  }

  static TextEditingValue _toLineEdge(
    String text,
    TextSelection sel, {
    required bool start,
    required bool extend,
    required bool doc,
  }) {
    final value = TextEditingValue(text: text, selection: sel);
    final from = sel.extentOffset;
    final int to;
    if (doc) {
      to = start ? 0 : text.length;
    } else {
      to = start ? _lineStart(text, from) : _lineEnd(text, from);
    }
    return _result(value, sel, to, extend);
  }

  static TextEditingValue _vertical(
    String text,
    TextSelection sel, {
    required bool down,
    required bool extend,
    required int lines,
  }) {
    final value = TextEditingValue(text: text, selection: sel);
    final from = sel.extentOffset;
    final lineStart = _lineStart(text, from);
    final column = from - lineStart;

    int target = lineStart;
    if (down) {
      for (var i = 0; i < lines; i++) {
        final end = _lineEnd(text, target);
        if (end >= text.length) {
          // No line below: go to end of text.
          return _result(value, sel, text.length, extend);
        }
        target = end + 1; // start of next line
      }
    } else {
      for (var i = 0; i < lines; i++) {
        if (target == 0) {
          return _result(value, sel, 0, extend);
        }
        target = _lineStart(text, target - 1);
      }
    }
    final targetLineEnd = _lineEnd(text, target);
    final to = (target + column).clamp(target, targetLineEnd);
    return _result(value, sel, to, extend);
  }

  // ---- offset helpers -------------------------------------------------------

  static int _lineStart(String text, int offset) {
    if (offset <= 0) return 0;
    final nl = text.lastIndexOf('\n', offset - 1);
    return nl == -1 ? 0 : nl + 1;
  }

  static int _lineEnd(String text, int offset) {
    final nl = text.indexOf('\n', offset);
    return nl == -1 ? text.length : nl;
  }

  static int _nextGrapheme(String text, int offset) {
    if (offset >= text.length) return text.length;
    if (offset + 1 < text.length &&
        _isHigh(text.codeUnitAt(offset)) &&
        _isLow(text.codeUnitAt(offset + 1))) {
      return offset + 2;
    }
    return offset + 1;
  }

  static int _prevGrapheme(String text, int offset) {
    if (offset <= 0) return 0;
    if (offset >= 2 &&
        _isLow(text.codeUnitAt(offset - 1)) &&
        _isHigh(text.codeUnitAt(offset - 2))) {
      return offset - 2;
    }
    return offset - 1;
  }

  static int _nextWord(String text, int offset) {
    var i = offset;
    while (i < text.length && _isSpace(text.codeUnitAt(i))) {
      i++;
    }
    while (i < text.length && !_isSpace(text.codeUnitAt(i))) {
      i++;
    }
    return i;
  }

  static int _prevWord(String text, int offset) {
    var i = offset;
    while (i > 0 && _isSpace(text.codeUnitAt(i - 1))) {
      i--;
    }
    while (i > 0 && !_isSpace(text.codeUnitAt(i - 1))) {
      i--;
    }
    return i;
  }

  static bool _isSpace(int c) =>
      c == 0x20 || c == 0x09 || c == 0x0A || c == 0x0D;
  static bool _isHigh(int c) => c >= 0xD800 && c <= 0xDBFF;
  static bool _isLow(int c) => c >= 0xDC00 && c <= 0xDFFF;
}
