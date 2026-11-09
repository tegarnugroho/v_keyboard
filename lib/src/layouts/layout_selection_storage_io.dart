import 'dart:convert';
import 'dart:io';

import 'layout_selection_storage.dart';

/// File-based persistence for the selected keyboard layout id.
class FileLayoutSelectionStorage implements LayoutSelectionStorage {
  FileLayoutSelectionStorage(this.file);

  final File file;

  @override
  Future<String?> load() async {
    try {
      if (!await file.exists()) {
        return null;
      }
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic> && decoded['layoutId'] is String) {
        return decoded['layoutId'] as String;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(String layoutId) async {
    try {
      final parent = file.parent;
      if (!await parent.exists()) {
        await parent.create(recursive: true);
      }
      final content = jsonEncode({'layoutId': layoutId});
      await file.writeAsString(content, flush: true);
    } catch (_) {
      // Discard write errors safely.
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

LayoutSelectionStorage createPlatformLayoutStorage({String? customPath}) {
  if (customPath != null && customPath.isNotEmpty) {
    return FileLayoutSelectionStorage(File(customPath));
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
      final filePath = '$baseDir/flutter_v_keyboard/selected_layout.json';
      return FileLayoutSelectionStorage(File(filePath));
    }

    final tempPath =
        '${Directory.systemTemp.path}/flutter_v_keyboard/selected_layout.json';
    return FileLayoutSelectionStorage(File(tempPath));
  } catch (_) {
    return InMemoryLayoutSelectionStorage();
  }
}
