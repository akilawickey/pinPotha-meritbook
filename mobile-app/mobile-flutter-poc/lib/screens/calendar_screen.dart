import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/posts_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/mobile_drawer.dart';
import '../widgets/posts_status.dart';
import 'post_list_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime? _month;
  DateTime? _lastSelected;
  void _shift(int months) =>
      setState(() => _month = DateTime(_month!.year, _month!.month + months));
  @override
  Widget build(BuildContext context) {
    final navigation = context.watch<NavigationProvider>();
    final posts = context.watch<PostsProvider>();
    final selected = navigation.selectedDate;
    if (_lastSelected != selected) {
      _month = DateTime(selected.year, selected.month);
      _lastSelected = selected;
    }
    final month = _month!;
    final days = DateTime(month.year, month.month + 1, 0).day;
    final offset = month.weekday - 1;
    final rows = ((days + offset) / 7).ceil();
    final counts = <DateTime, int>{};
    for (final post in posts.posts) {
      final date = AppDateUtils.getStartOfDay(post.displayDate);
      counts.update(date, (value) => value + 1, ifAbsent: () => 1);
    }
    return Scaffold(
        appBar: AppBar(title: const Text('PinPotha')),
        drawer: const MobileDrawer(),
        body: posts.loading || posts.error != null
            ? PostsStatus(posts: posts)
            : ListView(padding: const EdgeInsets.all(16), children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          tooltip: 'Previous year',
                          onPressed: month.year > 1 ? () => _shift(-12) : null,
                          icon: const Icon(Icons.keyboard_double_arrow_left)),
                      IconButton(
                          tooltip: 'Previous month',
                          onPressed: month.year > 1 || month.month > 1
                              ? () => _shift(-1)
                              : null,
                          icon: const Icon(Icons.chevron_left)),
                      Expanded(
                          child: Text(
                              AppDateUtils.formatDate(month,
                                  format: 'MMMM yyyy'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium)),
                      IconButton(
                          tooltip: 'Next month',
                          onPressed: month.year < 9999 || month.month < 12
                              ? () => _shift(1)
                              : null,
                          icon: const Icon(Icons.chevron_right)),
                      IconButton(
                          tooltip: 'Next year',
                          onPressed:
                              month.year < 9999 ? () => _shift(12) : null,
                          icon: const Icon(Icons.keyboard_double_arrow_right)),
                    ]),
                Row(children: [
                  for (final day in [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun'
                  ])
                    Expanded(
                        child: Center(
                            child: Text(day,
                                style: Theme.of(context).textTheme.labelSmall)))
                ]),
                GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rows * 7,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7, childAspectRatio: .85),
                    itemBuilder: (context, index) {
                      final day = index - offset + 1;
                      if (day < 1 || day > days) return const SizedBox.shrink();
                      final date = DateTime(month.year, month.month, day);
                      final count = counts[date] ?? 0;
                      final active = AppDateUtils.sameDay(date, selected);
                      return Semantics(
                          label:
                              '${AppDateUtils.formatDate(date)}, $count good thoughts',
                          selected: active,
                          child: InkWell(
                            key: ValueKey(
                                'day-${AppDateUtils.formatDate(date)}'),
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              navigation.selectDate(date);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                      builder: (_) =>
                                          PostListScreen(date: date)));
                            },
                            child: Container(
                                margin: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                    color: active
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                        : null,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('$day'),
                                      SizedBox(
                                          height: 12,
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                for (var dot = 0;
                                                    dot <
                                                        (count > 1 ? 2 : count);
                                                    dot++)
                                                  Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 1),
                                                      child: Icon(Icons.circle,
                                                          size: 5,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary)),
                                              ])),
                                    ])),
                          ));
                    }),
                const SizedBox(height: 16),
                Text(
                    'Selected: ${AppDateUtils.formatDate(selected, format: 'EEE, dd MMM yyyy')}',
                    style: Theme.of(context).textTheme.titleMedium),
                Text('${counts[selected] ?? 0} good thoughts'),
                const SizedBox(height: 16),
                FilledButton.icon(
                    onPressed: () => navigation.select(1),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Good Thought')),
                TextButton(
                    onPressed: () => navigation.select(2),
                    child: const Text('View All Good Things')),
              ]));
  }
}
