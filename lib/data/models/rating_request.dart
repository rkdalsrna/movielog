int validateServerScore(double value) { //평점이 1~5 사이의 정수인지 검증
  if (value < 1 || value > 5 || value != value.roundToDouble()) {
    throw ArgumentError('서버 평점은 1~5 사이 정수여야 합니다.');
  }
  return value.toInt();
}

class CreateRatingRequest { //영화 평점 등록 요청 DTO
  const CreateRatingRequest({
    required this.movieId,
    required this.score,
    this.comment,
  });

  final int movieId;
  final int score;
  final String? comment;

  Map<String, dynamic> toJson() => {
    'movieId': movieId,
    'score': score,
    if (comment != null && comment!.trim().isNotEmpty) //null이 아니고 공백이 아니고 비어있지 않으면 댓글을 JSON에 추가
      'comment': comment!.trim(),
  };
}