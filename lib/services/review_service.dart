import '../models/review_stats.dart';
import '../models/wish_item.dart';

class ReviewService {
  ReviewStats generateStats(List<WishItem> wishItems) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    final weeklyItems = wishItems
        .where((item) => item.createdAt != null && item.createdAt!.isAfter(weekStart))
        .toList();

    final weeklyWishCount = weeklyItems.length;
    final weeklyPurchasedCount =
        weeklyItems.where((item) => item.status == 'purchased').length;
    final weeklySkippedCount =
        weeklyItems.where((item) => item.status == 'skipped').length;

    final coolingSkippedCount = wishItems
        .where((item) => item.status == 'skipped' && item.coolingEndTime != null)
        .length;

    final categoryStats = <String, int>{};
    for (var item in wishItems) {
      if (item.category != null) {
        categoryStats[item.category!] = (categoryStats[item.category!] ?? 0) + 1;
      }
    }

    double estimatedSavings = 0;
    for (var item in wishItems) {
      if (item.status == 'skipped' && item.itemPrice != null) {
        estimatedSavings += item.itemPrice!;
      }
    }

    return ReviewStats(
      weeklyWishCount: weeklyWishCount,
      weeklyPurchasedCount: weeklyPurchasedCount,
      weeklySkippedCount: weeklySkippedCount,
      coolingSkippedCount: coolingSkippedCount,
      categoryStats: categoryStats,
      estimatedSavings: estimatedSavings,
    );
  }
}
