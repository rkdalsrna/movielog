import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:movielog/data/models/tmdb_movie_dto.dart';
import 'package:movielog/view_models/movie_list_view_model.dart';
import 'package:movielog/preferences/genre_preference.dart';
import 'package:movielog/screens/movie/widgets/genre_filter_bottom_sheet.dart';
import 'package:movielog/screens/movie/widgets/movie_grid.dart';
import 'package:movielog/screens/movie/widgets/movie_list_empty.dart';
import 'package:movielog/screens/movie/widgets/movie_list_error.dart';
import 'package:movielog/screens/movie/widgets/movie_list_loading.dart';
import 'package:movielog/theme/app_colors.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key, this.initialGenresQuery});

  final String? initialGenresQuery;

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  static final _genrePreference = GenrePreference();

  //장르 이름은 API가 반환한 목록을 사용
  List<String> get _genres => context
      .read<MovieListViewModel>()
      .genres
      .map((genre) => genre.name)
      .toList();

  //Query Parameter와 일치하는 적용 장르 상태
  late Set<String> _selectedGenres;

  Set<String> _genresFromQuery(String? query) {
    if (query == null || query.isEmpty) return {};

    return query.split(',').where((genre) => genre.isNotEmpty).toSet();
  }

  @override
  void initState() {
    super.initState();

    //처음 전달받은 Query Parameter로 적용 장르 초기화
    _selectedGenres = _genresFromQuery(widget.initialGenresQuery);

    //Query Parameter가 없으면 마지막 선택 장르 복원
    _restoreSelectedGenres();
  }

  Future<void> _restoreSelectedGenres() async {
    //URL에 장르가 있으면 Query Parameter 우선 사용
    if (_selectedGenres.isNotEmpty) return;

    Set<String> savedGenres;

    try {
      savedGenres = await _genrePreference.read();
    } catch (error) {
      //저장소 조회 실패 시 전체 영화 목록 유지
      debugPrint('선택 장르 복원 실패: $error');
      return;
    }

    final validGenres = savedGenres;

    //저장된 장르가 없거나 화면이 사라지면 복원 중단
    if (validGenres.isEmpty || !mounted) return;

    //저장된 장르를 화면 상태에 복원
    setState(() => _selectedGenres = validGenres);

    final location = Uri(
      path: '/movies',
      queryParameters: {'genre': validGenres.join(',')},
    ).toString();

    //복원된 장르를 Query Parameter에도 반영
    context.go(location);
  }

  @override
  void didUpdateWidget(covariant MovieListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    //URL의 Query Parameter 변경 시 선택 카테고리 동기화
    if (oldWidget.initialGenresQuery != widget.initialGenresQuery) {
      _selectedGenres = _genresFromQuery(widget.initialGenresQuery);
    }
  }

  //선택한 장르 중 하나라도 일치하는 영화를 OR 조건으로 필터링
  List<TmdbMovieDto> _filterMovies(
    List<TmdbMovieDto> loadedMovies,
    MovieListViewModel viewModel,
  ) {
    if (_selectedGenres.isEmpty) return loadedMovies;

    //선택한 장르 이름을 ID로 변환해 하나라도 일치하는 영화 표시
    final selectedIds = viewModel.genres
        .where((genre) => _selectedGenres.contains(genre.name))
        .map((genre) => genre.id)
        .toSet();
    return loadedMovies
        .where((movie) => movie.genreIds.any(selectedIds.contains))
        .toList();
  }

  Future<void> _openGenreFilter() async {
    final selectedGenres = await showModalBottomSheet<Set<String>>(
      context: context,
      //ShellRoute의 하단 네비게이션까지 덮도록 루트 Navigator 사용
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

    //BottomSheet 취소 시 기존 필터 유지
    if (selectedGenres == null || !mounted) return;

    //저장 결과를 기다리지 않고 선택 장르를 화면에 먼저 적용
    setState(() => _selectedGenres = selectedGenres);

    final location = Uri(
      path: '/movies',
      queryParameters: selectedGenres.isEmpty
          ? null
          : {'genre': selectedGenres.join(',')},
    ).toString();

    //확인한 장르를 Query Parameter에 적용
    context.go(location);

    try {
      //확인한 장르를 로컬 저장소에 저장
      await _genrePreference.save(selectedGenres);
    } catch (error) {
      //저장 실패가 현재 화면 필터에 영향을 주지 않게 처리
      debugPrint('선택 장르 저장 실패: $error');
    }
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
            //ViewModel의 상태 변경을 구독해 목록 영역 갱신
            child: Consumer<MovieListViewModel>(
              builder: (context, viewModel, child) {
                final filteredMovies = _filterMovies(
                  viewModel.movies,
                  viewModel,
                );
                //요청 상태에 따라 로딩·오류·빈 목록·영화 목록 표시
                return switch (viewModel.status) {
                  MovieListLoadStatus.idle ||
                  MovieListLoadStatus.loading => const MovieListLoading(),
                  MovieListLoadStatus.error => MovieListError(
                    message: viewModel.message,
                    onRetry: () => viewModel.loadInitial(),
                  ),
                  MovieListLoadStatus.empty => const MovieListEmpty(),
                  MovieListLoadStatus.success =>
                    filteredMovies.isEmpty
                        ? const MovieListEmpty()
                        : MovieGrid(
                            movies: filteredMovies,
                            //카드에 표시할 장르 ID와 이름 연결
                            genreNames: {
                              for (final genre in viewModel.genres)
                                genre.id: genre.name,
                            },
                            onMoviePressed: (movie) {
                              context.push('/movies/${movie.id}');
                            },
                          ),
                };
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
