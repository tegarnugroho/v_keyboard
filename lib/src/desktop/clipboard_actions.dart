import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../clipboard/clipboard_history_manager.dart';
import '../engine/text_input_engine.dart';
import '../models/key_intents.dart';

/// Optional developer overrides for clipboard / context-menu actions. Returning
/// `true` from a handler suppresses the package's default behaviour.
class ClipboardCallbacks {
  const ClipboardCallbacks({
    this.onCopy,
    this.onCut,
    this.onPaste,
    this.onSelectAll,
    this.onHistory,
  });

  final bool Function(String selectedText)? onCopy;
  final bool Function(String selectedText)? onCut;
  final bool Function()? onPaste;
  final bool Function()? onSelectAll;
  final bool Function()? onHistory;
}

/// Standard clipboard operations against a [TextEditingController], using
/// Flutter's [Clipboard]. Mutations fire [onChanged] with the new text.
class ClipboardActions {
  const ClipboardActions._();

  static Future<void> perform(
    ClipboardIntent intent,
    TextEditingController controller, {
    ValueChanged<String>? onChanged,
    ClipboardCallbacks? callbacks,
    ClipboardHistoryManager? history,
    bool isSensitive = false,
    bool readOnly = false,
    VoidCallback? onOpenHistory,
  }) async {
    final value = controller.value;
    final selection = value.selection;
    final selectedText = selection.isValid && !selection.isCollapsed
        ? selection.textInside(value.text)
        : '';

    switch (intent) {
      case ClipboardIntent.copy:
        if (callbacks?.onCopy?.call(selectedText) ?? false) return;
        if (selectedText.isNotEmpty) {
          await Clipboard.setData(ClipboardData(text: selectedText));
          if (!isSensitive) {
            await history?.record(selectedText);
          }
        }

      case ClipboardIntent.cut:
        if (readOnly) return;
        if (callbacks?.onCut?.call(selectedText) ?? false) return;
        if (selectedText.isNotEmpty) {
          await Clipboard.setData(ClipboardData(text: selectedText));
          controller.value = TextInputEngine.deleteBackward(controller.value);
          onChanged?.call(controller.text);
          if (!isSensitive) {
            await history?.record(selectedText);
          }
        }

      case ClipboardIntent.paste:
        if (readOnly) return;
        if (callbacks?.onPaste?.call() ?? false) return;
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        final text = data?.text;
        if (text != null && text.isNotEmpty) {
          controller.value = TextInputEngine.insert(controller.value, text);
          onChanged?.call(controller.text);
        }

      case ClipboardIntent.selectAll:
        if (callbacks?.onSelectAll?.call() ?? false) return;
        controller.value = TextInputEngine.selectAll(controller.value);

      case ClipboardIntent.history:
        if (callbacks?.onHistory?.call() ?? false) return;
        onOpenHistory?.call();
    }
  }
}
