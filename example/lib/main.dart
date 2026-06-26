import 'package:flutter/material.dart';

import 'demos/chat_demo.dart';
import 'demos/index_navigation_demo.dart';
import 'demos/reverse_demo.dart';
import 'demos/sticky_custom_scroll_view_demo.dart';
import 'demos/sticky_standalone_demo.dart';
import 'demos/sticky_tailer_demo.dart';

/// Gallery of focused FlashListView / FlashSliverList examples, one per case.
void main() => runApp(const FlashListViewGalleryApp());

class FlashListViewGalleryApp extends StatelessWidget {
  const FlashListViewGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlashListView gallery',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const GalleryScreen(),
    );
  }
}

class _Demo {
  const _Demo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
}

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  static final List<_Demo> _demos = [
    _Demo(
      title: 'Sticky · standalone',
      subtitle: 'Section headers pinned in a full-screen FlashListView',
      icon: Icons.push_pin,
      builder: (_) => const StickyStandaloneDemo(),
    ),
    _Demo(
      title: 'Sticky · inside CustomScrollView',
      subtitle: 'Headers pin under a pinned SliverAppBar; two lists + slivers',
      icon: Icons.layers,
      builder: (_) => const StickyCustomScrollViewDemo(),
    ),
    _Demo(
      title: 'Sticky · pinned to bottom',
      subtitle: 'stickyAtTailer — active header pinned at the bottom edge',
      icon: Icons.vertical_align_bottom,
      builder: (_) => const StickyTailerDemo(),
    ),
    _Demo(
      title: 'Index navigation',
      subtitle: 'jump / animate / ensureVisible / paging / getVisibleRange',
      icon: Icons.my_location,
      builder: (_) => const IndexNavigationDemo(),
    ),
    _Demo(
      title: 'Reverse list',
      subtitle: 'reverse: true — index 0 at the bottom, grows upward',
      icon: Icons.swap_vert,
      builder: (_) => const ReverseDemo(),
    ),
    _Demo(
      title: 'Chat · keepPosition',
      subtitle: 'firstItemAlign.end + keepPosition + permanent typing row',
      icon: Icons.chat_bubble_outline,
      builder: (_) => const ChatDemo(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FlashListView examples')),
      body: ListView.separated(
        itemCount: _demos.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final demo = _demos[index];
          return ListTile(
            leading: CircleAvatar(child: Icon(demo.icon)),
            title: Text(demo.title),
            subtitle: Text(demo.subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: demo.builder)),
          );
        },
      ),
    );
  }
}
