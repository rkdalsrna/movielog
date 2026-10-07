import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:movielog/models/movie.dart';
import 'package:movielog/screens/movie/widgets/genre_filter_bottom_sheet.dart';
import 'package:movielog/screens/movie/widgets/movie_grid.dart';
import 'package:movielog/screens/movie/widgets/movie_list_empty.dart';
import 'package:movielog/screens/movie/widgets/movie_list_error.dart';
import 'package:movielog/screens/movie/widgets/movie_list_loading.dart';
import 'package:movielog/services/fake_movie_service.dart';
import 'package:movielog/theme/app_colors.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key, this.initialGenresQuery});

  final String? initialGenresQuery;

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  static const _movieService = FakeMovieService();

  // 성공·빈 목록·실패 화면을 확인하기 위한 요청 모드
  static const _loadMode = MovieLoadMode.success;

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

  // 영화 목록 요청 상태를 보관하는 Future
  late Future<List<Movie>> _moviesFuture;

  Set<String> _genresFromQuery(String? query) {
    if (query == null || query.isEmpty) return {};

    return query.split(',').where(_genres.contains).toSet();
  }

  @override
  void initState() {
    super.initState();

    // 화면 최초 진입 시 영화 목록 요청
    _moviesFuture = _movieService.fetchMovies(mode: _loadMode);

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
  List<Movie> _filterMovies(List<Movie> loadedMovies) {
    // 선택된 장르가 없으면 모든 영화 반환
    if (_selectedGenres.isEmpty) return loadedMovies;

    return loadedMovies.where((movie) {
      return _selectedGenres.any((genre) => movie.genre.contains(genre));
    }).toList();
  }

  void _retry() {
    setState(() {
      // 다시 시도할 때만 새로운 Future 생성
      _moviesFuture = _movieService.fetchMovies(mode: _loadMode);
    });
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
            child: FutureBuilder<List<Movie>>(
              future: _moviesFuture,
              builder: (context, snapshot) {
                // 영화 목록을 기다리는 동안 Loading 표시
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const MovieListLoading();
                }

                // 내부 오류 정보 대신 사용자용 Error 화면 표시
                if (snapshot.hasError) {
                  return MovieListError(onRetry: _retry);
                }

                // 완료된 데이터가 null이면 빈 목록 사용
                final loadedMovies = snapshot.data ?? const <Movie>[];
                final filteredMovies = _filterMovies(loadedMovies);

                // 빈 목록이면 Empty 화면 표시
                if (filteredMovies.isEmpty) {
                  return const MovieListEmpty();
                }

                // 성공 시 기존 영화 Grid 표시
                return MovieGrid(
                  movies: filteredMovies,
                  onMoviePressed: (movie) {
                    // 선택한 영화 ID를 포함한 상세 Route 이동
                    context.push('/movies/${movie.id}');
                  },
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
