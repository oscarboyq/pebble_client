import 'package:flutter/material.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/theme/app_text_styles.dart';
import 'package:pebble_type/feature/reviews/models/review_model.dart';
import 'package:pebble_type/feature/reviews/widgets/star_rating.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.userName,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              StarRating(rating: review.rating, size: 16),
            ],
          ),
          if (review.title.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingXm),
            Text(
              review.title,
              style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
          if (review.body.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingXm),
            Text(review.body, style: AppTextStyles.bodyMd),
          ],
          const SizedBox(height: AppDimensions.spacingXm),
          Text(
            _formatDate(review.createdAt),
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
