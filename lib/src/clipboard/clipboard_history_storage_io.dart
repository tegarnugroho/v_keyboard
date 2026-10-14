import 'dart:convert';
import 'dart:io';

import 'clipboard_history_item.dart';
import 'clipboard_history_storage.dart';

/// File-based persistence for [ClipboardHistoryItem]s using JSON serialization.
class FileClipboardHistoryStorage implements ClipboardHistoryStorage {
  FileClipboardHistoryStorage(this.file);

  final File file;

  @override
  Future<List<ClipboardHistoryItem>> load() async {
    try {
      if (!await file.exists()) {
        return [];
      }
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return [];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      final items = <ClipboardHistoryItem>[];
      for (final entry in decoded) {
        if (entry is Map<String, dynamic>) {
          try {
            items.add(ClipboardHistoryItem.fromJson(entry));
          } catch (_) {
            // Skip corrupted individual item.
          }
        }
      }
      return items;
    } catch (_) {
      // Return empty list on corrupted file, missing permissions, or I/O failure.
      return [];
    }
  }

  @override
  Future<void> save(List<ClipboardHistoryItem> items) async {
    try {
      final parent = file.parent;
      if (!await parent.exists()) {
        await parent.create(recursive: true);
      }
      final jsonList = items.map((i) => i.toJson()).toList();
      final content = jsonEncode(jsonList);
      await file.writeAsString(content, flush: true);
    } catch (_) {
      // Discard write errors safely without terminating caller.
    }
  }

  @override
  Future<void> clear() async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Discard deletion errors safely.
    }
  }
}

ClipboardHistoryStorage createPlatformDefaultStorage({String? customPath}) {
  if (customPath != null && customPath.isNotEmpty) {
    return FileClipboardHistoryStorage(File(customPath));
  }

  try {
    String? baseDir;
    if (Platform.isWindows) {
      baseDir = Platform.environment['APPDATA'] ??
          Platform.environment['LOCALAPPDATA'];
    } else if (Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        baseDir = '$home/Library/Application Support';
      }
    } else if (Platform.isLinux) {
      baseDir = Platform.environment['XDG_DATA_HOME'];
      if (baseDir == null || baseDir.isEmpty) {
        final home = Platform.environment['HOME'];
        if (home != null) {
          baseDir = '$home/.local/share';
        }
      }
    }

    if (baseDir != null && baseDir.isNotEmpty) {
      final filePath = '$baseDir/flutter_v_keyboard/clipboard_history.json';
      return FileClipboardHistoryStorage(File(filePath));
    }

    // Fallback for mobile platforms or environments without standard home dirs
    final tempPath =
        '${Directory.systemTemp.path}/flutter_v_keyboard/clipboard_history.json';
    return FileClipboardHistoryStorage(File(tempPath));
  } catch (_) {
    // If accessing Platform or File fails for any reason, safely fall back to in-memory.
    return InMemoryClipboardHistoryStorage();
  }
}
