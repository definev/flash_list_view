part of '../flash_list_view_render.dart';

/// Sticky header/tailer element selection during layout.
mixin FlashListViewRenderStickyMixin on FlashListViewRenderCoreMixin {
  FlashListViewRenderData? trackedNextStickyElement;

  void determineHeaderStickyElement(BoxConstraints childConstraints) {
    final double scrollOffset = constraints.scrollOffset;
    final double cacheOrigin = constraints.cacheOrigin;
    final double viewportHeight = constraints.viewportMainAxisExtent;
    trackedNextStickyElement = null;

    if (cacheOrigin <= 0 &&
        constraints.remainingPaintExtent >= viewportHeight &&
        childManager.totalItemHeight > viewportHeight) {
      FlashListViewRenderData? firstElementInViewport;
      bool oldStickyInRenderedElements = false;

      for (var item in childManager.renderedElements) {
        if (firstElementInViewport == null && item.offset > scrollOffset) {
          firstElementInViewport = item;
        }
        if (item == childManager.stickyElement) {
          oldStickyInRenderedElements = true;
        }

        if (firstElementInViewport != null &&
            trackedNextStickyElement == null) {
          if (childManager.queryIsStickyItemByIndex(item.index)) {
            trackedNextStickyElement = item;
          }
        }
      }

      int? prevStickyIndex;
      if (firstElementInViewport != null) {
        for (var i = firstElementInViewport.index - 1; i >= 0; i--) {
          if (childManager.queryIsStickyItemByIndex(i)) {
            prevStickyIndex = i;
            break;
          }
        }
      }

      removeOldStickyElement(
        childConstraints,
        prevStickyIndex,
        oldStickyInRenderedElements,
      );
    }

    if (childManager.stickyElement != null) {
      childManager.notifyStickyChanged(childManager.stickyElement!.index);
    } else {
      childManager.notifyStickyChanged(null);
    }
  }

  void determineTailerStickyElement(BoxConstraints childConstraints) {
    final double scrollOffset = constraints.scrollOffset;
    final double cacheOrigin = constraints.cacheOrigin;
    final double viewportHeight = constraints.viewportMainAxisExtent;
    trackedNextStickyElement = null;

    if (cacheOrigin <= 0 &&
        constraints.remainingPaintExtent >= viewportHeight &&
        childManager.totalItemHeight > viewportHeight) {
      FlashListViewRenderData? firstOrLastElementInViewport;
      bool oldStickyInRenderedElements = false;

      for (var i = childManager.renderedElements.length - 1; i >= 0; i--) {
        var item = childManager.renderedElements[i];

        if (firstOrLastElementInViewport == null &&
            item.offset + item.height < scrollOffset + viewportHeight) {
          firstOrLastElementInViewport = item;
        }
        if (item == childManager.stickyElement) {
          oldStickyInRenderedElements = true;
        }

        if (firstOrLastElementInViewport != null &&
            trackedNextStickyElement == null) {
          if (childManager.queryIsStickyItemByIndex(item.index)) {
            trackedNextStickyElement = item;
          }
        }
      }

      int? prevStickyIndex;
      if (firstOrLastElementInViewport != null) {
        for (
          var i = firstOrLastElementInViewport.index + 1;
          i < childManager.childCount;
          i++
        ) {
          if (childManager.queryIsStickyItemByIndex(i)) {
            prevStickyIndex = i;
            break;
          }
        }
      }

      removeOldStickyElement(
        childConstraints,
        prevStickyIndex,
        oldStickyInRenderedElements,
      );
    }

    if (childManager.stickyElement != null) {
      childManager.notifyStickyChanged(childManager.stickyElement!.index);
    } else {
      childManager.notifyStickyChanged(null);
    }
  }

  void removeOldStickyElement(
    BoxConstraints childConstraints,
    int? prevStickyIndex,
    bool oldStickyInRenderedElements,
  ) {
    FlashListViewRenderData? prevStickyElement;
    FlashListViewRenderData? removedSticky;
    if (prevStickyIndex != null) {
      for (var item in childManager.renderedElements) {
        if (item.index == prevStickyIndex) {
          prevStickyElement = item;
          break;
        }
      }
      if (prevStickyElement == null) {
        removedSticky = childManager.stickyElement;
        invokeLayoutCallback((constraints) {
          prevStickyElement = childManager.constructOneIndexElement(
            prevStickyIndex,
            0,
            false,
          );
        });

        var size = layoutItem(
          prevStickyElement,
          childConstraints,
          parentUsesSize: true,
        );
        var itemHeight = size.height;

        childManager.updateElementPosition(
          spEle: prevStickyElement!,
          newHeight: itemHeight,
          needUpdateNextElementOffset: false,
        );
      } else {
        if (childManager.stickyElement != prevStickyElement) {
          removedSticky = childManager.stickyElement;
        }
      }

      childManager.stickyElement = prevStickyElement!;
    } else {
      removedSticky = childManager.stickyElement;
      childManager.stickyElement = null;
    }

    if (removedSticky != null && !oldStickyInRenderedElements) {
      invokeLayoutCallback((constraints) {
        childManager.removeChildElement(removedSticky!.element);
      });
    }
  }
}
