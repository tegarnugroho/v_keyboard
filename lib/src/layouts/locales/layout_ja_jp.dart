import 'package:flutter/material.dart';

import '../../models/key_data.dart';
import '../../models/keyboard_layout.dart';
import '../../models/keyboard_type.dart';
import '../builtin_layouts.dart';
import 'locale_layout_helper.dart';

/// Japanese (ja_JP) JIS Kana layout with `¥` currency and voicing marks (`゛`, `゜`).
class LayoutJaJp {
  const LayoutJaJp._();

  static KeyboardLayout build({
    VKeyboardType type = VKeyboardType.standard,
  }) {
    return KeyboardLayout(
      id: 'ja_JP',
      initialPage: 'abc',
      pages: {
        'abc': [
          [
            KeyData.char('た'),
            KeyData.char('て'),
            KeyData.char('い', shift: 'ぃ', alternates: const ['ぃ']),
            KeyData.char('す'),
            KeyData.char('か', alternates: const ['が']),
            KeyData.char('ん'),
            KeyData.char('な'),
            KeyData.char('に'),
            KeyData.char('ら'),
            KeyData.char('せ'),
            KeyData.char('゛'),
            KeyData.char('゜'),
          ],
          [
            KeyData.char('ち', alternates: const ['ぢ']),
            KeyData.char('と', alternates: const ['ど']),
            KeyData.char('し', alternates: const ['じ']),
            KeyData.char('は', alternates: const ['ば', 'ぱ']),
            KeyData.char('き', alternates: const ['ぎ']),
            KeyData.char('く', alternates: const ['ぐ']),
            KeyData.char('ま'),
            KeyData.char('の'),
            KeyData.char('り'),
            KeyData.char('れ'),
            KeyData.char('け', alternates: const ['げ']),
          ],
          [
            KeyData.shift(flex: 1.2),
            KeyData.char('つ', shift: 'っ', alternates: const ['づ', 'っ']),
            KeyData.char('さ', alternates: const ['ざ']),
            KeyData.char('そ', alternates: const ['ぞ']),
            KeyData.char('ひ', alternates: const ['び', 'ぴ']),
            KeyData.char('こ', alternates: const ['ご']),
            KeyData.char('み'),
            KeyData.char('も'),
            KeyData.char('ね'),
            KeyData.char('る'),
            KeyData.char('め'),
            KeyData.char('ろ'),
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
            KeyData.clipboardHistory(flex: 1.0),
            KeyData.symbol('、', flex: 0.9),
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
