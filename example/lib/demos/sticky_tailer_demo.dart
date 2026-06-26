import 'package:flash_list_view/flash_list_view.dart';
import 'package:flutter/material.dart';

import '_shared.dart';

/// Case 3 — Sticky pinned to the bottom edge (`stickyAtTailer: true`).
///
/// Same sectioned data as the standalone demo, but the active header pins to
/// the *bottom* of the viewport and is pushed down by the next section's header
/// as you scroll up. Useful for "current group" footers.
class StickyTailerDemo extends StatefulWidget {
  const StickyTailerDemo({super.key});

  @override
  State<StickyTailerDemo> createState() => _StickyTailerDemoState();
}

class _StickyTailerDemoState extends State<StickyTailerDemo> {
  final _controller = FlashListViewController();
  late final List<FlatEntry> _entries = buildSectionedEntries(
    sections: 12,
    itemsPerSection: 8,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sticky · pinned to bottom')),
      body: FlashListView(
        controller: _controller,
        reverse: true,
        delegate: FlashListViewDelegate(
          (context, index) {
            final entry = _entries[index];
            return entry.isHeader
                ? SectionHeaderTile(label: entry.label)
                : ItemTile(label: entry.label);
          },
          childCount: _entries.length,
          onItemKey: (index) => _entries[index].key,
          onItemSticky: (index) => _entries[index].isHeader,
          stickyAtTailer: false,
          onItemHeight: (index) =>
              _entries[index].isHeader ? kHeaderHeight : kItemHeight,
          preferItemHeight: kItemHeight,
        ),
      ),
      bottomNavigationBar: StickyBanner(
        stickyIndex: _controller.sliverController.stickyIndex,
        entries: _entries,
        title: 'Pinned at bottom',
      ),
    );
  }
}
