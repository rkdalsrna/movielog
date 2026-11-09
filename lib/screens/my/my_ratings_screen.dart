import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/rating_dto.dart';
import '../../screens/movie/widgets/rating_dialog.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../view_models/my_ratings_view_model.dart';
import '../../widgets/delete_rating_dialog.dart';
import '../../widgets/loading_overlay.dart';
import 'widgets/rating_card.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  Future<void> _onEditPressed(
    BuildContext context,
    RatingDto rating,
  ) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RatingDialog(
        initialScore: rating.score,
        initialComment: rating.comment,
        onSubmit: (score, comment) async {
          final viewModel = context.read<MyRatingsViewModel>();
          try {
            await viewModel.updateRating(
              ratingId: rating.ratingId,
              score: score,
              comment: comment,
            );
          } catch (_) {
            throw StateError(
              viewModel.message ?? '수정하지 못했습니다. 잠시 후 다시 시도해 주세요.',
            );
          }
        },
      ),
    );

    if (!context.mounted || saved != true) return;
  }

  Future<void> _onDeletePressed(
    BuildContext context,
    RatingDto rating,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeleteRatingDialog(
        onConfirm: () async {
          final viewModel = context.read<MyRatingsViewModel>();
          try {
            await viewModel.deleteRating(rating.ratingId);
          } catch (_) {
            throw StateError(
              viewModel.message ?? '삭제하지 못했습니다. 잠시 후 다시 시도해 주세요.',
            );
          }
        },
      ),
    );

    if (!context.mounted || confirmed != true) return;
  }

  Future<void> _onDeleteSelectedPressed(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteRatingDialog(
        title: '선택한 평점을 삭제할까요?',
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final viewModel = context.read<MyRatingsViewModel>();
    await viewModel.deleteSelectedRatings();
    if (!context.mounted) return;
    final message = viewModel.message;
    if (viewModel.selectedRatingIds.isNotEmpty && message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyRatingsViewModel>(
      builder: (context, viewModel, child) {
        final isLoading =
            viewModel.status == MyRatingsLoadStatus.idle ||
            viewModel.status == MyRatingsLoadStatus.loading ||
            viewModel.isDeletingSelected;
        return PopScope(
          canPop: !viewModel.isDeletingSelected,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              leading: const BackButton(),
              title: const Text(
                '내가 등록한 평점',
                style: AppTextStyles.appBarTitle,
              ),
              actions: [
                if (viewModel.status == MyRatingsLoadStatus.success &&
                    !viewModel.isSelectionMode)
                  TextButton(
                    onPressed: viewModel.isDeletingSelected
                        ? null
                        : viewModel.startSelection,
                    child: const Text('편집'),
                  ),
              ],
            ),
            body: LoadingOverlay(
              isLoading: isLoading,
              child: SafeArea(
                child: Column(
                  children: [
                    if (viewModel.isSelectionMode)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${viewModel.selectedRatingIds.length}개 선택됨',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              TextButton(
                                onPressed: viewModel.isDeletingSelected
                                    ? null
                                    : viewModel.cancelSelection,
                                child: const Text('취소'),
                              ),
                            ],
                        ),
                      ),
                    Expanded(child: _buildBody(context, viewModel)),
                    if (viewModel.isSelectionMode)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: viewModel.selectedRatingIds.isEmpty ||
                                    viewModel.isDeletingSelected
                                ? null
                                : () => _onDeleteSelectedPressed(context),
                            child: Text(
                              '선택한 ${viewModel.selectedRatingIds.length}개 삭제',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MyRatingsViewModel viewModel) {
    switch (viewModel.status) {
      case MyRatingsLoadStatus.idle:
      case MyRatingsLoadStatus.loading:
        return const SizedBox.expand();
      case MyRatingsLoadStatus.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                viewModel.refreshWarning ??
                    viewModel.message ??
                    '평점을 불러오지 못했습니다.',
              ),
              TextButton(
                onPressed: viewModel.load,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        );
      case MyRatingsLoadStatus.empty:
        return const Center(child: Text('등록된 평점이 없습니다.'));
      case MyRatingsLoadStatus.success:
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (viewModel.message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  viewModel.message!,
                  style: AppTextStyles.bodySmall,
                ),
              ),
            for (final entry in viewModel.ratings)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RatingCard(
                  entry: entry,
                  onEdit: () => _onEditPressed(context, entry.rating),
                  onDelete: () => _onDeletePressed(context, entry.rating),
                  isSelectionMode: viewModel.isSelectionMode,
                  isSelected: viewModel.selectedRatingIds.contains(
                    entry.rating.ratingId,
                  ),
                  onSelected: (_) => viewModel.toggleRatingSelection(
                    entry.rating.ratingId,
                  ),
                ),
              ),
          ],
        );
    }
  }
}
