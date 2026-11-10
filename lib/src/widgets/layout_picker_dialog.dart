import 'package:flutter/material.dart';

import '../controller/v_keyboard_controller.dart';
import '../layouts/v_keyboard_layouts.dart';
import '../scope/v_keyboard_scope.dart';
import '../theme/v_keyboard_theme.dart';

/// Shows a picker to select from the enabled keyboard layouts.
///
/// When [context] is below the [VKeyboardScope] that owns [controller], the
/// picker is rendered by the scope itself via
/// [VKeyboardController.openLayoutPicker]. That works even when the scope is
/// placed in `MaterialApp.builder` (above the `Navigator`) and keeps focus on
/// the active field so the keyboard stays open. Otherwise it falls back to a
/// modal bottom sheet / dialog, which requires a `Navigator`.
Future<String?> showVKeyboardLayoutPicker(
  BuildContext context, {
  required VKeyboardController controller,
  required VKeyboardTheme theme,
}) {
  final enabledLayouts = controller.config.enabledLayouts;
  if (enabledLayouts.isEmpty) return Future.value(null);

  if (VKeyboardScope.maybeOf(context)?.controller == controller) {
    return controller.openLayoutPicker();
  }

  final mq = MediaQuery.of(context);
  final isNarrow = mq.size.width < 600;

  void select(BuildContext ctx, String id) {
    controller.setLayout(id);
    Navigator.of(ctx).pop(id);
  }

  if (isNarrow) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => VKeyboardLayoutPickerPanel(
        controller: controller,
        theme: theme,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        onSelected: (id) => select(ctx, id),
      ),
    );
  } else {
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380, maxHeight: 420),
          child: Material(
            color: Colors.transparent,
            child: VKeyboardLayoutPickerPanel(
              controller: controller,
              theme: theme,
              onSelected: (id) => select(ctx, id),
            ),
          ),
        ),
      ),
    );
  }
}

/// The list of enabled layouts shown by [showVKeyboardLayoutPicker].
class VKeyboardLayoutPickerPanel extends StatelessWidget {
  const VKeyboardLayoutPickerPanel({
    super.key,
    required this.controller,
    required this.theme,
    required this.onSelected,
    this.borderRadius,
  });

  final VKeyboardController controller;
  final VKeyboardTheme theme;
  final ValueChanged<String> onSelected;

  /// Panel corner radius. Defaults to the theme's key radius.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final enabledLayouts = controller.config.enabledLayouts;
    return Container(
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: borderRadius ??
            (theme.borderRadius is BorderRadius
                ? theme.borderRadius as BorderRadius
                : BorderRadius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Icons.language_rounded,
                  color: theme.accentColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Select keyboard layout',
                    style: theme.textStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: enabledLayouts.length,
              itemBuilder: (_, index) {
                final id = enabledLayouts[index];
                final displayName = VKeyboardLayouts.getDisplayName(id);
                final shortLabel = VKeyboardLayouts.getShortLabel(id);
                final isSelected = controller.currentLayoutId == id;

                return Material(
                  color: isSelected
                      ? theme.accentColor.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  child: ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    leading: Container(
                      width: 44,
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? theme.accentColor : theme.keyColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          shortLabel,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : theme.textStyle.color,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      '$displayName · $shortLabel',
                      style: theme.textStyle.copyWith(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? theme.accentColor
                            : theme.textStyle.color,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: theme.accentColor,
                            size: 20,
                          )
                        : null,
                    onTap: () => onSelected(id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
