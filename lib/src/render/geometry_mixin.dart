part of '../flash_list_view_render.dart';

/// Scroll extent, paint extent, and viewport size-change detection.
mixin FlashListViewRenderGeometryMixin
    on FlashListViewRenderCoreMixin, RenderSliverHelpers {
  List<double> calcPaintExtentAndCacheExtent() {
    double firstRenderChildOffset = 0;
    double endRenderChildOffset = 0;
    var elements = childManager.renderedElements;
    if (elements.isNotEmpty) {
      firstRenderChildOffset = elements.first.offset;
      var lastElement = elements.last;
      endRenderChildOffset = lastElement.offset + lastElement.height;
    }

    double paintExtent = constraints.viewportMainAxisExtent;

    paintExtent = calculatePaintOffset(
      constraints,
      from: firstRenderChildOffset,
      to: endRenderChildOffset,
    );

    final double cacheExtent = calculateCacheOffset(
      constraints,
      from: firstRenderChildOffset,
      to: endRenderChildOffset,
    );

    return [
      paintExtent,
      cacheExtent,
      firstRenderChildOffset,
      endRenderChildOffset,
    ];
  }

  double getScrollExtent() {
    var totalItemHeight = childManager.totalItemHeight;
    if (childManager.firstItemAlign == FirstItemAlign.end) {
      if (totalItemHeight < constraints.viewportMainAxisExtent) {
        return constraints.viewportMainAxisExtent;
      }
    }
    return totalItemHeight;
  }

  double getPaintExtent(double origPaintExtent) {
    if (childManager.firstItemAlign == FirstItemAlign.end) {
      var totalItemHeight = childManager.totalItemHeight;
      if (totalItemHeight < constraints.viewportMainAxisExtent) {
        return calculatePaintOffset(
          constraints,
          from: 0,
          to: constraints.viewportMainAxisExtent,
        );
      }
    }
    return origPaintExtent;
  }

  double getCacheExtent(double originCacheExtent) {
    if (childManager.firstItemAlign == FirstItemAlign.end) {
      var totalItemHeight = childManager.totalItemHeight;
      if (totalItemHeight < constraints.viewportMainAxisExtent) {
        return calculateCacheOffset(
          constraints,
          from: 0,
          to: constraints.viewportMainAxisExtent,
        );
      }
    }
    return originCacheExtent;
  }
}
