
import 'package:rijig_mobile/features/cart/model/trashcart_model.dart';
import 'package:rijig_mobile/features/cart/repositories/trashcart_repo.dart';

class CartService {
  final CartRepository _repository;

  CartService(this._repository);

  Future<void> addOrUpdateCartItem({
    required String trashId,
    required int amount,
  }) async {
    // Business logic validation
    if (trashId.isEmpty) {
      throw Exception('Trash ID tidak boleh kosong');
    }

    if (amount <= 0) {
      throw Exception('Jumlah harus lebih dari 0');
    }

    if (amount > 100) {
      throw Exception('Jumlah maksimal 100 kg per item');
    }

    try {
      await _repository.addOrUpdateCartItem(trashId: trashId, amount: amount);
    } catch (e) {
      throw Exception('Gagal menambahkan item: $e');
    }
  }

  Future<Cart> getCartItems() async {
    try {
      final cart = await _repository.getCartItems();
      return cart;
    } catch (e) {
      throw Exception('Gagal memuat keranjang: $e');
    }
  }

  Future<void> deleteCartItem(String trashId) async {
    if (trashId.isEmpty) {
      throw Exception('Trash ID tidak boleh kosong');
    }

    try {
      await _repository.deleteCartItem(trashId);
    } catch (e) {
      throw Exception('Gagal menghapus item: $e');
    }
  }

  Future<void> clearCart() async {
    try {
      await _repository.clearCart();
    } catch (e) {
      throw Exception('Gagal mengosongkan keranjang: $e');
    }
  }

  // Business logic: Check if cart meets minimum weight requirement
  bool meetsMinimumWeight(Cart cart, {int minimumWeight = 3}) {
    return cart.totalAmount >= minimumWeight;
  }

  // Business logic: Calculate estimated earnings
  int calculateEstimatedEarnings(Cart cart) {
    return cart.cartItems.fold(0, (total, item) {
      return total + (item.amount * item.trashPrice);
    });
  }

  // Business logic: Validate cart before checkout
  Map<String, dynamic> validateCart(Cart cart) {
    final errors = <String>[];

    if (cart.cartItems.isEmpty) {
      errors.add('Keranjang masih kosong');
    }

    if (!meetsMinimumWeight(cart)) {
      errors.add('Minimum total berat 3kg');
    }

    for (final item in cart.cartItems) {
      if (item.amount <= 0) {
        errors.add('${item.trashName} memiliki jumlah tidak valid');
      }
    }

    return {'isValid': errors.isEmpty, 'errors': errors};
  }
}
