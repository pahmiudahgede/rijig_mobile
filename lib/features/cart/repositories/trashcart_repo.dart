import 'package:rijig_mobile/core/api/api_exception.dart';
import 'package:rijig_mobile/core/api/api_services.dart';
import 'package:rijig_mobile/features/cart/model/trashcart_model.dart';

abstract class CartRepository {
  Future<CartApiResponse<dynamic>> addOrUpdateCartItem(
    AddOrUpdateCartRequest request,
  );
  Future<Cart> getCartItems();
  Future<CartApiResponse<dynamic>> deleteCartItem(String trashId);
  Future<CartApiResponse<dynamic>> clearCart();
}

class CartRepositoryImpl implements CartRepository {
  final Https _https = Https();

  static const String _cartEndpoint = '/cart';
  static const String _cartItemEndpoint = '/cart/item';
  static const String _cartClearEndpoint = '/cart/clear';

  @override
  Future<CartApiResponse<dynamic>> addOrUpdateCartItem(
    AddOrUpdateCartRequest request,
  ) async {
    try {
      final response = await _https.post(
        _cartItemEndpoint,
        body: request.toJson(),
      );

      return CartApiResponse<dynamic>.fromJson(response, null);
    } on ApiException catch (e) {
      throw ApiException(e.message, e.statusCode);
    } catch (e) {
      throw ApiException(
        'Unexpected error occurred while adding/updating cart item',
        500,
      );
    }
  }

  @override
  Future<Cart> getCartItems() async {
    try {
      final response = await _https.get(_cartEndpoint);

      final cartResponse = CartApiResponse<Cart>.fromJson(
        response,
        (json) => Cart.fromJson(json),
      );

      if (!cartResponse.isSuccess) {
        throw ApiException(cartResponse.message, cartResponse.status);
      }

      return cartResponse.data ??
          Cart(
            id: '',
            userId: '',
            totalAmount: 0,
            estimatedTotalPrice: 0.0,
            cartItems: [],
          );
    } on ApiException catch (e) {
      throw ApiException(e.message, e.statusCode);
    } catch (e) {
      throw ApiException(
        'Unexpected error occurred while fetching cart items',
        500,
      );
    }
  }

  @override
  Future<CartApiResponse<dynamic>> deleteCartItem(String trashId) async {
    try {
      final response = await _https.delete('$_cartItemEndpoint/$trashId');

      return CartApiResponse<dynamic>.fromJson(response, null);
    } on ApiException catch (e) {
      throw ApiException(e.message, e.statusCode);
    } catch (e) {
      throw ApiException(
        'Unexpected error occurred while deleting cart item',
        500,
      );
    }
  }

  @override
  Future<CartApiResponse<dynamic>> clearCart() async {
    try {
      final response = await _https.delete(_cartClearEndpoint);

      return CartApiResponse<dynamic>.fromJson(response, null);
    } on ApiException catch (e) {
      throw ApiException(e.message, e.statusCode);
    } catch (e) {
      throw ApiException('Unexpected error occurred while clearing cart', 500);
    }
  }
}

class MockCartRepository implements CartRepository {
  static final List<CartItem> _mockCartItems = [];

  @override
  Future<CartApiResponse<dynamic>> addOrUpdateCartItem(
    AddOrUpdateCartRequest request,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final existingIndex = _mockCartItems.indexWhere(
      (item) => item.trashId == request.trashId,
    );

    if (existingIndex != -1) {
      final existingItem = _mockCartItems[existingIndex];
      _mockCartItems[existingIndex] = existingItem.copyWith(
        amount: request.amount,
        subtotalEstimatedPrice: existingItem.trashPrice * request.amount,
      );
    } else {
      _mockCartItems.add(
        CartItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          trashId: request.trashId,
          trashName: 'Mock Trash Item',
          trashIcon: '/mock/icon.png',
          trashPrice: 1200.0,
          amount: request.amount,
          subtotalEstimatedPrice: 1200.0 * request.amount,
        ),
      );
    }

    return CartApiResponse<dynamic>(
      status: 200,
      message: 'Berhasil menambah/mengubah item keranjang',
    );
  }

  @override
  Future<Cart> getCartItems() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final totalAmount = _mockCartItems.fold<int>(
      0,
      (sum, item) => sum + item.amount,
    );

    final estimatedTotalPrice = _mockCartItems.fold<double>(
      0.0,
      (sum, item) => sum + item.subtotalEstimatedPrice,
    );

    return Cart(
      id: 'mock_cart_id',
      userId: 'mock_user_id',
      totalAmount: totalAmount,
      estimatedTotalPrice: estimatedTotalPrice,
      cartItems: List.from(_mockCartItems),
    );
  }

  @override
  Future<CartApiResponse<dynamic>> deleteCartItem(String trashId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _mockCartItems.removeWhere((item) => item.trashId == trashId);

    return CartApiResponse<dynamic>(
      status: 200,
      message: 'Berhasil menghapus item dari keranjang',
    );
  }

  @override
  Future<CartApiResponse<dynamic>> clearCart() async {
    await Future.delayed(const Duration(milliseconds: 300));

    _mockCartItems.clear();

    return CartApiResponse<dynamic>(
      status: 200,
      message: 'Berhasil mengosongkan keranjang',
    );
  }
}
