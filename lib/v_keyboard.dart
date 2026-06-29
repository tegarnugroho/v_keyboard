/// A fully customizable, native-feeling virtual keyboard and text input
/// system for Flutter.
///
/// Wrap your app (or a subtree) in a [VKeyboardScope] and use
/// [VTextField] in place of `TextField`. The keyboard appears when a
/// field gains focus and pushes the UI like the system keyboard.
library v_keyboard;

export 'src/config/v_keyboard_config.dart';
export 'src/theme/v_keyboard_theme.dart';
export 'src/models/key_data.dart';
export 'src/models/key_intents.dart';
export 'src/models/keyboard_type.dart';
export 'src/models/keyboard_layout.dart';
export 'src/layouts/builtin_layouts.dart';
export 'src/layouts/desktop_layouts.dart';
export 'src/layouts/emoji_data.dart';
export 'src/emojis/emojis.dart';
export 'src/engine/text_input_engine.dart';
export 'src/responsive/keyboard_metrics.dart';
export 'src/controller/keyboard_session.dart';
export 'src/controller/v_keyboard_controller.dart';
export 'src/desktop/keyboard_modifier_controller.dart';
export 'src/desktop/keyboard_navigation.dart';
export 'src/desktop/keyboard_shortcut_manager.dart';
export 'src/desktop/clipboard_actions.dart';
export 'src/scope/v_keyboard_scope.dart';
export 'src/widgets/v_text_field.dart';
export 'src/widgets/v_keyboard_shortcuts.dart';
export 'src/widgets/keyboard_view.dart';
