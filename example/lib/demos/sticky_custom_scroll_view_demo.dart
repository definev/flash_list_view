import 'package:flash_list_view/flash_list_view.dart';
import 'package:flutter/material.dart';

import '_shared.dart';

/// Case 2 — Sticky [FlashSliverList] composed inside a [CustomScrollView].
///
/// This is the Sliver-compatibility case: section headers pin to the viewport
/// line *below* the pinned [SliverAppBar], two independent [FlashSliverList]s
/// are interleaved with plain box slivers, and each list tracks its own active
/// header via `FlashSliverListController.stickyIndex`.
class StickyCustomScrollViewDemo extends StatefulWidget {
  const StickyCustomScrollViewDemo({super.key});

  @override
  State<StickyCustomScrollViewDemo> createState() =>
      _StickyCustomScrollViewDemoState();
}

class _StickyCustomScrollViewDemoState
    extends State<StickyCustomScrollViewDemo> {
  final _scrollController = ScrollController();
  final _listA = FlashSliverListController();
  final _listB = FlashSliverListController();

  late final List<FlatEntry> _entriesA = buildSectionedEntries(
    sections: 5,
    itemsPerSection: 6,
  );
  late final List<FlatEntry> _entriesB = buildSectionedEntries(
    sections: 5,
    itemsPerSection: 6,
  );

  @override
  void dispose() {
    _scrollController.dispose();
    _listA.dispose();
    _listB.dispose();
    super.dispose();
  }

  FlashListViewDelegate _stickyDelegate(List<FlatEntry> entries) {
    return FlashListViewDelegate(
      (context, index) {
        final entry = entries[index];
        return entry.isHeader
            ? SectionHeaderTile(label: entry.label)
            : ItemTile(label: entry.label);
      },
      childCount: entries.length,
      onItemKey: (index) => entries[index].key,
      onItemSticky: (index) => entries[index].isHeader,
      onItemHeight: (index) =>
          entries[index].isHeader ? kHeaderHeight : kItemHeight,
      preferItemHeight: kItemHeight,
    );
  }

  Widget _labelSliver(String text, Color color, Color onColor) {
    return SliverToBoxAdapter(
      child: Container(
        color: color,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Text(
          text,
          style: TextStyle(
            color: onColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          const SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Pinned AppBar + sticky lists'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Scroll up: each list keeps its current section header pinned '
                'right under the AppBar. Old builds disabled sticky here '
                'because the AppBar consumed paint extent.',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ),
          ),
          _labelSliver(
            'FlashSliverList #1',
            scheme.tertiaryContainer,
            scheme.onTertiaryContainer,
          ),
          FlashSliverList(
            controller: _listA,
            delegate: _stickyDelegate(_entriesA),
          ),
          _labelSliver(
            'A plain SliverToBoxAdapter between the two lists',
            scheme.surfaceContainerHighest,
            scheme.onSurface,
          ),
          _labelSliver(
            'FlashSliverList #2',
            scheme.tertiaryContainer,
            scheme.onTertiaryContainer,
          ),
          FlashSliverList(
            controller: _listB,
            delegate: _stickyDelegate(_entriesB),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
      bottomNavigationBar: _DualStickyStatus(
        listA: _listA,
        entriesA: _entriesA,
        listB: _listB,
        entriesB: _entriesB,
      ),
    );
  }
}

/// Footer showing both lists' currently pinned headers side by side.
class _DualStickyStatus extends StatelessWidget {
  const _DualStickyStatus({
    required this.listA,
    required this.entriesA,
    required this.listB,
    required this.entriesB,
  });

  final FlashSliverListController listA;
  final List<FlatEntry> entriesA;
  final FlashSliverListController listB;
  final List<FlatEntry> entriesB;

  String _labelFor(int? index, List<FlatEntry> entries) {
    if (index == null || index < 0 || index >= entries.length) return '—';
    return entries[index].label;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<int?>(
                  valueListenable: listA.stickyIndex,
                  builder: (context, index, _) =>
                      Text('#1 ▸ ${_labelFor(index, entriesA)}'),
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<int?>(
                  valueListenable: listB.stickyIndex,
                  builder: (context, index, _) =>
                      Text('#2 ▸ ${_labelFor(index, entriesB)}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
