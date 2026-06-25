part of '../flash_list_view_render.dart';

/// Shared render state and layout helpers used by all render mixins.
mixin FlashListViewRenderCoreMixin on RenderSliver {
  FlashListViewElement get childManager;

  FlashListViewRenderData? firstPainItemInViewport;
  double? firstPainItemOffsetY;

  FlashListViewRenderData? lastPainItemInViewport;
  double? lastPainItemOffsetY;
  double? lastPainItemHeight;

  double? currentScrollOffset;
  double? currentViewportHeight;

  List<FlashListViewRenderData> paintedElements = [];
  List<FlashListViewRenderData> paintedElementsInViewport = [];

  bool isAdjustOperation = false;
  double? scrollOffsetDifferFromLast;
  double? lastScrollOffset;

  Size layoutItem(
    FlashListViewRenderData? spElement,
    Constraints constraints, {
    bool parentUsesSize = false,
  }) {
    var child = spElement?.element.renderObject as RenderBox?;
    if (child != null && child.parent == this) {
      child.layout(constraints, parentUsesSize: parentUsesSize);
      return child.size;
    }
    return const Size(0, 0);
  }
}
