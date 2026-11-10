import 'ime_engine.dart';

/// Traditional Chinese Zhuyin / Bopomofo Input Method Engine (zh_TW).
///
/// Converts Zhuyin syllables into Traditional Hanzi candidate characters and phrases.
class ZhuyinImeEngine implements ImeEngine {
  const ZhuyinImeEngine();

  @override
  String get localeId => 'zh_TW';

  @override
  bool get commitOnSpace => true;

  @override
  bool isValidInput(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    // Bopomofo range: U+3105 to U+312F
    // Tone marks: ˊ (0x02CA), ˇ (0x02C7), ˋ (0x02CB), ˙ (0x02D9)
    return (code >= 0x3105 && code <= 0x312F) ||
        char == 'ˊ' ||
        char == 'ˇ' ||
        char == 'ˋ' ||
        char == '˙' ||
        char == ' ';
  }

  @override
  String normalizeInput(String char) => char;

  /// High-frequency multi-syllable Traditional Chinese phrases by Bopomofo.
  static const Map<String, List<String>> phrases = {
    'ㄋㄧㄏㄠ': ['你好', '擬好'],
    'ㄋㄧˇㄏㄠˇ': ['你好'],
    'ㄒㄧㄝㄒㄧㄝ': ['謝謝'],
    'ㄗㄞㄐㄧㄢ': ['再見'],
    'ㄊㄞㄨㄢ': ['臺灣', '台灣'],
    'ㄓㄨㄥㄍㄨㄛ': ['中國'],
    'ㄆㄥㄧㄡ': ['朋友'],
    'ㄍㄨㄥㄗㄨㄛ': ['工作'],
    'ㄒㄩㄝㄒㄧㄠ': ['學校'],
    'ㄒㄩㄝㄕㄥ': ['學生'],
    'ㄌㄠㄕ': ['老師'],
    'ㄨㄛㄇㄣ': ['我們'],
    'ㄊㄚㄇㄣ': ['他們', '她們', '它們'],
    'ㄋㄧㄇㄣ': ['你們'],
    'ㄓㄜㄍㄜ': ['這個'],
    'ㄋㄚㄍㄜ': ['那個'],
    'ㄕㄣㄇㄜ': ['什麼'],
    'ㄗㄣㄇㄜ': ['怎麼'],
    'ㄨㄟㄕㄣㄇㄜ': ['為什麼'],
    'ㄨㄟㄌㄜ': ['為了'],
    'ㄧㄐㄧㄥ': ['已經'],
    'ㄎㄜㄧ': ['可以'],
    'ㄒㄧㄏㄨㄢ': ['喜歡'],
    'ㄎㄞㄕ': ['開始'],
    'ㄨㄣㄊㄧ': ['問題'],
    'ㄕㄐㄧㄢ': ['時間', '事件'],
    'ㄐㄧㄣㄊㄧㄢ': ['今天'],
    'ㄇㄧㄥㄊㄧㄢ': ['明天'],
    'ㄗㄨㄛㄊㄧㄢ': ['昨天'],
    'ㄒㄧㄢㄗㄞ': ['現在'],
    'ㄧㄧㄤ': ['一樣'],
    'ㄇㄟㄧㄡ': ['沒有'],
    'ㄉㄨㄟㄅㄨㄑㄧ': ['對不起'],
    'ㄇㄟㄍㄨㄢㄒㄧ': ['沒關係'],
    'ㄎㄨㄞㄌㄜ': ['快樂'],
    'ㄕㄥㄖ': ['生日'],
    'ㄒㄧㄣㄋㄧㄢ': ['新年'],
    'ㄉㄚㄐㄧㄚ': ['大家'],
    'ㄕㄡㄐㄧ': ['手機'],
    'ㄉㄧㄢㄋㄠ': ['電腦'],
    'ㄐㄧㄢㄆㄢ': ['鍵盤'],
    'ㄕㄨㄖㄨ': ['輸入'],
    'ㄏㄨㄢㄧㄥ': ['歡迎'],
    'ㄈㄟㄔㄤ': ['非常'],
    'ㄍㄠㄒㄧㄥ': ['高興'],
    'ㄓㄉㄠ': ['知道'],
    'ㄇㄧㄥㄅㄞ': ['明白'],
    'ㄖㄣㄕ': ['認識'],
    'ㄅㄤㄓㄨ': ['幫助'],
    'ㄒㄩㄝㄒㄧ': ['學習'],
    'ㄧㄧㄨㄢ': ['醫院'],
    'ㄧㄕㄥ': ['醫生'],
    'ㄏㄨㄛㄔㄜ': ['火車'],
    'ㄈㄟㄐㄧ': ['飛機'],
    'ㄔㄜㄓㄢ': ['車站'],
    'ㄐㄧㄔㄤ': ['機場'],
  };

