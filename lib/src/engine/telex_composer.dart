import 'package:flutter/widgets.dart';

import 'text_input_engine.dart';

/// Algorithmic Telex syllable composer for Vietnamese keyboards.
///
/// Implements standard Vietnamese Telex input rules:
/// * Vowel modifications:
///   * `aa` -> `â`, `aw` -> `ă`
///   * `ee` -> `ê`
///   * `oo` -> `ô`, `ow` -> `ơ`
///   * `uw` or standalone `w` -> `ư`
///   * `uow` -> `ươ`
///   * `dd` -> `đ`
/// * Toggle / Undo: typing the same modifier key immediately reverts to raw letters
///   (e.g. `â` + `a` -> `aa`, `đ` + `d` -> `dd`).
/// * Tone marks (Dấu thanh):
///   * `s` -> Sắc (acute: á, ắ, ấ, é, ế, í, ó, ố, ớ, ú, ứ, ý)
///   * `f` -> Huyền (grave: à, ằ, ầ, è, ề, ì, ò, ồ, ờ, ù, ừ, ỳ)
///   * `r` -> Hỏi (hook: ả, ẳ, ẩ, ẻ, ể, ỉ, ỏ, ổ, ở, ủ, ử, ỷ)
///   * `x` -> Ngã (tilde: ã, ẵ, ẫ, ẽ, ễ, ĩ, õ, ỗ, ỡ, ũ, ữ, ỹ)
///   * `j` -> Nặng (underdot: ạ, ặ, ậ, ẹ, ệ, ị, ọ, ộ, ợ, ụ, ự, ỵ)
///   * `z` -> Remove tone mark
/// * Smart tone placement: dynamically places the tone mark on the correct vowel
///   according to modern Vietnamese orthography (e.g. `việt`, `toán`, `thương`).
/// * Case preservation: maintains proper upper and lower casing.
class TelexComposer {
  const TelexComposer._();

  static const Map<String, List<String>> _vowelTones = {
    'a': ['a', 'á', 'à', 'ả', 'ã', 'ạ'],
    'ă': ['ă', 'ắ', 'ằ', 'ẳ', 'ẵ', 'ặ'],
    'â': ['â', 'ấ', 'ầ', 'ẩ', 'ẫ', 'ậ'],
    'e': ['e', 'é', 'è', 'ẻ', 'ẽ', 'ẹ'],
    'ê': ['ê', 'ế', 'ề', 'ể', 'ễ', 'ệ'],
    'i': ['i', 'í', 'ì', 'ỉ', 'ĩ', 'ị'],
    'o': ['o', 'ó', 'ò', 'ỏ', 'õ', 'ọ'],
    'ô': ['ô', 'ố', 'ồ', 'ổ', 'ỗ', 'ộ'],
    'ơ': ['ơ', 'ớ', 'ờ', 'ở', 'ỡ', 'ợ'],
    'u': ['u', 'ú', 'ù', 'ủ', 'ũ', 'ụ'],
    'ư': ['ư', 'ứ', 'ừ', 'ử', 'ữ', 'ự'],
    'y': ['y', 'ý', 'ỳ', 'ỷ', 'ỹ', 'ỵ'],
  };

  static final Map<String, (String base, int tone)> _charToTone = () {
    final map = <String, (String, int)>{};
    for (final entry in _vowelTones.entries) {
      final base = entry.key;
      final tones = entry.value;
      for (var t = 0; t < tones.length; t++) {
        map[tones[t]] = (base, t);
        map[tones[t].toUpperCase()] = (base, t);
      }
    }
    return map;
  }();

  static const Map<String, int> _toneKeys = {
    's': 1, // Sắc
    'f': 2, // Huyền
    'r': 3, // Hỏi
    'x': 4, // Ngã
    'j': 5, // Nặng
    'z': 0, // Hủy dấu
  };

  /// Whether [char] is a Telex modifier or tone key.
  static bool isTelexKey(String char) {
    if (char.length != 1) return false;
    final lower = char.toLowerCase();
    return lower == 'a' ||
        lower == 'w' ||
        lower == 'e' ||
        lower == 'o' ||
        lower == 'd' ||
        _toneKeys.containsKey(lower);
  }

  /// Checks if [char] is a Vietnamese vowel.
  static bool isVowel(String char) {
    if (char.length != 1) return false;
    return _charToTone.containsKey(char);
  }

