import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../config/virtual_keyboard_config.dart';
import '../layouts/builtin_layouts.dart';
import '../models/keyboard_layout.dart';
import '../models/keyboard_type.dart';

/// An editing session: everything the controller needs to drive a single
/// [VirtualTextField]. Created when a field gains focus and discarded when it
/// loses focus.
///
/// A session never holds editing state itself — the source of truth is the
/// field's [TextEditingController], so the state can never be lost when the
/// keyboard shows/hides or switches fields.
class KeyboardSession {
  KeyboardSession({
    required this.id,
    required this.editingController,
    required this.focusNode,
    required this.type,
    required this.textInputAction,
    required this.config,
    required this.contextRef,
    this.customLayout,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.onSelectionChanged,
    this.onAction,
    this.obscureText = false,
  });

  /// Stable identity for the field (used to detect re-attach of the same one).
  final Object id;

  final TextEditingController editingController;
  final FocusNode focusNode;
  final VirtualKeyboardType type;
  final TextInputAction textInputAction;
  final VirtualKeyboardConfig config;
  final KeyboardLayout? customLayout;

  /// A function returning the field's [BuildContext], used for focus traversal.
  /// Returns null once the field is disposed, so traversal degrades safely.
  final BuildContext? Function() contextRef;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final ValueChanged<TextSelection>? onSelectionChanged;
  final ValueChanged<TextInputAction>? onAction;
  final bool obscureText;

  /// The resolved layout for this session.
  late final KeyboardLayout layout =
      BuiltinLayouts.resolve(type, custom: customLayout);

  /// Whether the enter key inserts a newline rather than submitting.
  bool get insertsNewline =>
      type == VirtualKeyboardType.multiline ||
      textInputAction == TextInputAction.newline;

  /// Whether auto-shift should be active for this session.
  bool get allowsAutoShift =>
      config.autoShiftFirstLetter &&
      type != VirtualKeyboardType.password &&
      _isAlphabetic;

  bool get _isAlphabetic => switch (type) {
        VirtualKeyboardType.standard ||
        VirtualKeyboardType.email ||
        VirtualKeyboardType.url ||
        VirtualKeyboardType.multiline =>
          true,
        _ => false,
      };

  /// The live editing value.
  TextEditingValue get value => editingController.value;
  set value(TextEditingValue v) => editingController.value = v;
}
