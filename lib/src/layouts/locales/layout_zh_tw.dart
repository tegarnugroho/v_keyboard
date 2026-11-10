import 'package:flutter/material.dart';

import '../../models/key_data.dart';
import '../../models/keyboard_layout.dart';
import '../../models/keyboard_type.dart';
import '../builtin_layouts.dart';
import 'locale_layout_helper.dart';

/// Traditional Chinese (zh_TW) Zhuyin (注音 / Bopomofo) layout with tone marks and Traditional punctuation.
class LayoutZhTw {
  const LayoutZhTw._();

  static KeyboardLayout build({
    VKeyboardType type = VKeyboardType.standard,
  }) {
    return KeyboardLayout(
      id: 'zh_TW',
      initialPage: 'abc',
      pages: {
        'abc': [
          LocaleLayoutHelper.rowOf('ㄅㄆㄇㄈㄉㄊㄋㄌㄍㄎ'),
          LocaleLayoutHelper.rowOf('ㄏㄐㄑㄒㄓㄔㄕㄖㄗㄘㄙ'),
          [
            KeyData.shift(flex: 1.2),
            ...LocaleLayoutHelper.rowOf('ㄧㄨㄩㄚㄛㄜㄝㄞㄟㄠㄢ'),
            KeyData.backspace(flex: 1.2),
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
            KeyData.symbol('，', flex: 1.0),
            KeyData.space(flex: 4.1),
            KeyData.symbol('。', flex: 1.0),
            KeyData.enter(flex: 1.7),
          ],
        ],
        '123': LocaleLayoutHelper.buildNumericSymbolPage(
          'symbols',
          currency: '\$',
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
