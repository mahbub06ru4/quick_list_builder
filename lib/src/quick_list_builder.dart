import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter/material.dart';

/// Signature for an async data fetcher used by [QuickListBuilder].
///
/// [page] is 1-based. [pageSize] is the requested page size.
/// Return a [QuickListPage] with the fetched items and whether more pages exist.
typedef QuickListFetcher<T> = Future<QuickListPage<T>> Function(
    int page,
    int pageSize,
    );

/// A page of results returned from a [QuickListFetcher].
class QuickListPage<T> {
  final List<T> items;
  final bool hasMore;

  /// Optional total count (useful for UI like "Showing 20 of 134").
  final int? total;

  const QuickListPage({
    required this.items,
    this.hasMore = false,
    this.total,
  });

  const QuickListPage.empty()
      : items = const [],
        hasMore = false,
        total = 0;
}

/// How items in [QuickListBuilder] are laid out.
enum QuickListLayout {
  /// Standard vertical/horizontal ListView.
  list,

  /// GridView with [SliverGridDelegateWithFixedCrossAxisCount].
  grid,
}

/// Selection mode for [QuickListBuilder].
enum QuickListSelectionMode {
  none,
  radio,
  checkbox,
  switchToggle,
}

/// A simple and flexible list builder that can easily be converted to
/// radio, checkbox, or switch styles, with grid layout, async API
/// integration, pagination, pull-to-refresh, and loading/error/empty states.
class QuickListBuilder<T> extends StatefulWidget {
  // ---------------------------------------------------------------------------
  // DATA SOURCE
  // ---------------------------------------------------------------------------

  /// Static data items to display. Provide either [items] OR [fetcher].
  final List<T>? items;

  /// Async fetcher for API-backed lists. Provide either [items] OR [fetcher].
  /// When provided, the widget manages loading / error / pagination state.
  final QuickListFetcher<T>? fetcher;

  /// Page size requested from [fetcher]. Defaults to 20.
  final int pageSize;

  /// Whether to enable infinite-scroll pagination when using [fetcher].
  final bool enablePagination;

  /// Whether to enable pull-to-refresh when using [fetcher].
  final bool enablePullToRefresh;

  /// External controller to trigger refresh/loadMore programmatically.
  final QuickListController<T>? controller;

  // ---------------------------------------------------------------------------
  // ITEM RENDERING
  // ---------------------------------------------------------------------------

  final Widget Function(BuildContext context, T item, int index)? itemBuilder;
  final Widget Function(T item)? titleBuilder;
  final Widget Function(T item)? subtitleBuilder;
  final Widget Function(T item)? leadingBuilder;
  final Widget Function(T item)? trailingBuilder;

  /// Builder for a sticky/inline section header. Return null to skip.
  final String Function(T item, int index)? sectionHeaderBuilder;

  /// Builder for a custom section header widget (overrides [sectionHeaderBuilder]).
  final Widget Function(BuildContext context, String header)?
  sectionHeaderWidgetBuilder;

  // ---------------------------------------------------------------------------
  // INTERACTION
  // ---------------------------------------------------------------------------

  final ValueChanged<T>? onItemTap;
  final ValueChanged<T>? onItemLongPress;
  final ValueChanged<dynamic>? onChanged;

  /// Enable/disable an item dynamically (e.g. disabled options).
  final bool Function(T item)? isItemEnabled;

  /// Determines whether an item is selected. Useful when [T] doesn't
  /// implement equality (e.g. comparing by id). Falls back to `==` if null.
  final bool Function(T item)? isItemSelected;

  // ---------------------------------------------------------------------------
  // SELECTION
  // ---------------------------------------------------------------------------

  final T? selectedItem;
  final List<T>? selectedItems;
  final QuickListSelectionMode selectionMode;
  final bool trailingSelection;

  /// Fully replace the radio widget. Receives the item, whether it's
  /// selected, and a callback to toggle it.
  final Widget Function(BuildContext context, T item, bool isSelected,
      VoidCallback onTap)? radioBuilder;

  /// Fully replace the checkbox widget. Same signature as [radioBuilder].
  final Widget Function(BuildContext context, T item, bool isSelected,
      VoidCallback onTap)? checkboxBuilder;

  /// Fully replace the switch widget. Same signature as [radioBuilder].
  final Widget Function(BuildContext context, T item, bool isSelected,
      VoidCallback onTap)? switchBuilder;

