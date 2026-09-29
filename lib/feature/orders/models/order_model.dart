import 'package:pebble_type/feature/products/models/product_model.dart';

class OrderItemModel {
  final int id;
  final ProductModel product;
  final ProductVariantModel? variant;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  OrderItemModel({
    required this.id,
    required this.product,
    required this.variant,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      variant: json['variant'] != null
          ? ProductVariantModel.fromJson(
              json['variant'] as Map<String, dynamic>,
            )
          : null,
      quantity: json['quantity'] as int,
      unitPrice: json['unit_price'] != null
          ? double.tryParse(json['unit_price'].toString()) ?? 0.0
          : 0.0,
      lineTotal: json['line_total'] != null
          ? double.tryParse(json['line_total'].toString()) ?? 0.0
          : 0.0,
    );
  }
}

class OrderModel {
  final int id;
  final String status;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final double totalAmount;
  final double subtotalAmount;
  final double discountAmount;
  final String appliedOfferName;
  final List<OrderItemModel> items;
  final DateTime createdAt;

  // Shipping dispatch fields
  final String carrier;
  final String trackingNumber;
  final String handledBy;
  final DateTime? estimatedDelivery;
  final String shippingNotes;
  final DateTime? shippedAt;

  OrderModel({
    required this.id,
    required this.status,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.totalAmount,
    this.subtotalAmount = 0,
    this.discountAmount = 0,
    this.appliedOfferName = '',
    required this.items,
    required this.createdAt,
    this.carrier = '',
    this.trackingNumber = '',
    this.handledBy = '',
    this.estimatedDelivery,
    this.shippingNotes = '',
    this.shippedAt,
  });

  bool get hasTracking => trackingNumber.isNotEmpty;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      status: json['status'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      addressLine1: json['address_line1'] as String,
      addressLine2: json['address_line2'] as String? ?? '',
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postal_code'] as String,
      country: json['country'] as String,
      totalAmount: json['total_amount'] != null
          ? double.tryParse(json['total_amount'].toString()) ?? 0.0
          : 0.0,
      subtotalAmount:
          double.tryParse(json['subtotal_amount']?.toString() ?? '') ?? 0.0,
      discountAmount:
          double.tryParse(json['discount_amount']?.toString() ?? '') ?? 0.0,
      appliedOfferName: json['applied_offer_name'] as String? ?? '',
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      carrier: json['carrier'] as String? ?? '',
      trackingNumber: json['tracking_number'] as String? ?? '',
      handledBy: json['handled_by'] as String? ?? '',
      estimatedDelivery: json['estimated_delivery'] != null
          ? DateTime.tryParse(json['estimated_delivery'] as String)
          : null,
      shippingNotes: json['shipping_notes'] as String? ?? '',
      shippedAt: json['shipped_at'] != null
          ? DateTime.tryParse(json['shipped_at'] as String)
          : null,
    );
  }
}
