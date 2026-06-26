import 'package:flash_list_view_example/demos/chat_demo.dart';
import 'package:flash_list_view_example/demos/index_navigation_demo.dart';
import 'package:flash_list_view_example/demos/reverse_demo.dart';
import 'package:flash_list_view_example/demos/sticky_custom_scroll_view_demo.dart';
import 'package:flash_list_view_example/demos/sticky_standalone_demo.dart';
import 'package:flash_list_view_example/demos/sticky_tailer_demo.dart';
import 'package:flash_list_view_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Each demo should mount, scroll, and tear down without throwing. This guards
/// the example against API drift in the library.
void main() {
  // Bounded pumps instead of pumpAndSettle: the chat demo's typing indicator
  // repeats forever, which would make pumpAndSettle time out.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  Future<void> pumpAndScroll(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(MaterialApp(home: screen));
    await settle(tester);

    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -400));
    await settle(tester);
    await tester.drag(scrollable, const Offset(0, 200));
    await settle(tester);

    expect(tester.takeException(), isNull);
  }

  testWidgets('gallery lists every demo', (tester) async {
    await tester.pumpWidget(const FlashListViewGalleryApp());
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsWidgets);
    expect(find.text('Sticky · inside CustomScrollView'), findsOneWidget);
  });

  testWidgets('sticky standalone', (tester) async {
    await pumpAndScroll(tester, const StickyStandaloneDemo());
  });

  testWidgets('sticky inside CustomScrollView', (tester) async {
    await pumpAndScroll(tester, const StickyCustomScrollViewDemo());
  });

  testWidgets('sticky tailer', (tester) async {
    await pumpAndScroll(tester, const StickyTailerDemo());
  });

  testWidgets('index navigation', (tester) async {
    await pumpAndScroll(tester, const IndexNavigationDemo());
  });

  testWidgets('reverse list', (tester) async {
    await pumpAndScroll(tester, const ReverseDemo());
  });

  testWidgets('chat', (tester) async {
    await pumpAndScroll(tester, const ChatDemo());
  });
}
