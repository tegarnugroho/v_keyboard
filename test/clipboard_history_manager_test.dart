import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_v_keyboard/flutter_v_keyboard.dart';

class FailingStorage implements ClipboardHistoryStorage {
  @override
  Future<List<ClipboardHistoryItem>> load() async {
    throw Exception('Storage read failed');
  }

  @override
  Future<void> save(List<ClipboardHistoryItem> items) async {
    throw Exception('Storage write failed');
  }

  @override
  Future<void> clear() async {
    throw Exception('Storage clear failed');
  }
}

void main() {
  group('ClipboardHistoryManager', () {
    test('records a copied item and orders most-recent-first', () async {
      final storage = InMemoryClipboardHistoryStorage();
      final manager = ClipboardHistoryManager(storage: storage);
      await manager.reload();

      await manager.record('First snippet');
      await manager.record('Second snippet');

      expect(manager.items.length, 2);
      expect(manager.items.first.text, 'Second snippet');
      expect(manager.items.last.text, 'First snippet');
    });

    test(
        'ignores empty or whitespace-only content while preserving meaningful whitespace',
        () async {
      final storage = InMemoryClipboardHistoryStorage();
      final manager = ClipboardHistoryManager(storage: storage);
      await manager.reload();

      final r1 = await manager.record('');
      final r2 = await manager.record('   ');
      final r3 = await manager.record('\n\t  ');

      expect(r1, isFalse);
      expect(r2, isFalse);
      expect(r3, isFalse);
      expect(manager.items, isEmpty);

      // Snippet with meaningful spaces around content
      final r4 = await manager.record('  indented code  ');
      expect(r4, isTrue);
      expect(manager.items.length, 1);
      expect(manager.items.first.text, '  indented code  ');
    });

    test(
        'duplicate content moves existing item to top and preserves original metadata',
        () async {
      final storage = InMemoryClipboardHistoryStorage();
      final manager = ClipboardHistoryManager(storage: storage);
      await manager.reload();

      await manager.record('Item A');
      final originalId = manager.items.first.id;
      final originalCreatedAt = manager.items.first.createdAt;

      await manager.togglePin(originalId);
      expect(manager.items.first.isPinned, isTrue);

      await manager.record('Item B');
      expect(manager.items.first.text, 'Item B');
      expect(manager.items.last.text, 'Item A');

      // Re-recording Item A moves it back to top
      await manager.record('Item A');
      expect(manager.items.length, 2);
      expect(manager.items.first.text, 'Item A');
      expect(manager.items.first.id, originalId);
      expect(manager.items.first.createdAt, originalCreatedAt);
      expect(manager.items.first.isPinned, isTrue);
    });

    test('enforces maxItems limit while pinned items survive eviction',
        () async {
      final storage = InMemoryClipboardHistoryStorage();
      final manager = ClipboardHistoryManager(storage: storage, maxItems: 2);
      await manager.reload();

      await manager.record('Item 1');
      await manager.record('Item 2');
      expect(manager.items.length, 2);

      // Pin Item 1 (now at index 1)
      final item1Id = manager.items.last.id;
      await manager.togglePin(item1Id);
      expect(manager.items.last.isPinned, isTrue);

      // Add Item 3: unpinned count would be 2 (Item 2 and Item 3).
      await manager.record('Item 3');
      expect(manager.items.length, 3); // 2 unpinned + 1 pinned

      // Add Item 4: unpinned limit of 2 is exceeded, so oldest unpinned (Item 2) is evicted.
      await manager.record('Item 4');
      final texts = manager.items.map((i) => i.text).toList();
      expect(texts, contains('Item 4'));
      expect(texts, contains('Item 3'));
      expect(texts, contains('Item 1')); // Pinned item survived!
      expect(texts, isNot(contains('Item 2'))); // Evicted
    });

    test('pinning and unpinning items', () async {
      final storage = InMemoryClipboardHistoryStorage();
      final manager = ClipboardHistoryManager(storage: storage);
      await manager.reload();

      await manager.record('Snippet');
      final id = manager.items.first.id;

      expect(manager.items.first.isPinned, isFalse);
      await manager.setPinned(id, true);
      expect(manager.items.first.isPinned, isTrue);
      await manager.togglePin(id);
      expect(manager.items.first.isPinned, isFalse);
    });

    test('deleting individual items', () async {
      final storage = InMemoryClipboardHistoryStorage();
      final manager = ClipboardHistoryManager(storage: storage);
      await manager.reload();

      await manager.record('Keep me');
      await manager.record('Delete me');

      final deleteId = manager.items.first.id;
      await manager.deleteItem(deleteId);

      expect(manager.items.length, 1);
      expect(manager.items.first.text, 'Keep me');
    });

    test('clearUnpinned clears only unpinned items; clearAll clears everything',
        () async {
      final storage = InMemoryClipboardHistoryStorage();
      final manager = ClipboardHistoryManager(storage: storage);
      await manager.reload();

      await manager.record('Unpinned 1');
      await manager.record('Pinned 1');
      await manager.record('Unpinned 2');

      final pinnedId = manager.items[1].id;
      await manager.togglePin(pinnedId);

      await manager.clearUnpinned();
      expect(manager.items.length, 1);
      expect(manager.items.first.text, 'Pinned 1');

      await manager.clearAll();
      expect(manager.items, isEmpty);
    });

    test('searching history with case-insensitive substring', () async {
      final storage = InMemoryClipboardHistoryStorage();
      final manager = ClipboardHistoryManager(storage: storage);
      await manager.reload();

      await manager.record('Flutter virtual keyboard');
      await manager.record('Dart language');
      await manager.record('KEYBOARD SHORTCUTS');

      expect(manager.search('').length, 3);
      expect(manager.search('keyboard').length, 2);
      expect(manager.search('VIRTUAL').length, 1);
      expect(manager.search('notFound'), isEmpty);
    });

    test('persists items across manager reinitialization', () async {
      final storage = InMemoryClipboardHistoryStorage();
      final manager1 = ClipboardHistoryManager(storage: storage);
      await manager1.reload();

      await manager1.record('Persisted text');
      await manager1.togglePin(manager1.items.first.id);

      final manager2 = ClipboardHistoryManager(storage: storage);
      await manager2.reload();

      expect(manager2.items.length, 1);
      expect(manager2.items.first.text, 'Persisted text');
      expect(manager2.items.first.isPinned, isTrue);
    });

    test('handles corrupted stored data gracefully', () async {
      final item = ClipboardHistoryItem.fromJson(const {
        'id': 123,
        'text': null,
        'createdAt': 'invalid-date',
      });
      expect(item.id, '123');
      expect(item.text, '');
      expect(item.createdAt, isNotNull);
      expect(item.isPinned, isFalse);
    });

    test('handles storage error gracefully', () async {
      final failing = FailingStorage();
      final manager = ClipboardHistoryManager(storage: failing);
      await manager.reload();

      expect(manager.error, isNotNull);
      expect(manager.isLoading, isFalse);
      expect(manager.items, isEmpty);
    });

    test('disabling clipboard history prevents new recordings', () async {
      final storage = InMemoryClipboardHistoryStorage();
      final manager = ClipboardHistoryManager(storage: storage, enabled: false);
      await manager.reload();

      final recorded = await manager.record('Should not save');
      expect(recorded, isFalse);
      expect(manager.items, isEmpty);

      manager.isEnabled = true;
      final recordedAfter = await manager.record('Should save');
      expect(recordedAfter, isTrue);
      expect(manager.items.length, 1);
    });
  });
}
