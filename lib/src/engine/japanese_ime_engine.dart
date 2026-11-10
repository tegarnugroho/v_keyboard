import 'ime_engine.dart';

/// Japanese Kana-to-Kanji and Katakana Input Method Engine (ja_JP).
///
/// Converts Hiragana composing sequences into Kanji and Katakana candidates.
class JapaneseImeEngine implements ImeEngine {
  const JapaneseImeEngine();

  @override
  String get localeId => 'ja_JP';

  @override
  bool get commitOnSpace => true;

  @override
  bool isValidInput(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    // Hiragana: U+3040..U+309F
    // Katakana: U+30A0..U+30FF
    // Voicing marks: ゛ (U+309B), ゜ (U+309C)
    // Prolonged sound mark: ー (U+30FC)
    return (code >= 0x3040 && code <= 0x30FF) ||
        char == '゛' ||
        char == '゜' ||
        char == 'ー';
  }

  @override
  String normalizeInput(String char) => char;

  /// Algorithmic conversion from Hiragana to Katakana.
  static String toKatakana(String hiragana) {
    final buffer = StringBuffer();
    for (final rune in hiragana.runes) {
      // Hiragana range 0x3041 (ぁ) to 0x3096 (ゖ) maps to Katakana by adding 0x60
      if (rune >= 0x3041 && rune <= 0x3096) {
        buffer.writeCharCode(rune + 0x60);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  /// High-frequency Kana to Kanji mappings.
  static const Map<String, List<String>> kanjiMap = {
    'にほん': ['日本'],
    'にっぽん': ['日本'],
    'とうきょう': ['東京'],
    'ありがとう': ['有難う'],
    'わたし': ['私'],
    'ぼく': ['僕'],
    'おれ': ['俺'],
    'あなた': ['貴方'],
    'かれ': ['彼'],
    'かのじょ': ['彼女'],
    'きょう': ['今日'],
    'あした': ['明日'],
    'きのう': ['昨日'],
    'いま': ['今'],
    'みず': ['水'],
    'やま': ['山'],
    'かわ': ['川'],
    'ひと': ['人'],
    'ほん': ['本'],
    'くるま': ['車'],
    'でんしゃ': ['電車'],
    'じかん': ['時間'],
    'しごと': ['仕事'],
    'せんせい': ['先生'],
    'がくせい': ['学生'],
    'ともだち': ['友達'],
    'でんわ': ['電話'],
    'てがみ': ['手紙'],
    'たべもの': ['食べ物'],
    'のみもの': ['飲み物'],
    'かいもの': ['買い物'],
    'いえ': ['家'],
    'へや': ['部屋'],
    'えき': ['駅'],
    'くうこう': ['空港'],
    'ねこ': ['猫'],
    'いぬ': ['犬'],
    'はな': ['花', '鼻'],
    'つき': ['月'],
    'たいよう': ['太陽'],
    'ひ': ['日', '火', '陽'],
    'あめ': ['雨', '飴'],
    'ゆき': ['雪'],
    'うみ': ['海'],
    'そら': ['空'],
    'き': ['木', '気'],
    'め': ['目'],
    'て': ['手'],
    'あし': ['足'],
    'くち': ['口'],
    'みみ': ['耳'],
    'あたま': ['頭'],
    'こころ': ['心'],
    'あい': ['愛'],
    'ゆめ': ['夢'],
    'へいわ': ['平和'],
    'せかい': ['世界'],
    'おんがく': ['音楽'],
    'えいが': ['映画'],
    'ほんとう': ['本当'],
    'だいじょうぶ': ['大丈夫'],
    'がんばって': ['頑張って'],
    'おはよう': ['お早う'],
    'こんにちは': ['今日は'],
    'こんばんは': ['今晩は'],
    'さようなら': ['左様なら'],
    'よろしく': ['宜しく'],
    'すき': ['好き'],
    'きらい': ['嫌い'],
    'おおきい': ['大きい'],
    'ちいさい': ['小さい'],
    'あたらしい': ['新しい'],
    'ふるい': ['古い'],
    'いい': ['良い'],
    'わるい': ['悪い'],
    'たかい': ['高い'],
    'やすい': ['安い'],
    'いく': ['行く'],
    'くる': ['来る'],
    'みる': ['見る'],
    'きく': ['聞く'],
    'いう': ['言う'],
    'たべる': ['食べる'],
    'のむ': ['飲む'],
    'かう': ['買う'],
    'かく': ['書く'],
    'よむ': ['読む'],
    'あるく': ['歩く'],
    'はしる': ['走る'],
    'まつ': ['待つ'],
    'はなす': ['話す'],
    'わかる': ['分かる'],
    'つくる': ['作る'],
    'つかう': ['使う'],
    'あう': ['会う'],
    'おもう': ['思う'],
  };

  @override
  List<String> getCandidates(String composingText, {int maxCandidates = 8}) {
    final query = composingText.trim();
    if (query.isEmpty) return const [];

    final results = <String>{};

    // 1. Exact Kanji match
    final kanjiList = kanjiMap[query];
    if (kanjiList != null) {
      results.addAll(kanjiList);
    }

    // 2. Original Hiragana
    results.add(query);

    // 3. Converted Katakana
    final katakana = toKatakana(query);
    if (katakana != query) {
      results.add(katakana);
    }

    // 4. Prefix match for Kanji
    if (results.length < maxCandidates) {
      for (final entry in kanjiMap.entries) {
        if (entry.key.startsWith(query) && entry.key != query) {
          results.addAll(entry.value);
          if (results.length >= maxCandidates) break;
        }
      }
    }

    return results.take(maxCandidates).toList();
  }
}
