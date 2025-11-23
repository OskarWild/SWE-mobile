import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foody_app/data/models/product_model.dart';
import 'package:foody_app/data/services/api_service.dart';
import 'package:foody_app/providers/auth_provider.dart';
import 'package:foody_app/presentation/screens/catalog/product_detail_screen.dart';
import 'package:foody_app/presentation/screens/catalog/add_product_screen.dart';

class CategoryItemsScreen extends StatefulWidget {
  final String categoryName;
  final bool isSupplier;

  const CategoryItemsScreen({
    super.key,
    required this.categoryName,
    required this.isSupplier,
  });

  @override
  State<CategoryItemsScreen> createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<ProductModel> _products = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedSort;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      _loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;
      final products = await _apiService.getProducts(
        userId: user?.id ?? '',
        search: _searchController.text.isEmpty ? null : _searchController.text,
        sortBy: _selectedSort,
        categoryId: widget.categoryName,
      );
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.sort_by_alpha),
            title: const Text('Name (A-Z)'),
            onTap: () {
              setState(() => _selectedSort = 'name_asc');
              Navigator.pop(context);
              _loadProducts();
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Price: Low to High'),
            onTap: () {
              setState(() => _selectedSort = 'price_asc');
              Navigator.pop(context);
              _loadProducts();
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Price: High to Low'),
            onTap: () {
              setState(() => _selectedSort = 'price_desc');
              Navigator.pop(context);
              _loadProducts();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showSortOptions,
            tooltip: 'Sort',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _loadProducts();
                  },
                )
                    : null,
              ),
              onSubmitted: (_) => _loadProducts(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $_error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProducts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
                : _products.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined,
                      size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'No products found',
                    style:
                    Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadProducts,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return ProductCard(product: product);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isSupplier
          ? FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddProductScreen(
                categoryName: widget.categoryName,
              ),
            ),
          );
          if (result == true) {
            _loadProducts();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      )
          : null,
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: product.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade200,
                child: product.imageUrl != null
                    ? Image.network(
                  product.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.image_not_supported,
                    size: 48,
                  ),
                )
                    : const Icon(Icons.shopping_bag_outlined, size: 48),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.finalPrice.toStringAsFixed(2)} ₸/${product.unit}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (product.discount != null && product.discount! > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${product.price.toStringAsFixed(2)} ₸',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        product.isInStock ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: product.isInStock ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.isInStock ? 'In Stock' : 'Out of Stock',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                          product.isInStock ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}