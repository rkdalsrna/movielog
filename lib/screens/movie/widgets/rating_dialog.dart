import 'package:flutter/material.dart';
import 'package:movielog/screens/movie/widgets/movie_rating_input.dart';
import 'package:movielog/theme/app_colors.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key, this.initialRating = 0});

  final double initialRating;

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  // Dialog 내부에서 선택한 별점 상태
  late double _rating;

  // 초기화 시 별점 입력 위젯 재생성
  int _inputVersion = 0;

  @override
  void initState() {
    super.initState();
    // 이전에 저장한 별점을 Dialog 초기값으로 사용
    _rating = widget.initialRating;
  }

  void _resetRating() {
    setState(() {
      // 별점 입력값 초기화
      _rating = 0;
      _inputVersion++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.warmWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '영화는 어떠셨나요?',
              style: TextStyle(
                color: AppColors.black,
                fontFamily: 'Manrope',
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            MovieRatingInput(
              key: ValueKey(_inputVersion),
              rating: _rating,
              onChanged: (value) {
                // 입력 별점과 확인 버튼 상태 갱신
                setState(() => _rating = value);
              },
            ),
            if (_rating > 0) ...[
              const SizedBox(height: 8),
              TextButton(onPressed: _resetRating, child: const Text('다시 선택하기')),
            ] else
              const SizedBox(height: 20),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                // 별점 선택 전 확인 버튼 비활성화
                onPressed: _rating == 0
                    ? null
                    // 선택한 별점을 상세 화면으로 반환
                    : () => Navigator.pop(context, _rating),
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
