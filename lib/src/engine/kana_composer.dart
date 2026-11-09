import 'package:flutter/widgets.dart';

import 'text_input_engine.dart';

/// Algorithmic kana dakuten (voicing) and handakuten (semi-voicing) composer
/// for Japanese keyboards.
///
/// Converts base kana to voiced/semi-voiced equivalents:
/// * Dakuten: `か` + `゛` = `が`, `は` + `゛` = `ば`, `ウ` + `゛` = `ヴ`.
/// * Handakuten: `は` + `゜` = `ぱ`, `ヒ` + `゜` = `ピ`.
/// * Backspace decomposition: `が` -> `か`, `ぱ` -> `は`.
class KanaComposer {
  const KanaComposer._();

  /// Dakuten mapping table for voiced sounds (濁点).
  static const Map<String, String> dakutenMap = {
    'か': 'が', 'き': 'ぎ', 'く': 'ぐ', 'け': 'げ', 'こ': 'ご',
    'さ': 'ざ', 'し': 'じ', 'す': 'ず', 'せ': 'ぜ', 'そ': 'ぞ',
    'た': 'だ', 'ち': 'ぢ', 'つ': 'づ', 'て': 'で', 'と': 'ど',
    'は': 'ば', 'ひ': 'び', 'ふ': 'ぶ', 'へ': 'べ', 'ほ': 'ぼ',
    'う': 'ゔ',
    'カ': 'ガ', 'キ': 'ギ', 'ク': 'グ', 'ケ': 'ゲ', 'コ': 'ゴ',
    'サ': 'ザ', 'シ': 'ジ', 'ス': 'ズ', 'セ': 'ゼ', 'ソ': 'ゾ',
    'タ': 'ダ', 'チ': 'ヂ', 'ツ': 'ヅ', 'テ': 'デ', 'ト': 'ド',
    'ハ': 'バ', 'ヒ': 'ビ', 'フ': 'ブ', 'ヘ': 'ベ', 'ホ': 'ボ',
    'ウ': 'ヴ',
  };

  /// Handakuten mapping table for semi-voiced sounds (半濁点).
  static const Map<String, String> handakutenMap = {
    'は': 'ぱ', 'ひ': 'ぴ', 'ふ': 'ぷ', 'へ': 'ぺ', 'ほ': 'ぽ',
    'ハ': 'パ', 'ヒ': 'ピ', 'フ': 'プ', 'ヘ': 'ペ', 'ホ': 'ポ',
  };

  static final Map<String, String> _decomposeDakuten = {
    for (final e in dakutenMap.entries) e.value: e.key,
  };

  static final Map<String, String> _decomposeHandakuten = {
    for (final e in handakutenMap.entries) e.value: e.key,
  };

  /// Whether [char] is a dakuten or handakuten mark (`゛`, `゜`).
  static bool isVoicingMark(String char) =>
      char == '゛' || char == '゜' || char == '\u309B' || char == '\u309C';

  /// Whether [char] is a voiced or semi-voiced Kana that can be decomposed.
  static bool canDecompose(String char) =>
      _decomposeDakuten.containsKey(char) ||
      _decomposeHandakuten.containsKey(char);

  /// Attempts to compose [lastChar] with [mark].
  static String? composeMark(String lastChar, String mark) {
    if (mark == '゛' || mark == '\u309B') {
      return dakutenMap[lastChar];
    } else if (mark == '゜' || mark == '\u309C') {
      return handakutenMap[lastChar];
    }
    return null;
  }

  /// Decomposes voiced/semi-voiced [char] back to base kana.
  static String? decomposeChar(String char) {
    return _decomposeHandakuten[char] ?? _decomposeDakuten[char];
  }

  /// Composes a voicing mark into [value], updating the character before the cursor.
  static TextEditingValue compose({
    required TextEditingValue value,
    required String mark,
  }) {
    if (!isVoicingMark(mark)) {
      return TextInputEngine.insert(value, mark);
    }

    final sel = value.selection;
    if (sel.isValid && !sel.isCollapsed) {
      return TextInputEngine.insert(value, mark);
    }

    final offset = sel.isValid ? sel.baseOffset : value.text.length;
    if (offset <= 0) {
      return TextInputEngine.insert(value, mark);
    }

    final before = value.text.substring(0, offset);
    final after = value.text.substring(offset);
    final lastChar = before.characters.last;

    final composed = composeMark(lastChar, mark);
    if (composed != null) {
      final prefix = before.substring(0, before.length - lastChar.length);
      final newText = '$prefix$composed$after';
      final newOffset = prefix.length + composed.length;
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newOffset),
        composing: TextRange.empty,
      );
    }

    return TextInputEngine.insert(value, mark);
  }

  /// Decomposes a voiced kana before the cursor on backspace.
  static TextEditingValue backspace({
    required TextEditingValue value,
  }) {
    final sel = value.selection;
    if (sel.isValid && !sel.isCollapsed) {
      return TextInputEngine.deleteBackward(value);
    }

    final offset = sel.isValid ? sel.baseOffset : value.text.length;
    if (offset <= 0) return value;

    final before = value.text.substring(0, offset);
    final after = value.text.substring(offset);
    final lastChar = before.characters.last;

    final decomposed = decomposeChar(lastChar);
    if (decomposed != null) {
      final prefix = before.substring(0, before.length - lastChar.length);
      final newText = '$prefix$decomposed$after';
      final newOffset = prefix.length + decomposed.length;
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newOffset),
        composing: TextRange.empty,
      );
    }

    return TextInputEngine.deleteBackward(value);
  }
}
