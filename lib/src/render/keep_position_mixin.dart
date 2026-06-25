part of '../flash_list_view_render.dart';

/// Anchor-based scroll correction when items are inserted before the viewport.
mixin FlashListViewRenderKeepPositionMixin
    on FlashListViewRenderCoreMixin, FlashListViewRenderGeometryMixin {
  int? findIndexByKeyAndOldIndex(String key, int oldIndex) {
    final cached = childManager.findIndexByKey(key);
    if (cached != null) {
      return cached;
    }

    var childCount = childManager.childCount;
    int startIndex = oldIndex - 5;
    if (startIndex < 0) startIndex = 0;
    int endIndex = oldIndex + 5;
    if (endIndex >= childCount) endIndex = childCount - 1;

    for (var i = startIndex; i <= endIndex; i++) {
      if (i >= 0 && i < childCount) {
        if (childManager.getKeyByItemIndex(i) == key) {
          return i;
        }
      }
    }
    for (var i = startIndex - 1; i >= 0; i--) {
      if (i >= 0 && i < childCount) {
        if (childManager.getKeyByItemIndex(i) == key) {
          return i;
        }
      }
    }

    for (var i = endIndex + 1; i < childCount; i++) {
      if (i >= 0 && i < childCount) {
        if (childManager.getKeyByItemIndex(i) == key) {
          return i;
        }
      }
    }

    return null;
  }

  bool handleKeepPositionInLayout(
    double viewportHeight,
    Constraints childConstraints,
  ) {
    if (childManager.keepPosition &&
        childManager.keepPositionOffset <= constraints.scrollOffset &&
        firstPainItemInViewport != null &&
        constraints.cacheOrigin <= 0 &&
        childManager.totalItemHeight > viewportHeight) {
      var matchedIndex = findIndexByKeyAndOldIndex(
        firstPainItemInViewport!.itemKey,
        firstPainItemInViewport!.index,
      );

      if (matchedIndex != null) {
        var itemDy = childManager.getScrollOffsetByIndex(matchedIndex);
        if (itemDy != firstPainItemOffsetY) {
          var correctOffsetDy =
              constraints.scrollOffset + (itemDy - (firstPainItemOffsetY ?? 0));

          if (constraints.scrollOffset != correctOffsetDy) {
            late FlashListViewRenderData chatElem;
            invokeLayoutCallback((constraints) {
              chatElem = childManager.constructOneIndexElement(
                matchedIndex,
                itemDy,
                true,
              );
            });

            var size = layoutItem(
              chatElem,
              childConstraints,
              parentUsesSize: true,
            );
            var itemHeight = size.height;

            childManager.updateElementPosition(
              spEle: chatElem,
              newHeight: itemHeight,
              needUpdateNextElementOffset: false,
            );
            isAdjustOperation = true;

            var extentResults = calcPaintExtentAndCacheExtent();
            final double paintExtent = extentResults[0];
            final double cacheExtent = extentResults[1];

            geometry = SliverGeometry(
              scrollExtent: getScrollExtent(),
              paintExtent: getPaintExtent(paintExtent),
              cacheExtent: getCacheExtent(cacheExtent),
              maxPaintExtent: getPaintExtent(paintExtent),
              hasVisualOverflow: false,
              scrollOffsetCorrection:
                  correctOffsetDy - constraints.scrollOffset,
            );
            return true;
          }
        }
      }
    }

    return false;
  }
}
