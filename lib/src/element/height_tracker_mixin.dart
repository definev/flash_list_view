part of '../flash_list_view_element.dart';

/// Fallback item height used when neither a measured height nor a delegate
/// estimate is available.
const double _kFallbackItemHeight = 50.0;

/// Tracks per-item heights and total scroll extent estimates.
mixin FlashListViewHeightTrackerMixin on FlashListViewDelegateConfigMixin {
  final Map<String, double> _itemHeights = {};
  double _totalItemHeight = 0;

  /// Cumulative-height index used for O(log n) scroll-offset queries instead of
  /// summing every preceding item on each lookup.
  final CumulativeHeightTree _heightTree = CumulativeHeightTree();
  int _heightTreeChildCount = -1;
  bool _heightTreeDirty = true;

  /// During [animateToIndex], heights are not saved to avoid scroll-back.
  bool isInScrolling = false;

  double get totalItemHeight => _totalItemHeight;

  double getItemHeight(String key, int index) {
    final measured = _itemHeights[key];
    if (measured != null) {
      return measured;
    }
    final delegate = _flashListViewDelegate;
    if (delegate != null) {
      final onItemHeight = delegate.onItemHeight;
      if (onItemHeight != null) {
        return onItemHeight(index);
      }
      return delegate.preferItemHeight;
    }
    return _kFallbackItemHeight;
  }

  void setItemHeight(String key, double height) {
    if (!isInScrolling) {
      _itemHeights[key] = height;
    }
  }

  String getKeyByItemIndex(int index) {
    final onItemKey = _flashListViewDelegate?.onItemKey;
    if (onItemKey != null) {
      return onItemKey(index);
    }
    return index.toString();
  }

  void calcTotalItemHeight() {
    _rebuildHeightTree();
    _totalItemHeight = _heightTree.total;
  }

  /// Rebuilds the cumulative-height tree from the current [getItemHeight]
  /// values. O(n), but only runs on invalidation or after a child-count change,
  /// never on a per-frame scroll path.
  void _rebuildHeightTree() {
    final count = childCount;
    _heightTree.rebuild(count, (i) => getItemHeight(getKeyByItemIndex(i), i));
    _heightTreeChildCount = count;
    _heightTreeDirty = false;
  }

  void _ensureHeightTree() {
    if (_heightTreeDirty || _heightTreeChildCount != childCount) {
      _rebuildHeightTree();
    }
  }

  double getScrollOffsetByIndex(int index) {
    if (index <= 0) {
      return 0;
    }
    _ensureHeightTree();
    return _heightTree.prefixSum(index);
  }

  double updateElementPosition2(
    FlashListViewRenderData spEle, {
    required double offset,
    required double height,
  }) {
    var oldHeight = spEle.height;
    var diff = height - oldHeight;
    _totalItemHeight += diff;
    spEle.offset = offset;
    spEle.height = height;
    if (spEle.element.renderObject!.parentData != null) {
      final parentData =
          spEle.element.renderObject!.parentData!
              as SliverMultiBoxAdaptorParentData;
      parentData.layoutOffset = spEle.offset;
    }
    final wasStored = !isInScrolling;
    setItemHeight(getKeyByItemIndex(spEle.index), height);
    // Keep the cumulative-height tree consistent with the freshly measured
    // height so offset queries stay accurate without forcing a full rebuild.
    // Skip when the height was not stored (during animated scrolling) or when
    // the tree is stale; a rebuild will pick up the change on the next query.
    if (wasStored &&
        !_heightTreeDirty &&
        _heightTreeChildCount == childCount &&
        spEle.index >= 0 &&
        spEle.index < _heightTreeChildCount) {
      _heightTree.update(spEle.index, height);
    }
    return diff;
  }
}
