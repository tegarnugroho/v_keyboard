import 'package:flutter/material.dart';

import '../clipboard/clipboard_history_item.dart';
import '../controller/v_keyboard_controller.dart';
import '../models/key_data.dart';
import '../theme/v_keyboard_theme.dart';

enum _ClipboardFilter { all, pinned, recent }

/// A scrollable Clipboard History panel displayed when `currentPage == 'clipboard'`.
///
/// Provides a modern search field, quick filter chips (All, Pinned, Recent),
/// a responsive grid of snippet cards with pin and delete quick actions,
/// and clear unpinned confirmation.
class ClipboardHistoryPanel extends StatefulWidget {
  const ClipboardHistoryPanel({
    super.key,
    required this.controller,
    required this.theme,
    required this.height,
    required this.maxWidth,
    this.bottomSafeArea = 0,
  });

  final VKeyboardController controller;
  final VKeyboardTheme theme;
  final double height;
  final double maxWidth;
  final double bottomSafeArea;

  @override
  State<ClipboardHistoryPanel> createState() => _ClipboardHistoryPanelState();
}

class _ClipboardHistoryPanelState extends State<ClipboardHistoryPanel> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';
  _ClipboardFilter _filter = _ClipboardFilter.all;
  bool _showClearConfirmation = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    widget.controller.clipboardHistory.syncFromSystemClipboard();
  }

  void _onSearchChanged() {
    final text = _searchController.text;
    if (text != _query) {
      setState(() => _query = text);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _pasteItem(ClipboardHistoryItem item) {
    widget.controller.pasteClipboardItem(item);
  }

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final manager = widget.controller.clipboardHistory;
    final hasOverlay = Overlay.maybeOf(context) != null;
    final panelWidth = (widget.maxWidth.isFinite ? widget.maxWidth : 600.0)
        .clamp(300.0, 850.0);

    return Material(
      color: theme.backgroundColor,
      child: SizedBox(
        height: widget.height + widget.bottomSafeArea,
        child: Column(
          children: [
            // Modern Header: Back, Icon badge, Title, Counter, Clear all, Close
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: panelWidth),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: theme.iconColor, size: 20),
                      tooltip: hasOverlay ? 'Back to keyboard' : null,
                      onPressed: () =>
                          widget.controller.closeClipboardHistory(),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.accentColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.content_paste_rounded,
                          color: theme.accentColor, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Clipboard',
                      style: theme.textStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (manager.items.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${manager.items.length}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: theme.accentColor,
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (manager.items.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.delete_sweep_outlined,
                            color: theme.iconColor.withValues(alpha: 0.8),
                            size: 20),
                        tooltip: hasOverlay ? 'Clear history' : null,
                        onPressed: () =>
                            setState(() => _showClearConfirmation = true),
                      ),
                    IconButton(
                      icon: Icon(Icons.close,
                          color: theme.iconColor.withValues(alpha: 0.8),
                          size: 20),
                      tooltip: hasOverlay ? 'Close' : null,
                      onPressed: () =>
                          widget.controller.closeClipboardHistory(),
                    ),
                  ],
                ),
              ),
            ),

            // Optional confirmation banner
            if (_showClearConfirmation)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.keyColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.redAccent.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: panelWidth),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_forever_rounded,
                            color: Colors.redAccent, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Clear unpinned items?',
                              style: theme.textStyle.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Pinned items will be preserved',
                              style: theme.subLabelStyle.copyWith(
                                fontSize: 11,
                                color: theme.iconColor.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            setState(() => _showClearConfirmation = false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          minimumSize: const Size(50, 32),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.iconColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() => _showClearConfirmation = false);
                          await manager.clearUnpinned();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: const Size(54, 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text('Clear',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),

            // Modern Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: panelWidth),
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    color: theme.keyColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.iconColor.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    boxShadow: theme.elevation > 0
                        ? [
                            BoxShadow(
                              color: theme.shadowColor.withValues(alpha: 0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            )
                          ]
                        : null,
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    style: theme.textStyle.copyWith(fontSize: 13),
                    cursorColor: theme.accentColor,
                    decoration: InputDecoration(
                      hintText: 'Search clipboard...',
                      hintStyle: theme.subLabelStyle.copyWith(
                        fontSize: 13,
                        color: theme.iconColor.withValues(alpha: 0.5),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 19,
                        color: theme.iconColor.withValues(alpha: 0.55),
                      ),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.cancel_rounded,
                                size: 16,
                                color: theme.iconColor.withValues(alpha: 0.55),
                              ),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      suffixIconConstraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),

            // Filter Chips (All · Pinned · Recent)
            if (manager.items.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: panelWidth),
                  child: SizedBox(
                    height: 28,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _filterChip(
                          label: 'All',
                          count: manager.items.length,
                          selected: _filter == _ClipboardFilter.all,
                          onTap: () =>
                              setState(() => _filter = _ClipboardFilter.all),
                        ),
                        const SizedBox(width: 6),
                        _filterChip(
                          label: 'Pinned',
                          icon: Icons.push_pin,
                          count: manager.items.where((i) => i.isPinned).length,
                          selected: _filter == _ClipboardFilter.pinned,
                          onTap: () =>
                              setState(() => _filter = _ClipboardFilter.pinned),
                        ),
                        const SizedBox(width: 6),
                        _filterChip(
                          label: 'Recent',
                          count: manager.items.where((i) => !i.isPinned).length,
                          selected: _filter == _ClipboardFilter.recent,
                          onTap: () =>
                              setState(() => _filter = _ClipboardFilter.recent),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Content List / Responsive Grid
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: panelWidth),
                  child: _buildBody(context, panelWidth),
                ),
              ),
            ),

            // Bottom bar: ABC · Space · Backspace
            Container(
              height: 48,
              padding: EdgeInsets.only(
                  left: 8, right: 8, bottom: widget.bottomSafeArea),
              child: Row(
                children: [
                  _barButton(
                    label: 'ABC',
                    icon: Icons.keyboard_alt_outlined,
                    onTap: () => widget.controller.closeClipboardHistory(),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _barButton(
                      label: 'Space',
                      icon: Icons.space_bar_rounded,
                      onTap: () => widget.controller.handleKey(KeyData.space()),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _barButton(
                    icon: Icons.backspace_outlined,
                    onTap: () =>
                        widget.controller.handleKey(KeyData.backspace()),
                    color: theme.iconColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    IconData? icon,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = widget.theme;
    return Material(
      color: selected
          ? theme.accentColor.withValues(alpha: 0.16)
          : theme.keyColor.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? theme.accentColor
                  : theme.iconColor.withValues(alpha: 0.15),
              width: selected ? 1.2 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 11,
                    color: selected ? theme.accentColor : theme.iconColor),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? theme.accentColor : theme.iconColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '($count)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? theme.accentColor
                      : theme.iconColor.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, double panelWidth) {
    final theme = widget.theme;
    final manager = widget.controller.clipboardHistory;

    if (manager.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: theme.accentColor),
      );
    }

    if (manager.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 32, color: theme.iconColor.withValues(alpha: 0.5)),
            const SizedBox(height: 6),
            Text('Failed to load clipboard history',
                style: theme.subLabelStyle.copyWith(fontSize: 13)),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => manager.reload(),
              child: Text('Retry', style: TextStyle(color: theme.accentColor)),
            ),
          ],
        ),
      );
    }

    var filtered = manager.search(_query);
    if (_filter == _ClipboardFilter.pinned) {
      filtered = filtered.where((i) => i.isPinned).toList();
    } else if (_filter == _ClipboardFilter.recent) {
      filtered = filtered.where((i) => !i.isPinned).toList();
    }

    if (manager.items.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.content_paste_rounded,
                  size: 26,
                  color: theme.accentColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Clipboard is empty',
                style: theme.textStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Copied text snippets will appear here',
                style: theme.subLabelStyle.copyWith(
                  fontSize: 11,
                  color: theme.iconColor.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.iconColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 26,
                  color: theme.iconColor.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'No matching items',
                style: theme.textStyle.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Try a different search term',
                style: theme.subLabelStyle.copyWith(
                  fontSize: 11,
                  color: theme.iconColor.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // On wider screens (e.g. desktop/tablet), arrange cards in 2 columns
    if (panelWidth >= 540) {
      final rowsCount = (filtered.length / 2).ceil();
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        itemCount: rowsCount,
        itemBuilder: (context, rowIndex) {
          final firstIndex = rowIndex * 2;
          final secondIndex = firstIndex + 1;
          final hasSecond = secondIndex < filtered.length;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildItemCard(filtered[firstIndex])),
              const SizedBox(width: 8),
              Expanded(
                child: hasSecond
                    ? _buildItemCard(filtered[secondIndex])
                    : const SizedBox.shrink(),
              ),
            ],
          );
        },
      );
    }

    // On compact screens (e.g. mobile), arrange in a single column
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      children: filtered.map(_buildItemCard).toList(),
    );
  }

  Widget _buildItemCard(ClipboardHistoryItem item) {
    final theme = widget.theme;
    final manager = widget.controller.clipboardHistory;
    final hasOverlay = Overlay.maybeOf(context) != null;
    final isPinned = item.isPinned;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color:
            isPinned ? theme.keyColor.withValues(alpha: 0.95) : theme.keyColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPinned
              ? theme.accentColor.withValues(alpha: 0.8)
              : theme.iconColor.withValues(alpha: 0.12),
          width: isPinned ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isPinned
                ? theme.accentColor.withValues(alpha: 0.08)
                : theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: isPinned ? 5 : 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _pasteItem(item),
          hoverColor: theme.accentColor.withValues(alpha: 0.06),
          splashColor: theme.accentColor.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top metadata row
                Row(
                  children: [
                    if (isPinned) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: theme.accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.push_pin,
                                size: 10, color: theme.accentColor),
                            const SizedBox(width: 3),
                            Text(
                              'PINNED',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: theme.accentColor,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 11,
                            color: theme.iconColor.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              _formatTimestamp(item.createdAt),
                              overflow: TextOverflow.ellipsis,
                              style: theme.subLabelStyle.copyWith(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Pin button
                    Material(
                      color: isPinned
                          ? theme.accentColor.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                          size: 16,
                          color: isPinned
                              ? theme.accentColor
                              : theme.iconColor.withValues(alpha: 0.55),
                        ),
                        tooltip: hasOverlay
                            ? (isPinned ? 'Unpin item' : 'Pin item')
                            : null,
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: () => manager.togglePin(item.id),
                      ),
                    ),
                    const SizedBox(width: 2),
                    // Delete button
                    Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: theme.iconColor.withValues(alpha: 0.55),
                        ),
                        tooltip: hasOverlay ? 'Delete item' : null,
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 28, minHeight: 28),
                        onPressed: () => manager.deleteItem(item.id),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Snippet text content
                Text(
                  item.text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textStyle.copyWith(
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _barButton({
    String? label,
    IconData? icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Material(
      color: widget.theme.specialKeyColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 40,
          constraints: const BoxConstraints(minWidth: 56),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    color: color ?? widget.theme.iconColor,
                    size: label != null ? 18 : 22),
                if (label != null) const SizedBox(width: 6),
              ],
              if (label != null)
                Text(
                  label,
                  style: widget.theme.textStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
