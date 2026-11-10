import 'package:flutter/material.dart';

import '../../models/key_data.dart';
import '../../models/keyboard_layout.dart';
import '../../models/keyboard_type.dart';
import '../builtin_layouts.dart';
import 'locale_layout_helper.dart';

/// Thai (th_TH) Kedmanee (เกษมณี) layout with `฿` (Thai Baht) currency and Thai numerals.
class LayoutThTh {
  const LayoutThTh._();

  static KeyboardLayout build({
    VKeyboardType type = VKeyboardType.standard,
  }) {
    return KeyboardLayout(
      id: 'th_TH',
      initialPage: 'abc',
      pages: {
        'abc': [
          [
            KeyData.char('ๆ', shift: '๐', alternates: const ['๐', 'ๅ']),
            KeyData.char('ไ', shift: '"', alternates: const ['"']),
            KeyData.char('ำ', shift: 'ฎ', alternates: const ['ฎ']),
            KeyData.char('พ', shift: 'ฑ', alternates: const ['ฑ', 'ภ']),
            KeyData.char('ะ', shift: 'ธ', alternates: const ['ธ']),
            KeyData.char('ั', shift: 'ํ', alternates: const ['ํ']),
            KeyData.char('ี', shift: '๊', alternates: const ['๊']),
            KeyData.char('ร', shift: 'ณ', alternates: const ['ณ']),
            KeyData.char('น', shift: 'ฯ', alternates: const ['ฯ']),
            KeyData.char('ย', shift: 'ญ', alternates: const ['ญ']),
            KeyData.char('บ', shift: 'ฐ', alternates: const ['ฐ']),
            KeyData.char('ล', shift: 'ฅ', alternates: const ['ฅ', 'ฃ']),
          ],
          [
            KeyData.char('ฟ', shift: 'ฤ', alternates: const ['ฤ']),
            KeyData.char('ห', shift: 'ฆ', alternates: const ['ฆ']),
            KeyData.char('ก', shift: 'ฏ', alternates: const ['ฏ']),
            KeyData.char('ด', shift: 'โ', alternates: const ['โ', 'ฎ']),
            KeyData.char('เ', shift: 'ฌ', alternates: const ['ฌ']),
            KeyData.char('้', shift: '็', alternates: const ['็']),
            KeyData.char('่', shift: '๋', alternates: const ['๋']),
            KeyData.char('า', shift: 'ษ', alternates: const ['ษ', 'ๅ']),
            KeyData.char('ส', shift: 'ศ', alternates: const ['ศ']),
            KeyData.char('ว', shift: 'ซ', alternates: const ['ซ']),
            KeyData.char('ง', shift: '.', alternates: const ['.']),
          ],
          [
            KeyData.shift(flex: 1.2),
            KeyData.char('ผ', shift: '(', alternates: const ['(']),
            KeyData.char('ป', shift: ')', alternates: const [')']),
            KeyData.char('แ', shift: 'ฉ', alternates: const ['ฉ']),
            KeyData.char('อ', shift: 'ฮ', alternates: const ['ฮ']),
            KeyData.char('ิ', shift: 'ฺ', alternates: const ['ฺ', 'ุ']),
            KeyData.char('ื', shift: '์', alternates: const ['์', 'ึ', 'ู']),
            KeyData.char('ท', shift: '?', alternates: const ['?', 'ถ']),
            KeyData.char('ม', shift: 'ฒ', alternates: const ['ฒ']),
            KeyData.char('ใ', shift: 'ฬ', alternates: const ['ฬ']),
            KeyData.char('ฝ', shift: 'ฦ', alternates: const ['ฦ']),
            KeyData.backspace(flex: 1.2),
          ],
          LocaleLayoutHelper.buildBottomRow(type: type),
        ],
        '123': [
          LocaleLayoutHelper.symbolsOf('๑๒๓๔๕๖๗๘๙๐'),
          LocaleLayoutHelper.symbolsOf('-/:;()฿&@"'),
          [
            KeyData.switchTo('symbols', label: '#+=', flex: 1.5),
            ...LocaleLayoutHelper.symbolsOf('.,?!\''),
            KeyData.backspace(flex: 1.5),
          ],
          [
            KeyData.switchTo('abc', label: 'กขค', flex: 1.4),
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
          primaryCurrency: '฿',
          includeEmoji:
              type == VKeyboardType.standard || type == VKeyboardType.multiline,
        ),
        'emoji': BuiltinLayouts.emojiPage,
      },
    );
  }
}
