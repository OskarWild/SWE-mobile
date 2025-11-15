class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String unit; // kg, l, pcs
  final String? imageUrl;
  final int stockLevel;
  final String categoryId;
  final String supplierId;
  final double? discount;
  final int? minimumOrderQuantity;
  
  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    this.imageUrl,
    required this.stockLevel,
    required this.categoryId,
    required this.supplierId,
    this.discount,
    this.minimumOrderQuantity,
  });
  
  // From JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'pcs',
      imageUrl: json['image_url'],
      stockLevel: json['stock_level'] ?? 0,
      categoryId: json['category_id']?.toString() ?? '',
      supplierId: json['supplier_id']?.toString() ?? '',
      discount: json['discount']?.toDouble(),
      minimumOrderQuantity: json['minimum_order_quantity'],
    );
  }
  
  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'image_url': imageUrl,
      'stock_level': stockLevel,
      'category_id': categoryId,
      'supplier_id': supplierId,
      'discount': discount,
      'minimum_order_quantity': minimumOrderQuantity,
    };
  }
  
  // Calculate final price with discount
  double get finalPrice {
    if (discount != null && discount! > 0) {
      return price * (1 - discount! / 100);
    }
    return price;
  }
  
  // Check if product is in stock
  bool get isInStock => stockLevel > 0;
}