import 'package:movielog/models/movie.dart';

// 홈 화면의 추천 영화
const featuredMovie = Movie(
  id: 1,
  title: '별빛 아래 우리',
  genre: '로맨스 · 드라마',
  year: 2024,
  runningTime: 120,
  posterAsset: 'assets/images/posters/hero_under_the_starlight.jpg',
  rating: 4.8,
);

// 홈과 영화 목록 화면에서 함께 사용하는 인기 영화 목록
const popularMovies = [
  Movie(
    id: 2,
    title: '어비스 워커',
    genre: 'SF · 액션',
    year: 2024,
    runningTime: 118,
    posterAsset: 'assets/images/posters/poster_abyss_walker.jpg',
    rating: 4.6,
  ),
  Movie(
    id: 3,
    title: '네 번째 오후',
    genre: '드라마',
    year: 2023,
    runningTime: 106,
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
    rating: 4.2,
  ),
  Movie(
    id: 4,
    title: '밤의 그림자',
    genre: '스릴러 · 미스터리',
    year: 2024,
    runningTime: 112,
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
    rating: 4.8,
  ),
  Movie(
    id: 5,
    title: '속삭이는 숲',
    genre: '판타지 · 미스터리',
    year: 2023,
    runningTime: 104,
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
    rating: 4.4,
  ),
  Movie(
    id: 6,
    title: '공허의 메아리',
    genre: 'SF · 드라마',
    year: 2024,
    runningTime: 124,
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
    rating: 4.1,
  ),
];

const movies = [featuredMovie, ...popularMovies];

// Route의 영화 ID로 상세 화면에 표시할 영화 조회
Movie? findMovieById(int? id) {
  for (final movie in movies) {
    if (movie.id == id) return movie;
  }
  return null;
}
