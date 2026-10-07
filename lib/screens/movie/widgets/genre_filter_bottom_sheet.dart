import 'package:flutter/material.dart';
import 'package:movielog/theme/app_colors.dart';

class GenreFilterBottomSheet extends StatefulWidget {
  const GenreFilterBottomSheet({
    super.key,
    required this.genres,
    required this.initialGenres,
  });

  final List<String> genres;
  final Set<String> initialGenres;

  @override
  State<GenreFilterBottomSheet> createState() => _GenreFilterBottomSheetState();
}

class _GenreFilterBottomSheetState extends State<GenreFilterBottomSheet> {
  late Set<String> _temporaryGenres;

  @override
  void initState() {
    super.initState();

    // 적용된 장르를 BottomSheet의 임시 선택 상태로 복사
    _temporaryGenres = {...widget.initialGenres};
  }

  void _toggleGenre(String genre, bool isSelected) {
    // 확인 전까지 BottomSheet 내부 선택 상태만 변경
    setState(() {
      if (isSelected) {
        _temporaryGenres.add(genre);
      } else {
        _temporaryGenres.remove(genre);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45, //화면 높이의 45%
      minChildSize: 0.35, //최소 35%
      maxChildSize: 0.85, //최대 85%
      snap: true,
      snapSizes: const [0.45, 0.85],
      expand: false,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.warmWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Expanded(
                // 헤더와 목록을 연결해 어느 영역에서든 높이 조절
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    // 제목은 고정하고 Checkbox 목록만 스크롤
                    const SliverPersistentHeader(
                      pinned: true,
                      delegate: _FilterHeaderDelegate(),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final genre = widget.genres[index];

                          return Theme(
                            data: Theme.of(context).copyWith(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              checkboxTheme: const CheckboxThemeData(
                                overlayColor: WidgetStatePropertyAll(
                                  Colors.transparent,
                                ),
                                splashRadius: 0,
                              ),
                            ),
                            child: CheckboxListTile(
                              value: _temporaryGenres.contains(genre),
                              onChanged: (value) =>
                                  _toggleGenre(genre, value ?? false),
                              title: Text(
                                genre,
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 16,
                                  height: 1,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                  letterSpacing: 0,
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                          );
                        }, childCount: widget.genres.length),
                      ),
                    ),
                  ],
                ),
              ),
              _ConfirmButton(
                onPressed: () {
                  // 확인 시 선택한 장르를 영화 목록 화면으로 반환
                  Navigator.pop(context, {..._temporaryGenres});
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterHeader extends StatelessWidget {
  const _FilterHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 28,
          child: Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.disabledButton,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '장르 필터',
                style: TextStyle(
                  color: AppColors.black,
                  fontFamily: 'Manrope',
                  fontSize: 20,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 5),
              Text(
                '여러 장르를 선택할 수 있어요',
                style: TextStyle(
                  color: AppColors.gray,
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  height: 1,
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _FilterHeaderDelegate();

  static const double _height = 79;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return const ColoredBox(color: AppColors.warmWhite, child: _FilterHeader());
  }

  @override
  bool shouldRebuild(covariant _FilterHeaderDelegate oldDelegate) => false;
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.warmWhite,
        border: Border(top: BorderSide(color: AppColors.statCardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('확인'),
            ),
          ),
        ),
      ),
    );
  }
}
