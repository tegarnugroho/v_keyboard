import 'dart:ffi';
import 'dart:io';

// Win32 `keybd_event` from user32.dll:
//   void keybd_event(BYTE bVk, BYTE bScan, DWORD dwFlags, ULONG_PTR dwExtraInfo)
typedef _KeybdEventC = Void Function(
    Uint8 bVk, Uint8 bScan, Uint32 dwFlags, IntPtr dwExtraInfo);
typedef _KeybdEventDart = void Function(int, int, int, int);

const int _keyEventfExtendedKey = 0x0001;
const int _keyEventfKeyUp = 0x0002;
const int _vkSnapshot = 0x2C; // PRINT SCREEN

_KeybdEventDart? _keybdEvent;
bool _resolved = false;

_KeybdEventDart? _resolve() {
  if (_resolved) return _keybdEvent;
  _resolved = true;
  if (!Platform.isWindows) return null;
  try {
    final user32 = DynamicLibrary.open('user32.dll');
    _keybdEvent =
        user32.lookupFunction<_KeybdEventC, _KeybdEventDart>('keybd_event');
  } catch (_) {
    _keybdEvent = null;
  }
  return _keybdEvent;
}

/// Synthesises a press+release of the Windows virtual-key [vk] (e.g. volume,
/// media, Win/Menu, Scroll Lock). [extended] is required for the extended keys
/// (media/volume/navigation). No-op on non-Windows platforms.
void sendNativeKey(int vk, {bool extended = false}) {
  final keybd = _resolve();
  if (keybd == null) return;
  final flags = extended ? _keyEventfExtendedKey : 0;
  keybd(vk, 0, flags, 0); // key down
  keybd(vk, 0, flags | _keyEventfKeyUp, 0); // key up
}

/// Triggers the native Windows Print Screen (captures the whole screen to the
/// clipboard). No-op on non-Windows platforms. Pure FFI — no runner code.
void triggerPrintScreen() => sendNativeKey(_vkSnapshot);
