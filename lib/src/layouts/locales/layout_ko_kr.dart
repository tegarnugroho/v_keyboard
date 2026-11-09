import '../../models/key_data.dart';
import '../../models/keyboard_layout.dart';
import '../../models/keyboard_type.dart';
import '../builtin_layouts.dart';
import 'locale_layout_helper.dart';

/// Korean (ko_KR) 2-Set Hangul (두벌식) layout with `₩` currency.
class LayoutKoKr {
  const LayoutKoKr._();

  static KeyboardLayout build({
    VKeyboardType type = VKeyboardType.standard,
  }) {
    return KeyboardLayout(
      id: 'ko_KR',
      initialPage: 'abc',
      pages: {
        'abc': [
          [
            KeyData.char('ㅂ', shift: 'ㅃ'),
            KeyData.char('ㅈ', shift: 'ㅉ'),
            KeyData.char('ㄷ', shift: 'ㄸ'),
            KeyData.char('ㄱ', shift: 'ㄲ'),
            KeyData.char('ㅅ', shift: 'ㅆ'),
            KeyData.char('ㅛ'),
            KeyData.char('ㅕ'),
            KeyData.char('ㅑ'),
            KeyData.char('ㅐ', shift: 'ㅒ'),
            KeyData.char('ㅔ', shift: 'ㅖ'),
          ],
          LocaleLayoutHelper.rowOf('ㅁㄴㅇㄹㅎㅗㅓㅏㅣ'),
          [
            KeyData.shift(flex: 1.5),
            ...LocaleLayoutHelper.rowOf('ㅋㅌㅊㅍㅠㅜㅡ'),
            KeyData.backspace(flex: 1.5),
          ],
          LocaleLayoutHelper.buildBottomRow(type: type),
        ],
        '123': LocaleLayoutHelper.buildNumericSymbolPage(
          'symbols',
          currency: '₩',
          includeEmoji:
              type == VKeyboardType.standard || type == VKeyboardType.multiline,
        ),
        'symbols': LocaleLayoutHelper.buildSymbolPage(
          '123',
          primaryCurrency: '₩',
          includeEmoji:
              type == VKeyboardType.standard || type == VKeyboardType.multiline,
        ),
        'emoji': BuiltinLayouts.emojiPage,
      },
    );
  }
}
