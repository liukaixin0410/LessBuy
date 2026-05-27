import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme.dart';
import '../providers/data_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../wish/pages/wish_input_page.dart';
import '../../import_order/pages/upload_page.dart';
import '../../inventory/pages/inventory_page.dart';
import '../../wish/pages/cooling_page.dart';
import '../../review/pages/review_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  final _pages = const [
    _HomeTab(),
    InventoryPage(),
    CoolingPage(),
    ReviewPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('断舍离消费助手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: '库存'),
          BottomNavigationBarItem(icon: Icon(Icons.hourglass_empty), label: '冷静期'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '复盘'),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出？'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(signOutProvider)();
              if (mounted) Navigator.pop(context);
            },
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(reviewStatsProvider);
    final wishItemsAsync = ref.watch(wishItemsProvider);

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('加载失败: $error')),
      data: (stats) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                const _StatCard(
                  title: '当前库存',
                  value: '2',
                  icon: Icons.inventory,
                  color: Colors.green,
                ),
                const _StatCard(
                  title: '待决策',
                  value: '2',
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
                _StatCard(
                  title: '本周避免购买',
                  value: stats.weeklySkippedCount.toString(),
                  icon: Icons.block,
                  color: Colors.red,
                ),
                _StatCard(
                  title: '预计节省',
                  value: '¥${stats.estimatedSavings.toStringAsFixed(0)}',
                  icon: Icons.savings,
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              '快捷操作',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _QuickActionCard(
              icon: Icons.add_photo_alternate_outlined,
              title: '导入订单截图',
              subtitle: '识别订单并添加到记录',
              color: AppColors.primary,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UploadPage()),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _QuickActionCard(
              icon: Icons.add_shopping_cart_outlined,
              title: '记录想买的东西',
              subtitle: '获得 AI 购买建议',
              color: AppColors.info,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WishInputPage()),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '最近想买',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.findAncestorStateOfType<_HomePageState>()?.setState(() {
                      context.findAncestorStateOfType<_HomePageState>()?._currentIndex = 2;
                    });
                  },
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            wishItemsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('加载失败: $error'),
              data: (wishItems) => wishItems.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        boxShadow: AppShadows.card,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 56,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            '还没有想买的东西~',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: wishItems.take(5).length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final item = wishItems[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            boxShadow: AppShadows.card,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(item.category).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getCategoryIcon(item.category),
                                color: _getCategoryColor(item.category),
                                size: 24,
                              ),
                            ),
                            title: Text(
                              item.itemName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  '${item.category ?? '未分类'} · ${item.reason ?? ''}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (item.estimatedPrice != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                                    child: Text(
                                      '预算: ¥${item.estimatedPrice!.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: _StatusChip(item.status),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('查看: ${item.itemName}')),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = '待决策';
      case 'cooling':
        color = Colors.blue;
        label = '冷静中';
      case 'purchased':
        color = Colors.green;
        label = '已购买';
      case 'skipped':
        color = Colors.red;
        label = '已放弃';
      default:
        color = Colors.grey;
        label = status;
    }
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
    );
  }
}

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

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
