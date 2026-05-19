import 'dart:async';
import 'package:flutter/material.dart';
import 'quick_list_builder.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuickListBuilder Demo',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const _DemoHome(),
    );
  }
}

// ---------------------------------------------------------------------------
// Demo home — tab navigator
// ---------------------------------------------------------------------------

class _DemoHome extends StatelessWidget {
  const _DemoHome();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('QuickListBuilder'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Selection'),
              Tab(text: 'Async / Grid'),
              Tab(text: 'Sections'),
              Tab(text: 'Controller'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SelectionTab(),
            _AsyncGridTab(),
            _SectionsTab(),
            _ControllerTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1 · Selection modes
// ---------------------------------------------------------------------------

class _SelectionTab extends StatefulWidget {
  const _SelectionTab();

  @override
  State<_SelectionTab> createState() => _SelectionTabState();
}

class _SelectionTabState extends State<_SelectionTab> {
  final _options = const ['Option A', 'Option B', 'Option C', 'Option D'];

  String? _radio = 'Option A';
  List<String> _checkboxes = ['Option B'];
  List<String> _switches = ['Option C'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Standard ────────────────────────────────────────────────
          _label('Standard — tap to snack'),
          Card(
            child: _options.quickList(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              divider: true,
              onItemTap: (item) => _snack(context, 'Tapped $item'),
            ),
          ),

          // ── Radio ────────────────────────────────────────────────────
          _label('Radio (selectionMode)'),
          Card(
            child: _options.quickList(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              selectionMode: QuickListSelectionMode.radio,
              selectedItem: _radio,
              onChanged: (val) => setState(() => _radio = val as String),
            ),
          ),

          // ── Checkbox trailing ─────────────────────────────────────────
          _label('Checkbox — trailing  •  selected: ${_checkboxes.join(', ')}'),
          Card(
            child: _options.quickList(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              selectionMode: QuickListSelectionMode.checkbox,
              trailingSelection: true,
              selectedItems: _checkboxes,
              onChanged: (val) => setState(() => _checkboxes = List<String>.from(val as List)),
            ),
          ),

          // ── Switch toggle ─────────────────────────────────────────────
          _label('Switch toggle  •  enabled: ${_switches.join(', ')}'),
          Card(
            child: _options.quickList(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              selectionMode: QuickListSelectionMode.switchToggle,
              trailingSelection: true,
              selectedItems: _switches,
              onChanged: (val) => setState(() => _switches = List<String>.from(val as List)),
            ),
          ),

          // ── Horizontal custom ─────────────────────────────────────────
          _label('Horizontal custom itemBuilder'),
          SizedBox(
            height: 90,
            child: _options.quickList(
              scrollDirection: Axis.horizontal,
              separator: const SizedBox(width: 8),
              itemBuilder: (context, item, index) => Container(
                width: 110,
                decoration: BoxDecoration(
                  color: Colors.indigo.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(item,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 2 · Async fetcher + Grid
// ---------------------------------------------------------------------------

class _AsyncGridTab extends StatefulWidget {
  const _AsyncGridTab();

  @override
  State<_AsyncGridTab> createState() => _AsyncGridTabState();
}

class _AsyncGridTabState extends State<_AsyncGridTab> {
  bool _useGrid = false;

  Future<QuickListPage<String>> _fetch(int page, int pageSize) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (page == 1 && DateTime.now().second % 7 == 0) {
      throw Exception('Simulated network error — pull to retry');
    }
    final start = (page - 1) * pageSize;
    final items = List.generate(
      pageSize,
      (i) => 'Item ${start + i + 1}',
    );
    return QuickListPage(items: items, hasMore: page < 4);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              const Text('Grid view'),
              const SizedBox(width: 8),
              Switch(
                value: _useGrid,
                onChanged: (v) => setState(() => _useGrid = v),
              ),
            ],
          ),
        ),
        Expanded(
          child: QuickListBuilder<String>(
            fetcher: _fetch,
            pageSize: 10,
            enablePagination: true,
            enablePullToRefresh: true,
            layout: _useGrid ? QuickListLayout.grid : QuickListLayout.list,
            gridCrossAxisCount: 2,
            gridChildAspectRatio: 2.5,
            padding: const EdgeInsets.all(8),
            divider: !_useGrid,
            skeletonCount: _useGrid ? 6 : 8,
            skeletonBuilder: (context) => _useGrid
                ? _GridSkeleton()
                : _ListSkeleton(),
            emptyWidget: const Center(child: Text('Nothing here')),
            errorBuilder: (context, error, retry) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent)),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: retry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
            endOfListWidget: const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                  child: Text('— end of list —',
                      style: TextStyle(color: Colors.grey))),
            ),
            itemBuilder: (context, item, index) => _useGrid
                ? Card(
                    child: Center(
                      child: Text(item,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  )
                : ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(item),
                  ),
          ),
        ),
      ],
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: _SkeletonBox(width: 40, height: 40, circle: true),
      title: _SkeletonBox(width: double.infinity, height: 14),
      subtitle: _SkeletonBox(width: 120, height: 10),
    );
  }
}

class _GridSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Card(child: _SkeletonBox(width: double.infinity, height: double.infinity));
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final bool circle;
  const _SkeletonBox(
      {required this.width, required this.height, this.circle = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: circle ? null : BorderRadius.circular(6),
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 3 · Section headers
// ---------------------------------------------------------------------------

class _SectionsTab extends StatelessWidget {
  const _SectionsTab();

  static final _people = [
    _Person('Alice', 'Engineering'),
    _Person('Bob', 'Engineering'),
    _Person('Carol', 'Design'),
    _Person('Dave', 'Design'),
    _Person('Eve', 'Marketing'),
    _Person('Frank', 'Marketing'),
  ];

  @override
  Widget build(BuildContext context) {
    return QuickListBuilder<_Person>(
      items: _people,
      divider: true,
      sectionHeaderBuilder: (item, index) => item.dept,
      titleBuilder: (item) => Text(item.name),
      subtitleBuilder: (item) => Text(item.dept),
      leadingBuilder: (item) => CircleAvatar(child: Text(item.name[0])),
      onItemTap: (item) => _snack(context, 'Tapped ${item.name}'),
    );
  }
}

class _Person {
  final String name;
  final String dept;
  const _Person(this.name, this.dept);
}

// ---------------------------------------------------------------------------
// Tab 4 · Controller (optimistic insert / remove / refresh)
// ---------------------------------------------------------------------------

class _ControllerTab extends StatefulWidget {
  const _ControllerTab();

  @override
  State<_ControllerTab> createState() => _ControllerTabState();
}

class _ControllerTabState extends State<_ControllerTab> {
  final _controller = QuickListController<String>();
  int _counter = 5;

  Future<QuickListPage<String>> _fetch(int page, int pageSize) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return QuickListPage(
      items: List.generate(pageSize, (i) => 'Server item ${(page - 1) * pageSize + i + 1}'),
      hasMore: page < 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Insert'),
                onPressed: () {
                  _counter++;
                  _controller.insert('Local item $_counter', at: 0);
                },
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove first'),
                onPressed: () {
                  final items = _controller.items;
                  if (items.isNotEmpty) _controller.remove(items.first);
                },
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                onPressed: () => _controller.refresh(),
              ),
            ],
          ),
        ),
        Expanded(
          child: QuickListBuilder<String>(
            controller: _controller,
            fetcher: _fetch,
            pageSize: 5,
            enablePullToRefresh: true,
            divider: true,
            titleBuilder: (item) => Text(item),
            trailingBuilder: (item) => IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => _controller.remove(item),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _label(String text) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey)),
    );

void _snack(BuildContext context, String msg) =>
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 1)));
