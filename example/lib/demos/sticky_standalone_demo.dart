import 'package:flash_list_view/flash_list_view.dart';
import 'package:flutter/material.dart';

import '_shared.dart';

/// Case 1 — Sticky section headers in a standalone [FlashListView].
///
/// The simplest setup: a full-screen list where every header index returns
/// `true` from [FlashListViewDelegate.onItemSticky]. One header stays pinned to
/// the top at a time and is pushed up by the next one.
class StickyStandaloneDemo extends StatefulWidget {
  const StickyStandaloneDemo({super.key});

  @override
  State<StickyStandaloneDemo> createState() => _StickyStandaloneDemoState();
}

class _StickyStandaloneDemoState extends State<StickyStandaloneDemo> {
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
      appBar: AppBar(
        title: const Text('Sticky · standalone'),
        bottom: StickyBanner(
          stickyIndex: _controller.sliverController.stickyIndex,
          entries: _entries,
        ),
      ),
      body: FlashListView(
        controller: _controller,
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
          onItemHeight: (index) =>
              _entries[index].isHeader ? kHeaderHeight : kItemHeight,
          preferItemHeight: kItemHeight,
        ),
      ),
    );
  }
}
