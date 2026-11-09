import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/rating_dto.dart';
import '../../screens/movie/widgets/rating_dialog.dart';
import '../../theme/app_text_styles.dart';
import '../../view_models/my_ratings_view_model.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/movielog_button.dart';
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
        onSubmit: (score, comment) => context
            .read<MyRatingsViewModel>()
            .updateRating(
              ratingId: rating.ratingId,
              score: score,
              comment: comment,
            ),
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
      builder: (_) => _DeleteRatingDialog(
        onConfirm: () => context
            .read<MyRatingsViewModel>()
            .deleteRating(rating.ratingId),
      ),
    );

    if (!context.mounted || confirmed != true) return;
  }

  Future<void> _onDeleteSelectedPressed(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('선택한 평점을 삭제할까요?'),
        content: const Text('삭제한 평점은 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final viewModel = context.read<MyRatingsViewModel>();
    await viewModel.deleteSelectedRatings();
    if (!context.mounted) return;
    final message = viewModel.message;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyRatingsViewModel>(
      builder: (context, viewModel, child) {
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
                if (viewModel.status == MyRatingsLoadStatus.success)
                  TextButton(
                    onPressed: viewModel.isDeletingSelected
                        ? null
                        : viewModel.isSelectionMode
                            ? viewModel.cancelSelection
                            : viewModel.startSelection,
                    child: Text(viewModel.isSelectionMode ? '취소' : '편집'),
                  ),
              ],
            ),
            body: LoadingOverlay(
              isLoading: viewModel.isDeletingSelected,
              child: SafeArea(
                child: Column(
                  children: [
                    if (viewModel.isSelectionMode)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${viewModel.selectedRatingIds.length}개 선택',
                            style: AppTextStyles.bodyMedium,
                          ),
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
        return const Center(child: CircularProgressIndicator());
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

class _DeleteRatingDialog extends StatefulWidget {
  const _DeleteRatingDialog({required this.onConfirm});

  final Future<void> Function() onConfirm;

  @override
  State<_DeleteRatingDialog> createState() => _DeleteRatingDialogState();
}

class _DeleteRatingDialogState extends State<_DeleteRatingDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeleting,
      child: AlertDialog(
        title: const Text('평점을 삭제할까요?'),
        content: const Text('삭제한 평점은 복구할 수 없습니다.'),
        actions: [
          MovieLogButton(
            label: '취소',
            onPressed: _isDeleting
                ? null
                : () => Navigator.pop(context, false),
          ),
          MovieLogButton(
            label: '삭제',
            isLoading: _isDeleting,
            onPressed: _isDeleting ? null : _onConfirm,
          ),
        ],
      ),
    );
  }

  Future<void> _onConfirm() async {
    setState(() => _isDeleting = true);
    try {
      await widget.onConfirm();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('삭제하지 못했습니다. 잠시 후 다시 시도해 주세요.'),
        ),
      );
    }
  }
}
