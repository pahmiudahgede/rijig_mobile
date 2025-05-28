import 'package:flutter/material.dart';
import 'package:rijig_mobile/core/api/api_exception.dart';
import 'package:rijig_mobile/features/cart/model/trashcart_model.dart';
import 'package:rijig_mobile/features/cart/repositories/trashcart_repo.dart';

enum CartOperationResult { success, failed, networkError, unauthorized }

class CartOperationResponse {
  final CartOperationResult result;
  final String message;
  final dynamic data;

  CartOperationResponse({
    required this.result,
    required this.message,
    this.data,
  });

  bool get isSuccess => result == CartOperationResult.success;
  bool get isNetworkError => result == CartOperationResult.networkError;
  bool get isUnauthorized => result == CartOperationResult.unauthorized;
}

abstract class CartService {
  Future<CartOperationResponse> addOrUpdateItem(String trashId, int amount);
  Future<CartOperationResponse> getCartItems();
  Future<CartOperationResponse> deleteItem(String trashId);
  Future<CartOperationResponse> clearCart();
  Future<CartOperationResponse> incrementItemAmount(String trashId);
  Future<CartOperationResponse> decrementItemAmount(String trashId);
}

class CartServiceImpl implements CartService {
  final CartRepository _repository;

  CartServiceImpl({CartRepository? repository})
    : _repository = repository ?? CartRepositoryImpl();

  @override
  Future<CartOperationResponse> addOrUpdateItem(
    String trashId,
    int amount,
  ) async {
    try {
      if (amount <= 0) {
        return CartOperationResponse(
          result: CartOperationResult.failed,
          message: 'Jumlah item harus lebih dari 0',
        );
      }

      final request = AddOrUpdateCartRequest(trashId: trashId, amount: amount);

      final response = await _repository.addOrUpdateCartItem(request);

      if (response.isSuccess) {
        return CartOperationResponse(
          result: CartOperationResult.success,
          message: response.message,
          data: response.data,
        );
      } else {
        return CartOperationResponse(
          result: CartOperationResult.failed,
          message: response.message,
        );
      }
    } on ApiException catch (e) {
      debugPrint('CartService - addOrUpdateItem error: ${e.message}');

      if (e.statusCode == 401 || e.statusCode == 403) {
        return CartOperationResponse(
          result: CartOperationResult.unauthorized,
          message: 'Sesi Anda telah berakhir, silakan login kembali',
        );
      }

      return CartOperationResponse(
        result:
            e.statusCode >= 500
                ? CartOperationResult.networkError
                : CartOperationResult.failed,
        message: e.message,
      );
    } catch (e) {
      debugPrint('CartService - addOrUpdateItem unexpected error: $e');
      return CartOperationResponse(
        result: CartOperationResult.networkError,
        message: 'Terjadi kesalahan jaringan, silakan coba lagi',
      );
    }
  }

  @override
  Future<CartOperationResponse> getCartItems() async {
    try {
      final cart = await _repository.getCartItems();

      return CartOperationResponse(
        result: CartOperationResult.success,
        message: 'Berhasil mengambil data keranjang',
        data: cart,
      );
    } on ApiException catch (e) {
      debugPrint('CartService - getCartItems error: ${e.message}');

      if (e.statusCode == 401 || e.statusCode == 403) {
        return CartOperationResponse(
          result: CartOperationResult.unauthorized,
          message: 'Sesi Anda telah berakhir, silakan login kembali',
        );
      }

      return CartOperationResponse(
        result:
            e.statusCode >= 500
                ? CartOperationResult.networkError
                : CartOperationResult.failed,
        message: e.message,
      );
    } catch (e) {
      debugPrint('CartService - getCartItems unexpected error: $e');
      return CartOperationResponse(
        result: CartOperationResult.networkError,
        message: 'Terjadi kesalahan jaringan, silakan coba lagi',
      );
    }
  }

