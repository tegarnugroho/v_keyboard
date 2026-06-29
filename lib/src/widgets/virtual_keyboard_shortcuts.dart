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
/// VirtualKeyboardShortcuts(
///   shortcuts: {
///     LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): save,
///     LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyP): print,
///   },
///   onMedia: (intent) => player.handle(intent),
///   child: ...,
/// )
/// ```
class VirtualKeyboardShortcuts extends InheritedWidget {
  const VirtualKeyboardShortcuts({
    super.key,
    this.shortcuts = const {},
    this.clipboardCallbacks,
    this.onMedia,
    this.onMetaKey,
    this.onMenuKey,
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

  KeyboardShortcutManager get manager => KeyboardShortcutManager(shortcuts);

  /// Reads the nearest instance without creating a dependency (safe to call
  /// from the controller outside of build).
  static VirtualKeyboardShortcuts? read(BuildContext context) {
    return context
        .getInheritedWidgetOfExactType<VirtualKeyboardShortcuts>();
  }

  @override
  bool updateShouldNotify(VirtualKeyboardShortcuts oldWidget) =>
      shortcuts != oldWidget.shortcuts ||
      clipboardCallbacks != oldWidget.clipboardCallbacks ||
      onMedia != oldWidget.onMedia ||
      onMetaKey != oldWidget.onMetaKey ||
      onMenuKey != oldWidget.onMenuKey;
}
