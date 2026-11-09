import 'package:flutter/widgets.dart';

import 'text_input_engine.dart';

/// Pure algorithmic syllable composition and decomposition engine for Korean
/// Hangul 2-Set (두벌식 / Dubeolsik) keyboards.
///
/// Follows the Unicode Standard (UAX #29 / Hangul Syllable Composition):
/// * Mathematical syllable formula: `0xAC00 + (cho * 21 + jung) * 28 + jong`.
/// * Real-time syllable composition (e.g. `ㅎ` + `ㅏ` + `ㄴ` = `한`).
/// * Compound vowel merging (e.g. `ㅗ` + `ㅏ` = `ㅘ`, `고` + `ㅏ` = `과`).
/// * Compound batchim merging (e.g. `ㄹ` + `ㄱ` = `ㄺ`, `달` + `ㄱ` = `닭`).
/// * Batchim splitting when a vowel follows (e.g. `간` + `ㅏ` = `가나`, `닭` + `ㅣ` = `달기`).
/// * Step-by-step backspace decomposition (e.g. `닭` -> `달` -> `다` -> `ㄷ` -> delete).
///
/// Fully stateless with zero external dependencies.
class HangulComposer {
  const HangulComposer._();

  static const int _hangulBase = 0xAC00;
  static const int _hangulEnd = 0xD7A3;

  /// Choseong (초성 / Initial Consonants) - 19 characters.
  static const List<String> choseongList = [
    'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ',
    'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
  ];

  /// Jungseong (중성 / Medial Vowels) - 21 characters.
  static const List<String> jungseongList = [
    'ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ', 'ㅘ',
    'ㅙ', 'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ', 'ㅢ', 'ㅣ',
  ];

  /// Jongseong (종성 / Final Consonants / Batchim) - 28 values (index 0 is none).
  static const List<String> jongseongList = [
    '', 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ',
    'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ',
    'ㅆ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
  ];

  // Compound vowels: (first_jung_idx, second_jung_idx) -> compound_jung_idx
  static const Map<(int, int), int> _compoundVowels = {
    (8, 0): 9,   // ㅗ + ㅏ = ㅘ
    (8, 1): 10,  // ㅗ + ㅐ = ㅙ
    (8, 20): 11, // ㅗ + ㅣ = ㅚ
    (13, 4): 14, // ㅜ + ㅓ = ㅝ
    (13, 5): 15, // ㅜ + ㅔ = ㅞ
    (13, 20): 16,// ㅜ + ㅣ = ㅟ
    (18, 20): 19,// ㅡ + ㅣ = ㅢ
  };

  // Standalone vowel combinations: (first_char, second_char) -> compound_char
  static const Map<(String, String), String> _vowelCombos = {
    ('ㅗ', 'ㅏ'): 'ㅘ',
    ('ㅗ', 'ㅐ'): 'ㅙ',
    ('ㅗ', 'ㅣ'): 'ㅚ',
    ('ㅜ', 'ㅓ'): 'ㅝ',
    ('ㅜ', 'ㅔ'): 'ㅞ',
    ('ㅜ', 'ㅣ'): 'ㅟ',
    ('ㅡ', 'ㅣ'): 'ㅢ',
  };

  // Compound batchim: (first_jong_idx, second_char) -> compound_jong_idx
  static const Map<(int, String), int> _compoundBatchim = {
    (1, 'ㅅ'): 3,   // ㄱ + ㅅ = ㄳ
    (4, 'ㅈ'): 5,   // ㄴ + ㅈ = ㄵ
    (4, 'ㅎ'): 6,   // ㄴ + ㅎ = ㄶ
    (8, 'ㄱ'): 9,   // ㄹ + ㄱ = ㄺ
    (8, 'ㅁ'): 10,  // ㄹ + ㅁ = ㄻ
    (8, 'ㅂ'): 11,  // ㄹ + ㅂ = ㄼ
    (8, 'ㅅ'): 12,  // ㄹ + ㅅ = ㄽ
    (8, 'ㅌ'): 13,  // ㄹ + ㅌ = ㄾ
    (8, 'ㅍ'): 14,  // ㄹ + ㅍ = ㄿ
    (8, 'ㅎ'): 15,  // ㄹ + ㅎ = ㅀ
    (17, 'ㅅ'): 18, // ㅂ + ㅅ = ㅄ
  };

