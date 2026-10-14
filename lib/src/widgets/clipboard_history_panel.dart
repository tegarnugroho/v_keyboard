import 'package:flutter/material.dart';

import '../clipboard/clipboard_history_item.dart';
import '../controller/v_keyboard_controller.dart';
import '../models/key_data.dart';
import '../theme/v_keyboard_theme.dart';

/// A scrollable Clipboard History panel displayed when `currentPage == 'clipboard'`.
///
/// Provides a search field, list of saved snippets, pin/unpin toggles, single item
/// deletion, and clear history with confirmation. Tapping an item pastes its full
/// content into the active field without closing the keyboard.
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
  bool _showClearConfirmation = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
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
    final panelWidth =
        (widget.maxWidth.isFinite ? widget.maxWidth : 600.0).clamp(300.0, 700.0);

    return Material(
      color: theme.backgroundColor,
      child: SizedBox(
        height: widget.height + widget.bottomSafeArea,
        child: Column(
          children: [
            // Header: Title, Clear all button, Close button
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: panelWidth),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: theme.iconColor, size: 20),
                      tooltip: 'Back to keyboard',
                      onPressed: () => widget.controller.closeClipboardHistory(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Clipboard',
                      style: theme.textStyle.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (manager.items.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.delete_sweep_outlined,
                            color: theme.iconColor, size: 20),
                        tooltip: 'Clear history',
                        onPressed: () =>
                            setState(() => _showClearConfirmation = true),
                      ),
                    IconButton(
                      icon: Icon(Icons.close, color: theme.iconColor, size: 20),
                      tooltip: 'Close',
                      onPressed: () => widget.controller.closeClipboardHistory(),
                    ),
                  ],
                ),
              ),
            ),

            // Optional confirmation banner
            if (_showClearConfirmation)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.keyColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: panelWidth),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: theme.accentColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Clear unpinned items?',
                          style: theme.subLabelStyle.copyWith(fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            setState(() => _showClearConfirmation = false),
                        child: Text('Cancel',
                            style: TextStyle(
                                color: theme.iconColor.withValues(alpha: 0.7))),
                      ),
                      TextButton(
                        onPressed: () async {
                          setState(() => _showClearConfirmation = false);
                          await manager.clearUnpinned();
                        },
                        child: Text('Clear',
                            style: TextStyle(color: theme.accentColor)),
                      ),
                    ],
                  ),
                ),
              ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: panelWidth),
                child: SizedBox(
                  height: 36,
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    style: theme.textStyle.copyWith(fontSize: 13),
                    cursorColor: theme.accentColor,
                    decoration: InputDecoration(
                      hintText: 'Search clipboard...',
                      hintStyle: theme.subLabelStyle.copyWith(fontSize: 13),
                      prefixIcon: Icon(Icons.search,
                          size: 18, color: theme.iconColor.withValues(alpha: 0.6)),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  size: 16,
                                  color: theme.iconColor.withValues(alpha: 0.6)),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      suffixIconConstraints:
                          const BoxConstraints(minWidth: 32, minHeight: 32),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      filled: true,
                      fillColor: theme.keyColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content List
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: panelWidth),
                  child: _buildBody(context),
                ),
              ),
            ),

            // Bottom bar: ABC · space · backspace
            Container(
              height: 48,
              padding: EdgeInsets.only(
                  left: 8, right: 8, bottom: widget.bottomSafeArea),
              child: Row(
                children: [
                  _barButton(
                    label: 'ABC',
                    onTap: () => widget.controller.closeClipboardHistory(),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _barButton(
                      onTap: () =>
                          widget.controller.handleKey(KeyData.space()),
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

  Widget _buildBody(BuildContext context) {
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

    final filtered = manager.search(_query);

    if (manager.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.content_paste_outlined,
                size: 36, color: theme.iconColor.withValues(alpha: 0.35)),
            const SizedBox(height: 8),
            Text('Clipboard is empty',
                style: theme.textStyle.copyWith(fontSize: 15)),
            const SizedBox(height: 4),
            Text('Copied text snippets will appear here',
                style: theme.subLabelStyle.copyWith(fontSize: 12)),
          ],
        ),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_outlined,
                size: 36, color: theme.iconColor.withValues(alpha: 0.35)),
            const SizedBox(height: 8),
            Text('No matching items',
                style: theme.textStyle.copyWith(fontSize: 15)),
            const SizedBox(height: 4),
            Text('Try a different search term',
                style: theme.subLabelStyle.copyWith(fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      cacheExtent: 600,
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(ClipboardHistoryItem item) {
    final theme = widget.theme;
    final manager = widget.controller.clipboardHistory;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: theme.keyColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: theme.elevation > 0
            ? [
                BoxShadow(
                  color: theme.shadowColor,
                  blurRadius: theme.elevation,
                  offset: Offset(0, theme.elevation * 0.5),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _pasteItem(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textStyle.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(item.createdAt),
                        style: theme.subLabelStyle.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: Icon(
                    item.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 18,
                    color: item.isPinned
                        ? theme.accentColor
                        : theme.iconColor.withValues(alpha: 0.5),
                  ),
                  tooltip: item.isPinned ? 'Unpin item' : 'Pin item',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () => manager.togglePin(item.id),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: theme.iconColor.withValues(alpha: 0.5),
                  ),
                  tooltip: 'Delete item',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () => manager.deleteItem(item.id),
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: icon != null
              ? Icon(icon, color: color ?? widget.theme.iconColor, size: 22)
              : Text(label ?? '',
                  style: widget.theme.textStyle.copyWith(fontSize: 15)),
        ),
      ),
    );
  }
}
