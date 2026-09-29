import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/widgets/reveal_on_scroll.dart';

/// 1:1 Implementation of Shopify Pebble Pre-Footer Trust Badges / Service Features
/// (sections--20816632381578__custom_section_4yLVt7).
///
/// Four editable trust messages. Fallback text describes the local showcase.
class TrustBadgesSection extends StatelessWidget {
  final List<Map<String, dynamic>> badges;
  const TrustBadgesSection({super.key, this.badges = const []});

  static const _items = [
    _TrustItem(
      icon: Icons.inventory_2_outlined,
      title: 'Browse freely',
      subtitle: 'Explore the local catalog and curated looks.',
    ),
    _TrustItem(
      icon: Icons.assignment_return_outlined,
      title: 'Clear totals',
      subtitle: 'Review cart pricing before checkout.',
    ),
    _TrustItem(
      icon: Icons.credit_card_outlined,
      title: 'Demo checkout',
      subtitle: 'Orders are recorded without payment.',
    ),
    _TrustItem(
      icon: Icons.chat_bubble_outline_rounded,
      title: 'Owner curated',
      subtitle: 'Stories and product pairings are editable.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = badges.isEmpty
        ? TrustBadgesSection._items
        : badges
              .map(
                (badge) => _TrustItem(
                  icon: switch (badge['icon_key']) {
                    'delivery' => Icons.inventory_2_outlined,
                    'returns' => Icons.assignment_return_outlined,
                    'payment' => Icons.credit_card_outlined,
                    _ => Icons.chat_bubble_outline_rounded,
                  },
                  title: '${badge['title'] ?? ''}',
                  subtitle: '${badge['subtitle'] ?? ''}',
                ),
              )
              .toList();
    if (items.length != 4) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 24,
          children: [
            for (final item in items)
              SizedBox(width: 220, child: _TrustBadgeCard(item: item)),
          ],
        ),
      );
    }
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 960;
    final isTablet = screenWidth >= 600 && screenWidth < 960;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 48.0 : 36.0,
        horizontal: isDesktop ? 48.0 : 20.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1360),
          child: Column(
            children: [
              // Subtle top divider line matching Shopify border
              Container(
                width: double.infinity,
                height: 1.0,
                color: const Color(0xFFF1F5F9),
              ),
              SizedBox(height: isDesktop ? 48.0 : 32.0),

              if (isDesktop)
                // ── Desktop: 4 Columns Row ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < items.length; i++) ...[
                      Expanded(
                        child: RevealOnScroll(
                          delay: Duration(milliseconds: i * 80),
                          child: _TrustBadgeCard(item: items[i]),
                        ),
                      ),
                      if (i < items.length - 1) const SizedBox(width: 32.0),
                    ],
                  ],
                )
              else if (isTablet)
                // ── Tablet: 2x2 Grid ──
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RevealOnScroll(
                            delay: const Duration(milliseconds: 0),
                            child: _TrustBadgeCard(item: items[0]),
                          ),
                        ),
                        const SizedBox(width: 24.0),
                        Expanded(
                          child: RevealOnScroll(
                            delay: const Duration(milliseconds: 80),
                            child: _TrustBadgeCard(item: items[1]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RevealOnScroll(
                            delay: const Duration(milliseconds: 160),
                            child: _TrustBadgeCard(item: items[2]),
                          ),
                        ),
                        const SizedBox(width: 24.0),
                        Expanded(
                          child: RevealOnScroll(
                            delay: const Duration(milliseconds: 240),
                            child: _TrustBadgeCard(item: items[3]),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                // ── Mobile: 2x2 Compact Grid ──
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _TrustBadgeCard(item: items[0])),
                        const SizedBox(width: 16.0),
                        Expanded(child: _TrustBadgeCard(item: items[1])),
                      ],
                    ),
                    const SizedBox(height: 28.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _TrustBadgeCard(item: items[2])),
                        const SizedBox(width: 16.0),
                        Expanded(child: _TrustBadgeCard(item: items[3])),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrustItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _TrustBadgeCard extends StatelessWidget {
  final _TrustItem item;

  const _TrustBadgeCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon
        Icon(item.icon, size: 34.0, color: const Color(0xFF0F172A)),
        const SizedBox(height: 12.0),

        // Title
        Text(
          item.title,
          textAlign: TextAlign.center,
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 4.0),

        // Subtitle
        Text(
          item.subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF64748B),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
