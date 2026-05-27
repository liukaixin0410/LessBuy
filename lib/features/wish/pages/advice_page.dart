import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/wish_item.dart';
import '../../home/providers/data_providers.dart';

class AdvicePage extends ConsumerWidget {
  final WishItem wishItem;

  const AdvicePage({super.key, required this.wishItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 购买建议')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wishItem.itemName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (wishItem.category != null)
                      Chip(
                        label: Text(wishItem.category!),
                        backgroundColor: Colors.blue.withValues(alpha: 0.1),
                        labelStyle: const TextStyle(color: Colors.blue),
                      ),
                    if (wishItem.itemPrice != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '¥${wishItem.itemPrice!.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _AdviceCard(wishItem: wishItem),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleSkip(context, ref),
                    icon: const Icon(Icons.block, color: Colors.red),
                    label: const Text('放弃购买', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleBuy(context, ref),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('立即购买', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (wishItem.aiAdviceType != 'skip_buy')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _handleCooling(context, ref),
                  icon: const Icon(Icons.hourglass_empty, color: Colors.blue),
                  label: const Text('加入冷静期 24h', style: TextStyle(color: Colors.blue)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleSkip(BuildContext context, WidgetRef ref) async {
    try {
      final updated = wishItem.copyWith(status: 'skipped');
      await ref.read(updateWishItemProvider(updated).future);
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已放弃购买！')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  void _handleBuy(BuildContext context, WidgetRef ref) async {
    try {
      final updated = wishItem.copyWith(status: 'purchased');
      await ref.read(updateWishItemProvider(updated).future);
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已记录购买！')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  void _handleCooling(BuildContext context, WidgetRef ref) async {
    try {
      final updated = wishItem.copyWith(
        status: 'cooling',
        coolingEndTime: DateTime.now().add(const Duration(hours: 24)),
      );
      await ref.read(updateWishItemProvider(updated).future);
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已加入冷静期！')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }
}

class _AdviceCard extends StatelessWidget {
  final WishItem wishItem;

  const _AdviceCard({required this.wishItem});

  @override
  Widget build(BuildContext context) {
    Color cardColor;
    IconData icon;
    String title;

    switch (wishItem.aiAdviceType) {
      case 'buy_now':
        cardColor = Colors.green;
        icon = Icons.check_circle_outline;
        title = '建议购买';
      case 'cool_down':
        cardColor = Colors.orange;
        icon = Icons.pause_circle_outline;
        title = '建议冷静';
      case 'skip_buy':
        cardColor = Colors.red;
        icon = Icons.remove_circle_outline;
        title = '建议放弃';
      default:
        cardColor = Colors.grey;
        icon = Icons.help_outline;
        title = '无建议';
    }

    return Card(
      color: cardColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 40, color: cardColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              wishItem.aiAdviceText ?? '暂无建议',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }
}
