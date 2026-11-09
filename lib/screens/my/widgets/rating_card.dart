import 'package:flutter/material.dart';

import '../../../data/models/rating_with_movie.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

class RatingCard extends StatelessWidget {
  const RatingCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelected,
  });

  final RatingWithMovie entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isSelectionMode;
  final bool isSelected;
  final ValueChanged<bool?>? onSelected;

  @override
  Widget build(BuildContext context) {
    final movie = entry.movie;
    final rating = entry.rating;
    final poster = movie?.posterAsset ?? '';
    final date = rating.createdAt;
    final dateText =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    const placeholder = ColoredBox(color: AppColors.statCardBorder);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.disabledButton, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              height: 124,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: poster.isEmpty
                    ? placeholder
                    : Image.network(
                        poster,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => placeholder,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie?.title ?? '영화 #${rating.movieId}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '별점 ${rating.score} / 5',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    rating.comment?.trim().isNotEmpty == true
                        ? rating.comment!
                        : '등록된 후기가 없습니다.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray,
                    ),
                  ),
                  if (movie == null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '포스터 정보 없음',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.gray,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '등록일 $dateText',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isSelectionMode)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: onSelected,
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: onEdit,
                          child: const Text('수정'),
                        ),
                        TextButton(
                          onPressed: onDelete,
                          child: const Text('삭제'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
