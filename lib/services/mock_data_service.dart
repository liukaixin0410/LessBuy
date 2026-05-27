import '../models/purchase_record.dart';
import '../models/inventory_item.dart';
import '../models/wish_item.dart';
import '../models/review_stats.dart';

class MockDataService {
  static final List<PurchaseRecord> _purchaseRecords = [
    PurchaseRecord(
      id: '1',
      userId: 'mock-user-id',
      platform: '淘宝',
      orderTime: DateTime.now().subtract(const Duration(days: 5)),
      itemName: '牛奶 250ml*12盒',
      quantity: 2,
      amount: 69.9,
      category: '食品',
    ),
    PurchaseRecord(
      id: '2',
      userId: 'mock-user-id',
      platform: '京东',
      orderTime: DateTime.now().subtract(const Duration(days: 10)),
      itemName: '洗衣液 2L',
      quantity: 1,
      amount: 39.9,
      category: '日用品',
    ),
  ];

  static final List<InventoryItem> _inventoryItems = [
    InventoryItem(
      id: '1',
      userId: 'mock-user-id',
      itemName: '牛奶',
      category: '食品',
      quantity: 3,
      status: 'enough',
      lastPurchaseTime: DateTime.now().subtract(const Duration(days: 5)),
    ),
    InventoryItem(
      id: '2',
      userId: 'mock-user-id',
      itemName: '洗衣液',
      category: '日用品',
      quantity: 1,
      status: 'low',
      lastPurchaseTime: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  static final List<WishItem> _wishItems = [
    WishItem(
      id: '1',
      userId: 'mock-user-id',
      itemName: '耳机',
      category: '电子产品',
      itemPrice: 299.0,
      reason: '觉得好看',
      aiAdviceType: 'buy_now',
      aiAdviceText: '库存中没有同类产品，可以购买！',
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    WishItem(
      id: '2',
      userId: 'mock-user-id',
      itemName: '巧克力',
      category: '食品',
      itemPrice: 89.0,
      reason: '情绪消费',
      aiAdviceType: 'cool_down',
      aiAdviceText: '你刚买了很多零食，建议冷静 24 小时再决定！',
      status: 'cooling',
      coolingEndTime: DateTime.now().add(const Duration(hours: 20)),
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];

  static Future<List<PurchaseRecord>> getPurchaseRecords() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_purchaseRecords);
  }

  static Future<void> addPurchaseRecord(PurchaseRecord record) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _purchaseRecords.insert(0, record.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  static Future<void> addPurchaseRecords(List<PurchaseRecord> records) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _purchaseRecords.insertAll(0, records);
  }

  static Future<List<InventoryItem>> getInventoryItems() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_inventoryItems);
  }

  static Future<void> addInventoryItem(InventoryItem item) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _inventoryItems.insert(0, item.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  static Future<void> updateInventoryItem(InventoryItem item) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _inventoryItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _inventoryItems[index] = item;
    }
  }

  static Future<void> deleteInventoryItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _inventoryItems.removeWhere((item) => item.id == id);
  }

  static Future<List<WishItem>> getWishItems() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_wishItems);
  }

  static Future<List<WishItem>> getWishItemsByStatus(String status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _wishItems.where((item) => item.status == status).toList();
  }

  static Future<WishItem> addWishItem(WishItem item) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newItem = item.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
    _wishItems.insert(0, newItem);
    return newItem;
  }

  static Future<void> updateWishItem(WishItem item) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _wishItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _wishItems[index] = item;
    }
  }

  static Future<void> deleteWishItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _wishItems.removeWhere((item) => item.id == id);
  }

  static Future<ReviewStats> getReviewStats() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final weekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
    final weeklyWishes = _wishItems.where((item) => item.createdAt != null && item.createdAt!.isAfter(weekStart)).toList();
    final purchasedCount = weeklyWishes.where((item) => item.status == 'purchased').length;
    final skippedCount = weeklyWishes.where((item) => item.status == 'skipped').length;
    final coolingSkipped = _wishItems.where((item) => item.status == 'skipped' && item.coolingEndTime != null).length;

    final categoryStats = <String, int>{};
    for (var item in _wishItems) {
      if (item.category != null) {
        categoryStats[item.category!] = (categoryStats[item.category!] ?? 0) + 1;
      }
    }

    double estimatedSavings = 0;
    for (var item in _wishItems) {
      if (item.status == 'skipped' && item.itemPrice != null) {
        estimatedSavings += item.itemPrice!;
      }
    }

    return ReviewStats(
      weeklyWishCount: weeklyWishes.length,
      weeklyPurchasedCount: purchasedCount,
      weeklySkippedCount: skippedCount,
      coolingSkippedCount: coolingSkipped,
      categoryStats: categoryStats,
      estimatedSavings: estimatedSavings + 500,
    );
  }
}
