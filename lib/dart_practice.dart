class Movie {
  String title;
  int year;

  Movie(this.title, this.year);
}

// nickname의 앞뒤 공백을 제거했을 때 내용이 비어있지 않으면 nickname을 반환하
// null이거나 비어있으면 '이름 없음'을 반환
String displayName(String? nickname) {
  return nickname?.trim().isNotEmpty == true ? nickname! : '이름 없음';
}

void main() {
  // 영화 3개 생성
  List<Movie> movies = [
    Movie('기생충', 2019),
    Movie('인터스텔라', 2014),
    Movie('어벤져스', 2012),
  ];

  // 영화 제목 출력
  for (Movie movie in movies) {
    print(movie.title);
  }

  // nullable 닉네임 안전한 기본값으로 처리
  String? nickname;

  print(displayName(nickname));
}