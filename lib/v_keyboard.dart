/// A fully customizable, native-feeling virtual keyboard and text input
/// system for Flutter.
///
/// Wrap your app (or a subtree) in a [VirtualKeyboardScope] and use
/// [VirtualTextField] in place of `TextField`. The keyboard appears when a
/// field gains focus and pushes the UI like the system keyboard.
library v_keyboard;

export 'src/config/virtual_keyboard_config.dart';
export 'src/theme/virtual_keyboard_theme.dart';
export 'src/models/key_data.dart';
export 'src/models/keyboard_type.dart';
export 'src/models/keyboard_layout.dart';
export 'src/layouts/builtin_layouts.dart';
export 'src/engine/text_input_engine.dart';
export 'src/responsive/keyboard_metrics.dart';
export 'src/controller/keyboard_session.dart';
export 'src/controller/virtual_keyboard_controller.dart';
export 'src/scope/virtual_keyboard_scope.dart';
export 'src/widgets/virtual_text_field.dart';
export 'src/widgets/keyboard_view.dart';
