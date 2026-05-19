# quick_list_builder

A lightweight and developer-friendly list widget for Flutter.
`QuickListBuilder` replaces boilerplate `ListView.builder` code with a single, feature-rich widget that handles selection, async data, pagination, grid layout, section headers, skeleton loading, and more — with zero extra dependencies.

---

## Features

- **4 selection modes** — none, radio, checkbox, switch toggle
- **Trailing or leading** selection placement
- **Async fetcher** — `Future`-based data source with built-in loading / error / empty states
- **Infinite scroll pagination** — auto-loads the next page near the scroll end
- **Pull-to-refresh** — `RefreshIndicator` wired automatically
- **Grid layout** — drop-in `GridView` with `layout: QuickListLayout.grid`
- **Section headers** — inline grouped headers via `sectionHeaderBuilder`
- **Skeleton loading** — custom per-item placeholders during initial load
- **Programmatic controller** — `QuickListController` for refresh, loadMore, insert, remove, replaceWhere
- **Custom builders** — `itemBuilder`, `titleBuilder`, `subtitleBuilder`, `leadingBuilder`, `trailingBuilder`, `radioBuilder`, `checkboxBuilder`, `switchBuilder`
- **Dividers & separators** — `divider` toggle, static `separator`, or per-index `separatorBuilder`
- **Animated item transitions** — configurable `animationDuration`
- **Item enable/disable** — per-item enabled state with 50 % opacity
- **Horizontal lists** — `scrollDirection: Axis.horizontal`
- **List extension** — `myList.quickList(...)` builds from any `List<T>` instantly
- Zero extra dependencies

---

## Installation

```yaml
dependencies:
  quick_list_builder: ^0.0.3
```

```dart
import 'package:quick_list_builder/quick_list_builder.dart';
```

---

## Quick start

### Static list

```dart
final items = ['Apple', 'Banana', 'Cherry'];

QuickListBuilder<String>(
  items: items,
  divider: true,
  onItemTap: (item) => print('Tapped $item'),
)
```

Or use the `List` extension:

```dart
items.quickList(
  divider: true,
  onItemTap: (item) => print('Tapped $item'),
)
```

---

## Selection modes

### Radio

```dart
String? selected = 'Apple';

QuickListBuilder<String>(
  items: items,
  selectionMode: QuickListSelectionMode.radio,
  selectedItem: selected,
  onChanged: (val) => setState(() => selected = val as String),
)
```

### Checkbox

```dart
List<String> selected = [];

QuickListBuilder<String>(
  items: items,
  selectionMode: QuickListSelectionMode.checkbox,
  trailingSelection: true,        // place checkbox on the right
  selectedItems: selected,
  onChanged: (val) => setState(() => selected = List<String>.from(val as List)),
)
```

### Switch toggle

```dart
QuickListBuilder<String>(
  items: items,
  selectionMode: QuickListSelectionMode.switchToggle,
  trailingSelection: true,
  selectedItems: enabled,
  onChanged: (val) => setState(() => enabled = List<String>.from(val as List)),
)
```

---

## Async data & pagination

Provide a `fetcher` instead of `items` to load data from an API.
The widget handles loading, error, empty, and infinite-scroll pagination states automatically.

```dart
Future<QuickListPage<User>> _fetchUsers(int page, int pageSize) async {
  final json = await api.getUsers(page: page, limit: pageSize);
  return QuickListPage(
    items: json.map(User.fromJson).toList(),
    hasMore: json.length == pageSize,
  );
}

QuickListBuilder<User>(
  fetcher: _fetchUsers,
  pageSize: 20,
  enablePagination: true,
  enablePullToRefresh: true,
  titleBuilder: (user) => Text(user.name),
  subtitleBuilder: (user) => Text(user.email),
  leadingBuilder: (user) => CircleAvatar(child: Text(user.name[0])),
  emptyWidget: const Center(child: Text('No users found')),
  errorBuilder: (context, error, retry) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$error'),
        FilledButton(onPressed: retry, child: const Text('Retry')),
      ],
    ),
  ),
  endOfListWidget: const Center(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Text('— no more results —'),
    ),
  ),
)
```

---

## Grid layout

Switch to a `GridView` with one parameter:

```dart
QuickListBuilder<Product>(
  fetcher: _fetchProducts,
  layout: QuickListLayout.grid,
  gridCrossAxisCount: 2,
  gridChildAspectRatio: 0.75,
  gridMainAxisSpacing: 8,
  gridCrossAxisSpacing: 8,
  itemBuilder: (context, product, index) => ProductCard(product),
)
```

