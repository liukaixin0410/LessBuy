class WishItem {
  final String? id;
  final String? userId;
  final String itemName;
  final String? itemImage;
  final double? itemPrice;
  final String? category;
  final String? reason;
  final String? aiAdviceType;
  final String? aiAdviceText;
  final String status;
  final DateTime? coolingEndTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WishItem({
    this.id,
    this.userId,
    required this.itemName,
    this.itemImage,
    this.itemPrice,
    this.category,
    this.reason,
    this.aiAdviceType,
    this.aiAdviceText,
    this.status = 'pending',
    this.coolingEndTime,
    this.createdAt,
    this.updatedAt,
  });

  WishItem copyWith({
    String? id,
    String? userId,
    String? itemName,
    String? itemImage,
    double? itemPrice,
    String? category,
    String? reason,
    String? aiAdviceType,
    String? aiAdviceText,
    String? status,
    DateTime? coolingEndTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WishItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemName: itemName ?? this.itemName,
      itemImage: itemImage ?? this.itemImage,
      itemPrice: itemPrice ?? this.itemPrice,
      category: category ?? this.category,
      reason: reason ?? this.reason,
      aiAdviceType: aiAdviceType ?? this.aiAdviceType,
      aiAdviceText: aiAdviceText ?? this.aiAdviceText,
      status: status ?? this.status,
      coolingEndTime: coolingEndTime ?? this.coolingEndTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'item_name': itemName,
      'item_image': itemImage,
      'item_price': itemPrice,
      'category': category,
      'reason': reason,
      'ai_advice_type': aiAdviceType,
      'ai_advice_text': aiAdviceText,
      'status': status,
      'cooling_end_time': coolingEndTime?.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory WishItem.fromJson(Map<String, dynamic> json) {
    return WishItem(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      itemName: json['item_name'] as String,
      itemImage: json['item_image'] as String?,
      itemPrice: (json['item_price'] as num?)?.toDouble(),
      category: json['category'] as String?,
      reason: json['reason'] as String?,
      aiAdviceType: json['ai_advice_type'] as String?,
      aiAdviceText: json['ai_advice_text'] as String?,
      status: json['status'] as String? ?? 'pending',
      coolingEndTime: json['cooling_end_time'] != null
          ? DateTime.parse(json['cooling_end_time'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
