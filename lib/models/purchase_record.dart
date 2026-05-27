class PurchaseRecord {
  final String? id;
  final String? userId;
  final String? platform;
  final DateTime? orderTime;
  final String itemName;
  final double quantity;
  final double? amount;
  final String? category;
  final String sourceType;
  final String? rawText;
  final String? imageUrl;
  final DateTime? createdAt;

  PurchaseRecord({
    this.id,
    this.userId,
    this.platform,
    this.orderTime,
    required this.itemName,
    this.quantity = 1,
    this.amount,
    this.category,
    this.sourceType = 'screenshot',
    this.rawText,
    this.imageUrl,
    this.createdAt,
  });

  PurchaseRecord copyWith({
    String? id,
    String? userId,
    String? platform,
    DateTime? orderTime,
    String? itemName,
    double? quantity,
    double? amount,
    String? category,
    String? sourceType,
    String? rawText,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return PurchaseRecord(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      platform: platform ?? this.platform,
      orderTime: orderTime ?? this.orderTime,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      sourceType: sourceType ?? this.sourceType,
      rawText: rawText ?? this.rawText,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'platform': platform,
      'order_time': orderTime?.toIso8601String(),
      'item_name': itemName,
      'quantity': quantity,
      'amount': amount,
      'category': category,
      'source_type': sourceType,
      'raw_text': rawText,
      'image_url': imageUrl,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
    };
  }

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) {
    return PurchaseRecord(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      platform: json['platform'] as String?,
      orderTime: json['order_time'] != null
          ? DateTime.parse(json['order_time'] as String)
          : null,
      itemName: json['item_name'] as String,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      amount: (json['amount'] as num?)?.toDouble(),
      category: json['category'] as String?,
      sourceType: json['source_type'] as String? ?? 'screenshot',
      rawText: json['raw_text'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