  @override
  Future<CartOperationResponse> deleteItem(String trashId) async {
    try {
      final response = await _repository.deleteCartItem(trashId);

      if (response.isSuccess) {
        return CartOperationResponse(
          result: CartOperationResult.success,
          message: response.message,
        );
      } else {
        return CartOperationResponse(
          result: CartOperationResult.failed,
          message: response.message,
        );
      }
    } on ApiException catch (e) {
      debugPrint('CartService - deleteItem error: ${e.message}');

      if (e.statusCode == 401 || e.statusCode == 403) {
        return CartOperationResponse(
          result: CartOperationResult.unauthorized,
          message: 'Sesi Anda telah berakhir, silakan login kembali',
        );
      }

      return CartOperationResponse(
        result:
            e.statusCode >= 500
                ? CartOperationResult.networkError
                : CartOperationResult.failed,
        message: e.message,
      );
    } catch (e) {
      debugPrint('CartService - deleteItem unexpected error: $e');
      return CartOperationResponse(
        result: CartOperationResult.networkError,
        message: 'Terjadi kesalahan jaringan, silakan coba lagi',
      );
    }
  }

  @override
  Future<CartOperationResponse> clearCart() async {
    try {
      final response = await _repository.clearCart();

      if (response.isSuccess) {
        return CartOperationResponse(
          result: CartOperationResult.success,
          message: response.message,
        );
      } else {
        return CartOperationResponse(
          result: CartOperationResult.failed,
          message: response.message,
        );
      }
    } on ApiException catch (e) {
      debugPrint('CartService - clearCart error: ${e.message}');

      if (e.statusCode == 401 || e.statusCode == 403) {
        return CartOperationResponse(
          result: CartOperationResult.unauthorized,
          message: 'Sesi Anda telah berakhir, silakan login kembali',
        );
      }

      return CartOperationResponse(
        result:
            e.statusCode >= 500
                ? CartOperationResult.networkError
                : CartOperationResult.failed,
        message: e.message,
      );
    } catch (e) {
      debugPrint('CartService - clearCart unexpected error: $e');
      return CartOperationResponse(
        result: CartOperationResult.networkError,
        message: 'Terjadi kesalahan jaringan, silakan coba lagi',
      );
    }
  }

  @override
  Future<CartOperationResponse> incrementItemAmount(String trashId) async {
    try {
      final cartResponse = await getCartItems();
      if (!cartResponse.isSuccess) {
        return cartResponse;
      }

      final cart = cartResponse.data as Cart;
      final item = cart.cartItems.firstWhere(
        (item) => item.trashId == trashId,
        orElse: () => throw Exception('Item tidak ditemukan di keranjang'),
      );

      return await addOrUpdateItem(trashId, item.amount + 1);
    } catch (e) {
      debugPrint('CartService - incrementItemAmount error: $e');
      return CartOperationResponse(
        result: CartOperationResult.failed,
        message: 'Gagal menambah jumlah item',
      );
    }
  }

  @override
  Future<CartOperationResponse> decrementItemAmount(String trashId) async {
    try {
      final cartResponse = await getCartItems();
      if (!cartResponse.isSuccess) {
        return cartResponse;
      }

      final cart = cartResponse.data as Cart;
      final item = cart.cartItems.firstWhere(
        (item) => item.trashId == trashId,
        orElse: () => throw Exception('Item tidak ditemukan di keranjang'),
      );

      if (item.amount <= 1) {
        return await deleteItem(trashId);
      }

      return await addOrUpdateItem(trashId, item.amount - 1);
    } catch (e) {
      debugPrint('CartService - decrementItemAmount error: $e');
      return CartOperationResponse(
        result: CartOperationResult.failed,
        message: 'Gagal mengurangi jumlah item',
      );
    }
  }
}

class CartServiceProvider {
  static CartService? _instance;

  static CartService get instance {
    _instance ??= CartServiceImpl();
    return _instance!;
  }

  static void setInstance(CartService service) {
    _instance = service;
  }
}
