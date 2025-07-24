import 'package:rijig_mobile/core/api/api_client.dart';
import 'package:rijig_mobile/core/api/api_response.dart';
import 'package:rijig_mobile/features/cart/model/trashcart_model.dart';

class CartRepository {
  final ApiClient _apiClient;

  CartRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<void> addOrUpdateCartItem({
    required String trashId,
    required int amount,
  }) async {
    try {
      final request = AddCartRequest(trashId: trashId, amount: amount);
      final ApiResponse response = await _apiClient.post(
        '/cart/item',
        body: request.toJson(),
      );
      
      if (!response.isSuccess) {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('Failed to add/update cart item: $e');
    }
  }

  Future<Cart> getCartItems() async {
    try {
      final ApiResponse response = await _apiClient.get('/cart');
      
      if (response.isSuccess && response.data != null) {
        return Cart.fromJson(response.data['data']);
      }
      
      throw Exception(response.message);
    } catch (e) {
      throw Exception('Failed to get cart items: $e');
    }
  }

  Future<void> deleteCartItem(String trashId) async {
    try {
      final ApiResponse response = await _apiClient.delete('/cart/item/$trashId');
      
      if (!response.isSuccess) {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('Failed to delete cart item: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      final ApiResponse response = await _apiClient.delete('/cart/clear');
      
      if (!response.isSuccess) {
        throw Exception(response.message);
      }
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }
}