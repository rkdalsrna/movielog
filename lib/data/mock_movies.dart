import 'package:movielog/models/movie.dart';

// 홈 화면의 추천 영화
const featuredMovie = Movie(
  id: 1,
  title: '별빛 아래 우리',
  genre: '드라마',
  year: 2023,
  runningTime: 120,
  posterAsset: 'assets/images/posters/hero_under_the_starlight.jpg',
  rating: 4.8,
  synopsis:
      '바쁜 현대 사회 속에서 서로의 존재를 잊고 살아가던 두 남녀가 우연한 계기로 작은 천문대에서 만나게 됩니다. 매일 밤 별을 관측하며 서로의 상처를 치유하고, 잊고 있던 꿈과 사랑을 다시금 깨닫게 되는 따뜻한 이야기입니다.\n\n과거의 아픔으로 인해 사랑에게 마음을 열지 못하던 여주인공은, 별자리처럼 변함없는 모습으로 자신을 기다려주는 남주인공을 통해 세상에 마음의 문을 열게 됩니다.',
);

// 홈과 영화 목록 화면에서 함께 사용하는 인기 영화 목록
const popularMovies = [
  Movie(
    id: 2,
    title: '우주의 끝에서',
    genre: 'SF',
    year: 2024,
    runningTime: 118,
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
    rating: 4.2,
  ),
  Movie(
    id: 3,
    title: '기억의 숲',
    genre: '애니메이션',
    year: 2022,
    runningTime: 106,
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
    rating: 4.9,
  ),
  Movie(
    id: 4,
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2024,
    runningTime: 112,
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
    rating: 3.8,
  ),
  Movie(
    id: 5,
    title: '봄날의 커피',
    genre: '로맨스',
    year: 2021,
    runningTime: 104,
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
    rating: 4.5,
  ),
  Movie(
    id: 6,
    title: '도시의 선',
    genre: '다큐멘터리',
    year: 2023,
    runningTime: 124,
    posterAsset: 'assets/images/posters/poster_abyss_walker.jpg',
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
