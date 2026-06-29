import 'package:flutter/widgets.dart';

import 'key_data.dart';

/// A keyboard layout: one or more named *pages* of key rows.
///
/// A page is a `List<List<KeyData>>` (rows of keys). The standard alphabetic
/// keyboard, for example, exposes the pages `abc`, `123` and `symbols`, and
/// switches between them via [KeyData.switchTo] keys.
@immutable
class KeyboardLayout {
  const KeyboardLayout({
    required this.id,
    required this.pages,
    required this.initialPage,
  }) : assert(pages.length > 0);

  /// Identifier for this layout (useful for debugging / theming).
  final String id;

  /// Map of page id -> rows of keys.
  final Map<String, List<List<KeyData>>> pages;

  /// The page shown first when the keyboard opens.
  final String initialPage;

  /// Returns the rows for [pageId], falling back to the initial page.
  List<List<KeyData>> rowsFor(String pageId) =>
      pages[pageId] ?? pages[initialPage]!;

  /// The maximum number of rows across all pages — used for height stability
  /// so the keyboard doesn't jump when switching pages.
  int get maxRows =>
      pages.values.fold(0, (m, rows) => rows.length > m ? rows.length : m);
}
