import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/rating_with_movie.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../view_models/my_ratings_view_model.dart';
import 'widgets/rating_card.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const BackButton(),
        title: const Text('내가 등록한 평점', style: AppTextStyles.appBarTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
            ),
            Expanded(
              child: Consumer<MyRatingsViewModel>(
                builder: (context, viewModel, child) {
                  switch (viewModel.status) {
                    case MyRatingsLoadStatus.idle:
                    case MyRatingsLoadStatus.loading:
                      return const Center(child: CircularProgressIndicator());
                    case MyRatingsLoadStatus.error:
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(viewModel.message ?? '평점을 불러오지 못했습니다.'),
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
                              child: RatingCard(entry: entry),
                            ),
                        ],
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
