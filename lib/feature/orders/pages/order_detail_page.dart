import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/theme/app_text_styles.dart';
import 'package:pebble_type/core/services/order_service.dart';
import 'package:pebble_type/feature/orders/models/order_model.dart';
import 'package:pebble_type/feature/orders/widgets/order_status_badge.dart';
import 'package:pebble_type/feature/orders/widgets/order_tracking_timeline.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailPage extends StatefulWidget {
  /// Pre-loaded order (used as a cache when navigating from the list).
  final OrderModel? order;

  /// Order id to resolve when no [order] is supplied (deep link/refresh).
  final int? orderId;

  const OrderDetailPage({super.key, this.order, this.orderId})
    : assert(
        order != null || orderId != null,
        'Either order or orderId must be provided',
      );

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  OrderModel? _order;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _load();
  }

  Future<void> _load() async {
    final id = widget.orderId ?? widget.order!.id;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final order = await OrderService.getOrder(id);
      if (mounted) {
        setState(() {
          _order = order;
          _loading = false;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Could not refresh this order. Try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    if (order != null) {
      return _OrderDetailView(
        order: order,
        onRefresh: _load,
        refreshing: _loading,
        error: _error,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: const Text(
          'Order',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator(color: AppColors.primary)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  const Text('Could not load this order.'),
                  const SizedBox(height: AppDimensions.spacingSm),
                  FilledButton(onPressed: _load, child: const Text('Retry')),
                ],
              ),
      ),
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  final OrderModel order;
  final Future<void> Function() onRefresh;
  final bool refreshing;
  final String? error;
  const _OrderDetailView({
    required this.order,
    required this.onRefresh,
    required this.refreshing,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          'Order #${order.id}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh order status',
            onPressed: refreshing ? null : onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (refreshing) const LinearProgressIndicator(),
                  if (error != null) ...[
                    Text(
                      error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                  ],
                  _Section(
                    title: 'Status',
                    child: OrderStatusBadge(status: order.status),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),

                  OrderTrackingTimeline(order: order),
                  const SizedBox(height: AppDimensions.spacingMd),

                  // ── Tracking / Shipping card ─────────────────────────
                  if (order.status == 'shipped' ||
                      order.status == 'delivered') ...[
                    _TrackingCard(order: order),
                    const SizedBox(height: AppDimensions.spacingMd),
                  ],

                  _Section(
                    title: 'Shipping Address',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.fullName, style: AppTextStyles.bodyMd),
                        Text(
                          order.phone,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXm),
                        Text(order.addressLine1, style: AppTextStyles.bodyMd),
                        if (order.addressLine2.isNotEmpty)
                          Text(order.addressLine2, style: AppTextStyles.bodyMd),
                        Text(
                          '${order.city}, ${order.state} ${order.postalCode}',
                          style: AppTextStyles.bodyMd,
                        ),
                        Text(order.country, style: AppTextStyles.bodyMd),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  _Section(
                    title: 'Items',
                    child: Column(
                      children: order.items
                          .map((item) => _OrderItemRow(item: item))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimensions.spacingMd),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLg,
                      ),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Subtotal'),
                            Text(
                              '\$${order.subtotalAmount.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                        if (order.discountAmount > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  order.appliedOfferName.isEmpty
                                      ? 'Discount'
                                      : order.appliedOfferName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '-\$${order.discountAmount.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ],
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: AppTextStyles.bodyLg.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '\$${order.totalAmount.toStringAsFixed(2)}',
                              style: AppTextStyles.bodyLg.copyWith(
                                fontWeight: FontWeight.w600,
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
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          child,
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final OrderItemModel item;
  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            child: SizedBox(
              width: 52,
              height: 52,
              child: item.product.primaryImageUrl != null
                  ? Image.network(
                      item.product.primaryImageUrl!,
                      fit: BoxFit.cover,
                      cacheWidth: 150,
                      gaplessPlayback: true,
                      errorBuilder: (context, error, stackTrace) =>
                          _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: AppTextStyles.bodyMd,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.variant != null)
                  Text(
                    '${item.variant!.color} · ${item.variant!.size}',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'x${item.quantity}',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '\$${item.lineTotal.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.background,
    child: const Icon(Icons.image_outlined, color: AppColors.border, size: 24),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Store-managed shipping information. Carrier scan updates are not available.
// ─────────────────────────────────────────────────────────────────────────────
const _carrierNames = {
  'fedex': 'FedEx',
  'dhl': 'DHL',
  'ups': 'UPS',
  'usps': 'USPS',
  'local': 'Local Courier',
  'other': 'Courier',
};

class _TrackingCard extends StatelessWidget {
  final OrderModel order;
  const _TrackingCard({required this.order});

  Future<void> _openCarrier(BuildContext context) async {
    final uri = Uri.tryParse(order.trackingUrl);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return;
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // Keep the tracking number available to copy if the device cannot open links.
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open the carrier link. Copy the tracking number instead.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final carrierName =
        _carrierNames[order.carrier] ??
        (order.carrier.isEmpty ? 'Courier' : order.carrier);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: const Color(0xFF90CAF9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: 10,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFBBDEFB),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusLg),
                topRight: Radius.circular(AppDimensions.radiusLg),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  size: 16,
                  color: Color(0xFF1565C0),
                ),
                const SizedBox(width: 8),
                Text(
                  order.status == 'delivered'
                      ? 'Your Order Was Delivered'
                      : 'Your Order Is On Its Way',
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carrier + tracking number row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Carrier',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            carrierName,
                            style: AppTextStyles.bodyMd.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (order.estimatedDelivery != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Est. Delivery',
                              style: AppTextStyles.labelSm.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'MMM d, yyyy',
                              ).format(order.estimatedDelivery!),
                              style: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                if (order.trackingNumber.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingMd),
                  Text(
                    'Tracking Number',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: order.trackingNumber),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tracking number copied'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSm,
                        ),
                        border: Border.all(color: const Color(0xFF90CAF9)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.trackingNumber,
                              style: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: const Color(0xFF1565C0),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.copy_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: AppDimensions.spacingMd),
                  Text(
                    'A tracking number has not been added yet. Check back for an update.',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],

                if (order.trackingUrl.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingMd),
                  OutlinedButton.icon(
                    onPressed: () => _openCarrier(context),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Track with carrier'),
                  ),
                ],

                if (order.shippingNotes.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingMd),
                  Text(
                    'Note',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(order.shippingNotes, style: AppTextStyles.bodyMd),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
