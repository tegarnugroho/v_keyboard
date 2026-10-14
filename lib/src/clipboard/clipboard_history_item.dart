import 'package:flutter/foundation.dart';

/// A single recorded clipboard snippet in [ClipboardHistoryManager].
@immutable
class ClipboardHistoryItem {
  const ClipboardHistoryItem({
    required this.id,
    required this.text,
    required this.createdAt,
    this.isPinned = false,
  });

  /// Unique identifier for this history item.
  final String id;

  /// The text content of the snippet.
  final String text;

  /// Timestamp when the snippet was first recorded.
  final DateTime createdAt;

  /// Whether this item is pinned. Pinned items are protected from automatic
  /// eviction and normal history clearing.
  final bool isPinned;

  ClipboardHistoryItem copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    bool? isPinned,
  }) {
    return ClipboardHistoryItem(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'isPinned': isPinned,
      };

  factory ClipboardHistoryItem.fromJson(Map<String, dynamic> json) {
    return ClipboardHistoryItem(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      isPinned: json['isPinned'] == true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClipboardHistoryItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          createdAt == other.createdAt &&
          isPinned == other.isPinned;

  @override
  int get hashCode => Object.hash(id, text, createdAt, isPinned);
}