---

## Section headers

Group items under inline headers automatically:

```dart
QuickListBuilder<Contact>(
  items: contacts,          // must be pre-sorted by group
  sectionHeaderBuilder: (contact, index) => contact.department,
  titleBuilder: (contact) => Text(contact.name),
  subtitleBuilder: (contact) => Text(contact.role),
  leadingBuilder: (contact) => CircleAvatar(child: Text(contact.name[0])),
)
```

Use `sectionHeaderWidgetBuilder` for a fully custom header widget.

---

## Skeleton loading

Show placeholder items while the first page loads:

```dart
QuickListBuilder<Post>(
  fetcher: _fetchPosts,
  skeletonCount: 6,
  skeletonBuilder: (context) => const ListTile(
    leading: _SkeletonCircle(),
    title: _SkeletonLine(width: double.infinity),
    subtitle: _SkeletonLine(width: 140),
  ),
  itemBuilder: (context, post, index) => PostTile(post),
)
```

---

## Programmatic controller

Use `QuickListController` to refresh, paginate, or mutate items from outside the widget:

```dart
final _controller = QuickListController<String>();

// Attach
QuickListBuilder<String>(
  fetcher: _fetch,
  controller: _controller,
  ...
)

// Elsewhere
_controller.refresh();                        // reload from page 1
_controller.insert('New item', at: 0);        // optimistic insert
_controller.remove('Old item');               // optimistic remove
_controller.replaceWhere((e) => e == 'x', 'y'); // swap item
```

---

## Custom item builder

Full control over each row:

```dart
QuickListBuilder<Order>(
  items: orders,
  itemBuilder: (context, order, index) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    child: ListTile(
      leading: Icon(
        order.isPaid ? Icons.check_circle : Icons.pending,
        color: order.isPaid ? Colors.green : Colors.orange,
      ),
      title: Text(order.title),
      subtitle: Text('\$${order.amount}'),
      trailing: Text(order.date),
    ),
  ),
)
```

---

## Separators

```dart
// Built-in divider
QuickListBuilder<String>(items: items, divider: true)

// Static separator widget
QuickListBuilder<String>(
  items: items,
  separator: const Padding(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Divider(height: 1),
  ),
)

// Per-index separator builder
QuickListBuilder<String>(
  items: items,
  separatorBuilder: (context, index, before, after) =>
      index == 2 ? const SizedBox(height: 24) : const Divider(),
)
```

---

## Horizontal list

```dart
SizedBox(
  height: 120,
  child: QuickListBuilder<Category>(
    items: categories,
    scrollDirection: Axis.horizontal,
    separator: const SizedBox(width: 12),
    itemBuilder: (context, cat, index) => CategoryChip(cat),
  ),
)
```

---

## Item enable / disable

```dart
QuickListBuilder<Plan>(
  items: plans,
  isItemEnabled: (plan) => plan.isAvailable,  // disabled items shown at 50 % opacity
  selectionMode: QuickListSelectionMode.radio,
  selectedItem: _selectedPlan,
  onChanged: (val) => setState(() => _selectedPlan = val as Plan),
  titleBuilder: (plan) => Text(plan.name),
  subtitleBuilder: (plan) => Text(plan.price),
)
```

---

## Full API reference

### Data source

| Param | Type | Default | Description |
|---|---|---|---|
| `items` | `List<T>?` | — | Static list. Provide either `items` or `fetcher` |
| `fetcher` | `QuickListFetcher<T>?` | — | Async page fetcher. Provide either `items` or `fetcher` |
| `pageSize` | `int` | `20` | Items per page requested from `fetcher` |
| `enablePagination` | `bool` | `true` | Auto-load next page on scroll |
| `enablePullToRefresh` | `bool` | `true` | Wrap with `RefreshIndicator` |
| `controller` | `QuickListController<T>?` | — | Programmatic controller |

### Item rendering

| Param | Description |
|---|---|
| `itemBuilder` | Full custom item widget — overrides all other builders |
| `titleBuilder` | Title widget for each item |
| `subtitleBuilder` | Subtitle widget for each item |
| `leadingBuilder` | Leading widget (left side) |
| `trailingBuilder` | Trailing widget (right side) |
| `sectionHeaderBuilder` | Returns a group header string for each item |
| `sectionHeaderWidgetBuilder` | Custom widget for section header |

### Selection

