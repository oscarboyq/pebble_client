import 'package:pebble_type/core/services/api_client.dart';
import 'package:pebble_type/feature/reviews/models/review_model.dart';

class ReviewService {
  static Future<List<ReviewModel>> getReviews(String slug) async {
    final response = await ApiClient.dio.get('products/$slug/reviews/');
    return (response.data as List<dynamic>)
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<ReviewModel> submitReview({
    required String slug,
    required int rating,
    String title = '',
    String body = '',
  }) async {
    final response = await ApiClient.dio.post(
      'products/$slug/reviews/',
      data: {'rating': rating, 'title': title, 'body': body},
    );
    return ReviewModel.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<void> deleteReview(String slug) async {
    await ApiClient.dio.delete('products/$slug/reviews/mine/');
  }
}
