import 'package:flutter/material.dart';
import 'package:foody_app/data/models/product_model.dart';
import 'package:foody_app/data/models/cart_item_model.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItemModel> _items = {};

  Map<String, CartItemModel> get items => {..._items};

  int get itemCount => _items.length;

  // Total Items Quantity
  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  // Cart Total Amount
  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Add Item
  void addItem(ProductModel product, int quantity) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += quantity;
    } else {
      _items[product.id] = CartItemModel(
        product: product,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  // Remove Item
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Update Item
  void updateQuantity(String productId, int quantity) {
    if (_items.containsKey(productId)) {
      if (quantity <= 0) {
        removeItem(productId);
      } else {
        _items[productId]!.quantity = quantity;
        notifyListeners();
      }
    }
  }

  // Clear All Items
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Get Items
  List<CartItemModel> getCartItems() {
    return _items.values.toList();
  }

  // Check Exists
  bool isInCart(String productId) {
    return _items.containsKey(productId);
  }

  // Get Product Quantity
  int getProductQuantity(String productId) {
    return _items[productId]?.quantity ?? 0;
  }
}