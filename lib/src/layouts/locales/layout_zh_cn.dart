import 'package:flutter/material.dart';

import '../../models/key_data.dart';
import '../../models/keyboard_layout.dart';
import '../../models/keyboard_type.dart';
import '../builtin_layouts.dart';
import 'locale_layout_helper.dart';

/// Simplified Chinese (zh_CN) Pinyin layout with Chinese punctuation and `¥` currency.
class LayoutZhCn {
  const LayoutZhCn._();

  static KeyboardLayout build({
    VKeyboardType type = VKeyboardType.standard,
  }) {
    return KeyboardLayout(
      id: 'zh_CN',
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
          [
            KeyData.switchTo('123', label: '123', flex: 1.3),
            if (type == VKeyboardType.standard || type == VKeyboardType.multiline)
              KeyData.switchTo(
                'emoji',
                label: '☺',
                icon: Icons.sentiment_satisfied_alt_rounded,
                flex: 1.0,
              ),
            KeyData.clipboardHistory(flex: 1.0),
            KeyData.symbol('，', flex: 0.9),
            KeyData.space(flex: 3.2),
            KeyData.symbol('。', flex: 0.9),
            KeyData.enter(flex: 1.7),
          ],
        ],
        '123': LocaleLayoutHelper.buildNumericSymbolPage(
          'symbols',
          currency: '¥',
          includeEmoji:
              type == VKeyboardType.standard || type == VKeyboardType.multiline,
        ),
        'symbols': LocaleLayoutHelper.buildSymbolPage(
          '123',
          primaryCurrency: '¥',
          includeEmoji:
              type == VKeyboardType.standard || type == VKeyboardType.multiline,
        ),
        'emoji': BuiltinLayouts.emojiPage,
      },
    );
  }
}
