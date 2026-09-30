import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/services/order_service.dart';
import 'package:pebble_type/core/theme/app_text_styles.dart';
import 'package:pebble_type/feature/cart/models/cart_model.dart';
import 'package:pebble_type/feature/cart/widgets/price_breakdown.dart';
import 'package:pebble_type/feature/cart/providers/cart_provider.dart';
import 'package:pebble_type/feature/orders/providers/order_provider.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _address1Ctrl = TextEditingController();
  final _address2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'US');

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    // Force a fresh fetch from server so cart state is never stale
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(cartProvider);
    });
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _address1Ctrl.dispose();
    _address2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _postalCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(CartModel cart) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
    });
    try {
      final order = await OrderService.placeOrder(
        fullName: _fullNameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        addressLine1: _address1Ctrl.text.trim(),
        addressLine2: _address2Ctrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        postalCode: _postalCtrl.text.trim(),
        country: _countryCtrl.text.trim(),
      );

      ref.read(lastOrderProvider.notifier).state = order;
      ref.invalidate(cartProvider); // cart is now empty on server
      ref.invalidate(ordersProvider);
      if (mounted) {
        context.go('${AppRoutes.orderConfirmation}?order_id=${order.id}');
      }
    } catch (e) {
      String message = 'Failed to place order. Please try again.';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map && data['detail'] != null) {
          message = data['detail'] as String;
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);
    final cart = cartAsync.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: const Text('Checkout', style: AppTextStyles.pageTitle),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: cartAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartAsync.hasError
          ? Center(
              child: Text(
                'Failed to load cart.',
                style: TextStyle(color: AppColors.error),
              ),
            )
          : cart == null || cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: AppColors.border,
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.home),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacingMd),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel(text: 'Shipping Address'),
                          const SizedBox(height: AppDimensions.spacingMd),
                          _Field(
                            controller: _fullNameCtrl,
                            label: 'Full Name',
                            validator: _required,
                          ),
                          _Field(
                            controller: _phoneCtrl,
                            label: 'Phone',
                            keyboardType: TextInputType.phone,
                            validator: _required,
                          ),
                          _Field(
                            controller: _address1Ctrl,
                            label: 'Address Line 1',
                            validator: _required,
                          ),
                          _Field(
                            controller: _address2Ctrl,
                            label: 'Address Line 2 (optional)',
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _Field(
                                  controller: _cityCtrl,
                                  label: 'City',
                                  validator: _required,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spacingSm),
                              Expanded(
                                child: _Field(
                                  controller: _stateCtrl,
                                  label: 'State',
                                  validator: _required,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _Field(
                                  controller: _postalCtrl,
                                  label: 'Postal Code',
                                  keyboardType: TextInputType.number,
                                  validator: _required,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.spacingSm),
                              Expanded(
                                child: _Field(
                                  controller: _countryCtrl,
                                  label: 'Country',
                                  validator: _required,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.spacingLg),
                          _SectionLabel(text: 'Order Summary'),
                          const SizedBox(height: AppDimensions.spacingMd),
                          _OrderSummaryCard(cart: cart),
                          const SizedBox(height: AppDimensions.spacingSm),
                          Text(
                            'This local showcase records an order without taking payment.',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingLg),
                          SizedBox(
                            width: double.infinity,
                            height: AppDimensions.buttonHeight,
                            child: ElevatedButton(
                              onPressed: _loading ? null : () => _submit(cart),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusMd,
                                  ),
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Place Order',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingLg),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
}

// helpers ----------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: AppTextStyles.bodyMd,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingMd,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            borderSide: const BorderSide(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  final CartModel cart;
  const _OrderSummaryCard({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ...cart.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.product.name} × ${item.quantity}',
                      style: AppTextStyles.bodyMd,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '\$${item.lineTotal.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyMd,
                  ),
                ],
              ),
            ),
          ),
          PriceBreakdown(cart: cart),
        ],
      ),
    );
  }
}
