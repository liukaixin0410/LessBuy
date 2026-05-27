import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/inventory_item.dart';
import '../../../models/wish_item.dart';
import '../../../models/review_stats.dart';
import '../../../services/mock_data_service.dart';
import '../../../services/advice_service.dart';

final inventoryProvider = FutureProvider<List<InventoryItem>>((ref) async {
  return await MockDataService.getInventoryItems();
});

final wishItemsProvider = FutureProvider<List<WishItem>>((ref) async {
  return await MockDataService.getWishItems();
});

final reviewStatsProvider = FutureProvider<ReviewStats>((ref) async {
  return await MockDataService.getReviewStats();
});

final addWishItemProvider = FutureProvider.family<WishItem, WishItem>((ref, item) async {
  final inventory = await MockDataService.getInventoryItems();
  final purchases = await MockDataService.getPurchaseRecords();

  final advice = AdviceService().generateAdvice(
    wishItem: item,
    inventory: inventory,
    purchaseRecords: purchases,
  );

  final wishItem = item.copyWith(
    aiAdviceType: advice.type,
    aiAdviceText: advice.text,
  );

  return await MockDataService.addWishItem(wishItem);
});

final updateWishItemProvider = FutureProvider.family<void, WishItem>((ref, item) async {
  await MockDataService.updateWishItem(item);
  ref.invalidate(wishItemsProvider);
  ref.invalidate(reviewStatsProvider);
});

final addInventoryItemProvider = FutureProvider.family<void, InventoryItem>((ref, item) async {
  await MockDataService.addInventoryItem(item);
  ref.invalidate(inventoryProvider);
});

final deleteInventoryItemProvider = FutureProvider.family<void, String>((ref, id) async {
  await MockDataService.deleteInventoryItem(id);
  ref.invalidate(inventoryProvider);
});
