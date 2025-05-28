import 'package:flutter/material.dart';
import 'package:rijig_mobile/features/cart/model/trashcart_model.dart';
import 'package:rijig_mobile/features/cart/service/trashcart_service.dart';

enum CartState { initial, loading, loaded, error, empty, updating }

class CartViewModel extends ChangeNotifier {
  final CartService _cartService;

  CartViewModel({CartService? cartService})
    : _cartService = cartService ?? CartServiceProvider.instance;

  CartState _state = CartState.initial;
  Cart? _cart;
  String _errorMessage = '';
  bool _isOperationInProgress = false;

  CartState get state => _state;
  Cart? get cart => _cart;
  String get errorMessage => _errorMessage;
  bool get isOperationInProgress => _isOperationInProgress;

  List<CartItem> get cartItems => _cart?.cartItems ?? [];
  int get totalItems => _cart?.totalAmount ?? 0;
  double get totalPrice => _cart?.estimatedTotalPrice ?? 0.0;
  bool get isEmpty => cartItems.isEmpty;
  bool get isNotEmpty => cartItems.isNotEmpty;

  void _setState(CartState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(CartState.error);
  }

  void _setOperationInProgress(bool inProgress) {
    _isOperationInProgress = inProgress;
    notifyListeners();
  }

  Future<void> loadCartItems({bool showLoading = true}) async {
    if (showLoading) {
      _setState(CartState.loading);
    }

    try {
      final response = await _cartService.getCartItems();

      if (response.isSuccess && response.data != null) {
        _cart = response.data as Cart;
        _setState(_cart!.isEmpty ? CartState.empty : CartState.loaded);
      } else if (response.isUnauthorized) {
        _setError('Sesi Anda telah berakhir, silakan login kembali');
      } else {
        _setError(response.message);
      }
    } catch (e) {
      debugPrint('CartViewModel - loadCartItems error: $e');
      _setError('Terjadi kesalahan tidak terduga');
    }
  }

  Future<bool> addOrUpdateItem(
    String trashId,
    int amount, {
    bool showUpdating = true,
  }) async {
    if (showUpdating) {
      _setOperationInProgress(true);
    }

    try {
      final response = await _cartService.addOrUpdateItem(trashId, amount);

      if (response.isSuccess) {
        await loadCartItems(showLoading: false);
        return true;
      } else {
        if (response.isUnauthorized) {
          _setError('Sesi Anda telah berakhir, silakan login kembali');
        } else {
          _setError(response.message);
        }
        return false;
      }
    } catch (e) {
      debugPrint('CartViewModel - addOrUpdateItem error: $e');
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    } finally {
      if (showUpdating) {
        _setOperationInProgress(false);
      }
    }
  }

  Future<bool> deleteItem(String trashId, {bool showUpdating = true}) async {
    if (showUpdating) {
      _setOperationInProgress(true);
    }

    try {
      final response = await _cartService.deleteItem(trashId);

      if (response.isSuccess) {
        await loadCartItems(showLoading: false);
        return true;
      } else {
        if (response.isUnauthorized) {
          _setError('Sesi Anda telah berakhir, silakan login kembali');
        } else {
          _setError(response.message);
        }
        return false;
      }
    } catch (e) {
      debugPrint('CartViewModel - deleteItem error: $e');
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    } finally {
      if (showUpdating) {
        _setOperationInProgress(false);
      }
    }
  }

  Future<bool> clearCart({bool showUpdating = true}) async {
    if (showUpdating) {
      _setOperationInProgress(true);
    }

    try {
      final response = await _cartService.clearCart();

      if (response.isSuccess) {
        await loadCartItems(showLoading: false);
        return true;
      } else {
        if (response.isUnauthorized) {
          _setError('Sesi Anda telah berakhir, silakan login kembali');
        } else {
          _setError(response.message);
        }
        return false;
      }
    } catch (e) {
      debugPrint('CartViewModel - clearCart error: $e');
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    } finally {
      if (showUpdating) {
        _setOperationInProgress(false);
      }
    }
  }

  Future<bool> incrementItemAmount(String trashId) async {
    _setOperationInProgress(true);

    try {
      final response = await _cartService.incrementItemAmount(trashId);

      if (response.isSuccess) {
        await loadCartItems(showLoading: false);
        return true;
      } else {
        if (response.isUnauthorized) {
          _setError('Sesi Anda telah berakhir, silakan login kembali');
        } else {
          _setError(response.message);
        }
        return false;
      }
    } catch (e) {
      debugPrint('CartViewModel - incrementItemAmount error: $e');
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    } finally {
      _setOperationInProgress(false);
    }
  }

  Future<bool> decrementItemAmount(String trashId) async {
    _setOperationInProgress(true);

    try {
      final response = await _cartService.decrementItemAmount(trashId);

      if (response.isSuccess) {
        await loadCartItems(showLoading: false);
        return true;
      } else {
        if (response.isUnauthorized) {
          _setError('Sesi Anda telah berakhir, silakan login kembali');
        } else {
          _setError(response.message);
        }
        return false;
      }
    } catch (e) {
      debugPrint('CartViewModel - decrementItemAmount error: $e');
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    } finally {
      _setOperationInProgress(false);
    }
  }

  CartItem? getItemByTrashId(String trashId) {
    try {
      return cartItems.firstWhere((item) => item.trashId == trashId);
    } catch (e) {
      return null;
    }
  }

  bool isItemInCart(String trashId) {
    return getItemByTrashId(trashId) != null;
  }

  int getItemAmount(String trashId) {
    final item = getItemByTrashId(trashId);
    return item?.amount ?? 0;
  }

  double getItemSubtotal(String trashId) {
    final item = getItemByTrashId(trashId);
    return item?.subtotalEstimatedPrice ?? 0.0;
  }

  void clearError() {
    if (_state == CartState.error) {
      _errorMessage = '';
      _setState(
        _cart == null || _cart!.isEmpty ? CartState.empty : CartState.loaded,
      );
    }
  }

  Future<void> refresh() async {
    await loadCartItems(showLoading: true);
  }

//   Future<void> refresh() async {
//   await loadCartItems(showLoading: false);
//   notifyListeners();
// }

  // @override
  // void dispose() {
  //   super.dispose();
  // }
}

extension CartViewModelExtension on CartViewModel {
  String get formattedTotalPrice {
    return 'Rp ${totalPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String getFormattedItemPrice(String trashId) {
    final item = getItemByTrashId(trashId);
    if (item == null) return 'Rp 0';

    return 'Rp ${item.trashPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String getFormattedItemSubtotal(String trashId) {
    final item = getItemByTrashId(trashId);
    if (item == null) return 'Rp 0';

    return 'Rp ${item.subtotalEstimatedPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }
}
