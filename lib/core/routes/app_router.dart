import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/services/storage_service.dart';
import 'package:pebble_type/core/widgets/main_shell.dart';
import 'package:pebble_type/feature/auth/pages/login_page.dart';
import 'package:pebble_type/feature/auth/pages/password_reset_pages.dart';
import 'package:pebble_type/feature/auth/pages/register_page.dart';
import 'package:pebble_type/feature/cart/pages/cart_page.dart';
import 'package:pebble_type/feature/collections/pages/collection_list_page.dart';
import 'package:pebble_type/feature/collections/pages/collections_index_page.dart';
import 'package:pebble_type/feature/content/pages/article_page.dart';
import 'package:pebble_type/feature/content/pages/blog_list_page.dart';
import 'package:pebble_type/feature/home/pages/home_page.dart';
import 'package:pebble_type/feature/home/pages/static_info_page.dart';
import 'package:pebble_type/feature/search/pages/search_results_page.dart';
import 'package:pebble_type/feature/orders/models/order_model.dart';
import 'package:pebble_type/feature/orders/pages/checkout_page.dart';
import 'package:pebble_type/feature/orders/pages/order_confirmation_page.dart';
import 'package:pebble_type/feature/orders/pages/order_detail_page.dart';
import 'package:pebble_type/feature/orders/pages/orders_page.dart';
import 'package:pebble_type/feature/products/pages/product_detail_page.dart';
import 'package:pebble_type/feature/products/pages/product_list_page.dart';
import 'package:pebble_type/feature/profile/pages/change_password_page.dart';
import 'package:pebble_type/feature/profile/pages/edit_profile_page.dart';
import 'package:pebble_type/feature/profile/pages/profile_page.dart';
import 'package:pebble_type/feature/reviews/pages/write_review_page.dart';
import 'package:pebble_type/feature/wishlist/pages/wishlist_page.dart';

abstract class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password/:uid/:token';
  static const String dashboard = '/';
  static const String home = '/products';
  static const String productDetails = '/products/:slug';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/detail';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  static const String wishlist = '/wishlist';
  static const String writeReview = '/products/:slug/review';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  errorBuilder: (context, state) =>
      _RouteNotFound(location: state.uri.toString()),
  redirect: (context, state) async {
    final token = await StorageService.getAccessToken();
    final loc = state.matchedLocation;
    final isOnAuth = loc == AppRoutes.login || loc == AppRoutes.register;
    if (token != null && isOnAuth) return AppRoutes.dashboard;

    final protectedPrefixes = [
      AppRoutes.checkout,
      AppRoutes.orders,
      AppRoutes.profile,
    ];
    final isProtected = protectedPrefixes.any((p) => loc.startsWith(p));
    if (token == null && isProtected) return AppRoutes.login;

    return null;
  },
  routes: [
    // ── Auth (no shell) ──────────────────────────────────────────
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      builder: (context, state) => ResetPasswordPage(
        uid: state.pathParameters['uid'] ?? '',
        token: state.pathParameters['token'] ?? '',
      ),
    ),

    // ── Checkout flow (no shell) ─────────────────────────────────
    GoRoute(
      path: AppRoutes.checkout,
      builder: (context, state) => const CheckoutPage(),
    ),
    GoRoute(
      path: AppRoutes.orderConfirmation,
      builder: (context, state) => const OrderConfirmationPage(),
    ),

    // ── Orders (no shell — pushed from profile / confirmation) ───
    GoRoute(
      path: AppRoutes.orders,
      builder: (context, state) => const OrdersPage(),
    ),
    GoRoute(
      path: '${AppRoutes.orderDetail}/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        final extra = state.extra;
        if (extra is OrderModel) return OrderDetailPage(order: extra);
        if (id == null) return const _OrderNotFound();
        return OrderDetailPage(orderId: id);
      },
    ),

    // ── Main shell with bottom navigation ───────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainShell(navigationShell: shell),
      branches: [
        // 0 · Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.dashboard,
              builder: (context, state) => const HomePage(),
              routes: [
                GoRoute(
                  path: 'pages/:slug',
                  builder: (context, state) {
                    final slug = state.pathParameters['slug'] ?? '';
                    return StaticInfoPage(slug: slug);
                  },
                ),
                GoRoute(
                  path: 'policies/:slug',
                  builder: (context, state) {
                    final slug = state.pathParameters['slug'] ?? '';
                    return StaticInfoPage(slug: slug);
                  },
                ),
                GoRoute(
                  path: 'search',
                  builder: (context, state) => const SearchResultsPage(),
                ),
                GoRoute(
                  path: 'blogs/:blog',
                  builder: (context, state) {
                    final blog = state.pathParameters['blog'] ?? 'news';
                    return BlogListPage(blog: blog);
                  },
                  routes: [
                    GoRoute(
                      path: ':slug',
                      builder: (context, state) {
                        final blog = state.pathParameters['blog'] ?? 'news';
                        final slug = state.pathParameters['slug'] ?? '';
                        return ArticlePage(blog: blog, slug: slug);
                      },
                    ),
                  ],
                ),
                GoRoute(
                  path: 'collections',
                  builder: (context, state) => const CollectionsIndexPage(),
                ),
                GoRoute(
                  path: 'collections/:slug',
                  builder: (context, state) {
                    final slug = state.pathParameters['slug'] ?? '';
                    final title = state.extra as String?;
                    return CollectionListPage(slug: slug, title: title);
                  },
                ),
              ],
            ),
          ],
        ),

        // 1 · Shop
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const ProductListPage(),
              routes: [
                GoRoute(
                  path: ':slug',
                  builder: (context, state) {
                    final slug = state.pathParameters['slug']!;
                    return ProductDetailPage(slug: slug);
                  },
                  routes: [
                    GoRoute(
                      path: 'review',
                      builder: (context, state) {
                        final slug = state.pathParameters['slug']!;
                        final name = state.extra as String? ?? '';
                        return WriteReviewPage(
                          productSlug: slug,
                          productName: name,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // 2 · Wishlist
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.wishlist,
              builder: (context, state) => const WishlistPage(),
            ),
          ],
        ),

        // 3 · Cart
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.cart,
              builder: (context, state) => const CartPage(),
            ),
          ],
        ),

        // 4 · Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfilePage(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => const EditProfilePage(),
                ),
                GoRoute(
                  path: 'change-password',
                  builder: (context, state) => const ChangePasswordPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

class _RouteNotFound extends StatelessWidget {
  final String location;

  const _RouteNotFound({required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.explore_off_outlined,
              size: 56,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Page not found',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              location,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderNotFound extends StatelessWidget {
  const _OrderNotFound();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Order'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Order not found.'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.go(AppRoutes.orders),
              child: const Text('Back to Orders'),
            ),
          ],
        ),
      ),
    );
  }
}
