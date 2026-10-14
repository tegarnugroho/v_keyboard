import 'clipboard_history_item.dart';
import 'clipboard_history_storage_stub.dart'
    if (dart.library.io) 'clipboard_history_storage_io.dart' as platform_storage;

/// Abstract persistence contract for [ClipboardHistoryManager].
abstract class ClipboardHistoryStorage {
  /// Loads persisted items from storage.
  ///
  /// Should return an empty list if no items are stored or if stored data is corrupted.
  Future<List<ClipboardHistoryItem>> load();

  /// Persists [items] to storage.
  Future<void> save(List<ClipboardHistoryItem> items);

  /// Clears persisted storage.
  Future<void> clear();

  /// Creates a default storage mechanism appropriate for the current platform.
  ///
  /// On platforms with `dart:io` support, this uses a local JSON file in a user
  /// data or temporary directory. On web, an in-memory storage is used.
  factory ClipboardHistoryStorage.defaultStorage({String? customPath}) =>
      platform_storage.createPlatformDefaultStorage(customPath: customPath);
}

/// In-memory storage implementation for testing or transient sessions.
class InMemoryClipboardHistoryStorage implements ClipboardHistoryStorage {
  InMemoryClipboardHistoryStorage([List<ClipboardHistoryItem>? initialItems])
      : _items = initialItems != null ? List.of(initialItems) : [];

  List<ClipboardHistoryItem> _items;

  @override
  Future<List<ClipboardHistoryItem>> load() async => List.unmodifiable(_items);

  @override
  Future<void> save(List<ClipboardHistoryItem> items) async {
    _items = List.of(items);
  }

  @override
  Future<void> clear() async {
    _items = [];
  }
}