  // --- Fine-grained styling for the default selection widgets ---

  /// Shape used by the default [Checkbox]. Pass e.g. a [CircleBorder] for
  /// a circular checkbox.
  final OutlinedBorder? checkboxShape;

  /// BorderSide used by the default [Checkbox] when unselected.
  final BorderSide? checkboxBorderSide;

  /// Whether the default [Checkbox] is tri-state.
  final bool checkboxTristate;

  /// Material tap target size for selection widgets.
  final MaterialTapTargetSize? selectionTapTargetSize;

  /// Visual density for selection widgets.
  final VisualDensity? selectionVisualDensity;

  /// Track color for the default [Switch].
  final MaterialStateProperty<Color?>? switchTrackColor;

  /// Thumb color for the default [Switch].
  final MaterialStateProperty<Color?>? switchThumbColor;

  /// Deprecated. Use `selectionMode: QuickListSelectionMode.radio` instead.
  @Deprecated('Use selectionMode: QuickListSelectionMode.radio')
  final bool isRadio;

  /// Deprecated. Use `selectionMode: QuickListSelectionMode.checkbox` instead.
  @Deprecated('Use selectionMode: QuickListSelectionMode.checkbox')
  final bool isCheckbox;

  /// Resolves the effective selection mode, honoring legacy bool flags.
  QuickListSelectionMode get effectiveSelectionMode {
    if (selectionMode != QuickListSelectionMode.none) return selectionMode;
    if (isRadio) return QuickListSelectionMode.radio;
    if (isCheckbox) return QuickListSelectionMode.checkbox;
    return QuickListSelectionMode.none;
  }
  final Color? activeColor;
  final Color? checkColor;

  // ---------------------------------------------------------------------------
  // STYLING
  // ---------------------------------------------------------------------------

  final EdgeInsetsGeometry? itemPadding;
  final EdgeInsetsGeometry? itemMargin;
  final EdgeInsetsGeometry? padding;
  final Color? itemBackgroundColor;
  final Color? selectedItemBackgroundColor;
  final BorderRadiusGeometry? itemBorderRadius;
  final BoxBorder? itemBorder;
  final List<BoxShadow>? itemShadow;

  /// Animation duration for item taps / selection changes.
  final Duration animationDuration;

  // ---------------------------------------------------------------------------
  // LAYOUT
  // ---------------------------------------------------------------------------

  final QuickListLayout layout;
  final int gridCrossAxisCount;
  final double gridChildAspectRatio;
  final double gridMainAxisSpacing;
  final double gridCrossAxisSpacing;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  /// Whether to show a divider between items. When true, a [Divider] is used
  /// with [dividerColor], [dividerThickness], [dividerHeight], [dividerIndent],
  /// and [dividerEndIndent]. For full control, use [separator] or
  /// [separatorBuilder] instead.
  final bool divider;
  final Color? dividerColor;
  final double? dividerThickness;
  final double? dividerHeight;
  final double? dividerIndent;
  final double? dividerEndIndent;

  /// A single static widget used as separator between items.
  /// Overrides [divider] when provided.
  final Widget? separator;

  /// Per-index separator builder. Highest priority — overrides both
  /// [separator] and [divider]. Receives the items on either side.
  final Widget Function(BuildContext context, int index, T before, T after)?
  separatorBuilder;
  final Axis scrollDirection;
  final ScrollController? scrollController;
  final bool reverse;

  // ---------------------------------------------------------------------------
  // STATE WIDGETS
  // ---------------------------------------------------------------------------

  /// Widget shown during the initial load. Defaults to a centered spinner.
  final Widget? loadingWidget;

  /// Widget shown when an error occurs. Receives the error and a retry callback.
  final Widget Function(BuildContext context, Object error, VoidCallback retry)?
  errorBuilder;

  /// Widget shown when the list is empty after loading.
  final Widget? emptyWidget;

  /// Widget shown at the bottom while loading more pages.
  final Widget? loadMoreWidget;

  /// Widget shown at the bottom when no more pages remain.
  final Widget? endOfListWidget;

  /// Shimmer / skeleton item count to show during initial load.
  /// If 0, [loadingWidget] is shown instead.
  final int skeletonCount;

  /// Builder for individual skeleton items (one per slot).
  final WidgetBuilder? skeletonBuilder;

