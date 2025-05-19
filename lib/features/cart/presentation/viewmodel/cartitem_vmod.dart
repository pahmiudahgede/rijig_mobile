import 'package:flutter/material.dart';
import 'package:rijig_mobile/features/cart/model/cartitem_model.dart';
import 'package:rijig_mobile/features/cart/repositories/cartitem_repo.dart';

class CartViewModel extends ChangeNotifier {
  final CartRepository _repository;
  CartViewModel(this._repository);
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadLocalCart() async {
    _isLoading = true;
    notifyListeners();

    _cartItems = await _repository.getLocalCart();

    _isLoading = false;
    notifyListeners();
  }

  void addOrUpdateItem(CartItem item) {
    final index = _cartItems.indexWhere((e) => e.trashId == item.trashId);
    if (index != -1) {
      _cartItems[index] = item;
    } else {
      _cartItems.add(item);
    }
    _repository.saveLocalCart(_cartItems);
    notifyListeners();
  }

  void removeItem(String trashId) {
    _cartItems.removeWhere((e) => e.trashId == trashId);
    _repository.saveLocalCart(_cartItems);
    notifyListeners();
  }

  Future<void> clearLocalCart() async {
    _cartItems.clear();
    await _repository.clearLocalCart();
    notifyListeners();
  }

  Future<void> flushCartToServer() async {
    if (_cartItems.isEmpty) return;

    _isLoading = true;
    notifyListeners();

    await _repository.flushCartToServer();
    await clearLocalCart();

    _isLoading = false;
    notifyListeners();
  }

  Future<CartResponse?> fetchCartFromServer() async {
    try {
      return await _repository.getCartFromServer();
    } catch (e) {
      debugPrint("Error fetching cart: $e");
      return null;
    }
  }

  Future<void> commitCart() async {
    await _repository.commitCart();
  }

  Future<void> refreshTTL() async {
    await _repository.refreshCartTTL();
  }

  Future<void> deleteItemFromServer(String trashId) async {
    await _repository.deleteCartItemFromServer(trashId);
  }

  Future<void> clearCartFromServer() async {
    await _repository.clearServerCart();
  }
}
