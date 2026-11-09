import 'package:flutter/material.dart';

import '../controller/v_keyboard_controller.dart';
import '../layouts/emoji_data.dart';
import '../models/key_data.dart';
import '../theme/v_keyboard_theme.dart';

/// A scrollable, categorised emoji panel shown for the `emoji` page.
///
/// Inserts the tapped emoji through the [VKeyboardController] (so it goes to the
/// active field), and provides an `ABC` / space / backspace bar at the bottom.
class EmojiPanel extends StatefulWidget {
  const EmojiPanel({
    super.key,
    required this.controller,
    required this.theme,
    required this.height,
    required this.maxWidth,
    this.bottomSafeArea = 0,
  });

  final VKeyboardController controller;
  final VKeyboardTheme theme;
  final double height;
  final double maxWidth;
  final double bottomSafeArea;

  @override
  State<EmojiPanel> createState() => _EmojiPanelState();
}

class _EmojiPanelState extends State<EmojiPanel> {
  int _category = 0;

  List<String> get _categories => EmojiData.categories.keys.toList();
  List<String> get _emojis => EmojiData.categories[_categories[_category]]!;

  void _insert(String emoji) =>
      widget.controller.handleKey(KeyData.symbol(emoji));

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final onSurface = theme.iconColor;
    final sidePadding = theme.contentPadding.horizontal / 2 +
        8.0 +
        theme.keyPadding.horizontal / 2;
    final panelWidth = widget.maxWidth.isFinite ? widget.maxWidth : 640.0;

    return Material(
      color: theme.backgroundColor,
      child: SizedBox(
        height: widget.height + widget.bottomSafeArea,
        child: Column(
          children: [
            // Emoji grid.
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: panelWidth),
                  child: GridView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: sidePadding,
                      vertical: 4,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 42,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                    ),
                    itemCount: _emojis.length,
                    itemBuilder: (context, i) {
                      final emoji = _emojis[i];
                      return InkWell(
                        borderRadius:
                            theme.borderRadius.resolve(Directionality.maybeOf(context)),
                        onTap: () => _insert(emoji),
                        child: Center(
                          child:
                              Text(emoji, style: const TextStyle(fontSize: 26)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Category tabs.
            SizedBox(
              height: 40,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: panelWidth),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: sidePadding),
                    itemCount: _categories.length,
                    itemBuilder: (context, i) {
                      final selected = i == _category;
                      final rep = EmojiData.categories[_categories[i]]!.first;
                      return GestureDetector(
                        onTap: () => setState(() => _category = i),
                        child: Container(
                          width: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: selected
                                    ? theme.accentColor
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                          child: Opacity(
                            opacity: selected ? 1 : 0.6,
                            child:
                                Text(rep, style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Bottom bar: ABC · space · backspace.
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: panelWidth),
                child: Container(
                  height: 48,
                  padding: EdgeInsets.symmetric(horizontal: sidePadding),
                  child: Row(
                    children: [
                      _barButton(
                        label: 'ABC',
                        onTap: () => widget.controller.switchPage('abc'),
                      ),
                      const SizedBox(width: 6),
                      _barButton(
                        icon: Icons.content_paste_outlined,
                        onTap: () => widget.controller.openClipboardHistory(),
                        color: onSurface,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _barButton(
                          onTap: () => widget.controller.handleKey(KeyData.space()),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _barButton(
                        icon: Icons.backspace_outlined,
                        onTap: () =>
                            widget.controller.handleKey(KeyData.backspace()),
                        color: onSurface,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.bottomSafeArea > 0)
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: panelWidth),
                  child: Container(
                    height: widget.bottomSafeArea,
                    padding: EdgeInsets.symmetric(
                      horizontal: theme.contentPadding.horizontal / 2 + 8.0,
                    ),
                    alignment: Alignment.centerLeft,
                    child: widget.controller.config.showHideKeyboardButton
                        ? Semantics(
                            button: true,
                            label: 'Close keyboard',
                            child: Material(
                              color: Colors.transparent,
                              child: InkResponse(
                                onTap: widget.controller.hide,
                                radius: 20,
                                highlightColor:
                                    theme.keyColor.withValues(alpha: 0.5),
                                splashColor:
                                    theme.accentColor.withValues(alpha: 0.2),
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 24,
                                    color: theme.iconColor.withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _barButton({
    String? label,
    IconData? icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    final radius =
        widget.theme.borderRadius.resolve(Directionality.maybeOf(context));
    return Material(
      color: widget.theme.specialKeyColor,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          height: 40,
          constraints: const BoxConstraints(minWidth: 56),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: icon != null
              ? Icon(icon, color: color ?? widget.theme.iconColor, size: 22)
              : Text(label ?? '',
                  style: widget.theme.textStyle.copyWith(fontSize: 15)),
        ),
      ),
    );
  }
}
