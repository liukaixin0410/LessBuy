import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../../../models/wish_item.dart';
import '../../home/providers/data_providers.dart';

class CoolingPage extends ConsumerWidget {
  const CoolingPage({super.key});

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case '食品':
        return Icons.restaurant;
      case '日用品':
        return Icons.home;
      case '服装':
        return Icons.checkroom;
      case '电子产品':
        return Icons.phone_android;
      case '家居':
        return Icons.chair;
      default:
        return Icons.shopping_bag;
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case '食品':
        return Colors.green;
      case '日用品':
        return Colors.blue;
      case '服装':
        return Colors.purple;
      case '电子产品':
        return Colors.orange;
      case '家居':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishItemsAsync = ref.watch(wishItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '冷静期',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: wishItemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('加载失败: $error')),
        data: (wishItems) {
          final coolingItems =
              wishItems.where((item) => item.status == 'cooling').toList();

          if (coolingItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hourglass_empty_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    '暂无冷静期中的商品',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    '添加想买的商品，开始冷静期吧！',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: coolingItems.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) => _CoolingItemCard(
              item: coolingItems[index],
              categoryIcon: _getCategoryIcon(coolingItems[index].category),
              categoryColor: _getCategoryColor(coolingItems[index].category),
            ),
          );
        },
      ),
    );
  }
}

class _CoolingItemCard extends ConsumerWidget {
  final WishItem item;
  final IconData categoryIcon;
  final Color categoryColor;

  const _CoolingItemCard({
    required this.item,
    required this.categoryIcon,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    categoryIcon,
                    color: categoryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (item.category != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          item.category!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      if (item.itemPrice != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '¥${item.itemPrice!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _CountdownChip(endTime: item.coolingEndTime),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side:
                          BorderSide(color: AppColors.error.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    onPressed: () => _handleSkip(context, ref),
                    icon: const Icon(Icons.block),
                    label: const Text('放弃'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                    onPressed: () => _handleBuy(context, ref),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      '购买',
                      style: TextStyle(color: Colors.white),
                    ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('已放弃！'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _handleBuy(BuildContext context, WidgetRef ref) async {
    try {
      final updated = item.copyWith(status: 'purchased');
      await ref.read(updateWishItemProvider(updated).future);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('已记录！'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
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

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.hourglass_empty,
            size: 16,
            color: AppColors.info,
          ),
          const SizedBox(width: 6),
          Text(
            '${hours}h ${minutes}m',
            style: const TextStyle(
              color: AppColors.info,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

