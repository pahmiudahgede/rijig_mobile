import 'package:rijig_mobile/features/cart/model/cartitem_model.dart';
import 'package:rijig_mobile/features/cart/service/cartitem_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartRepository {
  final CartService _cartService = CartService();
  final String _localCartKey = 'local_cart';

  Future<List<CartItem>> getLocalCart() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localCartKey);
    if (raw == null || raw.isEmpty) return [];

    return CartItem.decodeList(raw);
  }

  Future<void> saveLocalCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = CartItem.encodeList(items);
    await prefs.setString(_localCartKey, encoded);
  }

  Future<void> clearLocalCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localCartKey);
  }

  Future<void> flushCartToServer() async {
    final items = await getLocalCart();
    if (items.isEmpty) return;

    await _cartService.postCart(items);
    await clearLocalCart();
  }

  Future<CartResponse> getCartFromServer() async {
    return await _cartService.getCart();
  }

  Future<void> commitCart() async {
    await _cartService.commitCart();
  }

  Future<void> clearServerCart() async {
    await _cartService.clearCart();
  }

  Future<void> deleteCartItemFromServer(String trashId) async {
    await _cartService.deleteCartItem(trashId);
  }

  Future<void> refreshCartTTL() async {
    await _cartService.refreshCartTTL();
  }
}
