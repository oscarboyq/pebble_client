# Pebble Little storefront

Responsive Flutter web storefront for the local Pebble Little showcase. It covers the home page, collections, product details, cart, and account-based checkout. Django and PostgreSQL provide the catalog, editable content, pricing, and orders.

## Run locally

Start the backend on `localhost:8000`, then run:

```bash
flutter pub get
flutter run -d chrome --web-port 3000
```

See the [complete local run guide](../../django/pebble_backend/pebble/RUN_LOCAL.md) for backend setup and the owner admin.

## Verify

```bash
flutter test
flutter analyze --no-pub
flutter build web --release --no-wasm-dry-run
```

The analyzer currently reports informational lints, with no errors or warnings. See the [Phase 11 buyer readiness report](../../django/pebble_backend/pebble/PHASE11_REPORT.md) and [Phase 6 integrated evidence](../../django/pebble_backend/pebble/PHASE6_REPORT.md).
