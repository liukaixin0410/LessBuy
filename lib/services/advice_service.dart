import '../models/wish_item.dart';
import '../models/inventory_item.dart';
import '../models/purchase_record.dart';

class AdviceResult {
  final String type;
  final String text;

  AdviceResult({required this.type, required this.text});
}

class AdviceService {
  AdviceResult generateAdvice({
    required WishItem wishItem,
    required List<InventoryItem> inventory,
    required List<PurchaseRecord> purchaseRecords,
  }) {
    final category = wishItem.category;

    final categoryInventory =
        inventory.where((item) => item.category == category).toList();
    final totalInventoryQuantity =
        categoryInventory.fold<double>(0, (sum, item) => sum + item.quantity);

    if (totalInventoryQuantity >= 3) {
      return AdviceResult(
        type: 'skip_buy',
        text: '库存中有 $totalInventoryQuantity 件同类商品，建议不要购买',
      );
    }

    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentPurchases = purchaseRecords
        .where((record) =>
            record.category == category &&
            record.orderTime != null &&
            record.orderTime!.isAfter(thirtyDaysAgo))
        .toList();

    if (recentPurchases.length >= 2) {
      return AdviceResult(
        type: 'cool_down',
        text: '近30天已购买 ${recentPurchases.length} 次同类商品，建议冷静一下',
      );
    }

    if (wishItem.reason == '情绪消费') {
      return AdviceResult(
        type: 'cool_down',
        text: '情绪消费需谨慎，建议24小时后再决定',
      );
    }

    return AdviceResult(
      type: 'buy_now',
      text: '目前库存充足且近期购买不多，可以购买',
    );
  }
}
