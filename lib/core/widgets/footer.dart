import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pebble_type/core/services/api_client.dart';
import 'package:pebble_type/feature/home/providers/home_provider.dart';

/// 1:1 Implementation of Authentic Shopify Pebble Dark Footer
/// (sections--20816632381578__footer).
///
/// Features:
/// - Sleek pure black canvas (#000000)
/// - Integrated Newsletter row:
///   - Headline: "Subscribe for updates,\ntips & exclusive offers"
///   - White rounded pill input box with circular black submit button
///   - Terms & Privacy agreement disclaimer
/// - 4 Navigation Columns:
///   - Company (Our Story, Contact, FAQs, Blog, Find a Store)
///   - Collection (Just Dropped, Best Sellers, Clothing, Pants, Shirts, Jeans)
///   - Get Help (Help Center, Live Chat, Return Policy, Shipping Info, Bulk Orders)
///   - Follow Us on Instagram (3 authentic 100x100 rounded lifestyle photos + @littlepebble.co)
/// - Social icon buttons (X, Instagram, TikTok, Pinterest) & Legal links
/// - Sub-footer bar: Copyright, Currency/Country selector, and Payment method badges
class AppFooter extends ConsumerStatefulWidget {
  const AppFooter({super.key});

  @override
  ConsumerState<AppFooter> createState() => _AppFooterState();
}

