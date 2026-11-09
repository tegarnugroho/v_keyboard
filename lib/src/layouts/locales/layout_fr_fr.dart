import '../../models/key_data.dart';
import '../../models/keyboard_layout.dart';
import '../../models/keyboard_type.dart';
import '../builtin_layouts.dart';
import 'locale_layout_helper.dart';

/// French (fr_FR) AZERTY layout with A/Q, Z/W swapped, M next to L,
/// é, è, à, ç, ù, and € currency.
class LayoutFrFr {
  const LayoutFrFr._();

  static KeyboardLayout build({
    VKeyboardType type = VKeyboardType.standard,
  }) {
    return KeyboardLayout(
      id: 'fr_FR',
      initialPage: 'abc',
      pages: {
        'abc': [
          [
            KeyData.char('a', alternates: const ['à', 'â', 'æ']),
            KeyData.char('z'),
            KeyData.char('e', alternates: const ['é', 'è', 'ê', 'ë']),
            KeyData.char('r'),
            KeyData.char('t'),
            KeyData.char('y'),
            KeyData.char('u', alternates: const ['ù', 'û', 'ü']),
            KeyData.char('i', alternates: const ['î', 'ï']),
            KeyData.char('o', alternates: const ['ô', 'œ']),
            KeyData.char('p'),
          ],
          [
            KeyData.char('q'),
            KeyData.char('s'),
            KeyData.char('d'),
            KeyData.char('f'),
            KeyData.char('g'),
            KeyData.char('h'),
            KeyData.char('j'),
            KeyData.char('k'),
            KeyData.char('l'),
            KeyData.char('m'),
            KeyData.char('ù', shift: 'Ù', alternates: const ['u', 'û']),
          ],
          [
            KeyData.shift(flex: 1.2),
            KeyData.char('w'),
            KeyData.char('x'),
            KeyData.char('c', alternates: const ['ç']),
            KeyData.char('v'),
            KeyData.char('b'),
            KeyData.char('n'),
            KeyData.char('é', shift: 'É', alternates: const ['e', 'è', 'ê']),
            KeyData.char('è', shift: 'È', alternates: const ['e', 'é', 'ê']),
            KeyData.char('à', shift: 'À', alternates: const ['a', 'â']),
            KeyData.char('ç', shift: 'Ç', alternates: const ['c']),
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
