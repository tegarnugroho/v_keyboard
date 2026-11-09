import '../../models/key_data.dart';
import '../../models/keyboard_layout.dart';
import '../../models/keyboard_type.dart';
import '../builtin_layouts.dart';
import 'locale_layout_helper.dart';

/// Nordic layout supporting Swedish, Norwegian, Danish, Finnish:
/// å, ä, ö, æ, ø, with € and kr currency symbols.
class LayoutNordic {
  const LayoutNordic._();

  static KeyboardLayout build({
    VKeyboardType type = VKeyboardType.standard,
  }) {
    return KeyboardLayout(
      id: 'nordic',
      initialPage: 'abc',
      pages: {
        'abc': [
          [
            ...LocaleLayoutHelper.rowOf('qwertyuiop'),
            LocaleLayoutHelper.charWithAlternates('å', const ['ä', 'æ'], shift: 'Å'),
          ],
          [
            ...LocaleLayoutHelper.rowOf('asdfghjkl'),
            LocaleLayoutHelper.charWithAlternates('ö', const ['ø', 'o'], shift: 'Ö'),
            LocaleLayoutHelper.charWithAlternates('ä', const ['æ', 'a'], shift: 'Ä'),
          ],
          [
            KeyData.shift(flex: 1.5),
            ...LocaleLayoutHelper.rowOf('zxcvbnm'),
            KeyData.backspace(flex: 1.5),
          ],
          LocaleLayoutHelper.buildBottomRow(type: type),
        ],
        '123': LocaleLayoutHelper.buildNumericSymbolPage(
          'symbols',
          currency: '€',
          includeEmoji: type == VKeyboardType.standard || type == VKeyboardType.multiline,
        ),
        'symbols': LocaleLayoutHelper.buildSymbolPage(
          '123',
          primaryCurrency: 'kr',
          includeEmoji: type == VKeyboardType.standard || type == VKeyboardType.multiline,
        ),
        'emoji': BuiltinLayouts.emojiPage,
      },
    );
  }
}
