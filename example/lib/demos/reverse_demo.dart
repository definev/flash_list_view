import 'package:flash_list_view/flash_list_view.dart';
import 'package:flutter/material.dart';

import '_shared.dart';

/// Case 5 — Reverse list (`reverse: true`).
///
/// Index 0 sits at the visual bottom and the list grows upward, like an event
/// log or feed. New rows are prepended at index 0 and appear at the bottom.
class ReverseDemo extends StatefulWidget {
  const ReverseDemo({super.key});

  @override
  State<ReverseDemo> createState() => _ReverseDemoState();
}

class _ReverseDemoState extends State<ReverseDemo> {
  final _controller = FlashListViewController();
  final List<String> _events = List.generate(
    40,
    (i) => 'Event #${40 - i}',
  );
  int _next = 41;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addEvent() {
    setState(() => _events.insert(0, 'Event #${_next++}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reverse list')),
      body: FlashListView(
        controller: _controller,
        reverse: true,
        delegate: FlashListViewDelegate(
          (context, index) => ItemTile(
            label: _events[index],
            trailing: index == 0
                ? const Icon(Icons.fiber_new, size: 18)
                : null,
          ),
          childCount: _events.length,
          onItemKey: (index) => _events[index],
          onItemHeight: (_) => kItemHeight,
          preferItemHeight: kItemHeight,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEvent,
        icon: const Icon(Icons.add),
        label: const Text('Add event'),
      ),
    );
  }
}
