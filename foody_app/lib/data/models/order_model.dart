import 'cart_item_model.dart';

enum OrderStatus {
  pending,
  accepted,
  rejected,
  inProgress,
  delivered,
  cancelled,
}

class OrderModel {
  final String id;
  final String userId;
  final String supplierId;
  final List<CartItemModel> items;
  final double totalAmount;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? deliveryAddress;
  final String? notes;
  final String? rejectionReason;

  OrderModel({
    required this.id,
    required this.userId,
    required this.supplierId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.deliveryAddress,
    this.notes,
    this.rejectionReason,
  });

  // From JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      supplierId: json['supplier_id']?.toString() ?? '',
      items: (json['items'] as List?)
              ?.map((item) => CartItemModel.fromJson(item))
              .toList() ??
          [],
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      status: _parseStatus(json['status']),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      deliveryAddress: json['delivery_address'],
      notes: json['notes'],
      rejectionReason: json['rejection_reason'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'supplier_id': supplierId,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'delivery_address': deliveryAddress,
      'notes': notes,
      'rejection_reason': rejectionReason,
    };
  }

  // Parse status from string
  static OrderStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':
        return OrderStatus.accepted;
      case 'rejected':
        return OrderStatus.rejected;
      case 'in_progress':
      case 'inprogress':
        return OrderStatus.inProgress;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  // Get status display text
  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.rejected:
        return 'Rejected';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Get status color
  String get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return 'orange';
      case OrderStatus.accepted:
        return 'blue';
      case OrderStatus.rejected:
        return 'red';
      case OrderStatus.inProgress:
        return 'purple';
      case OrderStatus.delivered:
        return 'green';
      case OrderStatus.cancelled:
        return 'grey';
    }
  }

  // Copy with
  OrderModel copyWith({
    String? id,
    String? userId,
    String? supplierId,
    List<CartItemModel>? items,
    double? totalAmount,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deliveryAddress,
    String? notes,
    String? rejectionReason,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      supplierId: supplierId ?? this.supplierId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      notes: notes ?? this.notes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}