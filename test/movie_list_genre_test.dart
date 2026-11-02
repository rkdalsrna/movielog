import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movielog/data/services/tmdb_movie_service.dart';
import 'package:movielog/view_models/movie_list_view_model.dart';

void main() {
  test('장르 변경과 새로고침은 선택 조건으로 page 1부터 조회', () async {
    final requests = <Map<String, dynamic>>[];
    final dio = Dio();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      if (options.path == '/genre/movie/list') {
        handler.resolve(Response(requestOptions: options, data: {
          'genres': [
            {'id': 28, 'name': '액션'},
            {'id': 35, 'name': '코미디'},
          ],
        }));
        return;
      }
      requests.add(Map.of(options.queryParameters));
      final page = options.queryParameters['page'] as int;
      handler.resolve(Response(requestOptions: options, data: {
        'page': page,
        'total_pages': 2,
        'total_results': 40,
        'results': List.generate(20, (i) => {
          'id': (page - 1) * 19 + i,
          'title': '영화 $i',
        }),
      }));
    }));
    final viewModel = MovieListViewModel(TmdbMovieService(dio));
    addTearDown(() {
      viewModel.dispose();
      dio.close(force: true);
    });

    await viewModel.selectGenres({'액션', '코미디'});
    expect(requests.map((r) => r['page']), [1, 2]);
    expect(requests.every((r) => r['with_genres'] == '28|35'), isTrue);
    expect(viewModel.movies.length, 30);
    expect(viewModel.movies.map((m) => m.id).toSet().length, 30);
    expect(viewModel.status, MovieListLoadStatus.success);

    requests.clear();
    await viewModel.selectGenres({'액션'});
    expect(requests.first['page'], 1);
    expect(requests.every((r) => r['with_genres'] == '28'), isTrue);

    requests.clear();
    await viewModel.loadInitial();
    expect(requests.first['page'], 1);
    expect(requests.first['with_genres'], '28');

    requests.clear();
    await viewModel.selectGenres({});
    expect(requests.first['page'], 1);
    expect(requests.every((r) => !r.containsKey('with_genres')), isTrue);
  });
}