  // Batchim splitting: compound_jong_idx -> (first_jong_idx, next_choseong_char)
  static const Map<int, (int, String)> _batchimSplit = {
    3: (1, 'ㅅ'),   // ㄳ -> ㄱ, ㅅ
    5: (4, 'ㅈ'),   // ㄵ -> ㄴ, ㅈ
    6: (4, 'ㅎ'),   // ㄶ -> ㄴ, ㅎ
    9: (8, 'ㄱ'),   // ㄺ -> ㄹ, ㄱ
    10: (8, 'ㅁ'),  // ㄻ -> ㄹ, ㅁ
    11: (8, 'ㅂ'),  // ㄼ -> ㄹ, ㅂ
    12: (8, 'ㅅ'),  // ㄽ -> ㄹ, ㅅ
    13: (8, 'ㅌ'),  // ㄾ -> ㄹ, ㅌ
    14: (8, 'ㅍ'),  // ㄿ -> ㄹ, ㅍ
    15: (8, 'ㅎ'),  // ㅀ -> ㄹ, ㅎ
    18: (17, 'ㅅ'), // ㅄ -> ㅂ, ㅅ
  };

  // Decomposing compound vowels on backspace: compound_jung_idx -> base_jung_idx
  static const Map<int, int> _vowelDecompose = {
    9: 8,   // ㅘ -> ㅗ
    10: 8,  // ㅙ -> ㅗ
    11: 8,  // ㅚ -> ㅗ
    14: 13, // ㅝ -> ㅜ
    15: 13, // ㅞ -> ㅜ
    16: 13, // ㅟ -> ㅜ
    19: 18, // ㅢ -> ㅡ
  };

  /// Whether [char] is a composed Hangul syllable (가..힣).
  static bool isHangulSyllable(String char) {
    if (char.length != 1) return false;
    final code = char.codeUnitAt(0);
    return code >= _hangulBase && code <= _hangulEnd;
  }

  /// Whether [char] is an initial consonant (초성).
  static bool isChoseong(String char) => choseongList.contains(char);

  /// Whether [char] is a medial vowel (중성).
  static bool isJungseong(String char) => jungseongList.contains(char);

  /// Whether [char] is a final consonant (종성 / 받침).
  static bool isJongseong(String char) =>
      char.isNotEmpty && jongseongList.contains(char);

  /// Whether [char] can be decomposed by backspace.
  static bool canDecompose(String char) {
    if (char.isEmpty) return false;
    return isHangulSyllable(char) ||
        isChoseong(char) ||
        isJungseong(char) ||
        _vowelCombos.containsValue(char);
  }

  /// Decomposes a Hangul syllable into `(choseong, jungseong, jongseong)` indices.
  static (int, int, int) decomposeSyllable(String syllable) {
    assert(isHangulSyllable(syllable));
    final code = syllable.codeUnitAt(0) - _hangulBase;
    final cho = code ~/ (21 * 28);
    final jung = (code % (21 * 28)) ~/ 28;
    final jong = code % 28;
    return (cho, jung, jong);
  }

  /// Composes a Hangul syllable from `(choseong, jungseong, jongseong)` indices.
  static String composeSyllable(int cho, int jung, int jong) {
    assert(cho >= 0 && cho < choseongList.length);
    assert(jung >= 0 && jung < jungseongList.length);
    assert(jong >= 0 && jong < jongseongList.length);
    final code = _hangulBase + (cho * 21 + jung) * 28 + jong;
    return String.fromCharCode(code);
  }

