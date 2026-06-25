part of '../flash_list_view_element.dart';

/// Reads [FlashListViewDelegate] configuration and handles init-index jumps.
mixin FlashListViewDelegateConfigMixin on FlashListViewElementCoreMixin {
  /// The current delegate typed as [FlashListViewDelegate], or null when the
  /// attached delegate is a plain [SliverChildDelegate].
  ///
  /// Centralizes the repeated `widget.delegate is FlashListViewDelegate`
  /// check used throughout the element mixins.
  FlashListViewDelegate? get _flashListViewDelegate {
    final delegate = widget.delegate;
    return delegate is FlashListViewDelegate ? delegate : null;
  }

  bool delegateNeedsInvalidation(
    FlashListViewDelegate newDelegate,
    FlashListViewDelegate oldDelegate,
  ) {
    return newDelegate.childCount != oldDelegate.childCount ||
        newDelegate.initIndex != oldDelegate.initIndex ||
        newDelegate.forceToExecuteInitIndex !=
            oldDelegate.forceToExecuteInitIndex ||
        newDelegate.keepPosition != oldDelegate.keepPosition ||
        newDelegate.keepPositionOffset != oldDelegate.keepPositionOffset ||
        newDelegate.firstItemAlign != oldDelegate.firstItemAlign ||
        newDelegate.onItemKey != oldDelegate.onItemKey ||
        newDelegate.onItemHeight != oldDelegate.onItemHeight ||
        newDelegate.preferItemHeight != oldDelegate.preferItemHeight ||
        newDelegate.disableCacheItems != oldDelegate.disableCacheItems;
  }

  void handleInitIndex(
    SliverChildDelegate newDelegate,
    SliverChildDelegate? oldDelegate,
  ) {
    int oldInitIndex = 0;
    int newInitIndex = 0;
    int oldChildCount = 0;
    int newChildCount = 0;
    int? oldForceToExecuteInitIndex;
    int? newForceToExecuteInitIndex;

    double newInitOffset = 0.0;
    bool newInitOffsetBasedOnBottom = false;

    if (oldDelegate != null && oldDelegate is FlashListViewDelegate) {
      oldInitIndex = oldDelegate.initIndex;
      oldChildCount = oldDelegate.childCount ?? 99999999;
      oldForceToExecuteInitIndex = oldDelegate.forceToExecuteInitIndex;
    }
    if (newDelegate is FlashListViewDelegate) {
      newInitIndex = newDelegate.initIndex;
      newChildCount = newDelegate.childCount ?? 99999999;
      newInitOffset = newDelegate.initOffset;
      newInitOffsetBasedOnBottom = newDelegate.initOffsetBasedOnBottom;
      newForceToExecuteInitIndex = newDelegate.forceToExecuteInitIndex;
    }

    bool needJump = false;
    if (newChildCount > 0) {
      if (oldInitIndex != newInitIndex && newInitIndex > 0) {
        needJump = true;
      } else if (newInitIndex > 0 && oldChildCount == 0) {
        needJump = true;
      }
    }

    if (oldForceToExecuteInitIndex != newForceToExecuteInitIndex) {
      needJump = true;
    }

    if (needJump) {
      indexShoudBeJumpTo = newInitIndex;
      indexShoudBeJumpOffset = newInitOffset;
      offsetBasedOnBottom = newInitOffsetBasedOnBottom;
      markAsInvalid = true;
    }
  }

  FirstItemAlign get firstItemAlign =>
      _flashListViewDelegate?.firstItemAlign ?? FirstItemAlign.start;

  bool get keepPosition {
    if (widget.controller?.suppressKeepPosition ?? false) {
      return false;
    }
    return _flashListViewDelegate?.keepPosition ?? false;
  }

  double get keepPositionOffset => _flashListViewDelegate?.keepPositionOffset ?? 0;

  bool get expandDirectToDownWhenFirstItemAlignToEnd =>
      _flashListViewDelegate?.expandDirectToDownWhenFirstItemAlignToEnd ?? false;

  bool queryIsStickyItemByIndex(int index) {
    final onItemSticky = _flashListViewDelegate?.onItemSticky;
    return onItemSticky != null ? onItemSticky(index) : false;
  }

  bool get stickyAtTailer => _flashListViewDelegate?.stickyAtTailer ?? false;

  bool get isSupportSticky => _flashListViewDelegate?.onItemSticky != null;

  bool get disableCacheItems => _flashListViewDelegate?.disableCacheItems ?? false;

  bool isPermanentItem(String key) {
    final onIsPermanent = _flashListViewDelegate?.onIsPermanent;
    return onIsPermanent != null ? onIsPermanent(key) : false;
  }
}