  /// Common single Zhuyin initial/vowel mappings to Traditional Hanzi.
  static const Map<String, List<String>> syllables = {
    'ㄅ': ['不', '把', '被', '比', '邊', '本', '部'],
    'ㄆ': ['朋', '品', '平', '怕', '跑', '片', '票'],
    'ㄇ': ['們', '沒', '買', '賣', '明', '面', '名'],
    'ㄈ': ['發', '分', '放', '風', '服', '反', '方'],
    'ㄉ': ['的', '得', '地', '到', '大', '點', '多'],
    'ㄊ': ['他', '她', '它', '同', '太', '聽', '天'],
    'ㄋ': ['你', '那', '能', '年', '南', '內', '難'],
    'ㄌ': ['了', '來', '里', '兩', '老', '路', '力'],
    'ㄍ': ['個', '過', '國', '高', '給', '公', '工'],
    'ㄎ': ['看', '可', '開', '快', '客', '課', '口'],
    'ㄏ': ['和', '好', '很', '後', '會', '話', '回'],
    'ㄐ': ['就', '家', '見', '進', '經', '幾', '機'],
    'ㄑ': ['去', '起', '前', '請', '錢', '情', '全'],
    'ㄒ': ['想', '下', '些', '小', '寫', '新', '先'],
    'ㄓ': ['這', '著', '中', '真', '知', '正', '子'],
    'ㄔ': ['出', '成', '長', '常', '吃', '車', '場'],
    'ㄕ': ['是', '時', '十', '事', '說', '生', '市', '使', '實', '什'],
    'ㄖ': ['人', '日', '讓', '認', '熱', '肉', '如'],
    'ㄗ': ['在', '自', '再', '做', '作', '走', '早'],
    'ㄘ': ['從', '此', '次', '錯', '草', '存', '材'],
    'ㄙ': ['死', '思', '四', '司', '隨', '歲', '送'],
    'ㄧ': ['一', '以', '意', '已', '醫', '衣', '議'],
    'ㄨ': ['我', '無', '五', '物', '文', '問', '完'],
    'ㄩ': ['月', '與', '雨', '語', '魚', '遇', '預'],
    'ㄚ': ['啊', '阿'],
    'ㄛ': ['哦', '喔'],
    'ㄜ': ['餓', '惡', '鵝'],
    'ㄝ': ['也', '夜', '業', '頁'],
    'ㄞ': ['愛', '矮', '挨', '哎'],
    'ㄟ': ['黑', '嘿', '給'],
    'ㄠ': ['傲', '澳', '奧'],
    'ㄢ': ['安', '按', '暗', '案'],
    'ㄣ': ['恩', '嗯'],
    'ㄤ': ['昂'],
    'ㄥ': ['更', '生', '風'],
    'ㄦ': ['二', '兒', '而', '耳'],
    'ㄋㄧ': ['你', '呢', '泥', '擬', '逆'],
    'ㄏㄠ': ['好', '號', '毫', '豪', '浩'],
    'ㄓㄨㄥ': ['中', '重', '種', '眾', '終'],
    'ㄍㄨㄛ': ['國', '過', '果', '鍋'],
    'ㄒㄧㄝ': ['謝', '寫', '些', '鞋', '斜'],
    'ㄗㄞ': ['在', '再', '載', '災'],
    'ㄐㄧㄢ': ['見', '間', '件', '建', '減'],
    'ㄊㄞ': ['台', '太', '態', '抬', '泰'],
    'ㄨㄢ': ['完', '萬', '晚', '玩', '彎'],
  };

  @override
  List<String> getCandidates(String composingText, {int maxCandidates = 8}) {
    final query = composingText.trim();
    if (query.isEmpty) return const [];

    final results = <String>{};

    // 1. Exact phrase match
    final exactPhrase = phrases[query];
    if (exactPhrase != null) {
      results.addAll(exactPhrase);
    }

    // 2. Exact syllable/character match
    final exactSyllable = syllables[query];
    if (exactSyllable != null) {
      results.addAll(exactSyllable);
    }

    // 3. Prefix search in phrases
    if (results.length < maxCandidates) {
      for (final entry in phrases.entries) {
        if (entry.key.startsWith(query) && entry.key != query) {
          results.addAll(entry.value);
          if (results.length >= maxCandidates) break;
        }
      }
    }

    // 4. Prefix search in syllables
    if (results.length < maxCandidates) {
      for (final entry in syllables.entries) {
        if (entry.key.startsWith(query) && entry.key != query) {
          results.addAll(entry.value);
          if (results.length >= maxCandidates) break;
        }
      }
    }

    return results.take(maxCandidates).toList();
  }
}
