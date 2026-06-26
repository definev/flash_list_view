import 'package:flash_list_view/src/flash_list_view_render.dart';
import 'package:flutter/widgets.dart';

import 'flash_list_view_element.dart';
import 'flash_list_view_visible_range.dart';

class FlashSliverListController {
  final ValueNotifier<int?> stickyIndex = ValueNotifier<int?>(null);

  void Function(double height, List<FlashListViewItemPosition> positions)?
  onPaintItemPositionsCallback;

  /// When true, [FlashListViewDelegate.keepPosition] is ignored for layout.
  ///
  /// Set synchronously before a programmatic jump so keepPosition does not run
  /// in the same frame as the jump (avoids racing delegate rebuilds).
  bool suppressKeepPosition = false;

  FlashListViewElement? _listView;

  bool jumpToIndex(
    int index, {
    double offset = 0,
    bool offsetBasedOnBottom = false,
  }) {
    final listView = _listView;
    if (listView == null) {
      assert(() {
        debugPrint(
          'FlashSliverListController.jumpToIndex: not attached to a list',
        );
        return true;
      }());
      return false;
    }
    listView.jumpToIndex(index, offset, offsetBasedOnBottom);
    return true;
  }

  Future<bool> animateToIndex(
    int index, {
    required Duration duration,
    required Curve curve,
    double offset = 0,
    bool offsetBasedOnBottom = false,
  }) async {
    final listView = _listView;
    if (listView == null) {
      assert(() {
        debugPrint(
          'FlashSliverListController.animateToIndex: not attached to a list',
        );
        return true;
      }());
      return false;
    }
    await listView.animateToIndex(
      index,
      offset: offset,
      basedOnBottom: offsetBasedOnBottom,
      duration: duration,
      curve: curve,
    );
    return true;
  }

  bool ensureVisible(
    int index, {
    double offset = 0,
    bool? offsetBasedOnBottom,
  }) {
    final listView = _listView;
    if (listView == null) {
      assert(() {
        debugPrint(
          'FlashSliverListController.ensureVisible: not attached to a list',
        );
        return true;
      }());
      return false;
    }
    listView.ensureVisible(index, offset, offsetBasedOnBottom);
    return true;
  }

  bool pageDown() {
    final listView = _listView;
    if (listView == null) return false;
    listView.pageDown();
    return true;
  }

  bool pageUp() {
    final listView = _listView;
    if (listView == null) return false;
    listView.pageUp();
    return true;
  }

  void attach(FlashListViewElement listView) {
    _listView = listView;
  }

  void detach() {
    _listView = null;
  }

  void dispose() {
    stickyIndex.dispose();
  }

  FlashListViewVisibleRange? getVisibleRange() {
    return _listView?.getVisibleRange();
  }
}
