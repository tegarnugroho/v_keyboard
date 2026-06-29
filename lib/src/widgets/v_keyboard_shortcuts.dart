import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../desktop/clipboard_actions.dart';
import '../desktop/keyboard_shortcut_manager.dart';
import '../models/key_intents.dart';

/// Registers custom keyboard shortcuts and desktop callbacks for the subtree.
///
/// Place anywhere above the [VirtualTextField]s that should honour them. The
/// shortcuts work for both the virtual keyboard and a hardware keyboard.
///
/// ```dart
/// VKeyboardShortcuts(
///   shortcuts: {
///     LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): save,
///     LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyP): print,
///   },
///   onMedia: (intent) => player.handle(intent),
///   child: ...,
/// )
/// ```
class VKeyboardShortcuts extends InheritedWidget {
  const VKeyboardShortcuts({
    super.key,
    this.shortcuts = const {},
    this.clipboardCallbacks,
    this.onMedia,
    this.onMetaKey,
    this.onMenuKey,
    this.onFunctionKey,
    required super.child,
  });

  /// Developer shortcuts. Combine modifiers + a trigger via [LogicalKeySet].
  final Map<LogicalKeySet, VoidCallback> shortcuts;

  /// Optional overrides for copy/cut/paste/select-all.
  final ClipboardCallbacks? clipboardCallbacks;

  /// Called when a media key is pressed.
  final ValueChanged<MediaIntent>? onMedia;

  /// Called when the Windows / Super (Meta) key is pressed.
  final VoidCallback? onMetaKey;

  /// Called when the Menu (context-menu) key is pressed.
  final VoidCallback? onMenuKey;

  /// Called for any function/special key not otherwise handled (Esc, F1–F12,
  /// PrtSc, ScrLk, Pause, Fn…). OS-level keys like Print Screen cannot be
  /// triggered from pure Dart — hook this to implement your own behaviour
  /// (e.g. capture a `RepaintBoundary`, or call a platform channel).
  final ValueChanged<LogicalKeyboardKey>? onFunctionKey;

  KeyboardShortcutManager get manager => KeyboardShortcutManager(shortcuts);

  /// Reads the nearest instance without creating a dependency (safe to call
  /// from the controller outside of build).
  static VKeyboardShortcuts? read(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<VKeyboardShortcuts>();
  }

  @override
  bool updateShouldNotify(VKeyboardShortcuts oldWidget) =>
      shortcuts != oldWidget.shortcuts ||
      clipboardCallbacks != oldWidget.clipboardCallbacks ||
      onMedia != oldWidget.onMedia ||
      onMetaKey != oldWidget.onMetaKey ||
      onMenuKey != oldWidget.onMenuKey ||
      onFunctionKey != oldWidget.onFunctionKey;
}
