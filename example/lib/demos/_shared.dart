import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

/// Fixed row metrics shared across the sticky demos so [onItemHeight] estimates
/// stay accurate before a row is laid out.
const double kHeaderHeight = 44;
const double kItemHeight = 60;

/// A single row in a flat, sectioned list. Section headers and normal items
/// live in the same flat index space — exactly how [onItemSticky] expects them:
/// every header index returns `true`.
class FlatEntry {
  const FlatEntry({
    required this.key,
    required this.label,
    required this.isHeader,
  });

  final String key;
  final String label;
  final bool isHeader;
}

/// Builds `sections` headers, each followed by `itemsPerSection` items, in a
/// single flat list. Keys are stable so `onItemKey` / keepPosition work.
List<FlatEntry> buildSectionedEntries({
  int sections = 8,
  int itemsPerSection = 8,
}) {
  final entries = <FlatEntry>[];
  for (var s = 0; s < sections; s++) {
    final letter = String.fromCharCode(65 + (s % 26));
    entries.add(
      FlatEntry(key: 'header-$s', label: 'Section $letter', isHeader: true),
    );
    for (var i = 0; i < itemsPerSection; i++) {
      entries.add(
        FlatEntry(
          key: 'item-$s-$i',
          label: '$letter · Item ${i + 1}',
          isHeader: false,
        ),
      );
    }
  }
  return entries;
}

/// Pinned/section header row.
class SectionHeaderTile extends StatelessWidget {
  const SectionHeaderTile({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: kHeaderHeight,
      color: scheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

/// Normal list row.
class ItemTile extends StatelessWidget {
  const ItemTile({super.key, required this.label, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: kItemHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: scheme.secondaryContainer,
            child: Text(
              label.characters.first,
              style: TextStyle(
                fontSize: 13,
                color: scheme.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Live readout of the currently pinned section, driven by
/// `FlashSliverListController.stickyIndex`. Render it as an [AppBar.bottom] or a
/// footer to watch the active header change while scrolling.
class StickyBanner extends StatelessWidget implements PreferredSizeWidget {
  const StickyBanner({
    super.key,
    required this.stickyIndex,
    required this.entries,
    this.title = 'Pinned section',
  });

  final ValueListenable<int?> stickyIndex;
  final List<FlatEntry> entries;
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(34);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: stickyIndex,
      builder: (context, index, _) {
        final label = (index != null && index >= 0 && index < entries.length)
            ? entries[index].label
            : '—';
        return Container(
          height: 34,
          width: double.infinity,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              const Icon(Icons.push_pin, size: 14),
              const SizedBox(width: 8),
              Text('$title: $label'),
            ],
          ),
        );
      },
    );
  }
}
