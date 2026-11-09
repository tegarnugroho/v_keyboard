import 'layout_selection_storage_stub.dart'
    if (dart.library.io) 'layout_selection_storage_io.dart'
    as platform_storage;

/// Abstract persistence contract for storing the user's selected keyboard layout.
abstract class LayoutSelectionStorage {
  /// Loads the persisted layout id, or returns null if none is saved.
  Future<String?> load();

  /// Persists the selected layout id.
  Future<void> save(String layoutId);

  /// Clears the persisted layout id.
  Future<void> clear();

  /// Creates a default storage mechanism appropriate for the current platform.
  factory LayoutSelectionStorage.defaultStorage({String? customPath}) =>
      platform_storage.createPlatformLayoutStorage(customPath: customPath);
}

/// In-memory layout storage implementation for testing or transient sessions.
class InMemoryLayoutSelectionStorage implements LayoutSelectionStorage {
  InMemoryLayoutSelectionStorage([this._savedId]);

  String? _savedId;

  @override
  Future<String?> load() async => _savedId;

  @override
  Future<void> save(String layoutId) async {
    _savedId = layoutId;
  }

  @override
  Future<void> clear() async {
    _savedId = null;
  }
}
