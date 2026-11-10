import 'package:flutter/material.dart';

import '../../models/key_data.dart';
import '../../models/keyboard_layout.dart';
import '../../models/keyboard_type.dart';
import '../builtin_layouts.dart';
import 'locale_layout_helper.dart';

/// Spanish (es_ES) layout with ñ, ¿, ¡ and € currency.
class LayoutEsEs {
  const LayoutEsEs._();

  static KeyboardLayout build({
    VKeyboardType type = VKeyboardType.standard,
  }) {
    return KeyboardLayout(
      id: 'es_ES',
      initialPage: 'abc',
      pages: {
        'abc': [
          [
            KeyData.char('q'),
            KeyData.char('w'),
            KeyData.char('e', alternates: const ['é']),
            KeyData.char('r'),
            KeyData.char('t'),
            KeyData.char('y'),
            KeyData.char('u', alternates: const ['ú', 'ü']),
            KeyData.char('i', alternates: const ['í']),
            KeyData.char('o', alternates: const ['ó']),
            KeyData.char('p'),
          ],
          [
            KeyData.char('a', alternates: const ['á']),
            KeyData.char('s'),
            KeyData.char('d'),
            KeyData.char('f'),
            KeyData.char('g'),
            KeyData.char('h'),
            KeyData.char('j'),
            KeyData.char('k'),
            KeyData.char('l'),
            KeyData.char('ñ', shift: 'Ñ', alternates: const ['n']),
          ],
          [
            KeyData.shift(flex: 1.5),
            KeyData.char('z'),
            KeyData.char('x'),
            KeyData.char('c'),
            KeyData.char('v'),
            KeyData.char('b'),
            KeyData.char('n', alternates: const ['ñ']),
            KeyData.char('m'),
            KeyData.backspace(flex: 1.5),
          ],
          LocaleLayoutHelper.buildBottomRow(type: type),
        ],
        '123': [
          LocaleLayoutHelper.symbolsOf('1234567890'),
          LocaleLayoutHelper.symbolsOf('-/:;()€&@"'),
          [
            KeyData.switchTo('symbols', label: '#+=', flex: 1.5),
            KeyData.symbol('¿'),
            KeyData.symbol('¡'),
            KeyData.symbol('.'),
            KeyData.symbol('?'),
            KeyData.symbol('!'),
            KeyData.backspace(flex: 1.5),
          ],
          [
            KeyData.switchTo('abc', label: 'ABC', flex: 1.4),
            if (type == VKeyboardType.standard || type == VKeyboardType.multiline)
              KeyData.switchTo(
                'emoji',
                label: '☺',
                icon: Icons.sentiment_satisfied_alt_rounded,
                flex: 1.1,
              ),
            KeyData.space(
              flex: (type == VKeyboardType.standard || type == VKeyboardType.multiline)
                  ? 5.1
                  : 5.6,
            ),
            KeyData.symbol('.', flex: 1),
            KeyData.enter(flex: 1.8),
          ],
        ],
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
