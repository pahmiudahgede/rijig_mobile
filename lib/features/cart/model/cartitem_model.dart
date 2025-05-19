import 'dart:convert';

class CartItem {
  final String trashId;
  final double amount;

  CartItem({required this.trashId, required this.amount});

  Map<String, dynamic> toJson() => {'trashid': trashId, 'amount': amount};

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      trashId: json['trashid'],
      amount: (json['amount'] as num).toDouble(),
    );
  }

  static String encodeList(List<CartItem> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<CartItem> decodeList(String source) =>
      (jsonDecode(source) as List<dynamic>)
          .map((e) => CartItem.fromJson(e))
          .toList();
}

class CartItemResponse {
  final String trashId; 
  final String trashIcon;
  final String trashName;
  final double amount;
  final double estimatedSubTotalPrice;

  CartItemResponse({
    required this.trashId,
    required this.trashIcon,
    required this.trashName,
    required this.amount,
    required this.estimatedSubTotalPrice,
  });

  factory CartItemResponse.fromJson(Map<String, dynamic> json) {
    return CartItemResponse(
      trashId: json['trashid'], 
      trashIcon: json['trashicon'] ?? '',
      trashName: json['trashname'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      estimatedSubTotalPrice:
          (json['estimated_subtotalprice'] as num).toDouble(),
    );
  }
}

class CartResponse {
  final String id;
  final String userId;
  final double totalAmount;
  final double estimatedTotalPrice;
  final String createdAt;
  final String updatedAt;
  final List<CartItemResponse> cartItems;

  CartResponse({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.estimatedTotalPrice,
    required this.createdAt,
    required this.updatedAt,
    required this.cartItems,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    var items =
        (json['cartitems'] as List<dynamic>)
            .map((e) => CartItemResponse.fromJson(e))
            .toList();

    return CartResponse(
      id: json['id'],
      userId: json['userid'],
      totalAmount: (json['totalamount'] as num).toDouble(),
      estimatedTotalPrice: (json['estimated_totalprice'] as num).toDouble(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      cartItems: items,
    );
  }
}
