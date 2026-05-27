import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/wish_item.dart';
import '../../home/providers/data_providers.dart';

class CoolingPage extends ConsumerWidget {
  const CoolingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishItemsAsync = ref.watch(wishItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('冷静期')),
      body: wishItemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('加载失败: $error')),
        data: (wishItems) {
          final coolingItems = wishItems.where((item) => item.status == 'cooling').toList();

          if (coolingItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('暂无冷静期中的商品', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: coolingItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _CoolingItemCard(
              item: coolingItems[index],
            ),
          );
        },
      ),
    );
  }
}

class _CoolingItemCard extends ConsumerWidget {
  final WishItem item;

  const _CoolingItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (item.category != null)
                        Chip(
                          label: Text(item.category!),
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          labelStyle: const TextStyle(color: Colors.blue, fontSize: 12),
                        ),
                      if (item.itemPrice != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '¥${item.itemPrice!.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                ),
                _CountdownChip(endTime: item.coolingEndTime),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _handleSkip(context, ref),
                    icon: const Icon(Icons.block, color: Colors.red),
                    label: const Text('放弃', style: TextStyle(color: Colors.red)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleBuy(context, ref),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('购买', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleSkip(BuildContext context, WidgetRef ref) async {
    try {
      final updated = item.copyWith(status: 'skipped');
      await ref.read(updateWishItemProvider(updated).future);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已放弃！')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('操作失败: $e')));
      }
    }
  }

  void _handleBuy(BuildContext context, WidgetRef ref) async {
    try {
      final updated = item.copyWith(status: 'purchased');
      await ref.read(updateWishItemProvider(updated).future);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已记录！')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('操作失败: $e')));
      }
    }
  }
}

class _CountdownChip extends StatefulWidget {
  final DateTime? endTime;

  const _CountdownChip({this.endTime});

  @override
  State<_CountdownChip> createState() => _CountdownChipState();
}

class _CountdownChipState extends State<_CountdownChip> {
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
  }

  void _updateRemaining() {
    if (widget.endTime != null) {
      _remaining = widget.endTime!.difference(DateTime.now());
      if (_remaining.isNegative) _remaining = Duration.zero;
    } else {
      _remaining = Duration.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.endTime == null) return const SizedBox();

    final hours = _remaining.inHours;
    final minutes = _remaining.inMinutes.remainder(60);

    return Chip(
      label: Text('${hours}h ${minutes}m'),
      backgroundColor: Colors.blue.withOpacity(0.1),
      labelStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
    );
  }
}
