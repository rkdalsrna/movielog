import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:movielog/theme/app_colors.dart';

class MovieRatingInput extends StatelessWidget {
  const MovieRatingInput({
    super.key,
    required this.rating,
    required this.onChanged,
  });

  final double rating;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    // 0.5점 단위의 별점 입력 처리
    return RatingBar.builder(
      initialRating: rating,
      minRating: 0.5,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: 40,
      itemPadding: const EdgeInsets.symmetric(horizontal: 2),
      unratedColor: AppColors.disabledButton,
      itemBuilder: (context, index) {
        return const Icon(Icons.star_rounded, color: AppColors.primary);
      },
      // 선택한 별점을 Dialog로 전달
      onRatingUpdate: onChanged,
    );
  }
}
