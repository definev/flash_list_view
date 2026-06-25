import 'package:flutter/material.dart';
import 'package:flash_list_view/flash_list_view.dart';
import 'package:flash_list_view/src/cumulative_height_tree.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CumulativeHeightTree', () {
    double naivePrefix(List<double> heights, int index) {
      var sum = 0.0;
      for (var i = 0; i < index && i < heights.length; i++) {
        sum += heights[i];
      }
      return sum;
    }

    test('prefix sums match a naive summation', () {
      final heights = <double>[10, 20, 5, 40, 15, 30];
      final tree = CumulativeHeightTree()
        ..rebuild(heights.length, (i) => heights[i]);

      for (var i = 0; i <= heights.length; i++) {
        expect(tree.prefixSum(i), naivePrefix(heights, i));
      }
      expect(tree.total, naivePrefix(heights, heights.length));
    });

    test('prefixSum clamps out-of-range indices', () {
      final heights = <double>[10, 20, 30];
      final tree = CumulativeHeightTree()
        ..rebuild(heights.length, (i) => heights[i]);

      expect(tree.prefixSum(-5), 0.0);
      expect(tree.prefixSum(0), 0.0);
      expect(tree.prefixSum(100), 60.0);
    });

    test('point update adjusts subsequent prefix sums', () {
      final heights = <double>[10, 20, 30, 40];
      final tree = CumulativeHeightTree()
        ..rebuild(heights.length, (i) => heights[i]);

      tree.update(1, 25); // 20 -> 25
      heights[1] = 25;

      for (var i = 0; i <= heights.length; i++) {
        expect(tree.prefixSum(i), naivePrefix(heights, i));
      }
      expect(tree.total, 105.0);
    });

    test('update ignores out-of-range indices and no-op deltas', () {
      final tree = CumulativeHeightTree()..rebuild(3, (_) => 10);
      tree.update(-1, 999);
      tree.update(3, 999);
      tree.update(0, 10); // same value, no change
      expect(tree.total, 30.0);
    });

    test('rebuild on a new count replaces previous contents', () {
      final tree = CumulativeHeightTree()..rebuild(3, (_) => 10);
      expect(tree.total, 30.0);
      expect(tree.length, 3);

      tree.rebuild(5, (_) => 4);
      expect(tree.total, 20.0);
      expect(tree.length, 5);
      expect(tree.prefixSum(2), 8.0);
    });

    test('empty tree reports zero', () {
      final tree = CumulativeHeightTree()..rebuild(0, (_) => 10);
      expect(tree.total, 0.0);
      expect(tree.length, 0);
      expect(tree.prefixSum(5), 0.0);
    });
  });

  group('FlashListViewDelegate.shouldRebuild', () {
    test('returns false when only builder identity is unchanged', () {
      Widget builder(BuildContext context, int index) => Text('$index');
      final delegate = FlashListViewDelegate(
        builder,
        childCount: 3,
        keepPosition: true,
      );
      expect(delegate.shouldRebuild(delegate), isFalse);
    });

    test('returns true when childCount changes', () {
      Widget builder(BuildContext context, int index) => Text('$index');
      final oldDelegate = FlashListViewDelegate(builder, childCount: 3);
      final newDelegate = FlashListViewDelegate(builder, childCount: 4);
      expect(newDelegate.shouldRebuild(oldDelegate), isTrue);
    });

    test('returns true when keepPosition changes', () {
      Widget builder(BuildContext context, int index) => Text('$index');
      final oldDelegate = FlashListViewDelegate(
        builder,
        childCount: 3,
        keepPosition: true,
      );
      final newDelegate = FlashListViewDelegate(
        builder,
        childCount: 3,
        keepPosition: false,
      );
      expect(newDelegate.shouldRebuild(oldDelegate), isTrue);
    });

    test('copyWith preserves unchanged fields', () {
      Widget builder(BuildContext context, int index) => Text('$index');
      final delegate = FlashListViewDelegate(
        builder,
        childCount: 3,
        keepPosition: true,
        preferItemHeight: 72,
      );
      final updated = delegate.copyWith(childCount: 4);
      expect(updated.childCount, 4);
      expect(updated.keepPosition, isTrue);
      expect(updated.preferItemHeight, 72);
      expect(updated.builder, same(builder));
    });
  });

  group('FlashSliverListController', () {
    test('suppressKeepPosition defaults to false', () {
      final controller = FlashSliverListController();
      expect(controller.suppressKeepPosition, isFalse);
      controller.dispose();
    });

    test('jumpToIndex returns false when not attached', () {
      final controller = FlashSliverListController();
      expect(controller.jumpToIndex(0), isFalse);
      controller.dispose();
    });
  });

  group('keepPosition_prepend', () {
    testWidgets('anchor index stays stable after prepend in reverse list', (
      tester,
    ) async {
      final controller = FlashListViewController();
      var data = List.generate(20, (i) => 'item-$i');

      Future<void> pumpList() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlashListView(
                reverse: true,
                controller: controller,
                delegate: FlashListViewDelegate(
                  (context, index) => SizedBox(
                    key: ValueKey(data[index]),
                    height: 50,
                    child: Text(data[index]),
                  ),
                  childCount: data.length,
                  onItemKey: (index) => data[index],
                  keepPosition: true,
                  keepPositionOffset: 0,
                  firstItemAlign: FirstItemAlign.end,
                  preferItemHeight: 50,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await pumpList();
      controller.jumpTo(400);
      await tester.pumpAndSettle();

      final rangeBefore = controller.sliverController.getVisibleRange();
      expect(rangeBefore, isNotNull);
      final anchorIndexBefore = rangeBefore!.firstIndex;
      final anchorKey = data[anchorIndexBefore];

      double? anchorPaintOffsetBefore;
      controller.sliverController.onPaintItemPositionsCallback =
          (widgetHeight, positions) {
            for (final position in positions) {
              if (position.index == anchorIndexBefore) {
                anchorPaintOffsetBefore = position.offset;
                break;
              }
            }
          };
      await tester.pumpAndSettle();

      data = ['prepended', ...data];
      await pumpList();

      final anchorIndexAfter = data.indexOf(anchorKey);
      expect(anchorIndexAfter, greaterThan(anchorIndexBefore));

      double? anchorPaintOffsetAfter;
      controller.sliverController.onPaintItemPositionsCallback =
          (widgetHeight, positions) {
            for (final position in positions) {
              if (position.index == anchorIndexAfter) {
                anchorPaintOffsetAfter = position.offset;
                break;
              }
            }
          };
      await tester.pumpAndSettle();

      final rangeAfter = controller.sliverController.getVisibleRange();
      expect(rangeAfter, isNotNull);
      expect(data[rangeAfter!.firstIndex], anchorKey);
      if (anchorPaintOffsetBefore != null && anchorPaintOffsetAfter != null) {
        expect(
          (anchorPaintOffsetAfter! - anchorPaintOffsetBefore!).abs(),
          lessThanOrEqualTo(4.0),
        );
      }
    });
  });

  group('jumpToIndex_with_padding', () {
    testWidgets('padding uses single SliverPadding wrapper', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              delegate: FlashListViewDelegate(
                (context, index) =>
                    const SizedBox(height: 40, child: Text('row')),
                childCount: 5,
                preferItemHeight: 40,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SliverPadding), findsOneWidget);
      final listView = tester.widget<FlashListView>(
        find.byType(FlashListView),
      );
      expect(
        listView.padding,
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      );
    });
  });

  group('onItemHeight_accuracy', () {
    testWidgets('jump uses onItemHeight estimates before layout', (
      tester,
    ) async {
      final controller = FlashListViewController();
      const itemHeight = 80.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: FlashListView(
                controller: controller,
                delegate: FlashListViewDelegate(
                  (context, index) =>
                      SizedBox(height: itemHeight, child: Text('item $index')),
                  childCount: 20,
                  onItemHeight: (_) => itemHeight,
                  preferItemHeight: itemHeight,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(controller.sliverController.jumpToIndex(10), isTrue);
      await tester.pumpAndSettle();

      final range = controller.sliverController.getVisibleRange();
      expect(range, isNotNull);
      expect(range!.firstIndex, lessThanOrEqualTo(10));
      expect(range.lastIndex, greaterThanOrEqualTo(10));
    });
  });

  group('cacheExtent', () {
    testWidgets('paints items in the cache band beyond the viewport', (
      tester,
    ) async {
      final controller = FlashListViewController();
      const itemHeight = 50.0;
      const childCount = 50;
      const cacheExtent = 200.0;
      const viewportHeight = 300.0;

      var paintedIndices = <int>{};

      controller.sliverController.onPaintItemPositionsCallback =
          (widgetHeight, positions) {
            paintedIndices.addAll(positions.map((p) => p.index));
          };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: viewportHeight,
              child: FlashListView(
                controller: controller,
                cacheExtent: cacheExtent,
                clipBehavior: Clip.none,
                delegate: FlashListViewDelegate(
                  (context, index) =>
                      SizedBox(height: itemHeight, child: Text('item $index')),
                  childCount: childCount,
                  onItemHeight: (_) => itemHeight,
                  preferItemHeight: itemHeight,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final visibleCount = (viewportHeight / itemHeight).ceil();
      final cacheCount = (cacheExtent / itemHeight).ceil();
      final expectedMinPainted = visibleCount + cacheCount;

      expect(
        paintedIndices.length,
        greaterThanOrEqualTo(expectedMinPainted),
        reason:
            'Cache-band items should be painted when cacheExtent is set '
            '(got ${paintedIndices.length}, expected ≥ $expectedMinPainted)',
      );
      expect(
        paintedIndices.reduce((a, b) => a > b ? a : b),
        greaterThanOrEqualTo(visibleCount - 1),
      );
    });

    testWidgets('getVisibleRange stays viewport-only with cacheExtent', (
      tester,
    ) async {
      final controller = FlashListViewController();
      const itemHeight = 50.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: FlashListView(
                controller: controller,
                cacheExtent: 400,
                delegate: FlashListViewDelegate(
                  (context, index) =>
                      SizedBox(height: itemHeight, child: Text('item $index')),
                  childCount: 50,
                  onItemHeight: (_) => itemHeight,
                  preferItemHeight: itemHeight,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final range = controller.sliverController.getVisibleRange();
      expect(range, isNotNull);
      final visibleItemCount = range!.lastIndex - range.firstIndex + 1;
      expect(visibleItemCount, lessThanOrEqualTo(8));
    });
  });

  group('edge_cases', () {
    testWidgets('empty list renders without exception', (tester) async {
      final controller = FlashListViewController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashListView(
              controller: controller,
              delegate: FlashListViewDelegate(
                (context, index) => const SizedBox(height: 40),
                childCount: 0,
                preferItemHeight: 40,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(FlashListView), findsOneWidget);
      expect(controller.sliverController.getVisibleRange(), isNull);
    });

    testWidgets('jump to last index in a large list lands in range', (
      tester,
    ) async {
      final controller = FlashListViewController();
      const itemHeight = 50.0;
      const childCount = 5000;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: FlashListView(
                controller: controller,
                delegate: FlashListViewDelegate(
                  (context, index) =>
                      SizedBox(height: itemHeight, child: Text('item $index')),
                  childCount: childCount,
                  onItemHeight: (_) => itemHeight,
                  preferItemHeight: itemHeight,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(controller.sliverController.jumpToIndex(childCount - 1), isTrue);
      await tester.pumpAndSettle();

      final range = controller.sliverController.getVisibleRange();
      expect(range, isNotNull);
      expect(range!.lastIndex, childCount - 1);
    });

    testWidgets('scroll extent equals the sum of item heights', (tester) async {
      final controller = FlashListViewController();
      const itemHeight = 50.0;
      const childCount = 30;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 400,
              child: FlashListView(
                controller: controller,
                delegate: FlashListViewDelegate(
                  (context, index) =>
                      SizedBox(height: itemHeight, child: Text('item $index')),
                  childCount: childCount,
                  onItemHeight: (_) => itemHeight,
                  preferItemHeight: itemHeight,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      const expectedExtent = itemHeight * childCount;
      expect(
        controller.position.maxScrollExtent,
        moreOrLessEquals(expectedExtent - 400, epsilon: 0.5),
      );
    });
  });
}
