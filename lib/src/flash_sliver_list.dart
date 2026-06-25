import 'package:flutter/material.dart';

import '../flash_list_view.dart';
import 'flash_list_view_element.dart';
import 'flash_list_view_render.dart';

class FlashSliverList extends SliverWithKeepAliveWidget {
  /// Creates a sliver that places box children in a linear array.
  const FlashSliverList({Key? key, required this.delegate, this.controller})
    : super(key: key);

  final SliverChildDelegate delegate;
  final FlashSliverListController? controller;

  @override
  FlashListViewElement createElement() => FlashListViewElement(this);

  @override
  FlashListViewRender createRenderObject(BuildContext context) {
    final FlashListViewElement element = context as FlashListViewElement;
    return FlashListViewRender(childManager: element);
  }
}