  const QuickListBuilder({
    super.key,
    this.items,
    this.fetcher,
    this.pageSize = 20,
    this.enablePagination = true,
    this.enablePullToRefresh = true,
    this.controller,
    this.itemBuilder,
    this.titleBuilder,
    this.subtitleBuilder,
    this.leadingBuilder,
    this.trailingBuilder,
    this.sectionHeaderBuilder,
    this.sectionHeaderWidgetBuilder,
    this.onItemTap,
    this.onItemLongPress,
    this.onChanged,
    this.isItemEnabled,
    this.isItemSelected,
    this.selectedItem,
    this.selectedItems,
    this.selectionMode = QuickListSelectionMode.none,
    @Deprecated('Use selectionMode: QuickListSelectionMode.radio')
    this.isRadio = false,
    @Deprecated('Use selectionMode: QuickListSelectionMode.checkbox')
    this.isCheckbox = false,
    this.trailingSelection = false,
    this.radioBuilder,
    this.checkboxBuilder,
    this.switchBuilder,
    this.checkboxShape,
    this.checkboxBorderSide,
    this.checkboxTristate = false,
    this.selectionTapTargetSize,
    this.selectionVisualDensity,
    this.switchTrackColor,
    this.switchThumbColor,
    this.activeColor,
    this.checkColor,
    this.itemPadding,
    this.itemMargin,
    this.padding,
    this.itemBackgroundColor,
    this.selectedItemBackgroundColor,
    this.itemBorderRadius,
    this.itemBorder,
    this.itemShadow,
    this.animationDuration = const Duration(milliseconds: 200),
    this.layout = QuickListLayout.list,
    this.gridCrossAxisCount = 2,
    this.gridChildAspectRatio = 1.0,
    this.gridMainAxisSpacing = 8,
    this.gridCrossAxisSpacing = 8,
    this.physics,
    this.shrinkWrap = false,
    this.divider = false,
    this.dividerColor,
    this.dividerThickness,
    this.dividerHeight,
    this.dividerIndent,
    this.dividerEndIndent,
    this.separator,
    this.separatorBuilder,
    this.scrollDirection = Axis.vertical,
    this.scrollController,
    this.reverse = false,
    this.loadingWidget,
    this.errorBuilder,
    this.emptyWidget,
    this.loadMoreWidget,
    this.endOfListWidget,
    this.skeletonCount = 0,
    this.skeletonBuilder,
  }) : assert(
  items != null || fetcher != null,
  'Provide either items or fetcher',
  );

  @override
  State<QuickListBuilder<T>> createState() => _QuickListBuilderState<T>();
}

class _QuickListBuilderState<T> extends State<QuickListBuilder<T>> {
  final List<T> _items = [];
  int _page = 1;
  bool _initialLoading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  Object? _error;
  late ScrollController _scrollController;
  bool _ownsScrollController = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _ownsScrollController = widget.scrollController == null;

    widget.controller?._attach(this);

