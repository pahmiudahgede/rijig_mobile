import 'dart:math' as math;

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/features/cart/presentation/viewmodel/trashcart_vmod.dart';
import 'package:rijig_mobile/features/cart/model/trashcart_model.dart';

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({super.key});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late CartViewModel _cartViewModel;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCart();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      _refreshCartData();
    }
  }

  void _refreshCartData() {
    if (mounted) {
      final cartViewModel = context.read<CartViewModel>();
      cartViewModel.refresh();
    }
  }

  void _initializeCart() async {
    if (_isInitialized) return;
    _cartViewModel = context.read<CartViewModel>();

    await _cartViewModel.loadCartItems(showLoading: false);

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshCartData();
      });
    }
  }

  Future<void> _removeItem(String trashId, String itemName) async {
    final success = await _cartViewModel.deleteItem(trashId);
    if (success) {
      _showSnackbar('$itemName berhasil dihapus');
    } else {
      _showSnackbar(_cartViewModel.errorMessage);
    }
  }

  Future<void> _clearAllItems() async {
    if (_cartViewModel.isEmpty) return;

    final confirmed = await _showConfirmationDialog(
      title: 'Hapus Semua Item',
      content: 'Apakah Anda yakin ingin menghapus semua item dari keranjang?',
      confirmText: 'Hapus Semua',
    );

    if (confirmed == true) {
      final success = await _cartViewModel.clearCart();
      if (success) {
        _showSnackbar('Semua item berhasil dihapus');
      } else {
        _showSnackbar(_cartViewModel.errorMessage);
      }
    }
  }

  Future<void> _incrementQuantity(String trashId) async {
    await _cartViewModel.incrementItemAmount(trashId);
    if (_cartViewModel.state == CartState.error) {
      _showSnackbar(_cartViewModel.errorMessage);
    }
  }

  Future<void> _decrementQuantity(String trashId) async {
    await _cartViewModel.decrementItemAmount(trashId);
    if (_cartViewModel.state == CartState.error) {
      _showSnackbar(_cartViewModel.errorMessage);
    }
  }

  Future<void> _showQuantityDialog(CartItem item) async {
    final TextEditingController controller = TextEditingController(
      text: item.amount.toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Input Jumlah ${item.trashName}'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Jumlah',
              border: OutlineInputBorder(),
              suffixText: 'kg',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final newAmount = int.tryParse(controller.text);
                if (newAmount != null && newAmount > 0) {
                  Navigator.of(context).pop(newAmount);
                } else {
                  _showSnackbar('Masukkan angka yang valid (lebih dari 0)');
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      final success = await _cartViewModel.addOrUpdateItem(
        item.trashId,
        result,
      );
      if (!success) {
        _showSnackbar(_cartViewModel.errorMessage);
      }
    }
  }

  Future<bool?> _showConfirmationDialog({
    required String title,
    required String content,
    required String confirmText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  Map<String, dynamic> _getTrashTypeConfig(String trashName) {
    final name = trashName.toLowerCase();
    if (name.contains('plastik')) {
      return {
        'icon': Icons.local_drink,
        'backgroundColor': Colors.blue.shade100,
        'iconColor': Colors.blue,
      };
    } else if (name.contains('kertas')) {
      return {
        'icon': Icons.description,
        'backgroundColor': Colors.orange.shade100,
        'iconColor': Colors.orange,
      };
    } else if (name.contains('logam') || name.contains('metal')) {
      return {
        'icon': Icons.build,
        'backgroundColor': Colors.grey.shade100,
        'iconColor': Colors.grey.shade700,
      };
    } else if (name.contains('kaca')) {
      return {
        'icon': Icons.wine_bar,
        'backgroundColor': Colors.green.shade100,
        'iconColor': Colors.green,
      };
    } else {
      return {
        'icon': Icons.delete_outline,
        'backgroundColor': Colors.grey.shade100,
        'iconColor': Colors.grey.shade600,
      };
    }
  }

  double get totalWeight => _cartViewModel.totalItems.toDouble();
  int get estimatedEarnings => _cartViewModel.totalPrice.round();

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detail Pesanan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<CartViewModel>(
            builder: (context, cartVM, child) {
              if (cartVM.isNotEmpty) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.refresh, color: Colors.black),
                      onPressed: () => _refreshCartData(),
                      tooltip: 'Refresh Data',
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.black),
                      onSelected: (value) {
                        if (value == 'clear_all') {
                          _clearAllItems();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'clear_all',
                          child: Row(
                            children: [
                              Icon(
                                Icons.clear_all,
                                color: Colors.red,
                                size: 20,
                              ),
                              Gap(8),
                              Text(
                                'Hapus Semua',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<CartViewModel>(
        builder: (context, cartVM, child) {
          if (cartVM.state == CartState.loading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Gap(16),
                  Text('Memuat keranjang...'),
                ],
              ),
            );
          }

          if (cartVM.state == CartState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  Gap(16),
                  Text(
                    'Terjadi kesalahan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  Gap(8),
                  Text(
                    cartVM.errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  Gap(24),
                  ElevatedButton(
                    onPressed: () => _refreshCartData(),
                    child: Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (cartVM.isEmpty) {
            return _buildEmptyState();
          }

          return CustomMaterialIndicator(
            onRefresh: () async {
              await _cartViewModel.loadCartItems(showLoading: false);
            },
            backgroundColor: Colors.white,
            indicatorBuilder: (context, controller) {
              return Padding(
                padding: const EdgeInsets.all(6.0),
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  value: controller.state.isLoading
                      ? null
                      : math.min(controller.value, 1.0),
                ),
              );
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildItemsSection(cartVM),
                  Gap(20),
                  _buildEarningsSection(cartVM),
                  Gap(20),
                  _buildBottomButton(cartVM),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          Gap(16),
          Text(
            'Keranjang kosong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          Gap(8),
          Text(
            'Tambahkan item sampah untuk melanjutkan',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          Gap(24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.add),
            label: Text('Tambah Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(CartViewModel cartVM) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSectionHeader(),
          Gap(16),
          ...cartVM.cartItems.map((item) => _buildItemCard(item)),
          Gap(16),
          _buildTotalWeight(cartVM),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.delete_outline, color: Colors.orange, size: 20),
        ),
        Gap(12),
        Text(
          'Jenis Sampah',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        Spacer(),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: Colors.blue, size: 16),
              Gap(4),
              Text(
                'Tambah',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(CartItem item) {
    final config = _getTrashTypeConfig(item.trashName);

    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Consumer<CartViewModel>(
        builder: (context, cartVM, child) {
          return Slidable(
            key: ValueKey('${item.trashId}_${item.id}'),
            endActionPane: ActionPane(
              motion: ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => _removeItem(item.trashId, item.trashName),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                  label: 'Hapus',
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  _buildItemIcon(config),
                  Gap(12),
                  _buildItemInfo(item),
                  _buildQuantityControls(item, cartVM),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemIcon(Map<String, dynamic> config) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: config['backgroundColor'],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(config['icon'], color: config['iconColor'], size: 20),
    );
  }

  Widget _buildItemInfo(CartItem item) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.trashName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Gap(4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Rp ${_formatCurrency(item.trashPrice.round())}/kg',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(CartItem item, CartViewModel cartVM) {
    return Row(
      children: [
        _buildQuantityButton(
          icon: Icons.remove,
          onTap: cartVM.isOperationInProgress
              ? null
              : () => _decrementQuantity(item.trashId),
          backgroundColor: Colors.white,
          iconColor: Colors.grey.shade600,
        ),
        Gap(8),
        GestureDetector(
          onTap: cartVM.isOperationInProgress
              ? null
              : () => _showQuantityDialog(item),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              '${item.amount} kg',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        Gap(8),
        _buildQuantityButton(
          icon: Icons.add,
          onTap: cartVM.isOperationInProgress
              ? null
              : () => _incrementQuantity(item.trashId),
          backgroundColor: Colors.blue,
          iconColor: Colors.white,
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onTap,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey.shade300 : backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: backgroundColor == Colors.white
              ? Border.all(color: Colors.grey.shade300)
              : null,
        ),
        child: Icon(
          icon,
          color: onTap == null ? Colors.grey.shade500 : iconColor,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildTotalWeight(CartViewModel cartVM) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.scale, color: Colors.grey.shade700, size: 16),
          ),
          Gap(12),
          Text(
            'Berat total',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Spacer(),
          Text(
            '${cartVM.totalItems} kg',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsSection(CartViewModel cartVM) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.folder, color: Colors.orange, size: 20),
              ),
              Gap(12),
              Text(
                'Rincian Perhitungan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Gap(16),
          // Detail per item
          ...cartVM.cartItems.map((item) => _buildItemCalculation(item)),
          Gap(12),
          // Divider
          Divider(color: Colors.grey.shade300),
          Gap(8),
          // Total
          _buildTotalCalculation(cartVM),
        ],
      ),
    );
  }

  Widget _buildItemCalculation(CartItem item) {
    final subtotal = (item.amount * item.trashPrice).round();
    
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.receipt_outlined, color: Colors.blue, size: 12),
          ),
          Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.trashName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Gap(2),
                Text(
                  '${item.amount} kg × Rp ${_formatCurrency(item.trashPrice.round())}/kg',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Rp ${_formatCurrency(subtotal)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCalculation(CartViewModel cartVM) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.account_balance_wallet, color: Colors.green, size: 16),
        ),
        Gap(12),
        Expanded(
          child: Text(
            'Total Estimasi Pendapatan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        Text(
          'Rp ${_formatCurrency(estimatedEarnings)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(CartViewModel cartVM) {
    return SizedBox(
      width: double.infinity,
      child: Consumer<CartViewModel>(
        builder: (context, cartVM, child) {
          final isLoading = cartVM.isOperationInProgress;
          final hasItems = cartVM.isNotEmpty;

          return ElevatedButton(
            onPressed: isLoading
                ? null
                : hasItems
                    ? () {
                        _showSnackbar('Lanjut ke proses selanjutnya');
                        router.push('/pickupmethod');
                      }
                    : () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasItems ? Colors.blue : Colors.grey.shade400,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : Text(
                    hasItems ? 'Lanjut' : 'Tambah Item',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          );
        },
      ),
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}