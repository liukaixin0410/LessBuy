import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 24),
            const Text(
              '快捷操作',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.add_photo_alternate, color: Colors.green),
                title: const Text('导入订单截图'),
                subtitle: const Text('识别订单并添加到记录'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UploadPage()),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.add_shopping_cart, color: Colors.blue),
                title: const Text('记录想买的东西'),
                subtitle: const Text('获得 AI 购买建议'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WishInputPage()),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '最近想买',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            wishItemsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('加载失败: $error'),
              data: (wishItems) => wishItems.isEmpty
                  ? const Center(child: Text('暂无记录'))
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: wishItems.take(3).length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = wishItems[index];
                        return ListTile(
                          title: Text(item.itemName),
                          subtitle: Text('${item.category ?? '未分类'} · ${item.reason ?? ''}'),
                          trailing: _StatusChip(item.status),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
