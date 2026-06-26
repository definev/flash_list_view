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

  /// Main-axis paint position of the sticky element relative to this sliver's
  /// leading edge. Computed during [paint] (it depends on the next sticky
  /// element's position) and reused by `childMainAxisPosition` so hit-testing
  /// and paint transforms agree with where the header is actually drawn.
  ///
  /// When the list is composed inside a [CustomScrollView] beneath other
  /// pinned slivers, this includes `constraints.overlap` so the header pins to
  /// the viewport line rather than this sliver's leading edge.
  double stickyMainAxisDelta = 0;

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
