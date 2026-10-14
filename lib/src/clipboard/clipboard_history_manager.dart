import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'clipboard_history_item.dart';
import 'clipboard_history_storage.dart';

/// Manages clipboard history recording, persistence, search, pinning, and deletion.
///
/// Records snippets copied or cut through `v_keyboard` and can synchronize with
/// the host operating system clipboard across all supported platforms (Android,
/// iOS, macOS, Windows, Linux, and Web).
class ClipboardHistoryManager extends ChangeNotifier {
  ClipboardHistoryManager({
    ClipboardHistoryStorage? storage,
    int maxItems = 50,
    bool enabled = true,
    bool syncSystemClipboard = true,
  })  : _storage = storage ?? ClipboardHistoryStorage.defaultStorage(),
        _maxItems = maxItems,
        _enabled = enabled,
        _syncSystemClipboard = syncSystemClipboard {
    _init();
  }

  final ClipboardHistoryStorage _storage;
  int _maxItems;
  bool _enabled;
  bool _syncSystemClipboard;
  List<ClipboardHistoryItem> _items = [];
  bool _isLoading = true;
  Object? _error;

  /// Whether storage initialization is in progress.
  bool get isLoading => _isLoading;

  /// Last storage or processing error, if any.
  Object? get error => _error;

  /// Whether recording to clipboard history is enabled.
  bool get isEnabled => _enabled;
  set isEnabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    notifyListeners();
  }

  /// Whether to synchronize with the host operating system clipboard.
  bool get syncSystemClipboard => _syncSystemClipboard;
  set syncSystemClipboard(bool value) {
    if (_syncSystemClipboard == value) return;
    _syncSystemClipboard = value;
    notifyListeners();
  }

  /// Maximum number of unpinned items preserved in history.
  ///
  /// Pinned items do not count against this limit and are never automatically evicted.
  int get maxItems => _maxItems;
  set maxItems(int value) {
    if (_maxItems == value) return;
    _maxItems = value;
    _enforceLimit();
    _persist();
    notifyListeners();
  }

  /// The list of clipboard history items, ordered with most recent first.
  List<ClipboardHistoryItem> get items => List.unmodifiable(_items);

  /// Reloads items from storage.
  Future<void> reload() => _init();

  Future<void> _init() async {
    try {
      _isLoading = true;
      notifyListeners();
      final loaded = await _storage.load();
      _items = List.of(loaded);
      _enforceLimit();
      _error = null;
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Synchronizes the clipboard history with the operating system clipboard.
  ///
  /// Works across all supported platforms (Android, iOS, macOS, Windows, Linux, Web)
  /// using Flutter's native [Clipboard.getData].
  ///
  /// If the OS clipboard contains non-empty text, it is recorded into history
  /// (or moved to the top position if already present).
  ///
  /// Returns `true` if an item was successfully imported or moved.
  Future<bool> syncFromSystemClipboard() async {
    if (!_enabled || !_syncSystemClipboard) return false;
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text;
      if (text != null && text.trim().isNotEmpty) {
        if (_items.isNotEmpty && _items.first.text == text) {
          return false;
        }
        return await record(text);
      }
    } catch (e) {
      _error = e;
    }
    return false;
  }

  /// Records text copied or cut through `v_keyboard`.
  ///
  /// Returns `true` if the text was recorded or moved to the top.
  /// Ignores empty or whitespace-only content, as well as when [isEnabled] is false.
  /// If an item with identical [text] already exists, it is moved to the top
  /// position (index 0) while preserving its original [ClipboardHistoryItem.id],
  /// [ClipboardHistoryItem.createdAt], and [ClipboardHistoryItem.isPinned].
  Future<bool> record(String text) async {
    if (!_enabled) return false;
    if (text.trim().isEmpty) return false;

    final existingIndex = _items.indexWhere((item) => item.text == text);
    if (existingIndex != -1) {
      final existing = _items.removeAt(existingIndex);
      _items.insert(0, existing);
    } else {
      final newItem = ClipboardHistoryItem(
        id: '${DateTime.now().microsecondsSinceEpoch}_${_items.length}',
        text: text,
        createdAt: DateTime.now(),
        isPinned: false,
      );
      _items.insert(0, newItem);
    }

    _enforceLimit();
    notifyListeners();
    await _persist();
    return true;
  }

  /// Toggles the pin state of the item with [id].
  Future<void> togglePin(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    final item = _items[index];
    _items[index] = item.copyWith(isPinned: !item.isPinned);
    _enforceLimit();
    notifyListeners();
    await _persist();
  }

  /// Sets the pin state of the item with [id].
  Future<void> setPinned(String id, bool isPinned) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    final item = _items[index];
    if (item.isPinned == isPinned) return;
    _items[index] = item.copyWith(isPinned: isPinned);
    _enforceLimit();
    notifyListeners();
    await _persist();
  }

  /// Deletes an item from history by its [id].
  Future<void> deleteItem(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    _items.removeAt(index);
    notifyListeners();
    await _persist();
  }

  /// Clears all unpinned items. Pinned items are preserved.
  Future<void> clearUnpinned() async {
    _items.removeWhere((i) => !i.isPinned);
    notifyListeners();
    await _persist();
  }

  /// Clears all items from history, including pinned items.
  Future<void> clearAll() async {
    _items.clear();
    notifyListeners();
    await _persist();
  }

  /// Filters items by [query] case-insensitively.
  ///
  /// If [query] is empty or whitespace-only, returns all [items].
  List<ClipboardHistoryItem> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return _items.where((item) => item.text.toLowerCase().contains(q)).toList();
  }

  void _enforceLimit() {
    int unpinnedCount = _items.where((i) => !i.isPinned).length;
    if (unpinnedCount <= _maxItems) return;

    for (int i = _items.length - 1; i >= 0 && unpinnedCount > _maxItems; i--) {
      if (!_items[i].isPinned) {
        _items.removeAt(i);
        unpinnedCount--;
      }
    }
  }

  Future<void> _persist() async {
    try {
      await _storage.save(_items);
    } catch (e) {
      _error = e;
    }
  }
}