    if (widget.fetcher != null) {
      _scrollController.addListener(_onScroll);
      _loadInitial();
    } else {
      _items.addAll(widget.items ?? []);
    }
  }

  @override
  void didUpdateWidget(covariant QuickListBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync static items if the parent updated them.
    if (widget.fetcher == null && widget.items != oldWidget.items) {
      _items
        ..clear()
        ..addAll(widget.items ?? []);
    }
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    if (_ownsScrollController) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // DATA LOADING
  // ---------------------------------------------------------------------------

  Future<void> _loadInitial() async {
    if (widget.fetcher == null) return;
    setState(() {
      _initialLoading = true;
      _error = null;
      _page = 1;
      _items.clear();
      _hasMore = true;
    });
    try {
      final result = await widget.fetcher!(1, widget.pageSize);
      if (!mounted) return;
      setState(() {
        _items.addAll(result.items);
        _hasMore = result.hasMore;
        _initialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _initialLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (widget.fetcher == null ||
        _loadingMore ||
        !_hasMore ||
        !widget.enablePagination) return;
    setState(() => _loadingMore = true);
    try {
      final nextPage = _page + 1;
      final result = await widget.fetcher!(nextPage, widget.pageSize);
      if (!mounted) return;
      setState(() {
        _items.addAll(result.items);
        _hasMore = result.hasMore;
        _page = nextPage;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingMore = false;
        // Don't replace the whole-list error here; surface as a snackbar-friendly callback.
      });
      _showLoadMoreError(e);
    }
  }

  Future<void> _refresh() => _loadInitial();

  void _onScroll() {
    if (!widget.enablePagination || _loadingMore || !_hasMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _showLoadMoreError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text('Failed to load more: $error'),
        action: SnackBarAction(label: 'Retry', onPressed: _loadMore),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Initial loading state
    if (_initialLoading) {
      return _buildLoading();
    }

    // Error state
    if (_error != null && _items.isEmpty) {
      return widget.errorBuilder?.call(context, _error!, _loadInitial) ??
          _defaultError(_error!);
    }

    // Empty state
    if (_items.isEmpty) {
      return widget.emptyWidget ?? _defaultEmpty();
    }

    Widget list = widget.layout == QuickListLayout.grid
        ? _buildGrid()
        : _buildList();

    if (widget.fetcher != null && widget.enablePullToRefresh) {
      list = RefreshIndicator(
        onRefresh: _refresh,
        child: list,
      );
    }

    return list;
  }

  Widget _buildLoading() {
    if (widget.skeletonCount > 0 && widget.skeletonBuilder != null) {
      return ListView.builder(
        padding: widget.padding,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        itemCount: widget.skeletonCount,
        itemBuilder: (context, index) => widget.skeletonBuilder!(context),
      );
    }
    return widget.loadingWidget ??
        const Center(child: CircularProgressIndicator());
  }

  Widget _defaultError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadInitial,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('Nothing to show here'),
          ],
        ),
      ),
    );
  }

  Widget _defaultSeparator(int index) {
    if (widget.separatorBuilder != null) {
      // index here is the *separator* index — between items[index] and items[index+1]
      return widget.separatorBuilder!(
        context,
        index,
        _items[index],
        _items[index + 1],
      );
    }
    if (widget.separator != null) return widget.separator!;
    if (widget.divider) {
      return widget.scrollDirection == Axis.vertical
          ? Divider(
        color: widget.dividerColor,
        thickness: widget.dividerThickness,
        height: widget.dividerHeight ?? 1,
        indent: widget.dividerIndent,
        endIndent: widget.dividerEndIndent,
      )
          : VerticalDivider(
        color: widget.dividerColor,
        thickness: widget.dividerThickness,
        width: widget.dividerHeight ?? 1,
        indent: widget.dividerIndent,
        endIndent: widget.dividerEndIndent,
      );
    }
    return widget.scrollDirection == Axis.vertical
        ? const SizedBox.shrink()
        : const SizedBox(width: 8);
  }

  Widget _buildList() {
    final useSeparator = widget.divider ||
        widget.separator != null ||
        widget.separatorBuilder != null;
    final hasFooter = widget.fetcher != null;
    final itemCount = _items.length + (hasFooter ? 1 : 0);

    Widget itemAt(int index) {
      if (hasFooter && index == _items.length) return _buildFooter();
      return _buildItem(context, index);
    }

    if (useSeparator) {
      return ListView.separated(
        controller: _scrollController,
        itemCount: itemCount,
        physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        separatorBuilder: (context, index) {
          // Don't draw a separator before the footer slot.
          if (hasFooter && index >= _items.length - 1) {
            return const SizedBox.shrink();
          }
          return _defaultSeparator(index);
        },
        itemBuilder: (context, index) => itemAt(index),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: itemCount,
      physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      itemBuilder: (context, index) => itemAt(index),
    );
  }

  Widget _buildGrid() {
    final hasFooter = widget.fetcher != null;
    return GridView.builder(
      controller: _scrollController,
      padding: widget.padding,
      physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
      shrinkWrap: widget.shrinkWrap,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      itemCount: _items.length + (hasFooter ? 1 : 0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.gridCrossAxisCount,
        childAspectRatio: widget.gridChildAspectRatio,
        mainAxisSpacing: widget.gridMainAxisSpacing,
        crossAxisSpacing: widget.gridCrossAxisSpacing,
      ),
      itemBuilder: (context, index) {
        if (hasFooter && index == _items.length) return _buildFooter();
        return _buildItem(context, index);
      },
    );
  }

  Widget _buildFooter() {
    if (_loadingMore) {
      return widget.loadMoreWidget ??
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
    }
    if (!_hasMore) {
      return widget.endOfListWidget ?? const SizedBox.shrink();
    }
    return const SizedBox.shrink();
  }

  // ---------------------------------------------------------------------------
  // ITEM BUILDING
  // ---------------------------------------------------------------------------

  bool _isSelected(T item) {
    if (widget.isItemSelected != null) return widget.isItemSelected!(item);
    if (widget.effectiveSelectionMode == QuickListSelectionMode.checkbox) {
      return widget.selectedItems?.contains(item) ?? false;
    }
    return widget.selectedItem == item;
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = _items[index];
    final isSelected = _isSelected(item);
    final isEnabled = widget.isItemEnabled?.call(item) ?? true;

    // Section header (inline)
    final headerText = widget.sectionHeaderBuilder?.call(item, index);
    final showHeader = headerText != null &&
        (index == 0 ||
            widget.sectionHeaderBuilder!(_items[index - 1], index - 1) !=
                headerText);

    Widget content;
    if (widget.itemBuilder != null) {
      content = widget.itemBuilder!(context, item, index);
    } else {
      content = ListTile(
        enabled: isEnabled,
        contentPadding: widget.itemPadding,
        title: widget.titleBuilder?.call(item) ?? Text(item.toString()),
        subtitle: widget.subtitleBuilder?.call(item),
        leading: _buildSelectionWidget(item, isSelected, isEnabled, true),
        trailing: _buildSelectionWidget(item, isSelected, isEnabled, false),
        selected: isSelected,
      );
    }

    // Wrap with interaction + decoration
    Widget wrapped = AnimatedContainer(
      duration: widget.animationDuration,
      decoration: BoxDecoration(
        color: isSelected
            ? widget.selectedItemBackgroundColor ?? widget.itemBackgroundColor
            : widget.itemBackgroundColor,
        borderRadius: widget.itemBorderRadius,
        border: widget.itemBorder,
        boxShadow: widget.itemShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: widget.itemBorderRadius is BorderRadius
              ? widget.itemBorderRadius as BorderRadius
              : null,
          onTap: isEnabled ? () => _handleTap(item) : null,
          onLongPress: isEnabled && widget.onItemLongPress != null
              ? () => widget.onItemLongPress!(item)
              : null,
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
            child: content,
          ),
        ),
      ),
    );

    if (widget.itemMargin != null) {
      wrapped = Padding(padding: widget.itemMargin!, child: wrapped);
    }

    if (showHeader) {
      final header = widget.sectionHeaderWidgetBuilder?.call(context, headerText) ??
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              headerText,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [header, wrapped],
      );
    }

    return wrapped;
  }

  Widget? _buildSelectionWidget(
      T item,
      bool isSelected,
      bool isEnabled,
      bool isLeadingSide,
      ) {
    if (isLeadingSide && widget.leadingBuilder != null) {
      return widget.leadingBuilder!(item);
    }
    if (!isLeadingSide && widget.trailingBuilder != null) {
      return widget.trailingBuilder!(item);
    }

    final mode = widget.effectiveSelectionMode;
    if (mode == QuickListSelectionMode.none) return null;

    final shouldShowHere = widget.trailingSelection ? !isLeadingSide : isLeadingSide;
    if (!shouldShowHere) return null;

    final onTap = isEnabled ? () => _handleTap(item) : () {};
    final onTapNullable = isEnabled ? () => _handleTap(item) : null;

    switch (mode) {
      case QuickListSelectionMode.radio:
        if (widget.radioBuilder != null) {
          return widget.radioBuilder!(context, item, isSelected, onTap);
        }
        return Radio<T>(
          value: item,
          groupValue: widget.selectedItem,
          activeColor: widget.activeColor,
          materialTapTargetSize: widget.selectionTapTargetSize,
          visualDensity: widget.selectionVisualDensity,
          onChanged: onTapNullable == null ? null : (_) => onTapNullable(),
        );
      case QuickListSelectionMode.checkbox:
        if (widget.checkboxBuilder != null) {
          return widget.checkboxBuilder!(context, item, isSelected, onTap);
        }
        return Checkbox(
          value: isSelected,
          tristate: widget.checkboxTristate,
          activeColor: widget.activeColor,
          checkColor: widget.checkColor,
          shape: widget.checkboxShape,
          side: widget.checkboxBorderSide,
          materialTapTargetSize: widget.selectionTapTargetSize,
          visualDensity: widget.selectionVisualDensity,
          onChanged: onTapNullable == null ? null : (_) => onTapNullable(),
        );
      case QuickListSelectionMode.switchToggle:
        if (widget.switchBuilder != null) {
          return widget.switchBuilder!(context, item, isSelected, onTap);
        }
        return Switch(
          value: isSelected,
          activeColor: widget.activeColor,
          trackColor: widget.switchTrackColor,
          thumbColor: widget.switchThumbColor,
          materialTapTargetSize: widget.selectionTapTargetSize,
          onChanged: onTapNullable == null ? null : (_) => onTapNullable(),
        );
      case QuickListSelectionMode.none:
        return null;
    }
  }

  void _handleTap(T item) {
    widget.onItemTap?.call(item);
    switch (widget.effectiveSelectionMode) {
      case QuickListSelectionMode.radio:
      case QuickListSelectionMode.switchToggle:
        widget.onChanged?.call(item);
        break;
      case QuickListSelectionMode.checkbox:
        final newSelection = List<T>.from(widget.selectedItems ?? []);
        if (newSelection.contains(item)) {
          newSelection.remove(item);
        } else {
          newSelection.add(item);
        }
        widget.onChanged?.call(newSelection);
        break;
      case QuickListSelectionMode.none:
        break;
    }
  }
}

