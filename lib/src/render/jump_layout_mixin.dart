part of '../flash_list_view_render.dart';

/// Programmatic jump-to-index during invalidation layout.
mixin FlashListViewRenderJumpMixin
    on FlashListViewRenderCoreMixin, FlashListViewRenderGeometryMixin {
  FlashListViewRenderData? jumpToElement;
  double jumpDistanceFromTop = 0;

  bool handleJump(
    int jumpIndex,
    double indexShoudBeJumpOffset,
    bool offsetBasedOnBottom,
    double viewportHeight,
    Constraints childConstraints,
  ) {
    if (jumpIndex >= 0 && jumpIndex < childManager.childCount) {
      var itemDy = childManager.getScrollOffsetByIndex(jumpIndex);

      invokeLayoutCallback((constraints) {
        jumpToElement = childManager.constructOneIndexElement(
          jumpIndex,
          itemDy,
          true,
        );
      });

      var size = layoutItem(
        jumpToElement,
        childConstraints,
        parentUsesSize: true,
      );
      var itemHeight = size.height;

      childManager.updateElementPosition(
        spEle: jumpToElement!,
        newHeight: itemHeight,
        needUpdateNextElementOffset: false,
      );

      var scrollDy = itemDy - indexShoudBeJumpOffset;
      jumpDistanceFromTop = indexShoudBeJumpOffset;
      if (offsetBasedOnBottom) {
        scrollDy =
            itemDy - (viewportHeight - (indexShoudBeJumpOffset + itemHeight));
        jumpDistanceFromTop =
            viewportHeight - (indexShoudBeJumpOffset + itemHeight);
      }

      if (scrollDy < 0) scrollDy = 0;

      if (constraints.scrollOffset != scrollDy) {
        isAdjustOperation = true;
        geometry = SliverGeometry(
          scrollExtent: getScrollExtent(),
          hasVisualOverflow: true,
          scrollOffsetCorrection: scrollDy - constraints.scrollOffset,
        );
        return true;
      }
    }

    return false;
  }

  /// Fine-tunes jump scroll offset after element layout compensates for height.
  double applyJumpCompensation(
    double scrollOffset,
    double compensationScroll,
    double viewportMainAxisExtent,
  ) {
    if (jumpToElement == null) return compensationScroll;

    var elementOffset = jumpToElement!.offset;
    var currentOffset = scrollOffset + compensationScroll;
    var targetOffsetFromTop = elementOffset - currentOffset;
    var distance = targetOffsetFromTop - jumpDistanceFromTop;
    if (distance != 0.0) {
      compensationScroll += distance;
    }
    if (scrollOffset + compensationScroll < 0) {
      compensationScroll = -scrollOffset;
    } else if (childManager.totalItemHeight -
            scrollOffset -
            compensationScroll <
        viewportMainAxisExtent) {
      compensationScroll =
          childManager.totalItemHeight - viewportMainAxisExtent - scrollOffset;
      if (scrollOffset + compensationScroll < 0) {
        compensationScroll = 0;
      }
    } else if (scrollOffset + compensationScroll >
        childManager.totalItemHeight) {
      compensationScroll = childManager.totalItemHeight - scrollOffset;
    }
    return compensationScroll;
  }
}
