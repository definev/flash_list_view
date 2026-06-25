import 'package:flutter/widgets.dart';

class FlashListViewRenderData {
  FlashListViewRenderData({
    required this.index,
    required this.element,
    required this.offset,
    required this.height,
    required this.itemKey,
    required this.isSticky,
  });
  
  final int index;
  final String itemKey;

  Element element;
  double offset;
  double height;
  bool isSticky;
  double? prevRenderHeight;
}
