class CartItem {
  final String id;
  final String trashId;
  final String trashName;
  final String trashIcon;
  final int trashPrice;
  final int amount;
  final int subtotalEstimatedPrice;

  CartItem({
    required this.id,
    required this.trashId,
    required this.trashName,
    required this.trashIcon,
    required this.trashPrice,
    required this.amount,
    required this.subtotalEstimatedPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? '',
      trashId: json['trash_id'] ?? '',
      trashName: json['trash_name'] ?? '',
      trashIcon: json['trash_icon'] ?? '',
      trashPrice: json['trash_price'] ?? 0,
      amount: json['amount'] ?? 0,
      subtotalEstimatedPrice: json['subtotal_estimated_price'] ?? 0,
    );
  }

  CartItem copyWith({
    String? id,
    String? trashId,
    String? trashName,
    String? trashIcon,
    int? trashPrice,
    int? amount,
    int? subtotalEstimatedPrice,
  }) {
    return CartItem(
      id: id ?? this.id,
      trashId: trashId ?? this.trashId,
      trashName: trashName ?? this.trashName,
      trashIcon: trashIcon ?? this.trashIcon,
      trashPrice: trashPrice ?? this.trashPrice,
      amount: amount ?? this.amount,
      subtotalEstimatedPrice:
          subtotalEstimatedPrice ?? this.subtotalEstimatedPrice,
    );
  }
}

class Cart {
  final String id;
  final String userId;
  final int totalAmount;
  final int estimatedTotalPrice;
  final List<CartItem> cartItems;

  Cart({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.estimatedTotalPrice,
    required this.cartItems,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      totalAmount: json['total_amount'] ?? 0,
      estimatedTotalPrice: json['estimated_total_price'] ?? 0,
      cartItems:
          (json['cart_items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Cart copyWith({
    String? id,
    String? userId,
    int? totalAmount,
    int? estimatedTotalPrice,
    List<CartItem>? cartItems,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalAmount: totalAmount ?? this.totalAmount,
      estimatedTotalPrice: estimatedTotalPrice ?? this.estimatedTotalPrice,
      cartItems: cartItems ?? this.cartItems,
    );
  }
}

class AddCartRequest {
  final String trashId;
  final int amount;

  AddCartRequest({required this.trashId, required this.amount});

  Map<String, dynamic> toJson() {
    return {'trash_id': trashId, 'amount': amount};
  }
}
