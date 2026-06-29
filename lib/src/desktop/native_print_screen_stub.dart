// No-op fallbacks used on platforms without `dart:ffi` (e.g. web).

/// Synthesises a native Windows virtual-key press. No-op here.
void sendNativeKey(int vk, {bool extended = false}) {}

/// Triggers the native Windows Print Screen. No-op here.
void triggerPrintScreen() {}
