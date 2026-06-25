part of '../flash_list_view_element.dart';

/// Element pool: rendered, cached, and permanent child elements.
mixin FlashListViewElementPoolMixin on FlashListViewHeightTrackerMixin {
  final List<FlashListViewRenderData> _renderedElements = [];
  List<FlashListViewRenderData> get renderedElements => _renderedElements;

  final Map<String, FlashListViewRenderData> _permanentElements = {};
  Map<String, FlashListViewRenderData> get permanentElements =>
      _permanentElements;

  FlashListViewRenderData? stickyElement;

  final List<FlashListViewRenderData> _cachedElements = [];
  List<FlashListViewRenderData> get cachedElements => _cachedElements;

  /// Drops rendered elements outside the scroll-content band
  /// [[startOffset], [endOffset]] aligned with [SliverConstraints.cacheOrigin]
  /// and [SliverConstraints.remainingCacheExtent].
  void removeOutOfScopeElements(double startOffset, double endOffset) {
    if (startOffset < 0) {
      startOffset = 0;
    }

    while (_renderedElements.isNotEmpty) {
      var item = _renderedElements[0];
      if ((item.offset + item.height) < startOffset) {
        _renderedElements.removeAt(0);
        putRenderItemToCacheOrPermanent(item);
        if (item == stickyElement) {
          stickyElement = null;
        }
      } else {
        break;
      }
    }

    while (_renderedElements.isNotEmpty) {
      var length = _renderedElements.length;
      var item = _renderedElements[length - 1];
      if (item.offset > endOffset) {
        _renderedElements.removeAt(length - 1);
        putRenderItemToCacheOrPermanent(item);
        if (item == stickyElement) {
          stickyElement = null;
        }
      } else {
        break;
      }
    }
  }

  FlashListViewRenderData constructOneIndexElement(
    int index,
    double itemOffset,
    bool needInsertToRenderElement,
  ) {
    var result = createOrReuseElement(index);
    result.offset = itemOffset;
    if (needInsertToRenderElement) {
      _renderedElements.insert(0, result);
    }
    return result;
  }

  FlashListViewRenderData? constructPrevElement(double targetScrollOffset) {
    double startOffset = targetScrollOffset;
    if (startOffset < 0) {
      startOffset = 0;
    }
    FlashListViewRenderData? result;

    if (_renderedElements.isNotEmpty) {
      var firstElement = _renderedElements[0];
      if (firstElement.offset > startOffset && firstElement.index > 0) {
        var indexOfCreate = firstElement.index - 1;
        result = createOrReuseElement(indexOfCreate);
        result.offset = firstElement.offset - result.height;
        _renderedElements.insert(0, result);
      }
    }
    return result;
  }

  double updateElementPosition({
    required FlashListViewRenderData spEle,
    required double newHeight,
    required bool needUpdateNextElementOffset,
  }) {
    var diff = updateElementPosition2(
      spEle,
      offset: spEle.offset,
      height: newHeight,
    );

    if (needUpdateNextElementOffset) {
      for (var i = 1; i < _renderedElements.length; i++) {
        var item = _renderedElements[i];
        item.offset += diff;
        if (item.element.renderObject != null) {
          final itemParentData =
              item.element.renderObject!.parentData!
                  as SliverMultiBoxAdaptorParentData;
          itemParentData.layoutOffset = item.offset;
        }
      }
    }

    return diff;
  }

  FlashListViewRenderData createOrReuseElement(int index) {
    Element? newElement = fetchItemFromCacheOrPermanent(index);
    if (newElement != null) {
      newElement = updateChild(newElement, buildChild(index), index);
    } else {
      newElement = createChild2(index);
    }

    var itemKey = getKeyByItemIndex(index);
    var height = getItemHeight(itemKey, index);
    var isSticky = queryIsStickyItemByIndex(index);
    return FlashListViewRenderData(
      element: newElement!,
      index: index,
      offset: 0,
      height: height,
      itemKey: itemKey,
      isSticky: isSticky,
    );
  }

  Element? createChild2(int index) {
    return updateChild(null, buildChild(index), index);
  }

  FlashListViewRenderData? constructNextElement(
    double targetStartScrollOffset,
    double targetEndScrollOffset,
  ) {
    double endOffset = targetEndScrollOffset;
    FlashListViewRenderData? result;

    if (_renderedElements.isNotEmpty) {
      var lastElement = _renderedElements[_renderedElements.length - 1];
      if ((lastElement.offset + lastElement.height) <= endOffset &&
          lastElement.index < childCount - 1) {
        var indexOfCreate = lastElement.index + 1;
        result = createOrReuseElement(indexOfCreate);
        result.offset = lastElement.offset + lastElement.height;
        _renderedElements.add(result);
      }
    } else {
      var accuHeight = 0.0;
      for (var i = 0; i < childCount; i++) {
        double startOffset = targetStartScrollOffset;
        if (startOffset < 0) {
          startOffset = 0;
        }
        var itemHeight = getItemHeight(getKeyByItemIndex(i), i);
        if (accuHeight <= startOffset &&
            (accuHeight + itemHeight) >= startOffset) {
          result = createOrReuseElement(i);
          result.offset = accuHeight;
          _renderedElements.add(result);
          break;
        }
        accuHeight += itemHeight;
      }
    }

    return result;
  }

  void removeChildElement(Element child) {
    final Element? result = updateChild(child, null, null);
    assert(result == null);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    bool stickyElementHasVisited = false;
    for (var item in _renderedElements) {
      if (item.element.renderObject?.parent != null) {
        visitor(item.element);
        if (item == stickyElement) {
          stickyElementHasVisited = true;
        }
      }
    }

    if (stickyElement != null && !stickyElementHasVisited) {
      visitor(stickyElement!.element);
    }

    for (var item in cachedElements) {
      visitor(item.element);
    }

    for (var key in permanentElements.keys) {
      visitor(permanentElements[key]!.element);
    }
  }

  void removeAllChildren() {
    if (_renderedElements.isNotEmpty) {
      for (var item in _renderedElements) {
        removeChildElement(item.element);
        if (item == stickyElement) {
          stickyElement = null;
        }
      }
      _renderedElements.clear();
    }

    if (stickyElement != null) {
      removeChildElement(stickyElement!.element);
    }
    stickyElement = null;

    for (var item in cachedElements) {
      removeChildElement(item.element);
    }
    cachedElements.clear();

    for (var key in permanentElements.keys) {
      removeChildElement(permanentElements[key]!.element);
    }

    permanentElements.clear();
  }

  void removeAllChildrenToCachedElements() {
    for (var item in _renderedElements) {
      putRenderItemToCacheOrPermanent(item);
      if (item == stickyElement) {
        stickyElement = null;
      }
    }
    _renderedElements.clear();

    if (stickyElement != null) {
      putRenderItemToCacheOrPermanent(stickyElement!);
    }
    stickyElement = null;
  }

  void putRenderItemToCacheOrPermanent(FlashListViewRenderData item) {
    var key = item.itemKey;
    if (isPermanentItem(key)) {
      if (permanentElements.containsKey(key)) {
        assert(false, "Item key has duplicate when cache permanent item");
      }
      permanentElements[key] = item;
    } else {
      cachedElements.add(item);
    }
  }

  Element? fetchItemFromCacheOrPermanent(int index) {
    Element? newElement;
    var itemKey = getKeyByItemIndex(index);
    if (permanentElements.containsKey(itemKey)) {
      if (permanentElements[itemKey]!.element.renderObject != null) {
        newElement = permanentElements[itemKey]!.element;
      }
      permanentElements.remove(itemKey);
    } else if (!isPermanentItem(itemKey) && cachedElements.isNotEmpty) {
      var matchedIndex = -1;
      List<int> needRemovedIndex = [];

      for (var i = 0; i < cachedElements.length; i++) {
        var item = cachedElements[i];
        if (item.element.renderObject == null ||
            item.element.renderObject!.parent != renderObject) {
          needRemovedIndex.add(i);
          if (item.itemKey == itemKey) {
            break;
          }
        }
        if (item.itemKey == itemKey) {
          matchedIndex = i;
          break;
        }
      }

      for (var index in needRemovedIndex.reversed) {
        cachedElements.removeAt(index);
      }

      if (matchedIndex == -1 && cachedElements.length > 20) {
        if (firstItemAlign == FirstItemAlign.end) {
          matchedIndex = cachedElements.length - 1;
        } else {
          matchedIndex = 0;
        }
      }

      if (matchedIndex != -1) {
        newElement = cachedElements[matchedIndex].element;
        cachedElements.removeAt(matchedIndex);
      }
    }

    if (newElement != null &&
        (newElement.renderObject == null ||
            newElement.renderObject!.parent != renderObject)) {
      return null;
    }
    return newElement;
  }
}
