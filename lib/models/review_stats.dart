class ReviewStats {
  final int weeklyWishCount;
  final int weeklyPurchasedCount;
  final int weeklySkippedCount;
  final int coolingSkippedCount;
  final Map<String, int> categoryStats;
  final double estimatedSavings;

  ReviewStats({
    required this.weeklyWishCount,
    required this.weeklyPurchasedCount,
    required this.weeklySkippedCount,
    required this.coolingSkippedCount,
    required this.categoryStats,
    required this.estimatedSavings,
  });
}
