/// The range of item indices currently laid out in the viewport, returned by
/// `FlashSliverListController.getVisibleRange`.
///
/// A zero-cost wrapper around a `(firstIndex, lastIndex, totalVisibleHeight)`
/// record.
extension type const FlashListViewVisibleRange(
  (int firstIndex, int lastIndex, double totalVisibleHeight) value
) {
  factory FlashListViewVisibleRange.create({
    required int firstIndex,
    required int lastIndex,
    required double totalVisibleHeight,
  }) => FlashListViewVisibleRange((firstIndex, lastIndex, totalVisibleHeight));

  int get firstIndex => value.$1;
  int get lastIndex => value.$2;
  double get totalVisibleHeight => value.$3;
}
