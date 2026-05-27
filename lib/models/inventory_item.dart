class InventoryItem {
  final String? id;
  final String? userId;
  final String itemName;
  final String? category;
  final double quantity;
  final DateTime? lastPurchaseTime;
  final String status;
  final String sourceType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InventoryItem({
    this.id,
    this.userId,
    required this.itemName,
    this.category,
    this.quantity = 1,
    this.lastPurchaseTime,
    this.status = 'enough',
    this.sourceType = 'manual',
    this.createdAt,
    this.updatedAt,
  });

  InventoryItem copyWith({
    String? id,
    String? userId,
    String? itemName,
    String? category,
    double? quantity,
    DateTime? lastPurchaseTime,
    String? status,
    String? sourceType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      lastPurchaseTime: lastPurchaseTime ?? this.lastPurchaseTime,
      status: status ?? this.status,
      sourceType: sourceType ?? this.sourceType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'item_name': itemName,
      'category': category,
      'quantity': quantity,
      'last_purchase_time': lastPurchaseTime?.toIso8601String(),
      'status': status,
      'source_type': sourceType,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      itemName: json['item_name'] as String,
      category: json['category'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
      lastPurchaseTime: json['last_purchase_time'] != null
          ? DateTime.parse(json['last_purchase_time'] as String)
          : null,
      status: json['status'] as String? ?? 'enough',
      sourceType: json['source_type'] as String? ?? 'manual',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
