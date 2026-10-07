import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/data/mock_movies.dart';
import 'package:movielog/models/movie.dart';
import 'package:movielog/screens/movie/widgets/genre_filter_bottom_sheet.dart';
import 'package:movielog/screens/movie/widgets/movie_grid_card.dart';
import 'package:movielog/theme/app_colors.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key, this.initialGenresQuery});

  final String? initialGenresQuery;

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  static const _genres = [
    '드라마',
    'SF',
    '애니메이션',
    '스릴러',
    '로맨스',
    '액션',
    '코미디',
    '판타지',
    '다큐멘터리',
  ];

  // Query Parameter와 일치하는 적용 장르 상태
  late Set<String> _selectedGenres;

  Set<String> _genresFromQuery(String? query) {
    if (query == null || query.isEmpty) return {};

    return query.split(',').where(_genres.contains).toSet();
  }

  @override
  void initState() {
    super.initState();
    // 처음 전달받은 Query Parameter로 적용 장르 초기화
    _selectedGenres = _genresFromQuery(widget.initialGenresQuery);
  }

  @override
  void didUpdateWidget(covariant MovieListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // URL의 Query Parameter 변경 시 선택 카테고리 동기화
    if (oldWidget.initialGenresQuery != widget.initialGenresQuery) {
      _selectedGenres = _genresFromQuery(widget.initialGenresQuery);
    }
  }

  // 선택한 장르 중 하나라도 일치하는 영화를 OR 조건으로 필터링
  List<Movie> get _filteredMovies {
    // 선택된 장르가 없으면 모든 영화 반환
    if (_selectedGenres.isEmpty) return movies;

    return movies.where((movie) {
      return _selectedGenres.any((genre) => movie.genre.contains(genre));
    }).toList();
  }

  Future<void> _openGenreFilter() async {
    final selectedGenres = await showModalBottomSheet<Set<String>>(
      context: context,
      // ShellRoute의 하단 네비게이션까지 덮도록 루트 Navigator 사용
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GenreFilterBottomSheet(
          genres: _genres,
          initialGenres: _selectedGenres,
        );
      },
    );

    // BottomSheet 취소 시 기존 필터 유지
    if (selectedGenres == null || !mounted) return;

    final location = Uri(
      path: '/movies',
      queryParameters: selectedGenres.isEmpty
          ? null
          : {'genre': selectedGenres.join(',')},
    ).toString();

    // 확인한 장르를 Query Parameter에 적용
    context.go(location);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const _MovieHeader(),
          _FilterAction(onPressed: _openGenreFilter),
          Expanded(
            // 필터링된 영화 목록을 2열 그리드로 표시
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(15, 8, 15, 24),
              itemCount: _filteredMovies.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                mainAxisExtent: 316.5,
              ),
              itemBuilder: (context, index) {
                final movie = _filteredMovies[index];

                return MovieGridCard(
                  movie: movie,
                  // 선택한 영화 ID를 포함한 상세 Route 이동
                  onTap: () => context.push('/movies/${movie.id}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieHeader extends StatelessWidget {
  const _MovieHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '영화',
              style: TextStyle(
                color: AppColors.primary,
                fontFamily: 'Manrope',
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            IconButton(
              onPressed: () {},
              tooltip: '영화 검색',
              icon: SvgPicture.asset(
                'assets/icons/search.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.black,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterAction extends StatelessWidget {
  const _FilterAction({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 23),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: const SizedBox(
              width: 18,
              height: 12,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Icon(Icons.filter_list, color: AppColors.primary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
