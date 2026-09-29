import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_strings.dart';
import 'package:pebble_type/core/providers/header_provider.dart';
import 'package:pebble_type/core/services/product_service.dart';
import 'package:pebble_type/core/widgets/pebble_image.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';
import 'package:pebble_type/feature/products/providers/product_providers.dart';

const _popularTerms = [
  'Softness Sweater',
  'Short',
  'Stripes Shirt',
  'Pants',
  'Linen',
];
const _featuredSlugs = ['print-tee-green', 'floral-pant-mint', 'wave-knit-top'];

/// Reuse current catalog images and prices for the reference's featured cards.
final searchFeaturedProductsProvider = FutureProvider<List<ProductModel>>((
  ref,
) async {
  final products = await Future.wait(
    _featuredSlugs.map((slug) async {
      try {
        return await ProductService.getProduct(slug);
      } catch (_) {
        return null;
      }
    }),
  );
  return products
      .whereType<ProductModel>()
      .where((product) => product.isActive)
      .toList();
});

class SearchOverlay extends ConsumerStatefulWidget {
  const SearchOverlay({super.key});

  @override
  ConsumerState<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends ConsumerState<SearchOverlay>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final AnimationController _animation;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animation.dispose();
    super.dispose();
  }

  void _close() => ref.read(isSearchOpenProvider.notifier).state = false;

  void _navigateTo(String route) {
    _close();
    context.push(route);
  }

  void _search(String term) {
    final query = term.trim();
    if (query.isNotEmpty) {
      _navigateTo('/search?q=${Uri.encodeComponent(query)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final anchor = ref.watch(searchAnchorProvider);
    final desktop = viewport.width >= 900 && anchor != null;
    final inputWidth = desktop ? 256.0 : viewport.width - 32;
    final inputLeft = desktop
        ? (anchor.right - inputWidth).clamp(
            12.0,
            viewport.width - inputWidth - 12,
          )
        : 16.0;
    final inputTop = desktop ? anchor.top - 2 : topInset + 12;
    final panelWidth = desktop ? 500.0 : viewport.width;
    final panelLeft = desktop
        ? (anchor.right - panelWidth).clamp(
            12.0,
            viewport.width - panelWidth - 12,
          )
        : 0.0;
    final panelTop = desktop ? anchor.bottom + 14 : topInset + 68;
    final query = _controller.text.trim();

    return Focus(
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          _close();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              top: panelTop,
              child: GestureDetector(
                key: const Key('search_scrim'),
                behavior: HitTestBehavior.opaque,
                onTap: _close,
                child: FadeTransition(
                  opacity: _animation,
                  child: ColoredBox(
                    color: Colors.black.withValues(alpha: 0.60),
                  ),
                ),
              ),
            ),
            if (!desktop)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: panelTop,
                child: const ColoredBox(color: Colors.white),
              ),
            Positioned(
              left: panelLeft,
              top: panelTop,
              width: panelWidth,
              child: FadeTransition(
                opacity: _animation,
                child: Material(
                  color: Colors.white,
                  borderRadius: desktop
                      ? const BorderRadius.vertical(bottom: Radius.circular(8))
                      : BorderRadius.zero,
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: (viewport.height - panelTop - 12).clamp(
                        0.0,
                        viewport.height,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: query.length < 2
                          ? _InitialSearchContent(
                              onSearch: _search,
                              onNavigate: _navigateTo,
                            )
                          : _SuggestionResults(
                              suggestionsAsync: ref.watch(
                                searchSuggestionsProvider(query),
                              ),
                              query: query,
                              onNavigate: _navigateTo,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: inputTop,
              left: inputLeft,
              width: inputWidth,
              height: 44,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF111111)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          onChanged: (_) => setState(() {}),
                          onSubmitted: _search,
                          textInputAction: TextInputAction.search,
                          style: GoogleFonts.bricolageGrotesque(fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: AppStrings.searchPrompt,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                              left: 15,
                              bottom: 2,
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close search',
                        onPressed: _close,
                        icon: const Icon(Icons.close, size: 19),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InitialSearchContent extends ConsumerWidget {
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onNavigate;

  const _InitialSearchContent({
    required this.onSearch,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(searchFeaturedProductsProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 27, 26, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SearchHeading('Popular Search'),
          const SizedBox(height: 15),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: _popularTerms
                .map(
                  (term) => ActionChip(
                    label: Text(term),
                    onPressed: () => onSearch(term),
                    backgroundColor: const Color(0xFFECECEC),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 3,
                    ),
                    shape: const StadiumBorder(),
                    labelStyle: GoogleFonts.bricolageGrotesque(
                      fontSize: 13,
                      color: const Color(0xFF595959),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          const _SearchHeading('Featured Products'),
          const SizedBox(height: 14),
          featured.when(
            loading: () => const SizedBox(
              height: 185,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (products) =>
                _FeaturedProducts(products: products, onNavigate: onNavigate),
          ),
        ],
      ),
    );
  }
}

class _SearchHeading extends StatelessWidget {
  final String text;
  const _SearchHeading(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.bricolageGrotesque(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF111111),
    ),
  );
}

class _FeaturedProducts extends StatelessWidget {
  final List<ProductModel> products;
  final ValueChanged<String> onNavigate;
  const _FeaturedProducts({required this.products, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 360;
        final cards = products
            .take(3)
            .map(
              (product) => SizedBox(
                width: narrow ? 135 : (constraints.maxWidth - 18) / 3,
                child: _FeaturedProductCard(
                  product: product,
                  onTap: () => onNavigate('/products/${product.slug}'),
                ),
              ),
            )
            .toList();
        if (narrow) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final card in cards) ...[card, const SizedBox(width: 9)],
              ],
            ),
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 9),
              cards[i],
            ],
          ],
        );
      },
    );
  }
}

