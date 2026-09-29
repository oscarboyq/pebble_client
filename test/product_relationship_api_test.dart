import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/core/services/api_client.dart';
import 'package:pebble_type/core/services/product_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'outfit and related requests use curated relationship endpoint',
    () async {
      final requests = <RequestOptions>[];
      final interceptor = InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.resolve(
            Response(
              requestOptions: options,
              data: {
                'intent': options.queryParameters['intent'],
                'products': [
                  {
                    'id': 2,
                    'category': {
                      'id': 1,
                      'name': 'T-Shirts',
                      'slug': 't-shirts',
                    },
                    'name': 'Layering Shirt',
                    'slug': 'layering-shirt',
                    'price': '28.00',
                    'images': <dynamic>[],
                    'variants': <dynamic>[],
                  },
                ],
              },
            ),
          );
        },
      );
    ApiClient.dio.interceptors.insert(0, interceptor);
      addTearDown(() => ApiClient.dio.interceptors.remove(interceptor));

      final outfit = await ProductService.getRelated(
        'basic-tee',
        intent: 'outfit',
      );
      final related = await ProductService.getRelated('basic-tee');

      expect(outfit.single.slug, 'layering-shirt');
      expect(related.single.slug, 'layering-shirt');
      expect(
        requests.map((request) => request.path),
        everyElement('products/basic-tee/related/'),
      );
      expect(requests.map((request) => request.queryParameters['intent']), [
        'outfit',
        'related',
      ]);
    },
  );
}
