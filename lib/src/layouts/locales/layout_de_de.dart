import '../../models/key_data.dart';
import '../../models/keyboard_layout.dart';
import '../../models/keyboard_type.dart';
import '../builtin_layouts.dart';
import 'locale_layout_helper.dart';

/// German (de_DE) QWERTZ layout with ä, ö, ü, ß and € currency.
class LayoutDeDe {
  const LayoutDeDe._();

  static KeyboardLayout build({
    VKeyboardType type = VKeyboardType.standard,
  }) {
    return KeyboardLayout(
      id: 'de_DE',
      initialPage: 'abc',
      pages: {
        'abc': [
          [
            ...LocaleLayoutHelper.rowOf('qwertzuiop'),
            LocaleLayoutHelper.charWithAlternates('ü', const ['u', 'ue'], shift: 'Ü'),
          ],
          [
            ...LocaleLayoutHelper.rowOf('asdfghjkl'),
            LocaleLayoutHelper.charWithAlternates('ö', const ['o', 'oe'], shift: 'Ö'),
            LocaleLayoutHelper.charWithAlternates('ä', const ['a', 'ae'], shift: 'Ä'),
          ],
          [
            KeyData.shift(flex: 1.2),
            ...LocaleLayoutHelper.rowOf('yxcvbnm'),
            LocaleLayoutHelper.charWithAlternates('ß', const ['ss'], shift: 'SS'),
            KeyData.backspace(flex: 1.2),
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
          primaryCurrency: '\$',
          includeEmoji: type == VKeyboardType.standard || type == VKeyboardType.multiline,
        ),
        'emoji': BuiltinLayouts.emojiPage,
      },
    );
  }
}
