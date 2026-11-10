import 'package:flutter/material.dart';

import '../controller/v_keyboard_controller.dart';
import '../theme/v_keyboard_theme.dart';

/// Horizontal candidate suggestion strip displayed above the keyboard
/// during active IME composition (e.g. Chinese Pinyin/Zhuyin or Japanese Kana).
class CandidateBar extends StatelessWidget {
  const CandidateBar({
    super.key,
    required this.controller,
    required this.theme,
    this.height = 38.0,
  });

  final VKeyboardController controller;
  final VKeyboardTheme theme;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final composing = controller.composingText;
        final candidates = controller.candidates;

        if (composing.isEmpty && candidates.isEmpty) {
          return const SizedBox.shrink();
        }

        final isDark = theme.isDark;
        final barBg = isDark
            ? theme.backgroundColor.withValues(alpha: 0.95)
            : theme.backgroundColor;
        final borderColor = isDark
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.08);

        return Container(
          height: height,
          decoration: BoxDecoration(
            color: barBg,
            border: Border(
              bottom: BorderSide(color: borderColor, width: 0.8),
            ),
          ),
          child: Row(
            children: [
              // Composing Buffer Badge
              if (composing.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: theme.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6.0),
                      border: Border.all(
                        color: theme.accentColor.withValues(alpha: 0.3),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      composing,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: theme.accentColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

              // Scrollable Candidates List
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 3.0),
                  itemCount: candidates.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 4.0),
                  itemBuilder: (context, index) {
                    final candidate = candidates[index];
                    final isFirst = index == 0;

                    return InkWell(
                      borderRadius: BorderRadius.circular(6.0),
                      onTap: () => controller.commitCandidate(candidate),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isFirst
                              ? theme.accentColor.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        child: Text(
                          '${index + 1}. $candidate',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight:
                                isFirst ? FontWeight.bold : FontWeight.w500,
                            color: isFirst
                                ? (isDark ? Colors.white : Colors.black87)
                                : (isDark ? Colors.white70 : Colors.black54),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
