import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rijig_mobile/features/cart/presentation/viewmodel/trashcart_vmod.dart';
import 'package:rijig_mobile/globaldata/trash/trash_model.dart';
import 'package:rijig_mobile/globaldata/trash/trash_viewmodel.dart';

class TrashPickScreen extends StatefulWidget {
  const TrashPickScreen({super.key});

  @override
  State<TrashPickScreen> createState() => _TrashPickScreenState();
}

class _TrashPickScreenState extends State<TrashPickScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _isInitialized = false;

  // Track loading states per item
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
    // Set loading state
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
      // Clear loading state
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
    await _handleQuantityChange(categoryId, (currentAmount + 1).toDouble());
  }

  Future<void> _decrementQuantity(String categoryId) async {
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    final currentAmount = cartViewModel.getItemAmount(categoryId);
    final newAmount = (currentAmount - 1).clamp(0, double.infinity);
    await _handleQuantityChange(categoryId, newAmount.toDouble());
  }

  Future<void> _resetQuantity(String categoryId) async {
    await _handleQuantityChange(categoryId, 0);
  }

  void _showQuantityDialog(String categoryId, String itemName) {
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    final currentAmount = cartViewModel.getItemAmount(categoryId);

    TextEditingController controller = TextEditingController(
      text: currentAmount.toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Input Jumlah $itemName'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  int? newQuantity = int.tryParse(controller.text);
                  if (newQuantity != null && newQuantity >= 0) {
                    Navigator.pop(context);
                    await _handleQuantityChange(
                      categoryId,
                      newQuantity.toDouble(),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Masukkan angka yang valid"),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                child: const Text('Simpan'),
              ),
            ],
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
              const SizedBox(width: 12),
              _buildQuantityDisplay(
                categoryId,
                amount.toDouble(),
                isItemLoading,
              ),
              const SizedBox(width: 12),
              _buildControlButton(
                icon: Icons.add,
                color: Colors.blue,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isItemLoading ? Colors.grey : Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  isItemLoading
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : const Text(
                        'Tambah',
                        style: TextStyle(
                          color: Colors.white,
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
              '${quantity.toInt()} kg',
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

  Widget _buildTrashItem(TrashCategory category) {
    final String? baseUrl = dotenv.env["BASE_URL"];

    return Consumer<CartViewModel>(
      builder: (context, cartViewModel, child) {
        final amount = cartViewModel.getItemAmount(category.id);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border:
                amount > 0
                    ? Border.all(
                      color: Colors.blue.withValues(alpha: 0.3),
                      width: 1.5,
                    )
                    : null,
            boxShadow: [
              BoxShadow(
                color:
                    amount > 0
                        ? Colors.blue.withValues(alpha: 0.1)
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
              const SizedBox(width: 16),
              Expanded(child: _buildCategoryInfo(category, amount)),
              _buildQuantityControls(category.id),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryIcon(String? baseUrl, TrashCategory category) {
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

  Widget _buildCategoryInfo(TrashCategory category, int quantity) {
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
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Rp ${category.price}/kg',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 24,
          child:
              quantity > 0
                  ? GestureDetector(
                    onTap: () => _resetQuantity(category.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(4),
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
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
              const SizedBox(width: 16),
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
            '${cartViewModel.cartItems.length} jenis    ${cartViewModel.totalItems} kg',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 10),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (!meetsMinimumWeight) ...[
            const SizedBox(height: 10),
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
        child: const Text(
          'Lanjut',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _handleContinue(CartViewModel cartViewModel) {
    // Navigate to cart summary or next step
    Navigator.pushNamed(context, '/cart-summary');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Pilih Sampah"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer2<TrashViewModel, CartViewModel>(
        builder: (context, trashViewModel, cartViewModel, child) {
          if (trashViewModel.isLoading) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder:
                  (context, index) => Container(
                    margin: const EdgeInsets.all(16),
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
            );
          }

          if (trashViewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Terjadi kesalahan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      trashViewModel.errorMessage ?? 'Error tidak diketahui',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _initializeData(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (!trashViewModel.hasData || trashViewModel.categories.isEmpty) {
            return const Center(child: Text('Tidak ada data kategori sampah'));
          }

          return Stack(
            children: [
              ListView.builder(
                padding: EdgeInsets.only(
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
              // Bottom Sheet with Animation
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
