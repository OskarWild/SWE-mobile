import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;

  CartItemModel({
    required this.product,
    required this.quantity,
  });

  // Calculate total price for this cart item
  double get totalPrice => product.finalPrice * quantity;

  // Check if quantity meets minimum order requirement
  bool get meetsMinimumOrder {
    if (product.minimumOrderQuantity == null) return true;
    return quantity >= product.minimumOrderQuantity!;
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
    };
  }

  // From JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json),
      quantity: json['quantity'] ?? 1,
    );
  }

  // Copy with
  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}