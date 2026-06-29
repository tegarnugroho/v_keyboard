import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../controller/keyboard_session.dart';
import '../engine/text_input_engine.dart';

/// Outcome of performing a [TextInputAction]: tells the controller whether to
/// keep the keyboard open.
enum ActionResult { keepOpen, close }

/// Translates a [TextInputAction] into native-like behaviour: focus traversal,
/// submission callbacks and keyboard visibility — mirroring Android/iOS.
class KeyboardActionHandler {
  const KeyboardActionHandler._();

  static ActionResult perform(KeyboardSession session) {
    final action = session.textInputAction;
    final config = session.config;

    // Newline never submits.
    if (action == TextInputAction.newline || session.insertsNewline) {
      session.value = TextInputEngine.newline(session.value);
      session.onChanged?.call(session.value.text);
      return ActionResult.keepOpen;
    }

    session.onAction?.call(action);

    switch (action) {
      case TextInputAction.next:
        if (config.moveFocusOnNext) {
          final moved = _move(session, forward: true);
          return moved ? ActionResult.keepOpen : ActionResult.close;
        }
        return ActionResult.keepOpen;

      case TextInputAction.previous:
        if (config.moveFocusOnPrevious) {
          _move(session, forward: false);
        }
        return ActionResult.keepOpen;

      case TextInputAction.search:
        _submit(session);
        return config.maintainFocusOnSearch
            ? ActionResult.keepOpen
            : ActionResult.close;

      case TextInputAction.send:
      case TextInputAction.go:
      case TextInputAction.join:
      case TextInputAction.route:
      case TextInputAction.emergencyCall:
      case TextInputAction.done:
      case TextInputAction.continueAction:
        _submit(session);
        return config.hideOnDone ? ActionResult.close : ActionResult.keepOpen;

      case TextInputAction.unspecified:
      case TextInputAction.none:
        _submit(session);
        return ActionResult.keepOpen;

      case TextInputAction.newline:
        return ActionResult.keepOpen; // handled above
    }
  }

  static void _submit(KeyboardSession session) {
    if (!session.config.submitOnDone) return;
    session.onEditingComplete?.call();
    session.onSubmitted?.call(session.value.text);
  }

  /// Moves focus forward/backward using Flutter's traversal so that
  /// FocusTraversalPolicy / FocusTraversalGroup are respected. Returns whether
  /// focus actually moved.
  static bool _move(KeyboardSession session, {required bool forward}) {
    final context = session.contextRef();
    if (context == null || !context.mounted) return false;
    final scope = FocusScope.of(context);
    return forward ? scope.nextFocus() : scope.previousFocus();
  }
}
