## 0.1.0
* Provide keep position feature
* provide show top in reverse mode
* Reuse list item element to save performance
## 0.1.1
* Provide jumpToIndex
## 1.0.0
* Provide anmiteToIndex
* Integrate pull_to_refresh

## 1.0.2
* Add initIndex,initOffset and initOffsetBasedOnBottom
* Add Element Positions Callback

## 1.0.3
* Correct the items did not response the gesture event

## 1.0.4
* Correct sticky header may not response the gesture event

## 1.0.5
* Fix the exception when change size of child

## 1.0.7
* Fix drag down item will be clip if the items can't fill full screen.

## 1.0.8
* When reuse exist element, the same key will be priority reused it. avoid update one item twice in very short time.

## 1.0.9
* Resolve performance issue when without onItemHeight and onItemKey and child count more than 1M

## 1.1.0
* Add permanent item which will not to be reused and keep in FlashListView util FlashListView disposed

## 1.1.1
* Provide option to determine whether or not generate items during scrolling to make scroll to index more smooth

## 1.1.2
* Fix bug: It cause exception when the user stop scroll manually while invoke animite to index

## 1.1.3
* Add FlashListView.builder and FlashListView.separated

## 1.1.4
* Add ensureVisible(index) functionality

## 1.1.5
* Fixed jump to index or init index will scroll to wrong position

## 1.1.6
* Fixed jump to index or init index will scroll to wrong position when initOffsetBasedOnBottom: true

## 1.1.7
* Fixed when remove all items and jump to index was set, onItemKey will get wrong.

## 1.1.8
* Fixed when remove some items, onItemKey will get wrong.

## 1.1.10
* Sticky header support reverse

## 1.1.11
* Fixed support PopupMenuButton

## 1.1.12
* Support stickyAtTailer in FlashListView

## 1.1.15
* Fixed detach issue

## 1.1.17
* Fixed touch item is incorrect when items can't fill full screen and firstItemAlign is FirstItemAlign.end

## 1.1.18
* Rewrite keep position logic.

## 1.1.22
* Fix the error when item is Dismissible widget

## 1.1.24
* Fixed _debugSubtreeRelayoutRootAlreadyMarkedNeedsLayout()': is not true error when disableCacheItems is false

## 1.1.25
* Add expandDirectToDownWhenFirstItemAlignToEnd property

## 1.1.26
* Fixed layout error when onIsPermanent: (keyOrIndex) => true

## 1.1.27
* Fixed flick when jump to last index

## 1.1.28
* Fixed page down bug

## 1.1.29
* expose getVisibleIndexData method in controller

## 1.1.29+vchat.3 (vendored fork)
* Single-path padding: `SliverPadding` only (removed duplicate element geometry padding)
* `FlashListViewDelegate.copyWith` and `findChildIndexCallback`
* Key cache rebuilds only when `childCount` changes
* Chat: `keepPosition: true` always; jumps use `suppressKeepPosition` without list rebuild
* Chat: synchronous jump when scroll controller has clients

## 1.1.29+vchat.2 (vendored fork)
* `suppressKeepPosition` on `FlashSliverListController` for synchronous keepPosition gating
* Padding-aware `getScrollOffsetByIndex` and `scrollExtent`
* `buildListSliver` / `wrapListSliver` helpers for subclass-safe padding
* Selective `FlashListViewDelegate.shouldRebuild` and narrowed `markAsInvalid` triggers
* Key → index cache for keepPosition lookup
* `FlashListViewVisibleRange` typed visibility API; controller scroll methods return `bool`
* Code health: `isScrollingNotifier`, `translateByDouble`

## 1.1.29+vchat.1 (vendored fork)
* Add `padding` parameter to `FlashListView`, `FlashListView.builder`, and `FlashListView.separated` constructors (applied via `SliverPadding` in `buildSlivers`)

## TODO
* Add horizontal scroll support
* Add creating items when flash list view created
* Add Flutter Key to reference items' element
* Add header is not override