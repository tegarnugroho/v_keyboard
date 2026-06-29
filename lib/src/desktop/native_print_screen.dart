/// Triggers the native Windows Print Screen where supported.
///
/// Uses a `dart:ffi` implementation on platforms that have it (desktop) and a
/// no-op stub elsewhere (e.g. web), so the package still compiles everywhere.
library;

export 'native_print_screen_stub.dart'
    if (dart.library.ffi) 'native_print_screen_ffi.dart';
