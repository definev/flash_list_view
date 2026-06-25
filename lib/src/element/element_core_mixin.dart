part of '../flash_list_view_element.dart';

/// Shared element state and child-count resolution used by all element mixins.
mixin FlashListViewElementCoreMixin on RenderObjectElement {
  bool markAsInvalid = true;
  int? indexShoudBeJumpTo;
  double indexShoudBeJumpOffset = 0.0;
  bool offsetBasedOnBottom = false;
  bool supressElementGenerate = false;

  @override
  FlashSliverList get widget => super.widget as FlashSliverList;

  ScrollableState? get parentScrollableState => Scrollable.of(this);

  Widget? buildChild(int index) {
    return widget.delegate.build(this, index);
  }

  @override
  Element? updateChild(Element? child, Widget? newWidget, Object? newSlot) {
    final SliverMultiBoxAdaptorParentData? oldParentData =
        child?.renderObject?.parentData as SliverMultiBoxAdaptorParentData?;
    Element? newChild;
    owner!.buildScope(this, () {
      newChild = super.updateChild(child, newWidget, newSlot);
    });
    final SliverMultiBoxAdaptorParentData? newParentData =
        newChild?.renderObject?.parentData as SliverMultiBoxAdaptorParentData?;

    if (oldParentData != newParentData &&
        oldParentData != null &&
        newParentData != null) {
      newParentData.layoutOffset = oldParentData.layoutOffset;
    }
    return newChild;
  }

  int? get estimatedChildCount => widget.delegate.estimatedChildCount;

  int get childCount {
    int? result = estimatedChildCount;
    if (result == null) {
      int lo = 0;
      int hi = 1;
      const int max = kIsWeb ? 9007199254740992 : ((1 << 63) - 1);
      while (buildChild(hi - 1) != null) {
        lo = hi - 1;
        if (hi < max ~/ 2) {
          hi *= 2;
        } else if (hi < max) {
          hi = max;
        } else {
          throw FlutterError(
            'Could not find the number of children in ${widget.delegate}.\n'
            "The childCount getter was called (implying that the delegate's builder returned null "
            'for a positive index), but even building the child with index $hi (the maximum '
            'possible integer) did not return null. Consider implementing childCount to avoid '
            'the cost of searching for the final child.',
          );
        }
      }
      while (hi - lo > 1) {
        final int mid = (hi - lo) ~/ 2 + lo;
        if (buildChild(mid - 1) == null) {
          hi = mid;
        } else {
          lo = mid;
        }
      }
      result = lo;
    }
    return result;
  }
}
