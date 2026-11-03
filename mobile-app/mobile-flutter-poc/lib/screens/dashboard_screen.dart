import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post_page.dart';
import '../providers/posts_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/posts_status.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _search = TextEditingController();
  final _pagination = PostPage();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PostsProvider>();
    final filtered =
        state.posts.where((post) => post.matches(_search.text)).toList();
    final page = _pagination.items(filtered);
    return Scaffold(
        appBar: AppBar(title: const Text('View Good Things')),
        body: state.loading || state.error != null
            ? PostsStatus(posts: state)
            : RefreshIndicator(
                onRefresh: state.retry,
                child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(children: [
                                TextField(
                                    controller: _search,
                                    decoration: InputDecoration(
                                        hintText:
                                            'Search notes or date (dd-MM-yyyy)',
                                        prefixIcon: const Icon(Icons.search),
                                        suffixIcon: IconButton(
                                            tooltip: 'Clear search',
                                            onPressed: () => setState(() {
                                                  _search.clear();
                                                  _pagination.page = 1;
                                                }),
                                            icon: const Icon(Icons.clear))),
                                    onChanged: (_) =>
                                        setState(() => _pagination.page = 1)),
                                Row(children: [
                                  Expanded(
                                      child: Text(
                                          '${filtered.length} good thoughts')),
                                  DropdownButton<int>(
                                      value: _pagination.pageSize,
                                      items: [6, 12, 24, 48]
                                          .map((size) => DropdownMenuItem(
                                              value: size,
                                              child: Text('$size per page')))
                                          .toList(),
                                      onChanged: (size) {
                                        if (size != null) {
                                          setState(
                                              () => _pagination.resize(size));
                                        }
                                      }),
                                ]),
                              ]))),
                      if (filtered.isEmpty)
                        SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                                child: Text(_search.text.trim().isEmpty
                                    ? 'No good thoughts yet. Add your first one.'
                                    : 'No matching good thoughts.')))
                      else
                        SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverLayoutBuilder(
                                builder: (context, constraints) => SliverGrid(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: constraints
                                                          .crossAxisExtent <
                                                      340
                                                  ? 1
                                                  : constraints
                                                              .crossAxisExtent >
                                                          700
                                                      ? 3
                                                      : 2,
                                              mainAxisSpacing: 12,
                                              crossAxisSpacing: 12,
                                              mainAxisExtent: 280),
                                      delegate: SliverChildBuilderDelegate(
                                          (_, index) =>
                                              PostCard(post: page[index]),
                                          childCount: page.length),
                                    ))),
                      if (filtered.isNotEmpty)
                        SliverToBoxAdapter(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                              IconButton(
                                  tooltip: 'Previous page',
                                  onPressed: _pagination.page > 1
                                      ? () => setState(() => _pagination.page--)
                                      : null,
                                  icon: const Icon(Icons.chevron_left)),
                              Text(
                                  'Page ${_pagination.page} of ${_pagination.pageCount(filtered.length)}'),
                              IconButton(
                                  tooltip: 'Next page',
                                  onPressed: _pagination.page <
                                          _pagination.pageCount(filtered.length)
                                      ? () => setState(() => _pagination.page++)
                                      : null,
                                  icon: const Icon(Icons.chevron_right)),
                            ])),
                    ]),
              ));
  }
}
