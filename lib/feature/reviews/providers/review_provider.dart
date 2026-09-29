import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pebble_type/core/services/review_service.dart';
import 'package:pebble_type/feature/reviews/models/review_model.dart';

final reviewsProvider = FutureProvider.family<List<ReviewModel>, String>((
  ref,
  slug,
) async {
  return ReviewService.getReviews(slug);
});
