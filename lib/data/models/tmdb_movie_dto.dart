//TMDB 영화 데이터
class TmdbMovieDto {
  const TmdbMovieDto({
    required this.id, //영화 고유 ID
    required this.title, //영화 제목
    required this.overview, //줄거리
    required this.posterPath, //포스터 이미지 경로
    required this.backdropPath, //배경 이미지 경로
    required this.releaseDate, //개봉일
    required this.genreIds, //장르 ID 목록
    required this.voteAverage, //평균 평점
    required this.popularity, //인기도
    this.runtime,
    this.genreNames = const [],
  });
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? releaseDate;
  final List<int> genreIds;
  final double voteAverage;
  final double popularity;
  final int? runtime;
  final List<String> genreNames;

  String get genre => genreNames.join(' · ');
  int get year {
    final value = releaseDate;
    return value != null && value.length >= 4
        ? int.tryParse(value.substring(0, 4)) ?? 0
        : 0;
  }

  int get runningTime => runtime ?? 0;
  String get posterAsset => posterPath == null
      ? ''
      : 'https://image.tmdb.org/t/p/w500$posterPath';
  double get rating => voteAverage / 2;
  String get synopsis => overview;
  //JSON 응답을 객체로 변환
  factory TmdbMovieDto.fromJson(Map<String, dynamic> json) {
    return TmdbMovieDto(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '제목 없음',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String?,
      genreIds: (json['genre_ids'] as List<dynamic>? ?? const [])
          .map((value) => (value as num).toInt())
          .toList(),
      voteAverage: (json['vote_average'] as num? ?? 0).toDouble(),
      popularity: (json['popularity'] as num? ?? 0).toDouble(),
      runtime: (json['runtime'] as num?)?.toInt(),
      genreNames: (json['genres'] as List<dynamic>? ?? const [])
          .map(
            (item) =>
                (item as Map<String, dynamic>)['name'] as String? ?? '',
          )
          .where((name) => name.isNotEmpty)
          .toList(),
    );
  }
}
