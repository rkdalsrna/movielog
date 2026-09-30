import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/data/mock_movies.dart';
import 'package:movielog/models/movie.dart';
import 'package:movielog/screens/movie/widgets/movie_grid_card.dart';
import 'package:movielog/theme/app_colors.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key, this.initialGenre});

  final String? initialGenre;

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  static const _genres = ['전체', '드라마', 'SF', '애니메이션', '스릴러'];

  // Query Parameter와 일치하는 카테고리 상태
  late String _selectedGenre;

  String _genreFromQuery(String? genre) {
    return genre != null && _genres.contains(genre) ? genre : _genres.first;
  }

  @override
  void initState() {
    super.initState();
    // 처음 전달받은 Query Parameter로 카테고리 초기화
    _selectedGenre = _genreFromQuery(widget.initialGenre);
  }

  @override
  void didUpdateWidget(covariant MovieListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // URL의 Query Parameter 변경 시 선택 카테고리 동기화
    if (oldWidget.initialGenre != widget.initialGenre) {
      _selectedGenre = _genreFromQuery(widget.initialGenre);
    }
  }

  // 선택한 카테고리에 해당하는 영화만 필터링
  List<Movie> get _filteredMovies {
    // 전체 선택 시 모든 영화 반환
    if (_selectedGenre == _genres.first) return movies;

    return movies
        .where((movie) => movie.genre.contains(_selectedGenre))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const _MovieHeader(),
          _GenreFilter(
            genres: _genres,
            selectedGenre: _selectedGenre,
            onSelected: (genre) {
              // 선택한 카테고리를 Query Parameter에 반영
              final location = Uri(
                path: '/movies',
                queryParameters: genre == _genres.first
                    ? null
                    : {'genre': genre},
              ).toString();

              context.go(location);
            },
          ),
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

class _GenreFilter extends StatelessWidget {
  const _GenreFilter({
    required this.genres,
    required this.selectedGenre,
    required this.onSelected,
  });

  final List<String> genres;
  final String selectedGenre;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      // 장르 필터를 가로로 스크롤할 수 있게 배치
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = genre == selectedGenre;

          return Align(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              // 선택한 칩의 카테고리를 부모 화면에 전달
              onTap: () => onSelected(genre),
              child: Container(
                height: 32,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.statCardBackground,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  genre,
                  maxLines: 1,
                  style: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.gray,
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
