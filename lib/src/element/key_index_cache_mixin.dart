part of '../flash_list_view_element.dart';

/// Stable key → index lookup used by keep-position and jump logic.
mixin FlashListViewKeyIndexCacheMixin on FlashListViewElementCoreMixin {
  final Map<String, int> _keyToIndex = {};
  int? _keyCacheChildCount;

  void rebuildKeyIndexCache() {
    if (_keyCacheChildCount == childCount) {
      return;
    }
    _keyToIndex.clear();
    _keyCacheChildCount = childCount;
    if (widget.delegate is! FlashListViewDelegate) {
      return;
    }
    final flashListDelegate = widget.delegate as FlashListViewDelegate;
    if (flashListDelegate.onItemKey == null) {
      return;
    }
    for (var i = 0; i < childCount; i++) {
      _keyToIndex[flashListDelegate.onItemKey!(i)] = i;
    }
  }

  int? findIndexByKey(String key) {
    if (_keyCacheChildCount != childCount) {
      rebuildKeyIndexCache();
    }
    final cached = _keyToIndex[key];
    if (cached != null) {
      return cached;
    }
    if (widget.delegate is FlashListViewDelegate) {
      final flashListDelegate = widget.delegate as FlashListViewDelegate;
      final callback = flashListDelegate.findChildIndexCallback;
      if (callback != null) {
        return callback(ValueKey<Object>(key));
      }
    }
    return null;
  }
}
