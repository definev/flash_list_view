import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../flash_list_view.dart';
import 'dart:math' as math;

class FlashListView extends CustomScrollView {
  final SliverChildDelegate delegate;
  final FlashListViewController? _controller;
  final EdgeInsetsGeometry? padding;

  const FlashListView({
    Key? key,
    required this.delegate,
    FlashListViewController? controller,
    bool reverse = false,
    Axis scrollDirection = Axis.vertical,
    bool? primary,
    ScrollPhysics? physics,
    ScrollBehavior? scrollBehavior,
    bool shrinkWrap = false,
    this.padding,
    Key? center,
    double anchor = 0.0,
    double? cacheExtent,
    int? semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    String? restorationId,
    Clip clipBehavior = Clip.hardEdge,
  }) : _controller = controller,
       super(
         key: key,
         controller: controller,
         reverse: reverse,
         scrollDirection: scrollDirection,
         primary: primary,
         physics: physics,
         scrollBehavior: scrollBehavior,
         shrinkWrap: shrinkWrap,
         center: center,
         anchor: anchor,
         cacheExtent: cacheExtent,
         semanticChildCount: semanticChildCount,
         dragStartBehavior: dragStartBehavior,
         keyboardDismissBehavior: keyboardDismissBehavior,
         restorationId: restorationId,
         clipBehavior: clipBehavior,
       );

  FlashListView.builder({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    FlashListViewController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    this.padding,
    required IndexedWidgetBuilder itemBuilder,
    int? itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double? cacheExtent,
    int? semanticChildCount,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    String? restorationId,
    Clip clipBehavior = Clip.hardEdge,
  }) : _controller = controller,
       delegate = SliverChildBuilderDelegate(
         itemBuilder,
         childCount: itemCount,
         addAutomaticKeepAlives: addAutomaticKeepAlives,
         addRepaintBoundaries: addRepaintBoundaries,
         addSemanticIndexes: addSemanticIndexes,
       ),
       super(
         key: key,
         scrollDirection: scrollDirection,
         reverse: reverse,
         controller: controller,
         primary: primary,
         physics: physics,
         shrinkWrap: shrinkWrap,
         cacheExtent: cacheExtent,
         semanticChildCount: semanticChildCount ?? itemCount,
         dragStartBehavior: dragStartBehavior,
         keyboardDismissBehavior: keyboardDismissBehavior,
         restorationId: restorationId,
         clipBehavior: clipBehavior,
       );

  FlashListView.separated({
    Key? key,
    Axis scrollDirection = Axis.vertical,
    bool reverse = false,
    FlashListViewController? controller,
    bool? primary,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    this.padding,
    required IndexedWidgetBuilder itemBuilder,
    required IndexedWidgetBuilder separatorBuilder,
    required int itemCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    double? cacheExtent,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollViewKeyboardDismissBehavior keyboardDismissBehavior =
        ScrollViewKeyboardDismissBehavior.manual,
    String? restorationId,
    Clip clipBehavior = Clip.hardEdge,
  }) : _controller = controller,
       delegate = SliverChildBuilderDelegate(
         (BuildContext context, int index) {
           final int itemIndex = index ~/ 2;
           final Widget widget;
           if (index.isEven) {
             widget = itemBuilder(context, itemIndex);
           } else {
             widget = separatorBuilder(context, itemIndex);
           }
           return widget;
         },
         childCount: _computeActualChildCount(itemCount),
         addAutomaticKeepAlives: addAutomaticKeepAlives,
         addRepaintBoundaries: addRepaintBoundaries,
         addSemanticIndexes: addSemanticIndexes,
         semanticIndexCallback: (Widget _, int index) {
           return index.isEven ? index ~/ 2 : null;
         },
       ),
       super(
         key: key,
         scrollDirection: scrollDirection,
         reverse: reverse,
         controller: controller,
         primary: primary,
         physics: physics,
         shrinkWrap: shrinkWrap,
         cacheExtent: cacheExtent,
         semanticChildCount: itemCount,
         dragStartBehavior: dragStartBehavior,
         keyboardDismissBehavior: keyboardDismissBehavior,
         restorationId: restorationId,
         clipBehavior: clipBehavior,
       );

  /// Builds the core [FlashSliverList] for this view.
  ///
  /// Subclasses that override [buildSlivers] should pass their sliver through
  /// [wrapListSliver] so [padding] is applied consistently via [SliverPadding].
  Widget buildListSliver() {
    return FlashSliverList(
      delegate: delegate,
      controller: _controller?.sliverController,
    );
  }

  /// Wraps [sliver] with [padding] when set.
  List<Widget> wrapListSliver(Widget sliver) {
    if (padding == null) {
      return [sliver];
    }
    return [SliverPadding(padding: padding!, sliver: sliver)];
  }

  @override
  List<Widget> buildSlivers(BuildContext context) {
    return wrapListSliver(buildListSliver());
  }

  static int _computeActualChildCount(int itemCount) {
    return math.max(0, itemCount * 2 - 1);
  }
}
