import '../../models/key_data.dart';
import '../../models/keyboard_layout.dart';
import '../../models/keyboard_type.dart';
import '../builtin_layouts.dart';
import 'locale_layout_helper.dart';

/// Vietnamese (vi_VN) QWERTY layout with `₫` (Vietnamese Đồng) currency and diacritic alternates.
class LayoutViVn {
  const LayoutViVn._();

  static KeyboardLayout build({
    VKeyboardType type = VKeyboardType.standard,
  }) {
    return KeyboardLayout(
      id: 'vi_VN',
      initialPage: 'abc',
      pages: {
        'abc': [
          [
            KeyData.char('q'),
            KeyData.char('w', alternates: const ['ư', 'ơ']),
            KeyData.char('e', alternates: const ['ê', 'é', 'è', 'ẻ', 'ẽ', 'ẹ', 'ế', 'ề', 'ể', 'ễ', 'ệ']),
            KeyData.char('r'),
            KeyData.char('t'),
            KeyData.char('y', alternates: const ['ý', 'ỳ', 'ỷ', 'ỹ', 'ỵ']),
            KeyData.char('u', alternates: const ['ư', 'ú', 'ù', 'ủ', 'ũ', 'ụ', 'ứ', 'ừ', 'ử', 'ữ', 'ự']),
            KeyData.char('i', alternates: const ['í', 'ì', 'ỉ', 'ĩ', 'ị']),
            KeyData.char('o', alternates: const ['ô', 'ơ', 'ó', 'ò', 'ỏ', 'õ', 'ọ', 'ố', 'ồ', 'ổ', 'ỗ', 'ộ', 'ớ', 'ờ', 'ở', 'ỡ', 'ợ']),
            KeyData.char('p'),
          ],
          [
            KeyData.char('a', alternates: const ['ă', 'â', 'á', 'à', 'ả', 'ã', 'ạ', 'ắ', 'ằ', 'ẳ', 'ẵ', 'ặ', 'ấ', 'ầ', 'ẩ', 'ẫ', 'ậ']),
            KeyData.char('s'),
            KeyData.char('d', alternates: const ['đ']),
            KeyData.char('f'),
            KeyData.char('g'),
            KeyData.char('h'),
            KeyData.char('j'),
            KeyData.char('k'),
            KeyData.char('l'),
          ],
          [
            KeyData.shift(flex: 1.5),
            KeyData.char('z'),
            KeyData.char('x'),
            KeyData.char('c'),
            KeyData.char('v'),
            KeyData.char('b'),
            KeyData.char('n'),
            KeyData.char('m'),
            KeyData.backspace(flex: 1.5),
          ],
          LocaleLayoutHelper.buildBottomRow(type: type),
        ],
        '123': LocaleLayoutHelper.buildNumericSymbolPage(
          'symbols',
          currency: '₫',
          includeEmoji:
              type == VKeyboardType.standard || type == VKeyboardType.multiline,
        ),
        'symbols': LocaleLayoutHelper.buildSymbolPage(
          '123',
          primaryCurrency: '₫',
          includeEmoji:
              type == VKeyboardType.standard || type == VKeyboardType.multiline,
        ),
        'emoji': BuiltinLayouts.emojiPage,
      },
    );
  }
}
