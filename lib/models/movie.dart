// 홈, 목록, 상세 화면에서 공통으로 사용하는 영화 모델
class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.runningTime,
    required this.posterAsset,
    required this.rating,
    this.synopsis = '',
  });

  final int id;
  final String title;
  final String genre;
  final int year;
  final int runningTime;
  final String posterAsset;
  final double rating;
  final String synopsis;
}
