import '../../models/key_data.dart';
import '../../models/keyboard_layout.dart';
import '../../models/keyboard_type.dart';
import '../builtin_layouts.dart';
import 'locale_layout_helper.dart';

/// English (UK) QWERTY layout with £ currency symbol.
class LayoutEnGb {
  const LayoutEnGb._();

  static KeyboardLayout build({
    VKeyboardType type = VKeyboardType.standard,
  }) {
    return KeyboardLayout(
      id: 'en_GB',
      initialPage: 'abc',
      pages: {
        'abc': [
          LocaleLayoutHelper.rowOf('qwertyuiop'),
          LocaleLayoutHelper.rowOf('asdfghjkl'),
          [
            KeyData.shift(flex: 1.5),
            ...LocaleLayoutHelper.rowOf('zxcvbnm'),
            KeyData.backspace(flex: 1.5),
          ],
          LocaleLayoutHelper.buildBottomRow(type: type),
        ],
        '123': LocaleLayoutHelper.buildNumericSymbolPage(
          'symbols',
          currency: '£',
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
