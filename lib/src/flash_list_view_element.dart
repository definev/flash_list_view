import 'package:flash_list_view/flash_list_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'cumulative_height_tree.dart';
import 'flash_list_view_render.dart';
import 'flash_list_view_render_data.dart';

part 'element/element_core_mixin.dart';
part 'element/key_index_cache_mixin.dart';
part 'element/delegate_config_mixin.dart';
part 'element/height_tracker_mixin.dart';
part 'element/element_pool_mixin.dart';
part 'element/scroll_navigation_mixin.dart';

class FlashListViewElement extends RenderObjectElement
    with
        FlashListViewElementCoreMixin,
        FlashListViewDelegateConfigMixin,
        FlashListViewHeightTrackerMixin,
        FlashListViewKeyIndexCacheMixin,
        FlashListViewElementPoolMixin,
        FlashListViewScrollNavigationMixin {
  FlashListViewElement(FlashSliverList widget) : super(widget) {
    if (widget.controller != null) {
      widget.controller!.attach(this);
      if (stickyElement != null) {
        widget.controller!.stickyIndex.value = stickyElement!.index;
      }
    }

    handleInitIndex(widget.delegate, null);
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    rebuildKeyIndexCache();
  }

  @override
  void update(covariant FlashSliverList newWidget) {
    final FlashSliverList oldWidget = widget;
    super.update(newWidget);
    if (oldWidget.controller != newWidget.controller) {
      if (oldWidget.controller != null) {
        oldWidget.controller!.detach();
      }
      if (newWidget.controller != null) {
        newWidget.controller!.attach(this);
        if (stickyElement != null) {
          newWidget.controller!.stickyIndex.value = stickyElement!.index;
        }
      }
    }

    final SliverChildDelegate newDelegate = newWidget.delegate;
    final SliverChildDelegate oldDelegate = oldWidget.delegate;
    if (newDelegate != oldDelegate &&
        (newDelegate.runtimeType != oldDelegate.runtimeType ||
            newDelegate.shouldRebuild(oldDelegate))) {
      performRebuild();
    }
    handleInitIndex(newDelegate, oldDelegate);

    var needsInvalidation = false;
    if (newDelegate != oldDelegate) {
      if (newDelegate is FlashListViewDelegate &&
          oldDelegate is FlashListViewDelegate) {
        final childCountChanged =
            newDelegate.childCount != oldDelegate.childCount;
        needsInvalidation = delegateNeedsInvalidation(newDelegate, oldDelegate);
        if (childCountChanged) {
          rebuildKeyIndexCache();
        }
      } else {
        needsInvalidation = true;
        rebuildKeyIndexCache();
      }
    }
    if (needsInvalidation) {
      markAsInvalid = true;
    }
    renderObject.markNeedsLayout();
  }

  @override
  void insertRenderObjectChild(covariant RenderBox child, int slot) {
    // ignore: invalid_use_of_protected_member
    renderObject.adoptChild(child);
  }

  @override
  void moveRenderObjectChild(
    covariant RenderObject child,
    int oldSlot,
    int newSlot,
  ) {}

  @override
  void removeRenderObjectChild(covariant RenderObject child, int slot) {
    // ignore: invalid_use_of_protected_member
    renderObject.dropChild(child as RenderBox);
  }

  @override
  void unmount() {
    if (widget.controller != null) {
      widget.controller!.detach();
    }
    super.unmount();
  }
}