class _FeaturedProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  const _FeaturedProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final price = product.priceAsDouble;
    final compare = product.compareAtPricesAsDouble;
    final onSale = compare != null && compare > price;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.76,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: PebbleImage.card(
                      imageUrl:
                          product.primaryCardImageUrl ??
                          product.primaryImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (product.badge.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: product.badge.toLowerCase() == 'sale'
                            ? const Color(0xFFC83320)
                            : const Color(0xFF59A977),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.badge,
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                '\$${price.toStringAsFixed(2)}',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: onSale ? const Color(0xFFD02F21) : Colors.black,
                ),
              ),
              if (onSale) ...[
                const SizedBox(width: 4),
                Text(
                  '\$${compare.toStringAsFixed(2)}',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 12,
                    color: const Color(0xFF777777),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionResults extends StatelessWidget {
  final AsyncValue<List<ProductSuggestion>> suggestionsAsync;
  final String query;
  final ValueChanged<String> onNavigate;

  const _SuggestionResults({
    required this.suggestionsAsync,
    required this.query,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(26),
    child: suggestionsAsync.when(
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, _) =>
          const Text('Suggestions are unavailable. Press Enter to search.'),
      data: (suggestions) {
        if (suggestions.isEmpty) {
          return Text(
            'No results for "$query"',
            style: GoogleFonts.bricolageGrotesque(fontSize: 13),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SearchHeading('Suggestions'),
            const SizedBox(height: 12),
            ...suggestions
                .take(6)
                .map(
                  (item) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      item.name,
                      style: GoogleFonts.bricolageGrotesque(fontSize: 13),
                    ),
                    trailing: const Icon(Icons.arrow_outward, size: 16),
                    onTap: () => onNavigate('/products/${item.slug}'),
                  ),
                ),
            TextButton(
              onPressed: () =>
                  onNavigate('/search?q=${Uri.encodeComponent(query)}'),
              child: const Text('View all results →'),
            ),
          ],
        );
      },
    ),
  );
}
