# flash_list_view vendored fork

Base: upstream [flutter_list_view 1.1.29](https://pub.dev/packages/flutter_list_view/versions/1.1.29)

Fork version: `1.1.29+vchat.4`

## Why vendored

Chat needs scroll features (`keepPosition`, `jumpToIndex`, reverse short-content alignment) with local fixes for padding, jump/keepPosition races, and performance tuning without waiting on upstream releases.

## Divergences from upstream 1.1.29

| Change | Files | Reason |
|--------|-------|--------|
| `padding` on `FlashListView` via `SliverPadding` only | `flash_list_view.dart` | Single padding path — no double-count with element geometry |
| `suppressKeepPosition` on controller | `flash_sliver_list_controller.dart`, `flash_list_view_element.dart` | Synchronous keepPosition gate for programmatic jumps |
| `buildListSliver` / `wrapListSliver` helpers | `flash_list_view.dart` | Subclasses apply padding consistently |
| Selective `shouldRebuild` | `flash_list_view_delegate.dart` | Avoid full invalidation on unrelated parent rebuilds |
| Narrow `markAsInvalid` triggers | `flash_list_view_element.dart` | Only invalidate on meaningful delegate changes |
| Key → index cache | `flash_list_view_element.dart`, `flash_list_view_render.dart` | O(1) keepPosition key lookup |
| `FlashListViewVisibleRange` typed API | `flash_list_view_model.dart`, `flash_sliver_list_controller.dart` | Replace `List<dynamic>` visibility data |
| Controller methods return `bool` | `flash_sliver_list_controller.dart` | Surface not-attached failures in debug |
| `isScrollingNotifier` for position notify | `flash_list_view_element.dart` | Avoid protected `ScrollPosition.activity` access |
| `FlashListViewDelegate.copyWith` / `findChildIndexCallback` | `flash_list_view_delegate.dart` | Partial delegate updates; stable key lookup after inserts |
| `Matrix4.translateByDouble` | `flash_list_view_render.dart` | Replace deprecated `translate` |
| `cacheExtent` honored in element pool + cache-band paint | `element_pool_mixin.dart`, `paint_mixin.dart`, `flash_list_view_render.dart` | `removeOutOfScopeElements` aligned with `SliverConstraints`; paint cache band for prefetch/peek |

## Chat integration contract

- **`onItemKey`**: required when `keepPosition: true`; keys must be stable and unique per row.
- **`suppressKeepPosition`**: set synchronously on `sliverController` before programmatic jumps (wired in `CursorJumpController` and legacy `messages_list` paths). Jumps run immediately when the scroll controller has clients.
- **`keepPosition`**: leave enabled on the delegate; use `suppressKeepPosition` instead of toggling `keepPosition: !isJumping` to avoid list rebuilds during jumps.
- **Stateless item widgets**: when `disableCacheItems: false`, off-screen items may be destroyed and recreated.
- **`onItemHeight` / `preferItemHeight`**: improves jump accuracy before first layout; chat uses ~72px normal / ~52px compact bubbles.

## Tests

Run from `packages/chat-communi/flash_list_view`:

```bash
flutter test
```
