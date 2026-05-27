class OcrParsedItem {
  final String? platform;
  final DateTime? orderTime;
  final String itemName;
  final double quantity;
  final double? amount;
  final String? category;
  final String? rawText;

  OcrParsedItem({
    this.platform,
    this.orderTime,
    required this.itemName,
    this.quantity = 1,
    this.amount,
    this.category,
    this.rawText,
  });

  OcrParsedItem copyWith({
    String? platform,
    DateTime? orderTime,
    String? itemName,
    double? quantity,
    double? amount,
    String? category,
    String? rawText,
  }) {
    return OcrParsedItem(
      platform: platform ?? this.platform,
      orderTime: orderTime ?? this.orderTime,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      rawText: rawText ?? this.rawText,
    );
  }
}
