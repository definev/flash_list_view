import 'package:flutter/widgets.dart';

import 'flash_sliver_list_controller.dart';

class FlashListViewController extends ScrollController {
  FlashListViewController()
    : sliverController = FlashSliverListController(),
      super();
  final FlashSliverListController sliverController;

  @override
  void dispose() {
    sliverController.dispose();
    super.dispose();
  }
}
