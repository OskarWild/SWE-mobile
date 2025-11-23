import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foody_app/data/models/category_model.dart';
import 'package:foody_app/data/services/api_service.dart';
import 'package:foody_app/providers/cart_provider.dart';
import 'package:foody_app/providers/auth_provider.dart';
import 'package:foody_app/presentation/screens/catalog/category_items_screen.dart';
import 'package:foody_app/presentation/screens/catalog/add_product_screen.dart';
import 'package:foody_app/presentation/screens/cart/cart_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ApiService _apiService = ApiService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      _loadCategories();
    });
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;
      final categories = await _apiService.getCategories(userId: user?.id ?? '');
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showCategorySelectionForAddProduct() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.category, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Select Category',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return ListTile(
                  leading: Icon(_getCategoryIcon(category.name)),
                  title: Text(category.name),
                  subtitle: Text('${category.count} items'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddProductScreen(
                          categoryName: category.name,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadCategories();
                    }
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('fruit') || name.contains('vegetable')) {
      return Icons.local_florist;
    } else if (name.contains('meat') || name.contains('fish')) {
      return Icons.set_meal;
    } else if (name.contains('dairy') || name.contains('milk')) {
      return Icons.local_drink;
    } else if (name.contains('bakery') || name.contains('bread')) {
      return Icons.bakery_dining;
    } else if (name.contains('beverage') || name.contains('drink')) {
      return Icons.local_cafe;
    } else if (name.contains('snack') || name.contains('sweet')) {
      return Icons.cake;
    } else {
      return Icons.shopping_basket;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isSupplier = authProvider.user?.role == 'supplier';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog'),
        actions: [
          if (isSupplier)
          // Add Product button for suppliers
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: _categories.isEmpty ? null : _showCategorySelectionForAddProduct,
              tooltip: 'Add Product',
            )
          else
          // Shopping cart for consumers
            Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CartScreen(),
                          ),
                        );
                      },
                      tooltip: 'Cart',
                    ),
                    if (cartProvider.itemCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cartProvider.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCategories,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _categories.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              'No categories found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadCategories,
        child: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return CategoryCard(
              category: category,
              isSupplier: isSupplier,
            );
          },
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final bool isSupplier;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isSupplier,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryItemsScreen(
              categoryName: category.name,
              isSupplier: isSupplier,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.primary,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category.name),
              size: 56,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                category.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${category.count}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'items',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('fruit') || name.contains('vegetable')) {
      return Icons.local_florist;
    } else if (name.contains('meat') || name.contains('fish')) {
      return Icons.set_meal;
    } else if (name.contains('dairy') || name.contains('milk')) {
      return Icons.local_drink;
    } else if (name.contains('bakery') || name.contains('bread')) {
      return Icons.bakery_dining;
    } else if (name.contains('beverage') || name.contains('drink')) {
      return Icons.local_cafe;
    } else if (name.contains('snack') || name.contains('sweet')) {
      return Icons.cake;
    } else {
      return Icons.shopping_basket;
    }
  }
}