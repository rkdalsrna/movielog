import 'package:flutter_dotenv/flutter_dotenv.dart';

//.env의 TMDB_ACCESS_TOKEN을 가져오는 역할
abstract final class TmdbConfig { //설정값을 모아두기 위한 클래스
  static String get accessToken =>
      dotenv.env['TMDB_ACCESS_TOKEN'] ?? '';
}