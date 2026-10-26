//TMDB 장르 데이터
class TmdbGenreDto {
  const TmdbGenreDto({
    required this.id, //장르 고유 ID
    required this.name, //장르 표시 이름
  });
  final int id;
  final String name;
  //JSON 응답을 객체로 변환
  factory TmdbGenreDto.fromJson(Map<String, dynamic> json) {
    return TmdbGenreDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );
  }
}