| Param | Type | Default | Description |
|---|---|---|---|
| `selectionMode` | `QuickListSelectionMode` | `none` | `none`, `radio`, `checkbox`, `switchToggle` |
| `selectedItem` | `T?` | — | Currently selected item (radio / switch) |
| `selectedItems` | `List<T>?` | — | Currently selected items (checkbox / switch) |
| `trailingSelection` | `bool` | `false` | Place selection widget on the trailing side |
| `isItemSelected` | `bool Function(T)?` | — | Custom equality check for selection state |
| `radioBuilder` | builder | — | Fully custom radio widget |
| `checkboxBuilder` | builder | — | Fully custom checkbox widget |
| `switchBuilder` | builder | — | Fully custom switch widget |
| `activeColor` | `Color?` | — | Active color for radio / checkbox |
| `checkColor` | `Color?` | — | Check mark color for checkbox |
| `checkboxShape` | `OutlinedBorder?` | — | Custom checkbox shape (e.g. `CircleBorder`) |

### Interaction

| Param | Type | Description |
|---|---|---|
| `onItemTap` | `ValueChanged<T>?` | Called when an item is tapped |
| `onItemLongPress` | `ValueChanged<T>?` | Called on long press |
| `onChanged` | `ValueChanged<dynamic>?` | Selection change callback |
| `isItemEnabled` | `bool Function(T)?` | Per-item enabled state |

### Layout

| Param | Type | Default | Description |
|---|---|---|---|
| `layout` | `QuickListLayout` | `list` | `list` or `grid` |
| `gridCrossAxisCount` | `int` | `2` | Grid columns |
| `gridChildAspectRatio` | `double` | `1.0` | Grid cell aspect ratio |
| `gridMainAxisSpacing` | `double` | `8` | Grid row spacing |
| `gridCrossAxisSpacing` | `double` | `8` | Grid column spacing |
| `scrollDirection` | `Axis` | `vertical` | Scroll axis |
| `shrinkWrap` | `bool` | `false` | Shrink-wrap the scroll view |
| `physics` | `ScrollPhysics?` | — | Custom scroll physics |
| `scrollController` | `ScrollController?` | — | External scroll controller |
| `reverse` | `bool` | `false` | Reverse scroll direction |
| `padding` | `EdgeInsetsGeometry?` | — | List padding |

### Separators

| Param | Type | Default | Description |
|---|---|---|---|
| `divider` | `bool` | `false` | Show `Divider` between items |
| `dividerColor` | `Color?` | — | Divider color |
| `dividerThickness` | `double?` | — | Divider thickness |
| `dividerIndent` / `dividerEndIndent` | `double?` | — | Divider indent |
| `separator` | `Widget?` | — | Static separator widget. Overrides `divider` |
| `separatorBuilder` | builder | — | Per-index separator. Highest priority |

### Item styling

| Param | Type | Description |
|---|---|---|
| `itemPadding` | `EdgeInsetsGeometry?` | Padding inside each item |
| `itemMargin` | `EdgeInsetsGeometry?` | Margin around each item |
| `itemBackgroundColor` | `Color?` | Default item background |
| `selectedItemBackgroundColor` | `Color?` | Background when selected |
| `itemBorderRadius` | `BorderRadiusGeometry?` | Item corner radius |
| `itemBorder` | `BoxBorder?` | Item border |
| `itemShadow` | `List<BoxShadow>?` | Item shadow |
| `animationDuration` | `Duration` | Selection animation duration (default `200 ms`) |

### State widgets

| Param | Description |
|---|---|
| `loadingWidget` | Widget shown during initial load (overrides skeleton) |
| `errorBuilder` | `(context, error, retry)` — custom error widget |
| `emptyWidget` | Widget shown when list is empty |
| `loadMoreWidget` | Widget shown at bottom while loading more pages |
| `endOfListWidget` | Widget shown when no more pages remain |
| `skeletonCount` | Number of skeleton items to show during initial load |
| `skeletonBuilder` | Builder for each skeleton item |

---

## QuickListController

```dart
final controller = QuickListController<T>();

controller.refresh();                           // reload from page 1
controller.loadMore();                          // load next page manually
controller.insert(item, at: 0);                 // insert at index
controller.remove(item);                        // remove by equality
controller.replaceWhere((e) => test(e), newItem); // conditional replace
controller.items;       // current item list (unmodifiable)
controller.isLoading;   // true during initial load
controller.isLoadingMore; // true while loading a page
controller.hasMore;     // whether more pages exist
controller.error;       // last initial-load error, if any
```

---

## License

MIT