  /// Composes a character into [value] using Vietnamese Telex rules.
  static TextEditingValue compose({
    required TextEditingValue value,
    required String char,
  }) {
    final sel = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);
    if (!sel.isCollapsed || sel.baseOffset < 0) {
      return TextInputEngine.insert(value, char);
    }

    final text = value.text;
    final offset = sel.baseOffset;

    // Find the word boundary before the cursor
    var wordStart = offset;
    while (wordStart > 0 && _isWordChar(text[wordStart - 1])) {
      wordStart--;
    }

    final word = text.substring(wordStart, offset);
    if (word.isEmpty) {
      // Standalone 'w' or 'W' produces 'ư' / 'Ư'
      if (char.toLowerCase() == 'w') {
        final replacement = char == 'W' ? 'Ư' : 'ư';
        return TextInputEngine.insert(value, replacement);
      }
      return TextInputEngine.insert(value, char);
    }

    final lowerChar = char.toLowerCase();
    final lowerWord = word.toLowerCase();

    // 1. Check diacritic modifications (a, w, e, o, d)
    final diacriticResult = _tryDiacritic(word, lowerWord, char, lowerChar);
    if (diacriticResult != null) {
      final newText = text.replaceRange(wordStart, offset, diacriticResult);
      final newOffset = wordStart + diacriticResult.length;
      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newOffset),
      );
    }

    // 2. Check tone mark modifications (s, f, r, x, j, z)
    final toneIndex = _toneKeys[lowerChar];
    if (toneIndex != null) {
      final toneResult = _tryTone(word, lowerWord, toneIndex, lowerChar);
      if (toneResult != null) {
        final newText = text.replaceRange(wordStart, offset, toneResult);
        final newOffset = wordStart + toneResult.length;
        return TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newOffset),
        );
      }
    }

    // Default: insert raw character
    return TextInputEngine.insert(value, char);
  }

  static bool _isWordChar(String char) {
    if (char.length != 1) return false;
    final code = char.codeUnitAt(0);
    // Standard Latin letters
    if ((code >= 0x41 && code <= 0x5A) || (code >= 0x61 && code <= 0x7A)) {
      return true;
    }
    // Vietnamese accented vowels and đ / Đ
    return _charToTone.containsKey(char) || char == 'đ' || char == 'Đ';
  }

  static String? _tryDiacritic(
    String word,
    String lowerWord,
    String char,
    String lowerChar,
  ) {
    final isUpper = char == char.toUpperCase() && char != lowerChar;

    // dd -> đ, DD -> Đ
    if (lowerChar == 'd') {
      if (lowerWord.endsWith('đ')) {
        // Toggle: đ + d -> dd
        final last = word[word.length - 1];
        final prefix = word.substring(0, word.length - 1);
        final restored = (last == 'Đ' ? 'D' : 'd') + (isUpper ? 'D' : 'd');
        return prefix + restored;
      }
      if (lowerWord.endsWith('d')) {
        final last = word[word.length - 1];
        final prefix = word.substring(0, word.length - 1);
        final replacement = (last == 'D' || isUpper) ? 'Đ' : 'đ';
        return prefix + replacement;
      }
    }

    // Vowel transformations
    final lastChar = word[word.length - 1];
    final lastInfo = _charToTone[lastChar];

    // aa -> â
    if (lowerChar == 'a') {
      if (lastInfo != null && lastInfo.$1 == 'â') {
        // Toggle: â + a -> aa
        final prefix = word.substring(0, word.length - 1);
        final base = lastChar == lastChar.toUpperCase() ? 'A' : 'a';
        final added = isUpper ? 'A' : 'a';
        return prefix + base + added;
      }
      if (lastInfo != null && lastInfo.$1 == 'a') {
        final prefix = word.substring(0, word.length - 1);
        final replacement =
            _formatVowel('â', lastInfo.$2, lastChar == lastChar.toUpperCase());
        return prefix + replacement;
      }
    }

    // ee -> ê
    if (lowerChar == 'e') {
      if (lastInfo != null && lastInfo.$1 == 'ê') {
        // Toggle: ê + e -> ee
        final prefix = word.substring(0, word.length - 1);
        final base = lastChar == lastChar.toUpperCase() ? 'E' : 'e';
        final added = isUpper ? 'E' : 'e';
        return prefix + base + added;
      }
      if (lastInfo != null && lastInfo.$1 == 'e') {
        final prefix = word.substring(0, word.length - 1);
        final replacement =
            _formatVowel('ê', lastInfo.$2, lastChar == lastChar.toUpperCase());
        return prefix + replacement;
      }
    }

    // oo -> ô
    if (lowerChar == 'o') {
      if (lastInfo != null && lastInfo.$1 == 'ô') {
        // Toggle: ô + o -> oo
        final prefix = word.substring(0, word.length - 1);
        final base = lastChar == lastChar.toUpperCase() ? 'O' : 'o';
        final added = isUpper ? 'O' : 'o';
        return prefix + base + added;
      }
      if (lastInfo != null && lastInfo.$1 == 'o') {
        final prefix = word.substring(0, word.length - 1);
        final replacement =
            _formatVowel('ô', lastInfo.$2, lastChar == lastChar.toUpperCase());
        return prefix + replacement;
      }
    }

    // 'w' modifications: aw -> ă, ow -> ơ, uw -> ư, uow -> ươ
    if (lowerChar == 'w') {
      // Toggle check
      if (lastInfo != null) {
        if (lastInfo.$1 == 'ă') {
          final prefix = word.substring(0, word.length - 1);
          final base = lastChar == lastChar.toUpperCase() ? 'A' : 'a';
          final added = isUpper ? 'W' : 'w';
          return prefix + base + added;
        }
        if (lastInfo.$1 == 'ơ') {
          final prefix = word.substring(0, word.length - 1);
          final base = lastChar == lastChar.toUpperCase() ? 'O' : 'o';
          final added = isUpper ? 'W' : 'w';
          return prefix + base + added;
        }
        if (lastInfo.$1 == 'ư') {
          final prefix = word.substring(0, word.length - 1);
          final base = lastChar == lastChar.toUpperCase() ? 'U' : 'u';
          final added = isUpper ? 'W' : 'w';
          return prefix + base + added;
        }
      }

      // Compound 'uo' + 'w' -> 'ươ'
      if (word.length >= 2) {
        final prevChar = word[word.length - 2];
        final prevInfo = _charToTone[prevChar];
        if (prevInfo != null &&
            (prevInfo.$1 == 'u' || prevInfo.$1 == 'ư') &&
            lastInfo != null &&
            lastInfo.$1 == 'o') {
          final prefix = word.substring(0, word.length - 2);
          final uRepl =
              _formatVowel('ư', 0, prevChar == prevChar.toUpperCase());
          final oRepl = _formatVowel(
              'ơ', lastInfo.$2, lastChar == lastChar.toUpperCase());
          return prefix + uRepl + oRepl;
        }
      }

      if (lastInfo != null) {
        if (lastInfo.$1 == 'a') {
          final prefix = word.substring(0, word.length - 1);
          final replacement = _formatVowel(
              'ă', lastInfo.$2, lastChar == lastChar.toUpperCase());
          return prefix + replacement;
        }
        if (lastInfo.$1 == 'o') {
          final prefix = word.substring(0, word.length - 1);
          final replacement = _formatVowel(
              'ơ', lastInfo.$2, lastChar == lastChar.toUpperCase());
          return prefix + replacement;
        }
        if (lastInfo.$1 == 'u') {
          final prefix = word.substring(0, word.length - 1);
          final replacement = _formatVowel(
              'ư', lastInfo.$2, lastChar == lastChar.toUpperCase());
          return prefix + replacement;
        }
      }

      // Standalone or after consonant 'w' -> 'ư'
      final uRepl = isUpper ? 'Ư' : 'ư';
      return word + uRepl;
    }

    return null;
  }

  static String? _tryTone(
    String word,
    String lowerWord,
    int requestedTone,
    String lowerChar,
  ) {
    // Collect all vowel indices in the word
    final vowelIndices = <int>[];
    for (var i = 0; i < word.length; i++) {
      if (_charToTone.containsKey(word[i])) {
        vowelIndices.add(i);
      }
    }

    if (vowelIndices.isEmpty) return null;

    // Determine target vowel index according to Vietnamese orthography
    final targetIdx = _findTargetVowel(word, vowelIndices);
    final targetChar = word[targetIdx];
    final targetInfo = _charToTone[targetChar]!;

    // Check toggle: if target vowel already has the requested tone, revert to neutral and append char
    if (requestedTone != 0 && targetInfo.$2 == requestedTone) {
      final neutralChar =
          _formatVowel(targetInfo.$1, 0, targetChar == targetChar.toUpperCase());
      final updated = word.substring(0, targetIdx) +
          neutralChar +
          word.substring(targetIdx + 1) +
          lowerChar;
      return updated;
    }

    // Apply tone
    final newVowel = _formatVowel(
      targetInfo.$1,
      requestedTone,
      targetChar == targetChar.toUpperCase(),
    );

    return word.substring(0, targetIdx) +
        newVowel +
        word.substring(targetIdx + 1);
  }

  /// Finds which vowel should receive the tone mark.
  static int _findTargetVowel(String word, List<int> vowelIndices) {
    if (vowelIndices.length == 1) return vowelIndices.first;

    // If any vowel already has a tone mark, target it (for replacing, toggling, or removing tone)
    for (final idx in vowelIndices) {
      if (_charToTone[word[idx]]!.$2 > 0) {
        return idx;
      }
    }

    // Check for modified vowels: â, ă, ê, ô, ơ, ư
    for (final idx in vowelIndices) {
      final base = _charToTone[word[idx]]!.$1;
      if (base == 'â' ||
          base == 'ă' ||
          base == 'ê' ||
          base == 'ô' ||
          base == 'ơ' ||
          base == 'ư') {
        // Exception: in 'ươ', tone mark goes on 'ơ'
        if (base == 'ư' &&
            vowelIndices.contains(idx + 1) &&
            _charToTone[word[idx + 1]]?.$1 == 'ơ') {
          return idx + 1;
        }
        return idx;
      }
    }

    final hasTrailingConsonant = vowelIndices.last < word.length - 1;

    // If syllable ends with a consonant (e.g. toan, hoang), tone goes on the last vowel in the group
    if (hasTrailingConsonant) {
      return vowelIndices.last;
    }

    // Open syllable (no trailing consonant)
    final cluster = vowelIndices.map((i) => _charToTone[word[i]]!.$1).join();
    if (cluster == 'oa' || cluster == 'oe' || cluster == 'uy') {
      return vowelIndices.last; // Modern rule: hóa, hòe, thủy
    }

    return vowelIndices.first; // e.g. mía, múa
  }

  static String _formatVowel(String base, int tone, bool isUpper) {
    final list = _vowelTones[base] ?? [base];
    final clamped = tone.clamp(0, list.length - 1);
    final char = list[clamped];
    return isUpper ? char.toUpperCase() : char;
  }

  /// Whether [char] is a composed Vietnamese character that can be decomposed on backspace.
  static bool canDecompose(String char) {
    if (char == 'đ' || char == 'Đ') return true;
    final info = _charToTone[char];
    return info != null && (info.$2 > 0 || info.$1 != char.toLowerCase());
  }

  /// Decomposes or removes the last character's tone / diacritic.
  static TextEditingValue backspace({required TextEditingValue value}) {
    final sel = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);
    if (!sel.isCollapsed || sel.baseOffset <= 0) {
      return TextInputEngine.deleteBackward(value);
    }

    final offset = sel.baseOffset;
    final text = value.text;
    final prevChar = text[offset - 1];

    if (prevChar == 'đ') {
      return TextEditingValue(
        text: text.replaceRange(offset - 1, offset, 'd'),
        selection: TextSelection.collapsed(offset: offset),
      );
    }
    if (prevChar == 'Đ') {
      return TextEditingValue(
        text: text.replaceRange(offset - 1, offset, 'D'),
        selection: TextSelection.collapsed(offset: offset),
      );
    }

    final info = _charToTone[prevChar];
    if (info != null) {
      final isUpper = prevChar == prevChar.toUpperCase();
      // If has tone, remove tone first
      if (info.$2 > 0) {
        final neutral = _formatVowel(info.$1, 0, isUpper);
        return TextEditingValue(
          text: text.replaceRange(offset - 1, offset, neutral),
          selection: TextSelection.collapsed(offset: offset),
        );
      }
      // If modified vowel (â, ă, ê, ô, ơ, ư), revert to raw vowel
      final rawBase = switch (info.$1) {
        'â' || 'ă' => 'a',
        'ê' => 'e',
        'ô' || 'ơ' => 'o',
        'ư' => 'u',
        _ => null,
      };
      if (rawBase != null) {
        final rep = isUpper ? rawBase.toUpperCase() : rawBase;
        return TextEditingValue(
          text: text.replaceRange(offset - 1, offset, rep),
          selection: TextSelection.collapsed(offset: offset),
        );
      }
    }

    return TextInputEngine.deleteBackward(value);
  }
}
