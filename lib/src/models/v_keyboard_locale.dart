/// Built-in language and country keyboard layout locales.
///
/// Provides type-safe enum constants for built-in layouts (`en_US`, `en_GB`,
/// `de_DE`, `fr_FR`, `es_ES`, `nordic`, `tr_TR`, `ru_RU`, `el_GR`, `ko_KR`,
/// `ja_JP`, `zh_CN`, `zh_TW`).
enum VKeyboardLocale {
  /// US English QWERTY with `$` currency.
  enUS('en_US', 'English (US)', 'EN'),

  /// UK English QWERTY with `£` currency.
  enGB('en_GB', 'English (UK)', 'GB'),

  /// German QWERTZ with swapped Y/Z, ä, ö, ü, ß and `€` currency.
  deDE('de_DE', 'Deutsch', 'DE'),

  /// French AZERTY with swapped A/Q and Z/W, M next to L, accents, and `€` currency.
  frFR('fr_FR', 'Français', 'FR'),

  /// Spanish QWERTY with ñ, ¿, ¡, and `€` currency.
  esES('es_ES', 'Español', 'ES'),

  /// Nordic QWERTY with å, ä, ö, æ, ø, and `€`/`kr` currency.
  nordic('nordic', 'Nordic', 'NO/SE'),

  /// Turkish Q with ğ, ü, ş, ı, ö, ç, ₺, and strict dotted/dotless I casing (`i ↔ İ`, `ı ↔ I`).
  trTR('tr_TR', 'Türkçe', 'TR'),

  /// Russian Cyrillic ЙЦУКЕН with `₽` currency.
  ruRU('ru_RU', 'Русский', 'RU'),

  /// Greek layout with Greek alphabet and `€` currency.
  elGR('el_GR', 'Ελληνικά', 'GR'),

  /// Korean 2-Set Hangul (두벌식) with syllable composition and `₩` currency.
  koKR('ko_KR', '한국어', 'KO'),

  /// Japanese JIS Kana layout with `¥` currency and voicing marks (`゛`, `゜`).
  jaJP('ja_JP', '日本語', 'JP'),

  /// Simplified Chinese Pinyin layout with Chinese punctuation and `¥` currency.
  zhCN('zh_CN', '简体中文', 'CN'),

  /// Traditional Chinese Zhuyin (注音 / Bopomofo) layout with tone marks.
  zhTW('zh_TW', '繁體中文', 'TW');

  const VKeyboardLocale(this.id, this.displayName, this.shortLabel);

  /// The unique string identifier for this locale (e.g. 'en_US', 'de_DE').
  final String id;

  /// Full localized display name (e.g. 'English (US)', 'Deutsch', 'Русский').
  final String displayName;

  /// Short country/language code (e.g. 'EN', 'DE', 'RU').
  final String shortLabel;

  /// Looks up a [VKeyboardLocale] by its string identifier [id], or null if not found.
  static VKeyboardLocale? fromId(String id) {
    for (final loc in values) {
      if (loc.id == id) return loc;
    }
    return null;
  }
}