// =============================================================================
// CONTROLLER — programmatic refresh / loadMore / mutate
// =============================================================================

class QuickListController<T> {
  _QuickListBuilderState<T>? _state;

  void _attach(_QuickListBuilderState<T> state) => _state = state;
  void _detach() => _state = null;

  /// Refresh the list from page 1.
  Future<void> refresh() async => _state?._loadInitial();

  /// Manually request the next page.
  Future<void> loadMore() async => _state?._loadMore();

  /// Current items currently held by the list.
  List<T> get items => List.unmodifiable(_state?._items ?? const []);

  /// Whether the list is currently loading the first page.
  bool get isLoading => _state?._initialLoading ?? false;

  /// Whether the list is currently loading more pages.
  bool get isLoadingMore => _state?._loadingMore ?? false;

  /// Whether more pages exist.
  bool get hasMore => _state?._hasMore ?? false;

  /// Last error encountered during initial load, if any.
  Object? get error => _state?._error;

  /// Insert an item locally (e.g. optimistic update).
  void insert(T item, {int? at}) {
    final s = _state;
    if (s == null) return;
    // ignore: invalid_use_of_protected_member
    s.setState(() {
      if (at == null) {
        s._items.add(item);
      } else {
        s._items.insert(at.clamp(0, s._items.length), item);
      }
    });
  }