  /// Attempts to compose [lastChar] with the incoming [jamo].
  ///
  /// Returns the composed string (which may be 1 or 2 characters),
  /// or null if they cannot be composed into a syllable.
  static String? composeChar(String lastChar, String jamo) {
    if (lastChar.isEmpty || jamo.isEmpty) return null;

    // Incoming character is a vowel (중성)
    if (isJungseong(jamo)) {
      final jungIdx = jungseongList.indexOf(jamo);

      // 1. Standalone choseong consonant + vowel -> syllable (ㄱ + ㅏ = 가)
      if (isChoseong(lastChar)) {
        final choIdx = choseongList.indexOf(lastChar);
        return composeSyllable(choIdx, jungIdx, 0);
      }

      // 2. Standalone vowel + vowel -> compound vowel (ㅗ + ㅏ = ㅘ)
      if (_vowelCombos.containsKey((lastChar, jamo))) {
        return _vowelCombos[(lastChar, jamo)];
      }

      // 3. Syllable + vowel
      if (isHangulSyllable(lastChar)) {
        final (cho, jung, jong) = decomposeSyllable(lastChar);

        // 3a. No batchim: can form compound vowel? (고 + ㅏ = 과)
        if (jong == 0 && _compoundVowels.containsKey((jung, jungIdx))) {
          final newJung = _compoundVowels[(jung, jungIdx)]!;
          return composeSyllable(cho, newJung, 0);
        }

        // 3b. Compound batchim: splits into first batchim + new syllable (닭 + ㅣ = 달기)
        if (_batchimSplit.containsKey(jong)) {
          final (firstJong, nextChoChar) = _batchimSplit[jong]!;
          final firstSyl = composeSyllable(cho, jung, firstJong);
          final nextChoIdx = choseongList.indexOf(nextChoChar);
          final secondSyl = composeSyllable(nextChoIdx, jungIdx, 0);
          return '$firstSyl$secondSyl';
        }

        // 3c. Single batchim: moves to become choseong of new syllable (간 + ㅏ = 가나)
        if (jong > 0) {
          final jongChar = jongseongList[jong];
          if (choseongList.contains(jongChar)) {
            final firstSyl = composeSyllable(cho, jung, 0);
            final nextChoIdx = choseongList.indexOf(jongChar);
            final secondSyl = composeSyllable(nextChoIdx, jungIdx, 0);
            return '$firstSyl$secondSyl';
          }
        }
      }
    }

    // Incoming character is a consonant (초성 / 종성)
    else if (isChoseong(jamo)) {
      // Syllable + consonant -> attach batchim
      if (isHangulSyllable(lastChar)) {
        final (cho, jung, jong) = decomposeSyllable(lastChar);

        // 1. No batchim: attach as single batchim (가 + ㄴ = 간)
        if (jong == 0 && jongseongList.contains(jamo)) {
          final jongIdx = jongseongList.indexOf(jamo);
          return composeSyllable(cho, jung, jongIdx);
        }

        // 2. Has single batchim: attach as compound batchim (달 + ㄱ = 닭)
        if (_compoundBatchim.containsKey((jong, jamo))) {
          final compoundJong = _compoundBatchim[(jong, jamo)]!;
          return composeSyllable(cho, jung, compoundJong);
        }
      }
    }

    return null;
  }

  /// Decomposes [char] by one input step when backspaced.
  ///
  /// Returns:
  /// * A string (which may be a decomposed syllable or single jamo), or
  /// * An empty string if the character was completely deleted, or
  /// * null if [char] is not a decomposable Hangul character.
  static String? decomposeChar(String char) {
    if (char.isEmpty) return null;

    if (isHangulSyllable(char)) {
      final (cho, jung, jong) = decomposeSyllable(char);

      // 1. Compound batchim -> single batchim (닭 -> 달)
      if (_batchimSplit.containsKey(jong)) {
        final (firstJong, _) = _batchimSplit[jong]!;
        return composeSyllable(cho, jung, firstJong);
      }

      // 2. Single batchim -> no batchim (달 -> 다)
      if (jong > 0) {
        return composeSyllable(cho, jung, 0);
      }

      // 3. Compound vowel -> base vowel (과 -> 고)
      if (_vowelDecompose.containsKey(jung)) {
        final baseJung = _vowelDecompose[jung]!;
        return composeSyllable(cho, baseJung, 0);
      }

      // 4. Syllable with single vowel -> choseong jamo (다 -> ㄷ)
      return choseongList[cho];
    }

    // Standalone compound vowel (ㅘ -> ㅗ)
    for (final entry in _vowelCombos.entries) {
      if (entry.value == char) {
        return entry.key.$1;
      }
    }

    // Standalone choseong or jungseong jamo deletes completely
    if (isChoseong(char) || isJungseong(char)) {
      return '';
    }

    return null;
  }

  /// Composes incoming [jamo] into [value], updating text and selection.
  static TextEditingValue compose({
    required TextEditingValue value,
    required String jamo,
  }) {
    if (jamo.isEmpty) return value;

    final sel = value.selection;
    // Ranged selection: replace selected text with jamo
    if (sel.isValid && !sel.isCollapsed) {
      return TextInputEngine.insert(value, jamo);
    }

    final offset = sel.isValid ? sel.baseOffset : value.text.length;
    if (offset <= 0) {
      return TextInputEngine.insert(value, jamo);
    }

    final before = value.text.substring(0, offset);
    final after = value.text.substring(offset);
    final lastChar = before.characters.last;

    final composed = composeChar(lastChar, jamo);
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

    // Cannot compose: insert normally
    return TextInputEngine.insert(value, jamo);
  }

  /// Decomposes the Hangul character before the cursor by one step.
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
