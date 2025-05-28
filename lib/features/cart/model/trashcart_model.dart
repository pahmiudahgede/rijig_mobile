class CartItem {
  final String id;
  final String trashId;
  final String trashName;
  final String trashIcon;
  final double trashPrice;
  final int amount;
  final double subtotalEstimatedPrice;

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
      trashPrice: (json['trash_price'] ?? 0).toDouble(),
      amount: json['amount'] ?? 0,
      subtotalEstimatedPrice:
          (json['subtotal_estimated_price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trash_id': trashId,
      'trash_name': trashName,
      'trash_icon': trashIcon,
      'trash_price': trashPrice,
      'amount': amount,
      'subtotal_estimated_price': subtotalEstimatedPrice,
    };
  }

  CartItem copyWith({
    String? id,
    String? trashId,
    String? trashName,
    String? trashIcon,
    double? trashPrice,
    int? amount,
    double? subtotalEstimatedPrice,
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

  @override
  String toString() {
    return 'CartItem(id: $id, trashId: $trashId, trashName: $trashName, amount: $amount, subtotalEstimatedPrice: $subtotalEstimatedPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem && other.trashId == trashId;
  }

  @override
  int get hashCode => trashId.hashCode;
}

class Cart {
  final String id;
  final String userId;
  final int totalAmount;
  final double estimatedTotalPrice;
  final List<CartItem> cartItems;

  Cart({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.estimatedTotalPrice,
    required this.cartItems,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return Cart(
      id: data['id'] ?? '',
      userId: data['user_id'] ?? '',
      totalAmount: data['total_amount'] ?? 0,
      estimatedTotalPrice: (data['estimated_total_price'] ?? 0).toDouble(),
      cartItems:
          (data['cart_items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'id': id,
        'user_id': userId,
        'total_amount': totalAmount,
        'estimated_total_price': estimatedTotalPrice,
        'cart_items': cartItems.map((item) => item.toJson()).toList(),
      },
    };
  }

  Cart copyWith({
    String? id,
    String? userId,
    int? totalAmount,
    double? estimatedTotalPrice,
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

  bool get isEmpty => cartItems.isEmpty;
  bool get isNotEmpty => cartItems.isNotEmpty;

  @override
  String toString() {
    return 'Cart(id: $id, userId: $userId, totalAmount: $totalAmount, estimatedTotalPrice: $estimatedTotalPrice, cartItems: ${cartItems.length})';
  }
}

class AddOrUpdateCartRequest {
  final String trashId;
  final int amount;

  AddOrUpdateCartRequest({required this.trashId, required this.amount});

  Map<String, dynamic> toJson() {
    return {'trash_id': trashId, 'amount': amount};
  }

  @override
  String toString() {
    return 'AddOrUpdateCartRequest(trashId: $trashId, amount: $amount)';
  }
}

class CartApiResponse<T> {
  final int status;
  final String message;
  final T? data;

  CartApiResponse({required this.status, required this.message, this.data});

  factory CartApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return CartApiResponse<T>(
      status: json['meta']?['status'] ?? 0,
      message: json['meta']?['message'] ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json) : null,
    );
  }

  bool get isSuccess => status >= 200 && status < 300;
}