class _AppFooterState extends ConsumerState<AppFooter> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSubscribed = false;
  String? _subscribeError;
  Map<String, dynamic>? get _settings =>
      ref.read(homeProvider).value?.footerSettings;
  List<Map<String, dynamic>> get _links =>
      ref.read(homeProvider).value?.footerLinks ?? const [];
  List<Map<String, dynamic>> get _instagramImages =>
      ref.read(homeProvider).value?.footerInstagramImages ?? const [];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSubscribe() async {
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      setState(() => _subscribeError = 'Enter a valid email address.');
      return;
    }
    try {
      await ApiClient.dio.post('home/newsletter/', data: {'email': email});
      if (mounted) {
        setState(() {
          _isSubscribed = true;
          _subscribeError = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _subscribeError = 'Signup failed. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeData = ref.watch(homeProvider).value;
    if (homeData != null &&
        homeData.hasManagedFooter &&
        homeData.footerSettings == null) {
      return const SizedBox.shrink();
    }
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 960;
    final isTablet = screenWidth >= 640 && screenWidth < 960;

    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: EdgeInsets.only(
        top: isDesktop ? 64.0 : 44.0,
        bottom: isDesktop
            ? 40.0
            : 88.0, // extra clearance for mobile bottom bar
        left: isDesktop ? 48.0 : 20.0,
        right: isDesktop ? 48.0 : 20.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1360),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Top Row: Integrated Newsletter ────────────────
              _buildNewsletterRow(context, isDesktop),

              // ── Divider ──────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isDesktop ? 44.0 : 32.0,
                ),
                child: Divider(
                  color: Colors.white.withValues(alpha: 0.12),
                  height: 1.0,
                  thickness: 1.0,
                ),
              ),

              // ── 2. Middle Row: 4 Navigation Columns ──────────────
              _buildNavigationColumns(context, isDesktop, isTablet),

              // ── Divider ──────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isDesktop ? 44.0 : 32.0,
                ),
                child: Divider(
                  color: Colors.white.withValues(alpha: 0.12),
                  height: 1.0,
                  thickness: 1.0,
                ),
              ),

              // ── 3. Bottom Row: Social & Legal ────────────────────
              _buildSocialAndLegalRow(context, isDesktop),

              const SizedBox(height: 28.0),

              // ── 4. Sub-Footer: Copyright, Currency & Payments ────
              _buildSubFooterRow(context, isDesktop),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 1. Integrated Newsletter
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildNewsletterRow(BuildContext context, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Headline on Left
          Expanded(
            child: Text(
              '${_settings?['newsletter_heading'] ?? 'Subscribe for updates,\ntips & exclusive offers'}',
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 36.0,
                fontWeight: FontWeight.w800,
                height: 1.15,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 48.0),

          // Input Box & Disclaimer on Right
          SizedBox(
            width: 440.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEmailInputPill(),
                if (_subscribeError != null)
                  Text(
                    _subscribeError!,
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),
                const SizedBox(height: 10.0),
                _buildAgreementDisclaimer(context),
              ],
            ),
          ),
        ],
      );
    }

    // Mobile / Tablet stacked
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_settings?['newsletter_heading'] ?? 'Subscribe for updates,\ntips & exclusive offers'}',
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 26.0,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.4,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20.0),
        _buildEmailInputPill(),
        if (_subscribeError != null)
          Text(
            _subscribeError!,
            style: const TextStyle(color: Colors.orangeAccent),
          ),
        const SizedBox(height: 10.0),
        _buildAgreementDisclaimer(context),
      ],
    );
  }

  Widget _buildEmailInputPill() {
    if (_isSubscribed) {
      return Container(
        height: 52.0,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E22),
          borderRadius: BorderRadius.circular(40.0),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF4ADE80),
              size: 20.0,
            ),
            const SizedBox(width: 10.0),
            Text(
              'Thank you for subscribing!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 52.0,
      padding: const EdgeInsets.only(
        left: 20.0,
        right: 5.0,
        top: 4.0,
        bottom: 4.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _onSubscribe(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14.0,
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'Enter your email',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 14.0,
                  color: const Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          _NewsletterSubmitButton(onTap: _onSubscribe),
        ],
      ),
    );
  }

  Widget _buildAgreementDisclaimer(BuildContext context) {
    final disclaimer = '${_settings?['newsletter_disclaimer'] ?? ''}';
    if (disclaimer.isNotEmpty) {
      return Text(
        disclaimer,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: const Color(0xFF94A3B8),
        ),
      );
    }
    return Text.rich(
      TextSpan(
        text: 'By subscribing you agree to the ',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12.0,
          color: const Color(0xFF94A3B8),
          height: 1.4,
        ),
        children: [
          TextSpan(
            text: 'Terms of Use',
            style: const TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.white,
            ),
          ),
          const TextSpan(text: ' & '),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.white,
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 2. Navigation Columns
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildNavigationColumns(
    BuildContext context,
    bool isDesktop,
    bool isTablet,
  ) {
    const companyLinks = [
      _NavLink('Our Story', '/pages/our-story'),
      _NavLink('Contact', '/pages/contact'),
      _NavLink('FAQs', '/pages/faqs'),
      _NavLink('Blog', '/blogs/news'),
      _NavLink('Find a Store', '/pages/find-a-store'),
    ];

    const collectionLinks = [
      _NavLink('Just Dropped', '/collections/new-arrivals'),
      _NavLink('Best Sellers', '/collections/best-sellers'),
      _NavLink('Clothing', '/collections/clothing'),
      _NavLink('Pants', '/collections/pants'),
      _NavLink('Shirts', '/collections/shirts'),
      _NavLink('Jeans', '/products/denim-jeans-kids'),
    ];

    const helpLinks = [
      _NavLink('Help Center', '/pages/help-center'),
      _NavLink('Live Chat', '/pages/contact'),
      _NavLink('Return Policy', '/pages/returns-refunds'),
      _NavLink('Shipping Info', '/pages/orders-shipping'),
      _NavLink('Bulk Orders', '/pages/track-order'),
    ];
    List<_NavLink> managed(String column, List<_NavLink> fallback) {
      if (_links.isEmpty &&
          ref.read(homeProvider).value?.hasManagedFooter != true) {
        return fallback;
      }
      return [
        for (final link in _links)
          if (link['column'] == column)
            _NavLink('${link['label'] ?? ''}', '${link['route'] ?? '#'}'),
      ];
    }

    final visibleCompanyLinks = managed('company', companyLinks);
    final visibleCollectionLinks = managed('collection', collectionLinks);
    final visibleHelpLinks = managed('help', helpLinks);

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _NavColumn(title: 'Company', links: visibleCompanyLinks),
          ),
          Expanded(
            flex: 2,
            child: _NavColumn(
              title: 'Collection',
              links: visibleCollectionLinks,
            ),
          ),
          Expanded(
            flex: 2,
            child: _NavColumn(title: 'Get Help', links: visibleHelpLinks),
          ),
          const SizedBox(width: 24.0),
          Expanded(
            flex: 5,
            child: _InstagramColumn(
              settings: _settings,
              images: _instagramImages,
            ),
          ),
        ],
      );
    }

    if (isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _NavColumn(title: 'Company', links: visibleCompanyLinks),
              ),
              Expanded(
                child: _NavColumn(
                  title: 'Collection',
                  links: visibleCollectionLinks,
                ),
              ),
              Expanded(
                child: _NavColumn(title: 'Get Help', links: visibleHelpLinks),
              ),
            ],
          ),
          const SizedBox(height: 36.0),
          _InstagramColumn(settings: _settings, images: _instagramImages),
        ],
      );
    }

    // Mobile View: Compact stacked columns
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _NavColumn(title: 'Company', links: visibleCompanyLinks),
            ),
            Expanded(
              child: _NavColumn(
                title: 'Collection',
                links: visibleCollectionLinks,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28.0),
        _NavColumn(title: 'Get Help', links: visibleHelpLinks),
        const SizedBox(height: 32.0),
        _InstagramColumn(settings: _settings, images: _instagramImages),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 3. Social & Legal Row
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSocialAndLegalRow(BuildContext context, bool isDesktop) {
    final socialIcons = [
      _SocialBtn(
        icon: Icons.close_rounded,
        label: 'X',
        link: '${_settings?['x_url'] ?? 'https://x.com'}',
      ),
      _SocialBtn(
        icon: Icons.camera_alt_outlined,
        label: 'Instagram',
        link: '${_settings?['instagram_url'] ?? 'https://instagram.com'}',
      ),
      _SocialBtn(
        icon: Icons.music_note_rounded,
        label: 'TikTok',
        link: '${_settings?['tiktok_url'] ?? 'https://tiktok.com'}',
      ),
      _SocialBtn(
        icon: Icons.push_pin_outlined,
        label: 'Pinterest',
        link: '${_settings?['pinterest_url'] ?? 'https://pinterest.com'}',
      ),
    ];

    final legalLinks = [
      _LegalLink(label: 'Accessibility', route: '/pages/accessibility'),
      _LegalLink(
        label: 'Terms of Service',
        route: '/policies/terms-of-service',
      ),
      _LegalLink(label: 'Privacy Policy', route: '/policies/privacy-policy'),
    ];
    if (_links.isNotEmpty) {
      legalLinks
        ..clear()
        ..addAll([
          for (final link in _links)
            if (link['column'] == 'legal')
              _LegalLink(
                label: '${link['label'] ?? ''}',
                route: '${link['route'] ?? '#'}',
              ),
        ]);
    }

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Social Buttons on Left
          Row(
            children: [
              for (final btn in socialIcons) ...[
                btn,
                const SizedBox(width: 10.0),
              ],
            ],
          ),

          // Legal Links on Right
          Row(
            children: [
              for (int i = 0; i < legalLinks.length; i++) ...[
                legalLinks[i],
                if (i < legalLinks.length - 1) const SizedBox(width: 24.0),
              ],
            ],
          ),
        ],
      );
    }

    // Mobile
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (final btn in socialIcons) ...[
              btn,
              const SizedBox(width: 10.0),
            ],
          ],
        ),
        const SizedBox(height: 20.0),
        Wrap(spacing: 18.0, runSpacing: 10.0, children: legalLinks),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 4. Sub-Footer Row: Copyright, Currency & Payment Badges
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildSubFooterRow(BuildContext context, bool isDesktop) {
    final copyrightText =
        '${_settings?['copyright_text'] ?? '© 2026 Pebble Little, Powered by Shopify'}';

    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Copyright
          Text(
            copyrightText,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: const Color(0xFF71717A),
            ),
          ),

          // Currency Pill & Payment Icons
          Row(
            children: [
              _buildCurrencyPill(),
              const SizedBox(width: 18.0),
              _buildPaymentBadges(),
            ],
          ),
        ],
      );
    }

    // Mobile
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [_buildCurrencyPill()]),
        const SizedBox(height: 16.0),
        _buildPaymentBadges(),
        const SizedBox(height: 16.0),
        Text(
          copyrightText,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.0,
            color: const Color(0xFF71717A),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: const Color(0xFF141417),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🇺🇸', style: TextStyle(fontSize: 14.0)),
          const SizedBox(width: 6.0),
          Text(
            'USD/ EN',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4.0),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 16.0,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBadges() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        _PaymentBadge(label: 'VISA', bg: Color(0xFF1A1F71), fg: Colors.white),
        SizedBox(width: 6.0),
        _PaymentBadge(label: 'MC', bg: Color(0xFFEB001B), fg: Colors.white),
        SizedBox(width: 6.0),
        _PaymentBadge(label: 'AMEX', bg: Color(0xFF006FCF), fg: Colors.white),
        SizedBox(width: 6.0),
        _PaymentBadge(label: 'PayPal', bg: Color(0xFF003087), fg: Colors.white),
        SizedBox(width: 6.0),
        _PaymentBadge(label: 'Pay', bg: Colors.white, fg: Colors.black),
        SizedBox(width: 6.0),
        _PaymentBadge(label: 'DISC', bg: Color(0xFFFF6000), fg: Colors.white),
      ],
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Subcomponents
// ────────────────────────────────────────────────────────────────────────────

