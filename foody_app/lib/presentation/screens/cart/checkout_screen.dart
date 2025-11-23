import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foody_app/providers/cart_provider.dart';
import 'package:foody_app/providers/auth_provider.dart';
import 'package:foody_app/data/services/api_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isProcessing = false;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = Provider.of<CartProvider>(context, listen: false);
    final cartItems = cart.getCartItems();

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Group items by supplier to create separate orders
      final Map<String, List<dynamic>> groupedBySupplier = {};

      for (final item in cartItems) {
        final supplierId = item.product.supplierId;
        if (!groupedBySupplier.containsKey(supplierId)) {
          groupedBySupplier[supplierId] = [];
        }
        groupedBySupplier[supplierId]!.add({
          'product_id': item.product.id,
          'quantity': item.quantity,
          'price': item.product.finalPrice,
        });
      }

      // Create orders for each supplier
      final List<String> createdOrderIds = [];

      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;

      for (final entry in groupedBySupplier.entries) {
        final supplierId = entry.key;
        final items = entry.value;

        // Calculate total for this supplier's items
        double supplierTotal = 0;
        for (final item in items) {
          supplierTotal += (item['price'] as double) * (item['quantity'] as int);
        }

        // Prepare order data for this supplier
        final orderData = {
          'user_id': user?.id ?? '',
          'supplier_id': supplierId,
          'items': items,
          'total_amount': supplierTotal,
          'delivery_address': _addressController.text.trim(),
          'notes': _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
          'status': 'pending',
        };

        // Send order to backend
        final result = await _apiService.createOrder(orderData);

        if (result.containsKey('id')) {
          createdOrderIds.add(result['id'].toString());
        }
      }

      // Clear cart after all orders are created successfully
      cart.clearCart();
      _addressController.clear();
      _notesController.clear();

      if (mounted) {
        // Success message with order count
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              createdOrderIds.length == 1
                  ? 'Order placed successfully!'
                  : '${createdOrderIds.length} orders placed successfully!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navigate back to catalog
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          final cartItems = cart.getCartItems();

          if (cartItems.isEmpty) {
            // Empty cart
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some products to checkout',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go to Catalog'),
                  ),
                ],
              ),
            );
          }

          // Checkout form
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary Card
                  Text(
                    'Order Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Items:',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                '${cart.totalQuantity}',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal:',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Text(
                                '${cart.totalAmount.toStringAsFixed(2)} ₸',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total:',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${cart.totalAmount.toStringAsFixed(2)} ₸',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Delivery Address Section
                  Text(
                    'Delivery Address',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      hintText: 'Enter your delivery address',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter delivery address';
                      }
                      if (value.trim().length < 10) {
                        return 'Please enter a complete address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Order Notes Section
                  Text(
                    'Additional Notes (Optional)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Any special instructions?',
                      prefixIcon: const Icon(Icons.note_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Items List Section
                  Text(
                    'Items (${cartItems.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Display all cart items
                  ...cartItems.map((item) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 1,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: item.product.imageUrl != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                          ),
                        )
                            : const Icon(Icons.shopping_bag_outlined),
                      ),
                      title: Text(
                        item.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${item.quantity} ${item.product.unit} × ${item.product.finalPrice.toStringAsFixed(2)} ₸',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: Text(
                        '${item.totalPrice.toStringAsFixed(2)} ₸',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  )),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
      // Bottom navigation bar
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.getCartItems().isEmpty) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            // Place Order Button
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    'Place Order (${cart.totalAmount.toStringAsFixed(2)} ₸)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}