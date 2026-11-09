import '../../models/key_data.dart';
import '../../models/keyboard_layout.dart';
import '../../models/keyboard_type.dart';
import '../builtin_layouts.dart';
import 'locale_layout_helper.dart';

/// Russian (ru_RU) ЙЦУКЕН layout with ₽ currency.
class LayoutRuRu {
  const LayoutRuRu._();

  static KeyboardLayout build({
    VKeyboardType type = VKeyboardType.standard,
  }) {
    return KeyboardLayout(
      id: 'ru_RU',
      initialPage: 'abc',
      pages: {
        'abc': [
          LocaleLayoutHelper.rowOf('йцукенгшщзхъ'),
          LocaleLayoutHelper.rowOf('фывапролджэ'),
          [
            KeyData.shift(flex: 1.2),
            ...LocaleLayoutHelper.rowOf('ячсмитьбюё'),
            KeyData.backspace(flex: 1.2),
          ],
          LocaleLayoutHelper.buildBottomRow(type: type),
        ],
        '123': LocaleLayoutHelper.buildNumericSymbolPage(
          'symbols',
          currency: '₽',
          includeEmoji: type == VKeyboardType.standard || type == VKeyboardType.multiline,
        ),
        'symbols': LocaleLayoutHelper.buildSymbolPage(
          '123',
          primaryCurrency: '€',
          includeEmoji: type == VKeyboardType.standard || type == VKeyboardType.multiline,
        ),
        'emoji': BuiltinLayouts.emojiPage,
      },
    );
  }
}