class _NewsletterSubmitButton extends StatefulWidget {
  final VoidCallback onTap;

  const _NewsletterSubmitButton({required this.onTap});

  @override
  State<_NewsletterSubmitButton> createState() =>
      _NewsletterSubmitButtonState();
}

class _NewsletterSubmitButtonState extends State<_NewsletterSubmitButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 42.0,
          height: 42.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0F172A),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8.0,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Center(
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 180),
              offset: _isHovered
                  ? const Offset(0.12, 0.0)
                  : const Offset(0.0, 0.0),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 18.0,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavLink {
  final String label;
  final String route;
  const _NavLink(this.label, this.route);
}

class _NavColumn extends StatelessWidget {
  final String title;
  final List<_NavLink> links;

  const _NavColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15.0,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 18.0),
        for (final link in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _HoverLink(label: link.label, route: link.route),
          ),
      ],
    );
  }
}

class _HoverLink extends StatefulWidget {
  final String label;
  final String route;

  const _HoverLink({required this.label, required this.route});

  @override
  State<_HoverLink> createState() => _HoverLinkState();
}

class _HoverLinkState extends State<_HoverLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          final r = widget.route.trim();
          if (r.isNotEmpty && r != '#') {
            context.go(r);
          }
        },
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 160),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14.0,
            fontWeight: _isHovered ? FontWeight.w500 : FontWeight.w400,
            color: _isHovered ? Colors.white : const Color(0xFFA1A1AA),
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