  /// Remove an item locally.
  void remove(T item) {
    final s = _state;
    if (s == null) return;
    // ignore: invalid_use_of_protected_member
    s.setState(() => s._items.remove(item));
  }

  /// Replace an item by matching predicate.
  void replaceWhere(bool Function(T item) test, T newItem) {
    final s = _state;
    if (s == null) return;
    final idx = s._items.indexWhere(test);
    if (idx == -1) return;
    // ignore: invalid_use_of_protected_member
    s.setState(() => s._items[idx] = newItem);
  }
}

// =============================================================================
// EXTENSIONS
// =============================================================================

extension QuickListExtension<T> on List<T> {
  /// Builds a [QuickListBuilder] from this list.
  QuickListBuilder<T> quickList({
    Key? key,
    Widget Function(BuildContext context, T item, int index)? itemBuilder,
    Widget Function(T item)? titleBuilder,
    Widget Function(T item)? subtitleBuilder,
    Widget Function(T item)? leadingBuilder,
    Widget Function(T item)? trailingBuilder,
    ValueChanged<T>? onItemTap,
    ValueChanged<T>? onItemLongPress,
    ValueChanged<dynamic>? onChanged,
    bool Function(T item)? isItemEnabled,
    bool Function(T item)? isItemSelected,
    T? selectedItem,
    List<T>? selectedItems,
    QuickListSelectionMode selectionMode = QuickListSelectionMode.none,
    @Deprecated('Use selectionMode: QuickListSelectionMode.radio')
    bool isRadio = false,
    @Deprecated('Use selectionMode: QuickListSelectionMode.checkbox')
    bool isCheckbox = false,
    bool trailingSelection = false,
    Color? activeColor,
    Color? checkColor,
    Widget Function(BuildContext context, T item, bool isSelected, VoidCallback onTap)? radioBuilder,
    Widget Function(BuildContext context, T item, bool isSelected, VoidCallback onTap)? checkboxBuilder,
    Widget Function(BuildContext context, T item, bool isSelected, VoidCallback onTap)? switchBuilder,
    OutlinedBorder? checkboxShape,
    BorderSide? checkboxBorderSide,
    bool checkboxTristate = false,
    MaterialTapTargetSize? selectionTapTargetSize,
    VisualDensity? selectionVisualDensity,
    MaterialStateProperty<Color?>? switchTrackColor,
    MaterialStateProperty<Color?>? switchThumbColor,
    EdgeInsetsGeometry? itemPadding,
    EdgeInsetsGeometry? itemMargin,
    EdgeInsetsGeometry? padding,
    Color? itemBackgroundColor,
    Color? selectedItemBackgroundColor,
    BorderRadiusGeometry? itemBorderRadius,
    BoxBorder? itemBorder,
    List<BoxShadow>? itemShadow,
    QuickListLayout layout = QuickListLayout.list,
    int gridCrossAxisCount = 2,
    double gridChildAspectRatio = 1.0,
    double gridMainAxisSpacing = 8,
    double gridCrossAxisSpacing = 8,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
    bool divider = false,
    Color? dividerColor,
    double? dividerThickness,
    double? dividerHeight,
    double? dividerIndent,
    double? dividerEndIndent,
    Widget? separator,
    Widget Function(BuildContext context, int index, T before, T after)? separatorBuilder,
    Axis scrollDirection = Axis.vertical,
    Widget? emptyWidget,
    String Function(T item, int index)? sectionHeaderBuilder,
  }) {
    return QuickListBuilder<T>(
      key: key,
      items: this,
      itemBuilder: itemBuilder,
      titleBuilder: titleBuilder,
      subtitleBuilder: subtitleBuilder,
      leadingBuilder: leadingBuilder,
      trailingBuilder: trailingBuilder,
      onItemTap: onItemTap,
      onItemLongPress: onItemLongPress,
      onChanged: onChanged,
      isItemEnabled: isItemEnabled,
      isItemSelected: isItemSelected,
      selectedItem: selectedItem,
      selectedItems: selectedItems,
      selectionMode: selectionMode,
      // ignore: deprecated_member_use_from_same_package
      isRadio: isRadio,
      // ignore: deprecated_member_use_from_same_package
      isCheckbox: isCheckbox,
      trailingSelection: trailingSelection,
      activeColor: activeColor,
      checkColor: checkColor,
      radioBuilder: radioBuilder,
      checkboxBuilder: checkboxBuilder,
      switchBuilder: switchBuilder,
      checkboxShape: checkboxShape,
      checkboxBorderSide: checkboxBorderSide,
      checkboxTristate: checkboxTristate,
      selectionTapTargetSize: selectionTapTargetSize,
      selectionVisualDensity: selectionVisualDensity,
      switchTrackColor: switchTrackColor,
      switchThumbColor: switchThumbColor,
      itemPadding: itemPadding,
      itemMargin: itemMargin,
      padding: padding,
      itemBackgroundColor: itemBackgroundColor,
      selectedItemBackgroundColor: selectedItemBackgroundColor,
      itemBorderRadius: itemBorderRadius,
      itemBorder: itemBorder,
      itemShadow: itemShadow,
      layout: layout,
      gridCrossAxisCount: gridCrossAxisCount,
      gridChildAspectRatio: gridChildAspectRatio,
      gridMainAxisSpacing: gridMainAxisSpacing,
      gridCrossAxisSpacing: gridCrossAxisSpacing,
      physics: physics,
      shrinkWrap: shrinkWrap,
      divider: divider,
      dividerColor: dividerColor,
      dividerThickness: dividerThickness,
      dividerHeight: dividerHeight,
      dividerIndent: dividerIndent,
      dividerEndIndent: dividerEndIndent,
      separator: separator,
      separatorBuilder: separatorBuilder,
      scrollDirection: scrollDirection,
      emptyWidget: emptyWidget,
      sectionHeaderBuilder: sectionHeaderBuilder,
    );
  }
}
