import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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

  //장르 이름은 API가 반환한 목록을 사용, _genres에서 이름만 추출
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _restoreSelectedGenres();
      if (mounted) _syncGenreRequest();
    });
  }

  Future<void> _restoreSelectedGenres() async {
    //URL에 장르가 있으면 Query Parameter 우선 사용
    if (_selectedGenres.isNotEmpty) return;

    final selectionBeforeRead = Set<String>.of(_selectedGenres);
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
    if (validGenres.isEmpty ||
        !mounted ||
        !setEquals(selectionBeforeRead, _selectedGenres)) {
      return;
    }

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
      //URL에서 장르가 변경돼도 서버에 다시 요청
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncGenreRequest();
      });
    }
  }

  //초기 진입과 장르 변경 시에만 API 요청
  void _syncGenreRequest() {
    final viewModel = context.read<MovieListViewModel>();
    if (viewModel.status != MovieListLoadStatus.idle &&
        setEquals(viewModel.selectedGenreNames, _selectedGenres)) {
      return;
    }
    viewModel.selectGenres(_selectedGenres);
  }

  Future<void> _openGenreFilter() async {
    //요청 전과 요청 중에는 장르 선택 차단
    final status = context.read<MovieListViewModel>().status;
    if (status == MovieListLoadStatus.idle ||
        status == MovieListLoadStatus.loading) {
      return;
    }

    final selectedGenres = await showModalBottomSheet<Set<String>>(
      context: context,
      //ShellRoute의 하단 네비게이션까지 덮도록 루트 Navigator 사용
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GenreFilterBottomSheet(
          genres: _genres, //API에서 받은 장르 이름을 선택 항목으로 전달
          initialGenres: _selectedGenres, //기존 선택 장르 전달
        );
      },
    );

    //BottomSheet 취소 시 기존 필터 유지
    if (selectedGenres == null || !mounted) return;
    //선택창이 열린 동안 요청이 시작되면 변경 적용 차단
    if (context.read<MovieListViewModel>().status ==
        MovieListLoadStatus.loading) {
      return;
    }

    //저장 결과를 기다리지 않고 선택 장르를 화면에 먼저 적용
    setState(() => _selectedGenres = selectedGenres);
    _syncGenreRequest();

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
          Consumer<MovieListViewModel>(
            builder: (context, viewModel, child) {
              //요청이 끝나면 장르 필터 버튼 활성화
              final isLoading =
                  viewModel.status == MovieListLoadStatus.idle ||
                  viewModel.status == MovieListLoadStatus.loading;
              return Opacity(
                opacity: isLoading ? 0.4 : 1,
                child: _FilterAction(
                  onPressed: isLoading ? null : _openGenreFilter,
                ),
              );
            },
          ),
          Expanded(
            //ViewModel의 상태 변경을 구독해 목록 영역 갱신
            child: Consumer<MovieListViewModel>(
              builder: (context, viewModel, child) {
                //서버에서 장르 필터링한 결과를 그대로 표시
                final filteredMovies = viewModel.movies;
                //요청 상태에 따라 로딩·오류·빈 목록·영화 목록 표시
                final content = switch (viewModel.status) {
                  MovieListLoadStatus.idle || MovieListLoadStatus.loading =>
                    const MovieListLoading(), //로딩 표시
                  MovieListLoadStatus.error => MovieListError(
                    message: viewModel.message, //오류 안내 문구
                    onRetry: () => viewModel.loadInitial(), //재시도 시 API 다시 호출
                  ),
                  MovieListLoadStatus.empty => const MovieListEmpty(), //빈 목록 안내
                  MovieListLoadStatus.success =>
                    filteredMovies.isEmpty
                        ? const MovieListEmpty() //장르 필터 결과가 없어도 빈 목록 표시
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
                //아래로 당기면 장르와 영화 목록 다시 조회
                return RefreshIndicator(
                  onRefresh: () => viewModel.loadInitial(),
                  child: content is MovieGrid
                      ? content
                      //로딩·오류·빈 목록에서도 화면을 당길 수 있도록 스크롤 제공
                      : CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: content,
                            ),
                          ],
                        ),
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

  final VoidCallback? onPressed;

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
