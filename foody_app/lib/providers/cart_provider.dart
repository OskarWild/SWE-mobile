import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/models/cart_item_model.dart';
import '../data/models/product_model.dart';

class CartProvider with ChangeNotifier {
  List<CartItemModel> _items = [];
  
  List<CartItemModel> get items => _items;
  
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  bool get hasItems => _items.isNotEmpty;

  // Initialize cart from storage
  Future<void> init() async {
    await _loadCart();
  }

  // Load cart from SharedPreferences
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart');
      
      if (cartJson != null) {
        final List<dynamic> decoded = jsonDecode(cartJson);
        _items = decoded.map((item) => CartItemModel.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  // Save cart to SharedPreferences
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(_items.map((item) => item.toJson()).toList());
      await prefs.setString('cart', cartJson);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  // Add product to cart
  void addToCart(ProductModel product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      // Update quantity if product already exists
      _items[existingIndex].quantity += quantity;
    } else {
      // Add new product to cart
      _items.add(CartItemModel(
        product: product,
        quantity: quantity,
      ));
    }
    
    _saveCart();
    notifyListeners();
  }

  // Remove product from cart
  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    _saveCart();
    notifyListeners();
  }

  // Update quantity
  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    
    if (index >= 0) {
      if (quantity <= 0) {
        removeFromCart(productId);
      } else {
        _items[index].quantity = quantity;
        _saveCart();
        notifyListeners();
      }
    }
  }

  // Increment quantity
  void incrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      _saveCart();
      notifyListeners();
    }
  }

  // Decrement quantity
  void decrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final minQty = _items[index].product.minimumOrderQuantity ?? 1;
      if (_items[index].quantity > minQty) {
        _items[index].quantity--;
        _saveCart();
        notifyListeners();
      }
    }
  }

  // Clear cart
  void clearCart() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  // Check if product is in cart
  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  // Get quantity of product in cart
  int getQuantity(String productId) {
    final item = _items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItemModel(
        product: ProductModel(
          id: '',
          name: '',
          description: '',
          price: 0,
          unit: '',
          stockLevel: 0,
          categoryId: '',
          supplierId: '',
        ),
        quantity: 0,
      ),
    );
    return item.quantity;
  }

  // Validate cart items (check stock, minimum order, etc.)
  List<String> validateCart() {
    final errors = <String>[];
    
    for (final item in _items) {
      if (!item.product.isInStock) {
        errors.add('${item.product.name} is out of stock');
      }
      
      if (!item.meetsMinimumOrder) {
        errors.add(
          '${item.product.name} requires minimum ${item.product.minimumOrderQuantity} ${item.product.unit}',
        );
      }
      
      if (item.quantity > item.product.stockLevel) {
        errors.add(
          '${item.product.name} has only ${item.product.stockLevel} ${item.product.unit} available',
        );
      }
    }
    
    return errors;
  }

  // Group items by supplier
  Map<String, List<CartItemModel>> groupBySupplier() {
    final Map<String, List<CartItemModel>> grouped = {};
    
    for (final item in _items) {
      final supplierId = item.product.supplierId;
      if (!grouped.containsKey(supplierId)) {
        grouped[supplierId] = [];
      }
      grouped[supplierId]!.add(item);
    }
    
    return grouped;
  }
}