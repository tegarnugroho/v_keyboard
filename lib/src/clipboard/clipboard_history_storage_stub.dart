import 'clipboard_history_storage.dart';

ClipboardHistoryStorage createPlatformDefaultStorage({String? customPath}) {
  return InMemoryClipboardHistoryStorage();
}
