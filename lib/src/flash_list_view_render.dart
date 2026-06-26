import 'flash_list_view_delegate.dart';
import 'package:flutter/rendering.dart';
import 'flash_list_view_element.dart';
import 'flash_list_view_render_data.dart';

part 'render/render_core_mixin.dart';
part 'render/geometry_mixin.dart';
part 'render/jump_layout_mixin.dart';
part 'render/keep_position_mixin.dart';
part 'render/sticky_layout_mixin.dart';
part 'render/paint_mixin.dart';

class FlashListViewRender extends RenderSliver
    with
        RenderSliverWithKeepAliveMixin,
        RenderSliverHelpers,
        FlashListViewRenderCoreMixin,
        FlashListViewRenderGeometryMixin,
        FlashListViewRenderJumpMixin,
        FlashListViewRenderKeepPositionMixin,
        FlashListViewRenderStickyMixin,
        FlashListViewRenderPaintMixin {
  FlashListViewRender({required this.childManager});

  @override
  final FlashListViewElement childManager;

  @override
  void setupParentData(RenderObject child) {
    if (child.parentData is! SliverMultiBoxAdaptorParentData) {
      child.parentData = SliverMultiBoxAdaptorParentData();
    }
  }

  @override
  void performLayout() {
    if (childManager.supressElementGenerate) {
      return;
    }

    final SliverConstraints constraints = this.constraints;
    if (lastScrollOffset != null) {
      scrollOffsetDifferFromLast = constraints.scrollOffset - lastScrollOffset!;
    }
    lastScrollOffset = constraints.scrollOffset;

    final targetStartScrollOffset =
        constraints.scrollOffset + constraints.cacheOrigin;
    final targetEndScrollOffset =
        targetStartScrollOffset + constraints.remainingCacheExtent;

    final viewportMainAxisExtent = constraints.viewportMainAxisExtent;

    final childConstraints = constraints.asBoxConstraints();

    if (childManager.markAsInvalid) {
      childManager.markAsInvalid = false;
      childManager.calcTotalItemHeight();
      childManager.removeAllChildrenToCachedElements();

      final jumpIndex = childManager.indexShoudBeJumpTo;
      final jumpOffset = childManager.indexShoudBeJumpOffset;
      final offsetBasedOnBottom = childManager.offsetBasedOnBottom;
      childManager.indexShoudBeJumpTo = null;
      childManager.indexShoudBeJumpOffset = 0.0;
      childManager.offsetBasedOnBottom = false;

      if (jumpIndex != null && jumpIndex < childManager.childCount) {
        if (handleJump(
          jumpIndex,
          jumpOffset,
          offsetBasedOnBottom,
          viewportMainAxisExtent,
          childConstraints,
        )) {
          return;
        }
      } else {
        if (handleKeepPositionInLayout(
          viewportMainAxisExtent,
          childConstraints,
        )) {
          return;
        }
      }
    }

    if (!isAdjustOperation) {
      childManager.removeOutOfScopeElements(
        targetStartScrollOffset,
        targetEndScrollOffset,
      );
    }

    double compensationScroll = 0;

    if (childManager.renderedElements.isNotEmpty) {
      double accumulateOffset = childManager.renderedElements[0].offset;
      for (var renderedElement in childManager.renderedElements) {
        var size = layoutItem(
          renderedElement,
          childConstraints,
          parentUsesSize: true,
        );
        var itemHeight = size.height;

        childManager.updateElementPosition2(
          renderedElement,
          offset: accumulateOffset,
          height: itemHeight,
        );

        accumulateOffset += itemHeight;
      }
    }

    while (true) {
      FlashListViewRenderData? spElement;
      invokeLayoutCallback((constraints) {
        spElement = childManager.constructPrevElement(targetStartScrollOffset);
      });
      if (spElement == null) break;
      var size = layoutItem(spElement, childConstraints, parentUsesSize: true);
      var itemHeight = size.height;
      var singleCompensationScroll = childManager.updateElementPosition(
        spEle: spElement!,
        newHeight: itemHeight,
        needUpdateNextElementOffset: true,
      );
      compensationScroll += singleCompensationScroll;
    }

    while (true) {
      FlashListViewRenderData? spElement;
      invokeLayoutCallback((constraints) {
        spElement = childManager.constructNextElement(
          targetStartScrollOffset,
          targetEndScrollOffset,
        );
      });

      if (spElement == null) break;
      var size = layoutItem(spElement, childConstraints, parentUsesSize: true);
      var itemHeight = size.height;
      childManager.updateElementPosition(
        spEle: spElement!,
        newHeight: itemHeight,
        needUpdateNextElementOffset: false,
      );
    }

    if (isAdjustOperation) {
      var maxRemainArea = childManager.totalItemHeight - viewportMainAxisExtent;
      if (childManager.totalItemHeight <= viewportMainAxisExtent &&
          constraints.scrollOffset > 0) {
        geometry = SliverGeometry(
          scrollExtent: getScrollExtent(),
          hasVisualOverflow: true,
          scrollOffsetCorrection: -constraints.scrollOffset,
        );
        return;
      } else if (maxRemainArea > 0 &&
          maxRemainArea < (constraints.scrollOffset + compensationScroll)) {
        geometry = SliverGeometry(
          scrollExtent: getScrollExtent(),
          hasVisualOverflow: true,
          scrollOffsetCorrection: maxRemainArea - constraints.scrollOffset,
        );
        return;
      }
    }

    if (childManager.isSupportSticky) {
      if (childManager.stickyAtTailer) {
        determineTailerStickyElement(childConstraints);
      } else {
        determineHeaderStickyElement(childConstraints);
      }
    }

    if (childManager.disableCacheItems) {
      if (childManager.cachedElements.isNotEmpty) {
        invokeLayoutCallback((constraints) {
          for (var item in childManager.cachedElements) {
            childManager.removeChildElement(item.element);
          }
        });
        childManager.cachedElements.clear();
      }
    } else if (childManager.cachedElements.isNotEmpty) {
      invokeLayoutCallback((constraints) {
        for (var item in childManager.cachedElements) {
          layoutItem(item, childConstraints, parentUsesSize: true);
        }
      });
    }

    for (var key in childManager.permanentElements.keys) {
      layoutItem(
        childManager.permanentElements[key],
        childConstraints,
        parentUsesSize: true,
      );
    }

    double differIncreaseHeight = 0;
    if (childManager.firstItemAlign == FirstItemAlign.end &&
        childManager.expandDirectToDownWhenFirstItemAlignToEnd &&
        scrollOffsetDifferFromLast != null &&
        scrollOffsetDifferFromLast!.abs() < 0.5) {
      differIncreaseHeight = detectRenderItemsSizeChange();
    }
    if (differIncreaseHeight > 0.5) {
      geometry = SliverGeometry(
        scrollExtent: getScrollExtent(),
        hasVisualOverflow: false,
        scrollOffsetCorrection: differIncreaseHeight,
      );
      return;
    }

    var extentResults = calcPaintExtentAndCacheExtent();
    final double paintExtent = extentResults[0];
    final double cacheExtent = extentResults[1];
    final double endRenderChildOffset = extentResults[3];

    compensationScroll = applyJumpCompensation(
      constraints.scrollOffset,
      compensationScroll,
      viewportMainAxisExtent,
    );

    final double targetEndScrollOffsetForPaint =
        constraints.scrollOffset + constraints.remainingPaintExtent;

    geometry = SliverGeometry(
      scrollExtent: getScrollExtent(),
      paintExtent: getPaintExtent(paintExtent),
      cacheExtent: getCacheExtent(cacheExtent),
      maxPaintExtent: getPaintExtent(paintExtent),
      hasVisualOverflow:
          endRenderChildOffset > targetEndScrollOffsetForPaint ||
          constraints.scrollOffset > 0.0,
      scrollOffsetCorrection:
          (compensationScroll < 0.01 && compensationScroll >= -0.01)
          ? null
          : compensationScroll,
    );

    if (isAdjustOperation) {
      childManager.notifyPositionChanged();
    }
    jumpToElement = null;
    isAdjustOperation = false;
  }

  double detectRenderItemsSizeChange() {
    var renderedElements = childManager.renderedElements;
    if (renderedElements.isEmpty) return 0;

    var showAllElements = false;
    if (renderedElements.isNotEmpty &&
        renderedElements.last.offset + renderedElements.last.height <
            constraints.viewportMainAxisExtent) {
      showAllElements = true;
    }

    int index = 0;
    double differIncreaseHeight = 0.0;
    for (var renderElement in renderedElements) {
      final child = renderElement.element.renderObject as RenderBox;
      if (child.parent == this) {
        final mainAxisDelta = childMainAxisPosition(child);

        if ((mainAxisDelta < constraints.remainingPaintExtent &&
                mainAxisDelta + child.size.height > 0) ||
            showAllElements) {
          if (paintedElements.length > index) {
            final oldPaintedElement = paintedElements[index];
            final newPaintedElement = renderElement;
            if ((oldPaintedElement.itemKey == newPaintedElement.itemKey) &&
                oldPaintedElement.prevRenderHeight != null &&
                newPaintedElement != childManager.stickyElement) {
              differIncreaseHeight +=
                  child.size.height - oldPaintedElement.prevRenderHeight!;
              newPaintedElement.prevRenderHeight = child.size.height;
              if (newPaintedElement.itemKey ==
                  lastPainItemInViewport?.itemKey) {
                return differIncreaseHeight;
              }
              index++;
            } else {
              return 0;
            }
          } else {
            return 0;
          }
        }
      }
    }

    return differIncreaseHeight;
  }

  @override
  double childMainAxisPosition(RenderBox child) {
    if (childManager.stickyElement != null &&
        childManager.stickyElement!.element.renderObject == child) {
      return stickyMainAxisDelta;
    }
    if (childManager.firstItemAlign == FirstItemAlign.end) {
      var actualScrollExtent = childManager.totalItemHeight;
      final axisDirection = applyGrowthDirectionToAxisDirection(
        constraints.axisDirection,
        constraints.growthDirection,
      );

      if (actualScrollExtent < constraints.viewportMainAxisExtent) {
        if (axisDirection == AxisDirection.down) {
          var delta = childScrollOffset(child)! - constraints.scrollOffset;
          delta =
              delta + constraints.viewportMainAxisExtent - actualScrollExtent;
          return delta;
        } else {
          var delta = childScrollOffset(child)! - constraints.scrollOffset;
          delta =
              delta + constraints.viewportMainAxisExtent - actualScrollExtent;
          return delta;
        }
      }
    }

    return childScrollOffset(child)! - constraints.scrollOffset;
  }

  @override
  double? childScrollOffset(RenderObject child) {
    assert(child.parent == this);
    final SliverMultiBoxAdaptorParentData childParentData =
        child.parentData! as SliverMultiBoxAdaptorParentData;
    return childParentData.layoutOffset;
  }

  void loopAllRenderObjects(void Function(RenderObject obj) handler) {
    var renderedElements = childManager.renderedElements;
    var stickyElement = childManager.stickyElement;
    var permanentElements = childManager.permanentElements;
    var stickyIsInRenderedElements = false;
    for (var element in renderedElements) {
      if (element.element.renderObject != null &&
          element.element.renderObject?.parent == this) {
        handler(element.element.renderObject!);
        if (element == stickyElement) {
          stickyIsInRenderedElements = true;
        }
      }
    }
    if (!stickyIsInRenderedElements && stickyElement != null) {
      if (stickyElement.element.renderObject != null &&
          stickyElement.element.renderObject?.parent == this) {
        handler(stickyElement.element.renderObject!);
      }
    }

    for (var element in childManager.cachedElements) {
      var eleRenderObj = element.element.renderObject;
      if (eleRenderObj != null && eleRenderObj.parent == this) {
        handler(eleRenderObj);
      }
    }

    for (var key in permanentElements.keys) {
      if (permanentElements[key]!.element.renderObject != null &&
          permanentElements[key]!.element.renderObject?.parent == this) {
        handler(permanentElements[key]!.element.renderObject!);
      }
    }
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    loopAllRenderObjects(visitor);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    loopAllRenderObjects((obj) {
      obj.attach(owner);
    });
  }

  @override
  void detach() {
    super.detach();
    loopAllRenderObjects((obj) {
      obj.detach();
    });
  }

  @override
  void applyPaintTransform(covariant RenderBox child, Matrix4 transform) {
    if (child.hasSize && child.parent == this) {
      applyPaintTransformForBoxChild(child, transform);
    }
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    final BoxHitTestResult boxResult = BoxHitTestResult.wrap(result);
    if (childManager.stickyElement != null) {
      var child =
          childManager.stickyElement!.element.renderObject as RenderBox?;
      if (child != null) {
        if (hitTestBoxChild(
          boxResult,
          child,
          mainAxisPosition: mainAxisPosition,
          crossAxisPosition: crossAxisPosition,
        )) {
          return true;
        }
      }
    }
    for (var i = childManager.renderedElements.length - 1; i >= 0; i--) {
      var item = childManager.renderedElements[i];
      if (childManager.stickyElement != item) {
        var child = item.element.renderObject as RenderBox?;
        if (child != null) {
          if (hitTestBoxChild(
            boxResult,
            child,
            mainAxisPosition: mainAxisPosition,
            crossAxisPosition: crossAxisPosition,
          )) {
            return true;
          }
        }
      }
    }

    return false;
  }

  @override
  bool hitTestBoxChild(
    BoxHitTestResult result,
    RenderBox child, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    final bool rightWayUp = getRightWayUp(constraints);
    double delta = childMainAxisPosition(child);
    final double crossAxisDelta = childCrossAxisPosition(child);
    double absolutePosition = mainAxisPosition - delta;
    final double absoluteCrossAxisPosition = crossAxisPosition - crossAxisDelta;
    Offset paintOffset;
    Offset transformedPosition;
    switch (constraints.axis) {
      case Axis.horizontal:
        if (!rightWayUp) {
          absolutePosition = child.size.width - absolutePosition;
          delta = geometry!.paintExtent - child.size.width - delta;
        }
        paintOffset = Offset(delta, crossAxisDelta);
        transformedPosition = Offset(
          absolutePosition,
          absoluteCrossAxisPosition,
        );
        break;
      case Axis.vertical:
        if (!rightWayUp) {
          absolutePosition = child.size.height - absolutePosition;
          delta = geometry!.paintExtent - child.size.height - delta;
        }
        paintOffset = Offset(crossAxisDelta, delta);
        transformedPosition = Offset(
          absoluteCrossAxisPosition,
          absolutePosition,
        );
        break;
    }
    return result.addWithOutOfBandPosition(
      paintOffset: paintOffset,
      hitTest: (BoxHitTestResult result) {
        return child.hitTest(result, position: transformedPosition);
      },
    );
  }

  bool getRightWayUp(SliverConstraints constraints) {
    bool rightWayUp;
    switch (constraints.axisDirection) {
      case AxisDirection.up:
      case AxisDirection.left:
        rightWayUp = false;
        break;
      case AxisDirection.down:
      case AxisDirection.right:
        rightWayUp = true;
        break;
    }
    switch (constraints.growthDirection) {
      case GrowthDirection.forward:
        break;
      case GrowthDirection.reverse:
        rightWayUp = !rightWayUp;
        break;
    }
    return rightWayUp;
  }

  @override
  void applyPaintTransformForBoxChild(RenderBox child, Matrix4 transform) {
    if (!child.hasSize) {
      return;
    }
    final bool rightWayUp = getRightWayUp(constraints);
    double delta = childMainAxisPosition(child);
    final double crossAxisDelta = childCrossAxisPosition(child);
    switch (constraints.axis) {
      case Axis.horizontal:
        if (!rightWayUp) {
          delta = geometry!.paintExtent - child.size.width - delta;
        }
        transform.translateByDouble(delta, crossAxisDelta, 0, 1);
        break;
      case Axis.vertical:
        if (!rightWayUp) {
          delta = geometry!.paintExtent - child.size.height - delta;
        }
        transform.translateByDouble(crossAxisDelta, delta, 0, 1);
        break;
    }
  }
}
