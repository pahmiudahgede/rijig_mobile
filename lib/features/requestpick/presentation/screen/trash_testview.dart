import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:rijig_mobile/core/router.dart';
import 'package:rijig_mobile/core/utils/guide.dart';
import 'package:rijig_mobile/features/cart/presentation/viewmodel/trashcart_vmod.dart';
import 'package:rijig_mobile/globaldata/trash/trash_viewmodel.dart';
import 'package:rijig_mobile/widget/appbar.dart';
import 'package:rijig_mobile/widget/buttoncard.dart';
import 'package:rijig_mobile/widget/formfiled.dart';
import 'package:rijig_mobile/widget/showmodal.dart';
import 'package:rijig_mobile/widget/skeletonize.dart';
import 'package:rijig_mobile/widget/unhope_handler.dart';
import 'package:toastification/toastification.dart';

class TestRequestPickScreen extends StatefulWidget {
  const TestRequestPickScreen({super.key});

  @override
  State<TestRequestPickScreen> createState() => _TestRequestPickScreenState();
}

class _TestRequestPickScreenState extends State<TestRequestPickScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _isInitialized = false;

  final Map<String, bool> _itemLoadingStates = {};

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    final trashViewModel = Provider.of<TrashViewModel>(context, listen: false);
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);

    await Future.wait([
      trashViewModel.loadCategories(),
      cartViewModel.loadCartItems(showLoading: false),
    ]);

    if (mounted) {
      _updateBottomSheetVisibility();
      setState(() {
        _isInitialized = true;
      });
    }
  }

  void _updateBottomSheetVisibility() {
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);

    if (cartViewModel.isNotEmpty) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  Future<void> _handleQuantityChange(
    String categoryId,
    double newQuantity,
  ) async {
    setState(() {
      _itemLoadingStates[categoryId] = true;
    });

    try {
      final cartViewModel = Provider.of<CartViewModel>(context, listen: false);

      if (newQuantity <= 0) {
        await cartViewModel.deleteItem(categoryId, showUpdating: false);
      } else {
        await cartViewModel.addOrUpdateItem(
          categoryId,
          newQuantity.toInt(),
          showUpdating: false,
        );
      }

      if (mounted) {
        _updateBottomSheetVisibility();
      }
    } finally {
      if (mounted) {
        setState(() {
          _itemLoadingStates[categoryId] = false;
        });
      }
    }
  }

  Future<void> _incrementQuantity(String categoryId) async {
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    final currentAmount = cartViewModel.getItemAmount(categoryId);
    await _handleQuantityChange(categoryId, (currentAmount + 2.5));
  }

  Future<void> _decrementQuantity(String categoryId) async {
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    final currentAmount = cartViewModel.getItemAmount(categoryId);
    final newAmount = (currentAmount - 2.5).clamp(0.0, double.infinity);
    await _handleQuantityChange(categoryId, newAmount);
  }

  Future<void> _resetQuantity(String categoryId) async {
    await _handleQuantityChange(categoryId, 0);
  }

  void _showQuantityDialog(String categoryId, String itemName) {
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    final currentAmount = cartViewModel.getItemAmount(categoryId);

    TextEditingController controller = TextEditingController(
      text: currentAmount.toString().replaceAll('.0', ''),
    );

    CustomModalDialog.showWidget(
      customWidget: FormFieldOne(
        controllers: controller,
        hintText: 'masukkan berat dengan benar ya..',
        isRequired: true,
        textInputAction: TextInputAction.done,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onTap: () {},
        onChanged: (value) {},
        fontSize: 14.sp,
        fontSizeField: 16.sp,
        onFieldSubmitted: (value) {},
        readOnly: false,
        enabled: true,
      ),
      context: context,
      buttonCount: 2,
      button1: CardButtonOne(
        textButton: "Simpan",
        onTap: () async {
          double? newQuantity = double.tryParse(controller.text);
          if (newQuantity != null && newQuantity >= 0) {
            Navigator.pop(context);
            await _handleQuantityChange(categoryId, newQuantity);
          } else {
            toastification.show(
              type: ToastificationType.warning,
              title: const Text("Masukkan angka yang valid"),
              autoCloseDuration: const Duration(seconds: 3),
            );
          }
        },
        fontSized: 14.sp,
        colorText: whiteColor,
        color: primaryColor,
        borderRadius: 10.sp,
        horizontal: double.infinity,
        vertical: 50,
        loadingTrue: false,
        usingRow: false,
      ),
      button2: CardButtonOne(
        textButton: "Batal",
        onTap: () => router.pop(),
        fontSized: 14.sp,
        colorText: primaryColor,
        color: Colors.transparent,
        borderRadius: 10,
        horizontal: double.infinity,
        vertical: 50,
        loadingTrue: false,
        usingRow: false,
      ),
    );
  }

  Widget _buildQuantityControls(String categoryId) {
    final isItemLoading = _itemLoadingStates[categoryId] ?? false;

    return Consumer<CartViewModel>(
      builder: (context, cartViewModel, child) {
        final amount = cartViewModel.getItemAmount(categoryId);

        if (amount > 0) {
          return Row(
            children: [
              _buildControlButton(
                icon: Icons.remove,
                color: Colors.red,
                onTap:
                    isItemLoading ? null : () => _decrementQuantity(categoryId),
                isLoading: isItemLoading,
              ),
              const Gap(12),
              _buildQuantityDisplay(
                categoryId,
                amount.toDouble(),
                isItemLoading,
              ),
              const Gap(12),
              _buildControlButton(
                icon: Icons.add,
                color: primaryColor,
                onTap:
                    isItemLoading ? null : () => _incrementQuantity(categoryId),
                isLoading: isItemLoading,
              ),
            ],
          );
        } else {
          return GestureDetector(
            onTap: isItemLoading ? null : () => _incrementQuantity(categoryId),
            child: Container(
              padding: PaddingCustom().paddingHorizontalVertical(16, 8),
              decoration: BoxDecoration(
                color: isItemLoading ? Colors.grey : primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  isItemLoading
                      ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                        ),
                      )
                      : Text(
                        'Tambah',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
            ),
          );
        }
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color:
              onTap != null
                  ? color.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            isLoading
                ? Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                )
                : Icon(
                  icon,
                  color: onTap != null ? color : Colors.grey,
                  size: 20,
                ),
      ),
    );
  }

  Widget _buildQuantityDisplay(
    String categoryId,
    double quantity,
    bool isLoading,
  ) {
    final trashViewModel = Provider.of<TrashViewModel>(context, listen: false);
    final category = trashViewModel.getCategoryById(categoryId);

    return GestureDetector(
      onTap:
          isLoading
              ? null
              : () => _showQuantityDialog(categoryId, category?.name ?? ''),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isLoading ? Colors.orange.shade300 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isLoading ? Colors.orange.shade50 : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
              ),
            Text(
              '${quantity.toString().replaceAll('.0', '')} kg',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isLoading ? Colors.orange.shade700 : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrashItem(dynamic category) {
    final String? baseUrl = dotenv.env["BASE_URL"];

    return Consumer<CartViewModel>(
      builder: (context, cartViewModel, child) {
        final amount = cartViewModel.getItemAmount(category.id);
        num price =
            (category.price is String)
                ? int.tryParse(category.price) ?? 0
                : category.price ?? 0;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          padding: PaddingCustom().paddingAll(16),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(12),
            border:
                amount > 0
                    ? Border.all(
                      color: primaryColor.withValues(alpha: 0.3),
                      width: 1.5,
                    )
                    : null,
            boxShadow: [
              BoxShadow(
                color:
                    amount > 0
                        ? primaryColor.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                spreadRadius: amount > 0 ? 2 : 1,
                blurRadius: amount > 0 ? 6 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildCategoryIcon(baseUrl, category),
              const Gap(16),
              Expanded(
                child: _buildCategoryInfo(category, price, amount.toDouble()),
              ),
              _buildQuantityControls(category.id),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryIcon(String? baseUrl, dynamic category) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(25),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Image.network(
          '$baseUrl${category.icon}',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.category, color: Colors.grey, size: 24);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryInfo(dynamic category, num price, double quantity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          category.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const Gap(4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Rp ${price.toString()}/kg',
            style: TextStyle(
              color: whiteColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Gap(4),
        SizedBox(
          height: 24,
          child:
              quantity > 0
                  ? GestureDetector(
                    onTap: () => _resetQuantity(category.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: PaddingCustom().paddingAll(4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 16,
                      ),
                    ),
                  )
                  : const SizedBox(),
        ),
      ],
    );
  }

  Widget _buildBottomSheet() {
    return Consumer<CartViewModel>(
      builder: (context, cartViewModel, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: PaddingCustom().paddingAll(16),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(child: _buildOrderSummary(cartViewModel)),
              const Gap(16),
              _buildContinueButton(cartViewModel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(CartViewModel cartViewModel) {
    final meetsMinimumWeight = cartViewModel.totalItems >= 3;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Column(
        key: ValueKey(cartViewModel.totalItems),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${cartViewModel.cartItems.length} jenis    ${cartViewModel.totalItems.toString()} kg',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const Gap(10),
          Row(
            children: [
              Text(
                'Est. ',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  cartViewModel.formattedTotalPrice,
                  style: TextStyle(
                    color: whiteColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (!meetsMinimumWeight) ...[
            const Gap(10),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: meetsMinimumWeight ? 0.0 : 1.0,
              child: const Text(
                'Minimum total berat 3kg',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContinueButton(CartViewModel cartViewModel) {
    final meetsMinimumWeight = cartViewModel.totalItems >= 3;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton(
        onPressed:
            meetsMinimumWeight ? () => _handleContinue(cartViewModel) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: meetsMinimumWeight ? Colors.blue : Colors.grey,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'Lanjut',
          style: TextStyle(
            color: whiteColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _handleContinue(CartViewModel cartViewModel) {
    final trashViewModel = Provider.of<TrashViewModel>(context, listen: false);

    Map<String, dynamic> orderData = {
      'selectedItems':
          cartViewModel.cartItems.map((cartItem) {
            trashViewModel.getCategoryById(cartItem.trashId);
            return {
              'id': cartItem.trashId,
              'name': cartItem.trashName,
              'quantity': cartItem.amount.toDouble(),
              'pricePerKg': cartItem.trashPrice,
              'totalPrice': cartItem.subtotalEstimatedPrice.round(),
            };
          }).toList(),
      'totalWeight': cartViewModel.totalItems.toDouble(),
      'totalPrice': cartViewModel.totalPrice.round(),
      'totalItems': cartViewModel.cartItems.length,
    };

    context.push('/ordersumary', extra: orderData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: const CustomAppBar(judul: "Pilih Sampah"),
      body: Consumer2<TrashViewModel, CartViewModel>(
        builder: (context, trashViewModel, cartViewModel, child) {
          if (trashViewModel.isLoading) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (context, index) => SkeletonCard(),
            );
          }

          if (trashViewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const Gap(16),
                  const Text(
                    'Terjadi kesalahan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Gap(8),
                  Padding(
                    padding: PaddingCustom().paddingHorizontal(32),
                    child: Text(
                      trashViewModel.errorMessage ?? 'Error tidak diketahui',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  const Gap(24),
                  ElevatedButton(
                    onPressed: () => _initializeData(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (!trashViewModel.hasData || trashViewModel.categories.isEmpty) {
            return InfoStateWidget(type: InfoStateType.emptyData);
          }

          return Stack(
            children: [
              ListView.builder(
                padding: PaddingCustom().paddingOnly(
                  top: 16,
                  right: 16,
                  bottom: cartViewModel.isNotEmpty ? 120 : 16,
                  left: 16,
                ),
                itemCount: trashViewModel.categories.length,
                itemBuilder: (context, index) {
                  final category = trashViewModel.categories[index];
                  return _buildTrashItem(category);
                },
              ),

              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Positioned(
                    left: 0,
                    right: 0,
                    bottom:
                        cartViewModel.isNotEmpty
                            ? (_slideAnimation.value - 1) * 200
                            : -200,
                    child:
                        cartViewModel.isNotEmpty
                            ? _buildBottomSheet()
                            : const SizedBox.shrink(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