class _InstagramColumn extends StatelessWidget {
  final Map<String, dynamic>? settings;
  final List<Map<String, dynamic>> images;
  const _InstagramColumn({this.settings, this.images = const []});

  static const _images = [
    'assets/images/instagram_1.webp',
    'assets/images/instagram_2.webp',
    'assets/images/instagram_3.webp',
  ];

  @override
  Widget build(BuildContext context) {
    final imagePaths = images.isEmpty
        ? _images
        : images.take(3).map((item) => '${item['image'] ?? ''}').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${settings?['instagram_heading'] ?? 'Follow Us on Instagram'}',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15.0,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 18.0),

        // 3 Square Lifestyle Photos
        Row(
          children: [
            for (int i = 0; i < imagePaths.length; i++) ...[
              Expanded(child: _InstagramPhoto(assetPath: imagePaths[i])),
              if (i < imagePaths.length - 1) const SizedBox(width: 12.0),
            ],
          ],
        ),
        const SizedBox(height: 14.0),

        // @littlepebble.co Handle
        _HoverLink(
          label: '${settings?['instagram_handle'] ?? '@littlepebble.co'}',
          route:
              '${settings?['instagram_url'] ?? 'https://instagram.com/shopify'}',
        ),
      ],
    );
  }
}

class _InstagramPhoto extends StatefulWidget {
  final String assetPath;

  const _InstagramPhoto({required this.assetPath});

  @override
  State<_InstagramPhoto> createState() => _InstagramPhotoState();
}

class _InstagramPhotoState extends State<_InstagramPhoto> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            scale: _isHovered ? 1.06 : 1.0,
            child: widget.assetPath.startsWith('http')
                ? Image.network(
                    widget.assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.camera_alt_outlined),
                  )
                : Image.asset(
                    widget.assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFF27272A),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white38,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SocialBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final String link;

  const _SocialBtn({
    required this.icon,
    required this.label,
    required this.link,
  });

  @override
  State<_SocialBtn> createState() => _SocialBtnState();
}

class _SocialBtnState extends State<_SocialBtn> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: _isHovered
              ? Colors.white.withValues(alpha: 0.22)
              : const Color(0xFF1E1E22),
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
            width: 1.0,
          ),
        ),
        child: Center(
          child: Icon(widget.icon, size: 18.0, color: Colors.white),
        ),
      ),
    );
  }
}

class _LegalLink extends StatefulWidget {
  final String label;
  final String route;

  const _LegalLink({required this.label, required this.route});

  @override
  State<_LegalLink> createState() => _LegalLinkState();
}

class _LegalLinkState extends State<_LegalLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          final r = widget.route.trim();
          if (r.isNotEmpty && r != '#') {
            context.go(r);
          }
        },
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 160),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.0,
            fontWeight: _isHovered ? FontWeight.w500 : FontWeight.w400,
            color: _isHovered ? Colors.white : const Color(0xFF94A3B8),
          ),
          child: Text(widget.label),
        ),
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _PaymentBadge({
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38.0,
      height: 24.0,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 0.6,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w900,
            color: fg,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
