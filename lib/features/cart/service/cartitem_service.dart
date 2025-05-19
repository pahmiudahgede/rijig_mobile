import 'package:rijig_mobile/core/api/api_services.dart';
import 'package:rijig_mobile/features/cart/model/cartitem_model.dart';

class CartService {
  final Https _https = Https();

  Future<void> postCart(List<CartItem> items) async {
    final body = {"items": items.map((e) => e.toJson()).toList()};

    await _https.post("/cart", body: body);
  }

  Future<CartResponse> getCart() async {
    final response = await _https.get("/cart");
    return CartResponse.fromJson(response['data']);
  }

  Future<void> deleteCartItem(String trashId) async {
    await _https.delete("/cart/$trashId");
  }

  Future<void> clearCart() async {
    await _https.delete("/cart");
  }

  Future<void> refreshCartTTL() async {
    await _https.put("/cart/refresh");
  }

  Future<void> commitCart() async {
    await _https.post("/cart/commit");
  }
}
