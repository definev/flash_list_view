import 'package:flash_list_view/flash_list_view.dart';
import 'package:flutter/material.dart';

import '_shared.dart';

/// Case 4 — Programmatic navigation over a large list.
///
/// Exercises the controller API: `jumpToIndex`, `animateToIndex`,
/// `ensureVisible`, `pageUp` / `pageDown`, and `getVisibleRange`. Variable row
/// heights show that jumps land accurately using `onItemHeight` estimates.
class IndexNavigationDemo extends StatefulWidget {
  const IndexNavigationDemo({super.key});

  @override
  State<IndexNavigationDemo> createState() => _IndexNavigationDemoState();
}

class _IndexNavigationDemoState extends State<IndexNavigationDemo> {
  static const _itemCount = 1000;

  final _controller = FlashListViewController();

  FlashListViewVisibleRange? _range;

  // Deterministic "random" heights so jumps must rely on onItemHeight.
  double _heightFor(int index) => 48 + (index % 5) * 16;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _refreshRange() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final range = _controller.sliverController.getVisibleRange();
      if (range != null) setState(() => _range = range);
    });
  }

  @override
  Widget build(BuildContext context) {
    final nav = _controller.sliverController;
    return Scaffold(
      appBar: AppBar(title: const Text('Index navigation')),
      body: Column(
        children: [
          _ControlBar(
            children: [
              FilledButton.tonal(
                onPressed: () => nav.jumpToIndex(500),
                child: const Text('Jump → 500'),
              ),
              FilledButton.tonal(
                onPressed: () => nav.animateToIndex(
                  0,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                ),
                child: const Text('Animate → 0'),
              ),
              FilledButton.tonal(
                onPressed: () => nav.animateToIndex(
                  _itemCount - 1,
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  offsetBasedOnBottom: true,
                ),
                child: const Text('Animate → last'),
              ),
              FilledButton.tonal(
                onPressed: () => nav.ensureVisible(250),
                child: const Text('ensureVisible(250)'),
              ),
              OutlinedButton(
                onPressed: nav.pageUp,
                child: const Text('Page up'),
              ),
              OutlinedButton(
                onPressed: nav.pageDown,
                child: const Text('Page down'),
              ),
            ],
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (_) {
                _refreshRange();
                return false;
              },
              child: FlashListView(
                controller: _controller,
                delegate: FlashListViewDelegate(
                  (context, index) => ItemTile(
                    label: 'Row $index',
                    trailing: Text(
                      '${_heightFor(index).toInt()}px',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  childCount: _itemCount,
                  onItemKey: (index) => 'row-$index',
                  onItemHeight: _heightFor,
                  preferItemHeight: 64,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Material(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              _range == null
                  ? 'getVisibleRange(): scroll to populate'
                  : 'getVisibleRange(): ${_range!.firstIndex} … '
                        '${_range!.lastIndex}  '
                        '(${_range!.totalVisibleHeight.toInt()}px visible)',
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrollable wrap of control buttons.
class _ControlBar extends StatelessWidget {
  const _ControlBar({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(spacing: 8, runSpacing: 8, children: children),
    );
  }
}
