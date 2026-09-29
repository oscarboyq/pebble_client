import 'package:pebble_type/feature/products/models/product_model.dart';

class CartOfferModel {
  final String type;
  final String name;
  final String? code;
  final int? pairs;

  const CartOfferModel({
    required this.type,
    required this.name,
    this.code,
    this.pairs,
  });

  factory CartOfferModel.fromJson(Map<String, dynamic> json) => CartOfferModel(
    type: json['type'] as String? ?? '',
    name: json['name'] as String? ?? '',
    code: json['code'] as String?,
    pairs: json['pairs'] as int?,
  );
}

class CartItemModel {
  final int id;
  final ProductModel product;
  final ProductVariantModel? variant;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
  final DateTime addedAt;

  CartItemModel({
    required this.id,
    required this.product,
    this.variant,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.addedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      variant: json['variant'] != null
          ? ProductVariantModel.fromJson(
              json['variant'] as Map<String, dynamic>,
            )
          : null,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      lineTotal: (json['line_total'] as num?)?.toDouble() ?? 0.0,
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  CartItemModel copywith({int? quantity, double? lineTotal}) {
    return CartItemModel(
      id: id,
      product: product,
      variant: variant,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice,
      lineTotal: lineTotal ?? this.lineTotal,
      addedAt: addedAt,
    );
  }
}

class CartModel {
  final int id;
  final List<CartItemModel> items;
  final double total;
  final double subtotal;
  final double discount;
  final CartOfferModel? appliedOffer;
  final String couponCode;
  final String? couponError;
  final int itemCount;
  final DateTime updatedAt;

  CartModel({
    required this.id,
    required this.items,
    required this.total,
    this.subtotal = 0,
    this.discount = 0,
    this.appliedOffer,
    this.couponCode = '',
    this.couponError,
    required this.itemCount,
    required this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] as int,
      items: (json['items'] as List<dynamic>)
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      subtotal:
          (json['subtotal'] as num?)?.toDouble() ??
          (json['total'] as num?)?.toDouble() ??
          0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      appliedOffer: json['applied_offer'] is Map<String, dynamic>
          ? CartOfferModel.fromJson(
              json['applied_offer'] as Map<String, dynamic>,
            )
          : null,
      couponCode: json['coupon_code'] as String? ?? '',
      couponError: json['coupon_error'] as String?,
      itemCount: json['item_count'] as int,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  factory CartModel.empty() {
    return CartModel(
      id: 0,
      items: [],
      total: 0.0,
      itemCount: 0,
      updatedAt: DateTime.now(),
    );
  }
}
