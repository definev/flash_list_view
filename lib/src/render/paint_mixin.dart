part of '../flash_list_view_render.dart';

final class FlashListViewGrowDirectionInfo {
  const FlashListViewGrowDirectionInfo({
    required this.mainAxisUnit,
    required this.crossAxisUnit,
    required this.originOffset,
    required this.addExtent,
    required this.axisDirection,
  });

  final Offset mainAxisUnit, crossAxisUnit, originOffset;
  final bool addExtent;
  final AxisDirection axisDirection;
}

final class FlashListViewItemPosition {
  const FlashListViewItemPosition({
    required this.index,
    required this.offset,
    required this.height,
  });

  final int index;
  final double offset;
  final double height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlashListViewItemPosition &&
          index == other.index &&
          offset == other.offset &&
          height == other.height;

  @override
  int get hashCode => index.hashCode ^ offset.hashCode ^ height.hashCode;
}

/// Paints visible list items and sticky overlays.
mixin FlashListViewRenderPaintMixin
    on FlashListViewRenderCoreMixin, FlashListViewRenderStickyMixin {
  bool intersectsPaintExtent(double mainAxisDelta, double childExtent) {
    return mainAxisDelta + childExtent > 0 &&
        mainAxisDelta < constraints.remainingPaintExtent;
  }

  bool intersectsCacheExtent(double mainAxisDelta, double childExtent) {
    return mainAxisDelta + childExtent > constraints.cacheOrigin &&
        mainAxisDelta < constraints.remainingCacheExtent;
  }

  FlashListViewGrowDirectionInfo getGrowDirectionInfo(Offset offset) {
    final Offset mainAxisUnit, crossAxisUnit, originOffset;
    final bool addExtent;
    final axisDirection = applyGrowthDirectionToAxisDirection(
      constraints.axisDirection,
      constraints.growthDirection,
    );
    switch (axisDirection) {
      case AxisDirection.up:
        mainAxisUnit = const Offset(0.0, -1.0);
        crossAxisUnit = const Offset(1.0, 0.0);
        originOffset = offset + Offset(0.0, geometry!.paintExtent);
        addExtent = true;
        break;
      case AxisDirection.right:
        mainAxisUnit = const Offset(1.0, 0.0);
        crossAxisUnit = const Offset(0.0, 1.0);
        originOffset = offset;
        addExtent = false;
        break;
      case AxisDirection.down:
        mainAxisUnit = const Offset(0.0, 1.0);
        crossAxisUnit = const Offset(1.0, 0.0);
        originOffset = offset;
        addExtent = false;
        break;
      case AxisDirection.left:
        mainAxisUnit = const Offset(-1.0, 0.0);
        crossAxisUnit = const Offset(0.0, 1.0);
        originOffset = offset + Offset(geometry!.paintExtent, 0.0);
        addExtent = true;
        break;
    }

    return FlashListViewGrowDirectionInfo(
      addExtent: addExtent,
      mainAxisUnit: mainAxisUnit,
      crossAxisUnit: crossAxisUnit,
      originOffset: originOffset,
      axisDirection: axisDirection,
    );
  }

  void paintItem(PaintingContext context, RenderObject child, Offset offset) {
    if (child.parent != this) {
      return;
    }
    if (child is RenderBox) {
      if (child.hasSize) {
        context.paintChild(child, offset);
      }
    } else {
      context.paintChild(child, offset);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    paintedElements.clear();
    paintedElementsInViewport.clear();

    var renderedElements = childManager.renderedElements;
    if (renderedElements.isEmpty) return;

    var growInfo = getGrowDirectionInfo(offset);
    firstPainItemInViewport = null;
    lastPainItemInViewport = null;
    Offset? nextStickyOffset;
    var paintElements = <FlashListViewItemPosition>[];
    var showAllElements = false;
    if (renderedElements.isNotEmpty &&
        renderedElements.last.offset + renderedElements.last.height <
            constraints.viewportMainAxisExtent) {
      showAllElements = true;
    }
    for (var renderElement in renderedElements) {
      RenderBox child = renderElement.element.renderObject as RenderBox;
      if (child.parent == this) {
        final double mainAxisDelta = childMainAxisPosition(child);
        final double crossAxisDelta = childCrossAxisPosition(child);

        var normalMainAxisUnit = const Offset(0.0, 1.0);
        var normalCrossAxisUnit = const Offset(1.0, 0.0);
        var normalChildOffset = Offset(
          offset.dx +
              normalMainAxisUnit.dx * mainAxisDelta +
              normalCrossAxisUnit.dx * crossAxisDelta,
          offset.dy +
              normalMainAxisUnit.dy * mainAxisDelta +
              normalCrossAxisUnit.dy * crossAxisDelta,
        );

        Offset childOffset = Offset(
          growInfo.originOffset.dx +
              growInfo.mainAxisUnit.dx * mainAxisDelta +
              growInfo.crossAxisUnit.dx * crossAxisDelta,
          growInfo.originOffset.dy +
              growInfo.mainAxisUnit.dy * mainAxisDelta +
              growInfo.crossAxisUnit.dy * crossAxisDelta,
        );
        if (growInfo.addExtent) {
          childOffset += growInfo.mainAxisUnit * child.size.height;
        }

        final childExtent = child.size.height;
        final inViewport =
            showAllElements ||
            intersectsPaintExtent(mainAxisDelta, childExtent);
        final inCache =
            showAllElements ||
            intersectsCacheExtent(mainAxisDelta, childExtent);

        if (inCache) {
          if (inViewport) {
            if (firstPainItemInViewport == null) {
              firstPainItemInViewport = renderElement;
              firstPainItemOffsetY = renderElement.offset;
            }

            if (lastPainItemInViewport == null) {
              paintedElementsInViewport.add(renderElement);
            }

            if (mainAxisDelta < constraints.remainingPaintExtent &&
                mainAxisDelta + childExtent >=
                    constraints.remainingPaintExtent) {
              if (lastPainItemInViewport == null) {
                lastPainItemInViewport = renderElement;
                lastPainItemOffsetY = renderElement.offset;
                lastPainItemHeight = childExtent;
              }
            }
          }

          renderElement.prevRenderHeight = childExtent;

          paintElements.add(
            FlashListViewItemPosition(
              index: renderElement.index,
              offset: childOffset.dy,
              height: childExtent,
            ),
          );
          if (renderElement != childManager.stickyElement) {
            paintItem(context, child, childOffset);
            if (inViewport) {
              paintedElements.add(renderElement);
            }
            if (renderElement == trackedNextStickyElement) {
              nextStickyOffset = normalChildOffset;
            }
          }
        }
      }
    }

    if (childManager.stickyAtTailer) {
      paintTailerSticky(context, offset, nextStickyOffset, growInfo);
    } else {
      paintHeaderSticky(context, offset, nextStickyOffset, growInfo);
    }

    childManager.notifyPaintItemPositionsCallback(
      constraints.viewportMainAxisExtent,
      paintElements,
    );

    currentScrollOffset = constraints.scrollOffset;
    currentViewportHeight = constraints.viewportMainAxisExtent;
  }

  void paintHeaderSticky(
    PaintingContext context,
    Offset offset,
    Offset? nextStickyOffset,
    FlashListViewGrowDirectionInfo growInfo,
  ) {
    if (childManager.stickyElement != null) {
      var stickyRenderObj =
          childManager.stickyElement!.element.renderObject as RenderBox?;
      if (stickyRenderObj != null && stickyRenderObj.parent == this) {
        if (nextStickyOffset == null ||
            nextStickyOffset.dy > stickyRenderObj.size.height) {
          var stickyOffsetDy = offset.dy;

          if (growInfo.axisDirection == AxisDirection.up) {
            stickyOffsetDy =
                offset.dy +
                constraints.viewportMainAxisExtent -
                stickyRenderObj.size.height;
          }
          var childOffset = Offset(offset.dx, stickyOffsetDy);
          paintItem(context, stickyRenderObj, childOffset);
        } else {
          var stickyOffsetDy =
              nextStickyOffset.dy - stickyRenderObj.size.height;
          if (growInfo.axisDirection == AxisDirection.up) {
            stickyOffsetDy =
                constraints.viewportMainAxisExtent -
                stickyRenderObj.size.height -
                stickyOffsetDy;
          }
          var childOffset = Offset(0, stickyOffsetDy);
          paintItem(context, stickyRenderObj, childOffset);
        }
      }
      paintedElements.add(childManager.stickyElement!);
    }
  }

  void paintTailerSticky(
    PaintingContext context,
    Offset offset,
    Offset? nextStickyOffset,
    FlashListViewGrowDirectionInfo growInfo,
  ) {
    if (childManager.stickyElement != null) {
      var stickyRenderObj =
          childManager.stickyElement!.element.renderObject as RenderBox?;
      if (stickyRenderObj != null && stickyRenderObj.parent == this) {
        if (nextStickyOffset == null ||
            nextStickyOffset.dy + trackedNextStickyElement!.height <
                constraints.viewportMainAxisExtent -
                    stickyRenderObj.size.height) {
          var stickyOffsetDy =
              offset.dy +
              constraints.viewportMainAxisExtent -
              stickyRenderObj.size.height;

          if (growInfo.axisDirection == AxisDirection.up) {
            stickyOffsetDy = offset.dy;
          }
          var childOffset = Offset(offset.dx, stickyOffsetDy);
          paintItem(context, stickyRenderObj, childOffset);
        } else {
          var stickyOffsetDy =
              trackedNextStickyElement!.height + nextStickyOffset.dy;
          if (growInfo.axisDirection == AxisDirection.up) {
            stickyOffsetDy =
                constraints.viewportMainAxisExtent -
                nextStickyOffset.dy -
                trackedNextStickyElement!.height -
                stickyRenderObj.size.height;
          }
          var childOffset = Offset(0, stickyOffsetDy);
          paintItem(context, stickyRenderObj, childOffset);
        }
      }
      paintedElements.add(childManager.stickyElement!);
    }
  }
}
