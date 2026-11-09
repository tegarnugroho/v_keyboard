import '../../models/key_data.dart';
import '../../models/keyboard_layout.dart';
import '../../models/keyboard_type.dart';
import '../builtin_layouts.dart';
import 'locale_layout_helper.dart';

/// Turkish Q (tr_TR) layout with ğ, ü, ş, ı, ö, ç,
/// strict dotted/dotless i casing (i ↔ İ, ı ↔ I), and ₺ currency.
class LayoutTrTr {
  const LayoutTrTr._();

  static KeyboardLayout build({
    VKeyboardType type = VKeyboardType.standard,
  }) {
    return KeyboardLayout(
      id: 'tr_TR',
      initialPage: 'abc',
      pages: {
        'abc': [
          [
            KeyData.char('q'),
            KeyData.char('w'),
            KeyData.char('e'),
            KeyData.char('r'),
            KeyData.char('t'),
            KeyData.char('y'),
            KeyData.char('u'),
            KeyData.char('ı', shift: 'I', alternates: const ['i', 'î']),
            KeyData.char('o'),
            KeyData.char('p'),
            KeyData.char('ğ', shift: 'Ğ', alternates: const ['g']),
            KeyData.char('ü', shift: 'Ü', alternates: const ['u']),
          ],
          [
            KeyData.char('a'),
            KeyData.char('s'),
            KeyData.char('d'),
            KeyData.char('f'),
            KeyData.char('g'),
            KeyData.char('h'),
            KeyData.char('j'),
            KeyData.char('k'),
            KeyData.char('l'),
            KeyData.char('ş', shift: 'Ş', alternates: const ['s']),
            KeyData.char('i', shift: 'İ', alternates: const ['ı', 'î']),
          ],
          [
            KeyData.shift(flex: 1.2),
            KeyData.char('z'),
            KeyData.char('x'),
            KeyData.char('c'),
            KeyData.char('v'),
            KeyData.char('b'),
            KeyData.char('n'),
            KeyData.char('m'),
            KeyData.char('ö', shift: 'Ö', alternates: const ['o']),
            KeyData.char('ç', shift: 'Ç', alternates: const ['c']),
            KeyData.backspace(flex: 1.2),
          ],
          LocaleLayoutHelper.buildBottomRow(type: type),
        ],
        '123': LocaleLayoutHelper.buildNumericSymbolPage(
          'symbols',
          currency: '₺',
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
