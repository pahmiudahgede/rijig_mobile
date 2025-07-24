import 'package:flutter/material.dart';
import 'package:rijig_mobile/features/cart/model/trashcart_model.dart';
import 'package:rijig_mobile/features/cart/repositories/trashcart_repo.dart';

enum CartState { initial, loading, loaded, error, updating }

class CartViewModel extends ChangeNotifier {
  final CartRepository _repository;

  CartViewModel(this._repository);

  CartState _state = CartState.initial;
  Cart? _cart;
  String? _errorMessage;
  String? _successMessage;
  bool _isOperationInProgress = false;

  CartState get state => _state;
  Cart? get cart => _cart;
  List<CartItem> get cartItems => _cart?.cartItems ?? [];
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get isLoading => _state == CartState.loading;
  bool get isUpdating => _state == CartState.updating;
  bool get hasError => _state == CartState.error;
  bool get isEmpty => cartItems.isEmpty;
  bool get isNotEmpty => cartItems.isNotEmpty;
  bool get isOperationInProgress => _isOperationInProgress;

  int get totalItems => _cart?.totalAmount ?? 0;

  int get totalPrice => _cart?.estimatedTotalPrice ?? 0;

  String get formattedTotalPrice {
    return 'Rp ${_formatCurrency(totalPrice)}';
  }

  int getItemAmount(String trashId) {
    try {
      final item = cartItems.firstWhere((item) => item.trashId == trashId);
      return item.amount;
    } catch (e) {
      return 0;
    }
  }

  Future<void> loadCartItems({bool showLoading = true}) async {
    if (showLoading) {
      _setState(CartState.loading);
    }
    _clearMessages();

    try {
      _cart = await _repository.getCartItems();
      _setState(CartState.loaded);
    } catch (e) {
      _setError(e.toString());
      _setState(CartState.error);
    }
  }

  Future<bool> addOrUpdateItem(
    String trashId,
    int amount, {
    bool showUpdating = true,
  }) async {
    if (showUpdating) {
      _setState(CartState.updating);
    }
    _setOperationInProgress(true);
    _clearMessages();

    try {
      if (amount <= 0) {
        throw Exception('Amount must be greater than 0');
      }

      await _repository.addOrUpdateCartItem(trashId: trashId, amount: amount);
      _setSuccess('Item berhasil ditambahkan ke keranjang');

      await loadCartItems(showLoading: false);
      return true;
    } catch (e) {
      _setError(e.toString());
      if (showUpdating) {
        _setState(CartState.error);
      }
      return false;
    } finally {
      _setOperationInProgress(false);
    }
  }

  Future<bool> deleteItem(String trashId, {bool showUpdating = true}) async {
    if (showUpdating) {
      _setState(CartState.updating);
    }
    _setOperationInProgress(true);
    _clearMessages();

    try {
      await _repository.deleteCartItem(trashId);
      _setSuccess('Item berhasil dihapus dari keranjang');

      await loadCartItems(showLoading: false);
      return true;
    } catch (e) {
      _setError(e.toString());
      if (showUpdating) {
        _setState(CartState.error);
      }
      return false;
    } finally {
      _setOperationInProgress(false);
    }
  }

  Future<bool> clearCart() async {
    _setState(CartState.updating);
    _setOperationInProgress(true);
    _clearMessages();

    try {
      await _repository.clearCart();
      _setSuccess('Keranjang berhasil dikosongkan');
      _cart = null;
      _setState(CartState.loaded);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setState(CartState.error);
      return false;
    } finally {
      _setOperationInProgress(false);
    }
  }

  Future<bool> incrementItemAmount(String trashId) async {
    final currentAmount = getItemAmount(trashId);
    return await addOrUpdateItem(
      trashId,
      currentAmount + 1,
      showUpdating: false,
    );
  }

  Future<bool> decrementItemAmount(String trashId) async {
    final currentAmount = getItemAmount(trashId);
    if (currentAmount <= 1) {
      return await deleteItem(trashId, showUpdating: false);
    }
    return await addOrUpdateItem(
      trashId,
      currentAmount - 1,
      showUpdating: false,
    );
  }

  Future<void> refresh() async {
    await loadCartItems();
  }

  void clearMessages() {
    _clearMessages();
  }

  void _setState(CartState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setOperationInProgress(bool inProgress) {
    _isOperationInProgress = inProgress;
    notifyListeners();
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
