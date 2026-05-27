import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/wish_item.dart';
import '../../home/providers/data_providers.dart';

class ReviewPage extends ConsumerWidget {
  const ReviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(reviewStatsProvider);
    final wishItemsAsync = ref.watch(wishItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('消费复盘')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('加载失败: $error')),
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.blue.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '本周成果',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: [
                          _MiniStat('想买次数', stats.weeklyWishCount.toString(), Colors.grey),
                          _MiniStat('已购买', stats.weeklyPurchasedCount.toString(), Colors.green),
                          _MiniStat('已放弃', stats.weeklySkippedCount.toString(), Colors.red),
                          _MiniStat('节省金额', '¥${stats.estimatedSavings.toStringAsFixed(0)}', Colors.blue),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '分类统计',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              wishItemsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('加载失败: $error'),
                data: (wishItems) => _CategoryStats(wishItems: wishItems),
              ),
              const SizedBox(height: 24),
              const Text(
                '近期记录',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              wishItemsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Text('加载失败: $error'),
                data: (wishItems) => ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: wishItems.take(5).length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) => _HistoryItem(item: wishItems[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MiniStat(this.title, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _CategoryStats extends StatelessWidget {
  final List<WishItem> wishItems;

  const _CategoryStats({required this.wishItems});

  @override
  Widget build(BuildContext context) {
    final categoryCounts = <String, int>{};
    for (final item in wishItems) {
      if (item.category != null) {
        categoryCounts[item.category!] = (categoryCounts[item.category!] ?? 0) + 1;
      }
    }

    if (categoryCounts.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    final sorted = categoryCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: sorted.take(5).map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(entry.key, style: const TextStyle(fontSize: 16)),
                  ),
                  SizedBox(
                    width: 150,
                    child: LinearProgressIndicator(
                      value: entry.value / sorted.first.value,
                      backgroundColor: Colors.grey[200],
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${entry.value}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final WishItem item;

  const _HistoryItem({required this.item});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;
    switch (item.status) {
      case 'purchased':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        label = '已购买';
      case 'skipped':
        color = Colors.red;
        icon = Icons.remove_circle_outline;
        label = '已放弃';
      case 'cooling':
        color = Colors.blue;
        icon = Icons.hourglass_empty;
        label = '冷静中';
      default:
        color = Colors.grey;
        icon = Icons.pending;
        label = '待决策';
    }

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(item.itemName),
      subtitle: item.category != null ? Text(item.category!) : null,
      trailing: Chip(
        label: Text(label),
        backgroundColor: color.withValues(alpha: 0.1),
        labelStyle: TextStyle(color: color),
      ),
    );
  }
}
