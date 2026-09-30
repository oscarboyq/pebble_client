# Pebble Storefront

Responsive Flutter e-commerce storefront powered by Django REST Framework and PostgreSQL.

[Live demo](https://pebble-client.onrender.com/) · [Backend](https://github.com/oscarboyq/pebble_backend) · [Architecture](https://github.com/oscarboyq/pebble_backend/blob/main/docs/PEBBLE_BACKEND_ARCHITECTURE.md)

## Features

- Product search, filters, collections, galleries, and variant selection.
- Registration, login, password reset, profiles, wishlists, and reviews.
- Cart, coupons, bundle offers, and order placement.
- Order history, status timeline, and carrier tracking links.
- Responsive homepage with banners, carousels, and lookbooks.

Checkout records orders without processing payments. Order tracking displays staff-entered updates.

## Stack

Flutter · Dart · Riverpod · GoRouter · Dio · JWT · Django REST Framework · PostgreSQL · Render

## Run

Requires Flutter with Chrome support and Dart compatible with `^3.11.5`.

```bash
git clone https://github.com/oscarboyq/pebble_client.git
cd pebble_client
flutter pub get
flutter run -d chrome --web-port 3000
```

Web requests use the hosted backend, including account and order actions. To use a local backend, change the `kIsWeb` URL in `lib/core/config/api_config.dart` to `http://localhost:8000/api/` and allow `http://localhost:3000` in the backend's development CORS settings.

## Test and build

```bash
flutter test
flutter analyze
flutter build web --release
```

Web build output: `build/web/`.

## Design

Inspired by the [Shopify Pebble theme](https://themes.shopify.com/themes/pebble/presets/pebble). Independent portfolio project; no affiliation with Shopify or the theme's creators.
