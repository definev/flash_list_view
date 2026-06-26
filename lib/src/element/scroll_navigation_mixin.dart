part of '../flash_list_view_element.dart';

/// Programmatic scroll: jump, animate, paging, and visibility queries.
mixin FlashListViewScrollNavigationMixin on FlashListViewElementPoolMixin {
  void jumpToIndex(int index, double offset, bool basedOnBottom) {
    assert(
      index >= 0 && index < childCount,
      "Index should be >=0 and  < child count",
    );
    indexShoudBeJumpTo = index;
    indexShoudBeJumpOffset = offset;
    offsetBasedOnBottom = basedOnBottom;
    markAsInvalid = true;
    renderObject.markNeedsLayout();
  }

  Future<void> animateToIndex(
    int index, {
    required double offset,
    required bool basedOnBottom,
    required Duration duration,
    required Curve curve,
  }) async {
    assert(
      index >= 0 && index < childCount,
      "Index should be >=0 and  <= child count",
    );

    var scrollOffset = getScrollOffsetByIndex(index);
    var flashListViewRender = renderObject as FlashListViewRender;
    var viewportHeight = flashListViewRender.currentViewportHeight ?? 0;

    if (basedOnBottom) {
      var itemHeight = getItemHeight(getKeyByItemIndex(index), index);
      scrollOffset = scrollOffset - (viewportHeight - itemHeight - offset);
    } else {
      scrollOffset -= offset;
    }

    if (scrollOffset < 0) scrollOffset = 0;

    supressElementGenerate = false;
    if (widget.delegate is FlashListViewDelegate) {
      var flashListDelegate = widget.delegate as FlashListViewDelegate;
      supressElementGenerate = flashListDelegate.isSupressElementGenerate;
    }

    try {
      isInScrolling = true;
      var position = parentScrollableState?.position;
      await position?.animateTo(scrollOffset, duration: duration, curve: curve);
    } catch (e, s) {
      if (kDebugMode) {
        print("error in animateToIndex in flash list view element, $e, $s");
      }
    } finally {
      isInScrolling = false;
      supressElementGenerate = false;
    }

    jumpToIndex(index, offset, basedOnBottom);
  }

  FlashListViewVisibleRange? getVisibleRange() {
    int last = 0;
    int first = 0;
    bool b1 = false;
    double totalHeight = 0;
    var flashListViewRender = renderObject as FlashListViewRender;
    for (var item in flashListViewRender.paintedElements) {
      totalHeight += item.height;
      if (!b1) {
        first = last = item.index;
        b1 = true;
      } else {
        if (item.index < first) first = item.index;
        if (item.index > last) last = item.index;
      }
    }
    if (!b1) {
      return null;
    }
    return FlashListViewVisibleRange.create(
      firstIndex: first,
      lastIndex: last,
      totalVisibleHeight: totalHeight,
    );
  }

  void ensureVisible(int index, double offset, bool? basedOnBottom) {
    assert(
      index >= 0 && index < childCount,
      "Index should be >=0 and  < child count",
    );
    var sdata =
        getVisibleRange() ??
        FlashListViewVisibleRange.create(
          firstIndex: 0,
          lastIndex: 0,
          totalVisibleHeight: 0,
        );
    int first = sdata.firstIndex;
    int last = sdata.lastIndex;
    if (index <= first) {
      jumpToIndex(index, 0, basedOnBottom ?? false);
    } else if (index >= last) {
      jumpToIndex(index, 0, basedOnBottom ?? true);
    }
  }

  void pageDown() {
    var flashListViewRender = renderObject as FlashListViewRender;
    var viewportHeight = flashListViewRender.currentViewportHeight ?? 0;
    var sdata =
        getVisibleRange() ??
        FlashListViewVisibleRange.create(
          firstIndex: 0,
          lastIndex: 0,
          totalVisibleHeight: 0,
        );
    int last = sdata.lastIndex;
    double totalHeight = sdata.totalVisibleHeight;
    if (totalHeight <= viewportHeight) {
      if (last + 1 < childCount) {
        jumpToIndex(last + 1, 0, false);
        return;
      }
      if (childCount > 0) {
        jumpToIndex(childCount - 1, 0, true);
      }
      return;
    }
    jumpToIndex(last, 0, false);
  }

  void pageUp() {
    var flashListViewRender = renderObject as FlashListViewRender;
    var viewportHeight = flashListViewRender.currentViewportHeight ?? 0;
    var sdata =
        getVisibleRange() ??
        FlashListViewVisibleRange.create(
          firstIndex: 0,
          lastIndex: 0,
          totalVisibleHeight: 0,
        );
    int first = sdata.firstIndex;
    double totalHeight = sdata.totalVisibleHeight;
    if (totalHeight <= viewportHeight) {
      if (first <= 1) {
        jumpToIndex(0, 0, false);
        return;
      }
      jumpToIndex(first - 1, 0, true);
      return;
    }
    jumpToIndex(first, 0, true);
  }

  void notifyPositionChanged() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      try {
        var position = parentScrollableState?.position;
        if (position != null && !position.isScrollingNotifier.value) {
          position.didStartScroll();
          position.didEndScroll();
        }
      } catch (e, s) {
        if (kDebugMode) {
          print(
            "error in notifyPositionChanged in flash list view element, $e, $s",
          );
        }
      }
    });
  }

  void notifyStickyChanged(int? index) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.controller != null) {
        if (widget.controller!.stickyIndex.value != index) {
          widget.controller!.stickyIndex.value = index;
        }
      }
    });
  }

  void notifyPaintItemPositionsCallback(
    double height,
    List<FlashListViewItemPosition> paintElements,
  ) {
    try {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        var onPaintItemPositionsCallback =
            widget.controller?.onPaintItemPositionsCallback;
        if (onPaintItemPositionsCallback != null) {
          onPaintItemPositionsCallback(height, paintElements);
        }
      });
    } catch (e, s) {
      if (kDebugMode) {
        print("notifyPaintItemPositionsCallback error $e, $s");
      }
    }
  }
}
