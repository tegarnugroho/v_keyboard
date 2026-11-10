import 'ime_engine.dart';
import 'pinyin_dictionary.dart';

/// Simplified Chinese Pinyin Input Method Engine (zh_CN).
///
/// Matches Pinyin inputs against phrases and single-syllable Hanzi characters.
class PinyinImeEngine implements ImeEngine {
  const PinyinImeEngine();

  @override
  String get localeId => 'zh_CN';

  @override
  bool get commitOnSpace => true;

  @override
  bool isValidInput(String char) {
    if (char.length != 1) return false;
    final code = char.codeUnitAt(0);
    // a-z, A-Z, or syllable separator '
    return (code >= 0x61 && code <= 0x7A) ||
        (code >= 0x41 && code <= 0x5A) ||
        char == "'";
  }

  @override
  String normalizeInput(String char) => char.toLowerCase();

  @override
  List<String> getCandidates(String composingText, {int maxCandidates = 8}) {
    final query = composingText.toLowerCase().trim();
    if (query.isEmpty) return const [];

    final results = <String>{};

    // 1. Exact phrase match
    final exactPhrase = PinyinDictionary.phrases[query];
    if (exactPhrase != null) {
      results.addAll(exactPhrase);
    }

    // 2. Exact syllable match
    final exactSyllable = PinyinDictionary.syllables[query];
    if (exactSyllable != null) {
      results.addAll(exactSyllable);
    }

    // 3. Multi-syllable prefix search on phrases (e.g. "nih" matches "nihao")
    if (results.length < maxCandidates) {
      for (final entry in PinyinDictionary.phrases.entries) {
        if (entry.key.startsWith(query) && entry.key != query) {
          results.addAll(entry.value);
          if (results.length >= maxCandidates) break;
        }
      }
    }

    // 4. Prefix search on syllables (e.g. "zhon" matches "zhong")
    if (results.length < maxCandidates) {
      for (final entry in PinyinDictionary.syllables.entries) {
        if (entry.key.startsWith(query) && entry.key != query) {
          results.addAll(entry.value);
          if (results.length >= maxCandidates) break;
        }
      }
    }

    // 5. Greedily segment multi-syllable queries into compound characters
    if (results.length < maxCandidates && query.length >= 2) {
      _segmentGreedy(query, results, maxCandidates);
    }

    return results.take(maxCandidates).toList();
  }

  void _segmentGreedy(String query, Set<String> results, int maxCandidates) {
    // Attempt to partition query into prefix syllable + suffix
    for (var len = query.length - 1; len >= 1; len--) {
      final prefix = query.substring(0, len);
      final suffix = query.substring(len);

      final prefixChars = PinyinDictionary.syllables[prefix];
      final suffixChars = PinyinDictionary.syllables[suffix];

      if (prefixChars != null && suffixChars != null) {
        final combined = '${prefixChars.first}${suffixChars.first}';
        results.add(combined);
        if (results.length >= maxCandidates) return;
      }
    }
  }
}
